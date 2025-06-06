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
		return @down[key]

	isJustReleased: (key) =>
		return @justReleased[key]

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


class Air extends Tile
	new: (x, y) =>
		super x, y, false


class Bricks extends Tile
	new: (x, y) =>
		super x, y, true, 34

TILE_MAPPING = {
	"0": Air,
	"1": Bricks,
	"-": Air,
}

class Level
	new: (filepath) =>
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

				x += 1

			table.insert @tiles, tileRow
			y += 1

	addEntity: (e) =>
		table.insert @entities, e
		e\enteredLevel self

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

	enteredLevel: (level) =>
		@level = level

	tick: =>
		@onTick!
		@gravity!

	gravity: =>
		@move 0, 1 if not @jumping

	onGround: =>
		expectedGroundY = @y + h + 1
		for x=0,w-1
			tile = @level\tileAt @x, @y

	move: (dx, dy) =>
		moved = false

		if dx != 0
			goalX = @x + dx
			signX, xCheckOffset = if dx > 0 then 1, @w - 1 else -1, 0
			while @x != goalX
				canMove = true
				destX = @x + signX
				for h = 0, @h - 1
					tile = @level\tileAt destX + xCheckOffset, @y + h
					
					if tile and tile.solid
						canMove = false
						break

				if canMove then
					@x = destX
					moved = true
				else 
					break

		if dy != 0
			goalY = @y + dy
			signY, yCheckOffset = if dy > 0 then 1, @h - 1 else -1, 0
			while @y != goalY
				canMove = true
				destY = @y + signY
				for w = 0, @w - 1
					tile = @level\tileAt @x + w, destY + yCheckOffset
					
					if tile and tile.solid
						canMove = false
						break

				if canMove then
					@y = destY
					moved = true
				else 
					break

		movedb

class Player extends Entity
	new: (input) =>
		super 32, 32, 4, 12
		@input = input
		@jumpFrame = 1
		@jumping = false

	enteredLevel: (level) =>
		super level
		@x, @y = level\playerStart!

	onTick: =>
		if @input\isDown "right"
			@move 1, 0
		elseif @input\isDown "left"
			@move -1, 0

	draw: (gfx) =>
		gfx\spr 65, @x - 2, @y - 4
		gfx\spr 97, @x - 2, @y + 4


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
		
		sprites = love.graphics.newImage "assets/sprites.png"
		@sprites = sprites
		sprites\setFilter "nearest", "nearest"
		quads = Quads sprites, 8
		spriteBatch = love.graphics.newSpriteBatch sprites, 1000
		@gfx = Gfx quads, spriteBatch

		@level = Level "assets/level1.csv"
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

		love.graphics.pop!

input = Input!
state = State input

love.init = -> 
	love.graphics.setDefaultFilter "nearest", "nearest"

love.draw        =       -> state\draw!
love.update      = (dt)  -> state\update dt
love.keypressed  = (key) -> input\keypressed key
love.keyreleased = (key) -> input\keyreleased key