local WIDTH = 200
local HEIGHT = 160
local SCALE = 4
local Input
do
  local _class_0
  local _base_0 = {
    keypressed = function(self, key)
      self.down[key] = true
    end,
    keyreleased = function(self, key)
      self.down[key] = false
      self.justReleased[key] = true
    end,
    isDown = function(self, key)
      return self.down[key]
    end,
    isJustReleased = function(self, key)
      return self.justReleased[key]
    end,
    tick = function(self)
      self.justReleased = { }
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.down = { }
      self.justReleased = { }
    end,
    __base = _base_0,
    __name = "Input"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Input = _class_0
end
local Tile
do
  local _class_0
  local _base_0 = {
    draw = function(self, gfx)
      if self.spr then
        return gfx:spr(self.spr, self.x, self.y)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, solid, spr)
      self.x = x
      self.y = y
      self.solid = solid
      self.spr = spr
    end,
    __base = _base_0,
    __name = "Tile"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Tile = _class_0
end
local Air
do
  local _class_0
  local _parent_0 = Tile
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      return _class_0.__parent.__init(self, x, y, false)
    end,
    __base = _base_0,
    __name = "Air",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Air = _class_0
end
local Bricks
do
  local _class_0
  local _parent_0 = Tile
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y)
      return _class_0.__parent.__init(self, x, y, true, 34)
    end,
    __base = _base_0,
    __name = "Bricks",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Bricks = _class_0
end
local TILE_MAPPING = {
  ["0"] = Air,
  ["1"] = Bricks,
  ["-"] = Air
}
local Level
do
  local _class_0
  local _base_0 = {
    addEntity = function(self, e)
      table.insert(self.entities, e)
      return e:enteredLevel(self)
    end,
    playerStart = function(self)
      return self.playerStartPos.x * 8, self.playerStartPos.y * 8
    end,
    tileAt = function(self, x, y)
      local cx, cy = math.floor(x / 8), math.floor(y / 8)
      if cx > 0 or cx < #self.tiles[1] or cy > 0 or cy < #self.tiles then
        return self.tiles[cy + 1][cx + 1]
      end
    end,
    tick = function(self)
      local _list_0 = self.entities
      for _index_0 = 1, #_list_0 do
        local entity = _list_0[_index_0]
        entity:tick()
      end
    end,
    draw = function(self, gfx)
      local _list_0 = self.tiles
      for _index_0 = 1, #_list_0 do
        local tileRow = _list_0[_index_0]
        for _index_1 = 1, #tileRow do
          local tile = tileRow[_index_1]
          tile:draw(gfx)
        end
      end
      local _list_1 = self.entities
      for _index_0 = 1, #_list_1 do
        local entity = _list_1[_index_0]
        entity:draw(gfx)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, filepath)
      local contents, size = love.filesystem.read(filepath)
      self.entities = { }
      self.tiles = { }
      local y = 0
      for line in string.gmatch(contents, "[^\r\n]+") do
        local tileRow = { }
        local x = 0
        for tileId in string.gmatch(line, "[^,]+") do
          if tileId == "-" then
            self.playerStartPos = {
              x = x,
              y = y
            }
          end
          local tile = TILE_MAPPING[tileId](x * 8, y * 8)
          table.insert(tileRow, tile)
          x = x + 1
        end
        table.insert(self.tiles, tileRow)
        y = y + 1
      end
    end,
    __base = _base_0,
    __name = "Level"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Level = _class_0
end
local Entity
do
  local _class_0
  local _base_0 = {
    enteredLevel = function(self, level)
      self.level = level
    end,
    tick = function(self)
      self:onTick()
      return self:gravity()
    end,
    gravity = function(self)
      if not self.jumping then
        return self:move(0, 1)
      end
    end,
    onGround = function(self)
      local expectedGroundY = self.y + h + 1
      for x = 0, w - 1 do
        local tile = self.level:tileAt(self.x, self.y)
      end
    end,
    move = function(self, dx, dy)
      local moved = false
      if dx ~= 0 then
        local goalX = self.x + dx
        local signX, xCheckOffset
        if dx > 0 then
          signX, xCheckOffset = 1, self.w - 1
        else
          signX, xCheckOffset = -1, 0
        end
        while self.x ~= goalX do
          local canMove = true
          local destX = self.x + signX
          for h = 0, self.h - 1 do
            local tile = self.level:tileAt(destX + xCheckOffset, self.y + h)
            if tile and tile.solid then
              canMove = false
              break
            end
          end
          if canMove then
            self.x = destX
            moved = true
          else
            break
          end
        end
      end
      if dy ~= 0 then
        local goalY = self.y + dy
        local signY, yCheckOffset
        if dy > 0 then
          signY, yCheckOffset = 1, self.h - 1
        else
          signY, yCheckOffset = -1, 0
        end
        while self.y ~= goalY do
          local canMove = true
          local destY = self.y + signY
          for w = 0, self.w - 1 do
            local tile = self.level:tileAt(self.x + w, destY + yCheckOffset)
            if tile and tile.solid then
              canMove = false
              break
            end
          end
          if canMove then
            self.y = destY
            moved = true
          else
            break
          end
        end
      end
      return movedb
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, w, h)
      self.x = x
      self.y = y
      self.w = w
      self.h = h
      self.jumping = false
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
local Player
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    enteredLevel = function(self, level)
      _class_0.__parent.__base.enteredLevel(self, level)
      self.x, self.y = level:playerStart()
    end,
    onTick = function(self)
      if self.input:isDown("right") then
        return self:move(1, 0)
      elseif self.input:isDown("left") then
        return self:move(-1, 0)
      end
    end,
    draw = function(self, gfx)
      gfx:spr(65, self.x - 2, self.y - 4)
      return gfx:spr(97, self.x - 2, self.y + 4)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, input)
      _class_0.__parent.__init(self, 32, 32, 4, 12)
      self.input = input
      self.jumpFrame = 1
      self.jumping = false
    end,
    __base = _base_0,
    __name = "Player",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Player = _class_0
end
local Quads
Quads = function(img, cs)
  local iw, ih = img:getDimensions()
  local w, h = iw / cs, ih / cs
  local _accum_0 = { }
  local _len_0 = 1
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      _accum_0[_len_0] = love.graphics.newQuad(x * cs, y * cs, cs, cs, img)
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
local Gfx
do
  local _class_0
  local _base_0 = {
    spr = function(self, idx, x, y, r, sx, sy, ox, oy, kx, ky)
      return self.spriteBatch:add(self.quads[idx], x, y, r, sx, sy, ox, oy, kx, ky)
    end,
    beginDraw = function(self)
      return self.spriteBatch:clear()
    end,
    endDraw = function(self)
      return love.graphics.draw(self.spriteBatch, 0, 0)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, quads, spriteBatch)
      self.quads = quads
      self.spriteBatch = spriteBatch
    end,
    __base = _base_0,
    __name = "Gfx"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Gfx = _class_0
end
local State
do
  local _class_0
  local _base_0 = {
    update = function(self, dt)
      if self.input:isDown("escape") then
        love.event.quit()
      end
      self.accumulator = self.accumulator + dt
      while self.accumulator > self.__class.updateTime do
        self:tick()
        self.accumulator = self.accumulator - self.__class.updateTime
      end
    end,
    tick = function(self)
      self.level:tick()
      return self.input:tick()
    end,
    draw = function(self)
      love.graphics.push()
      love.graphics.scale(SCALE, SCALE)
      self.gfx:beginDraw()
      self.level:draw(self.gfx)
      self.gfx:endDraw()
      return love.graphics.pop()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, input)
      self.input = input
      self.accumulator = 0
      local sprites = love.graphics.newImage("assets/sprites.png")
      self.sprites = sprites
      sprites:setFilter("nearest", "nearest")
      local quads = Quads(sprites, 8)
      local spriteBatch = love.graphics.newSpriteBatch(sprites, 1000)
      self.gfx = Gfx(quads, spriteBatch)
      self.level = Level("assets/level1.csv")
      return self.level:addEntity((Player(self.input)))
    end,
    __base = _base_0,
    __name = "State"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.updateTime = 1 / 30
  State = _class_0
end
local input = Input()
local state = State(input)
love.init = function()
  return love.graphics.setDefaultFilter("nearest", "nearest")
end
love.draw = function()
  return state:draw()
end
love.update = function(dt)
  return state:update(dt)
end
love.keypressed = function(key)
  return input:keypressed(key)
end
love.keyreleased = function(key)
  return input:keyreleased(key)
end
