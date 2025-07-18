bump = require "lib.bump"

WIDTH = 200
HEIGHT = 160
SCALE = 4

class Input
    new: =>
        @down = {}
        @justReleased = {}

    keypressed: (key) =>
        @down[key] = true

    keyreleased: (key) =>
        @down[key] = false
        @justReleased[key] = true

    isDown: (key) =>
        @down[key]

    isJustReleased: (key) =>
        @justReleased[key]

    tick: =>
        @justReleased = {}

class Tile
    new: (x, y, solid, spr) =>
        @x = x
        @y = y
        @solid = solid
        @spr = spr

    draw: (gfx) =>
        if @spr
            gfx\spr @spr, @x, @y

    addToWorld: (world) =>
        world\add self, @x, @y, 8, 8


class Air extends Tile
    new: (x, y) =>
        super x, y, false

    addToWorld: (world) =>
        -- Air tiles can't be added to the world.


class Bricks extends Tile
    new: (x, y) =>
        super x, y, true, 34

TILE_MAPPING = {
    "0": Air,
    "1": Bricks,
    "-": Air,
}

class Level
    new: (filepath, world) =>
        @world = world
        contents, size = love.filesystem.read filepath

        @entities = {}
        @tiles = {}
        y = 0
        for line in string.gmatch contents, "[^\r\n]+"
            tileRow = {}
            x = 0
            for tileId in string.gmatch line, "[^,]+" 
                if tileId == "-"
                    @playerStartPos = {x: x, y: y}

                tile = TILE_MAPPING[tileId] x * 8, y * 8
                table.insert tileRow, tile

                tile\addToWorld @world

                x += 1

            table.insert @tiles, tileRow
            y += 1

    addEntity: (e) =>
        table.insert @entities, e
        e\enteredLevel self
        e\addToWorld @world

    playerStart: =>
        @playerStartPos.x * 8, @playerStartPos.y * 8

    tileAt: (x, y) =>
        cx, cy = math.floor(x / 8), math.floor(y / 8)

        if cx > 0 or cx < #@tiles[1] or cy > 0 or cy < #@tiles
            @tiles[cy + 1][cx + 1]

    tick: () =>
        entity\tick! for entity in *@entities

    draw: (gfx) =>
        for tileRow in *@tiles
            for tile in *tileRow
                tile\draw gfx

        entity\draw gfx for entity in *@entities

class Entity
    new: (x, y, w, h) =>
        @x = x
        @y = y
        @w = w
        @h = h
        @jumping = false
        @applyGravity = true

    enteredLevel: (level) =>
        @level = level

    addToWorld: (world) =>
        world\add self, @x, @y, @w, @h
        @world = world

    tick: =>
        @onTick!
        @gravity! if @applyGravity

    gravity: =>
        return if @jumping

        bx, by = @x, @y
        @move 0, 1

    checkOnGround: =>
        ax, ay = @world\check self, @x, @y + 1
        ax == @x and ay == @y

    move: (dx, dy) =>
        tx = dx + @x
        ty = dy + @y
        ax, ay, cols, len = @world\move self, tx, ty

        @x = ax
        @y = ay

        for collision in *cols
            return true if collision.normal.y > 0

deferredRenders = {}

pingPong = (val) ->
    return 1 if val == 0
    0

class Player extends Entity
    @jumpSpeeds: {-2, -2, -2, -1, -1, -1, 0, 1, 1, 1, 2, 2, 2}

    new: (input) =>
        super 32, 32, 4, 12
        @input = input
        @jumpFrame = 1
        @jumping = false
        @moveFrame = 1
        @animFrame = 0
        @animOffset = 0
        @facing = 1 -- 1 = right, 0 = left

    enteredLevel: (level) =>
        super level
        @x, @y = level\playerStart!

    onTick: =>
        @doJump! if @jumping

        if @input\isDown "right"
            @moveFrame += 1
            @animOffset = 1
            @move 1.5, 0
            @facing = 1
        elseif @input\isDown "left"
            @moveFrame += 1
            @animOffset = 1
            @move -1.5, 0
            @facing = 0
        else
            @moveFrame = 0
            @animFrame = 0
            @animOffset = 0

        if not @jumping and @input\isDown "space"
            @jump!

        if @moveFrame > 0 and @moveFrame % 6 == 0
            @animFrame = pingPong @animFrame

    draw: (gfx) =>
        --@spriteBatch\add @quads[idx], x, y, r, sx, sy, ox, oy, kx, ky 
        sx = 1
        ox = 0

        if @facing == 0
            sx = -1
            ox = @w * 2
        gfx\spr 65 + @animFrame + @animOffset, @x - 2, @y - 4, 0, sx, 1, ox
        gfx\spr 97 + @animFrame + @animOffset, @x - 2, @y + 4, 0, sx, 1, ox

    jump: =>
        @jumpFrame = 1
        @jumping = true

    doJump: =>
        bx, by = @x, @y
        bonked = @move 0, @@jumpSpeeds[math.min(@jumpFrame, #@@jumpSpeeds)]

        if bonked
            @jumpFrame = 8
        else
            @jumpFrame += 1

        @jumping = not @checkOnGround!

Quads = (img, cs) -> -- cs= cellSize
    iw, ih = img\getDimensions!
    w, h = iw / cs, ih / cs

    [love.graphics.newQuad(x * cs, y * cs, cs, cs, img) for y=0,h-1 for x=0,w-1]

class Gfx
    new: (quads, spriteBatch) =>
        @quads = quads
        @spriteBatch = spriteBatch

    spr: (idx, x, y, r, sx, sy, ox, oy, kx, ky) =>
        -- Draws sprite at idx of @quads
        @spriteBatch\add @quads[idx], x, y, r, sx, sy, ox, oy, kx, ky 

    beginDraw: =>
        @spriteBatch\clear!

    endDraw: =>
        love.graphics.draw @spriteBatch, 0, 0

class State
    @updateTime: 1 / 30

    new: (input) =>
        @input = input
        @accumulator = 0
        @world = bump.newWorld!
        
        sprites = love.graphics.newImage "assets/sprites.png"
        @sprites = sprites
        sprites\setFilter "nearest", "nearest"
        quads = Quads sprites, 8
        spriteBatch = love.graphics.newSpriteBatch sprites, 1000
        @gfx = Gfx quads, spriteBatch

        @level = Level "assets/level1.csv", @world
        @level\addEntity (Player @input)

    update: (dt) =>
        love.event.quit! if @input\isDown "escape"

        @accumulator += dt

        while @accumulator > @@updateTime
            @tick!
            @accumulator -= @@updateTime

    tick: =>
        @level\tick!
        @input\tick!

    draw: =>
        love.graphics.push!
        love.graphics.scale SCALE, SCALE

        @gfx\beginDraw!

        @level\draw @gfx

        @gfx\endDraw!

        f! for f in *deferredRenders

        love.graphics.pop!

        deferredRenders = {}

input = Input!
state = State input

love.init = -> 
    love.graphics.setDefaultFilter "nearest", "nearest"

love.draw        =       -> state\draw!
love.update      = (dt)  -> state\update dt
love.keypressed  = (key) -> input\keypressed key
love.keyreleased = (key) -> input\keyreleased key