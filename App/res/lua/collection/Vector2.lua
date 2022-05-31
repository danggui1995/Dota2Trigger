---@class Vector2
Vector2 = { __typename = 'Vector2' }
setmetatable(Vector2, Vector2)
local getter = {}
Vector2.__getter = getter

Vector2.__index = function(t, k)
    local value = rawget(Vector2, k)
    if value then
        return value
    end

    if getter[k] then
        return getter[k]()
    end
end

Vector2.__call = function(t, x, y)
    local v = { x = x or 0, y = y or 0 }
    setmetatable(v, Vector2)
    return v
end

Vector2.__tostring = function(self)
    return string.format("(%0.1f, %0.1f)", self.x, self.y)
end

Vector2.__div = function(va, d)
    return Vector2(va.x / d, va.y / d)
end

Vector2.__mul = function(va, d)
    if type(va) == "number" then
        va, d = d, va
    end
    return Vector2(va.x * d, va.y * d)
end

Vector2.__add = function(va, vb)
    return Vector2(va.x + vb.x, va.y + vb.y)
end

Vector2.__sub = function(va, vb)
    return Vector2(va.x - vb.x, va.y - vb.y)
end

Vector2.__unm = function(va)
    return Vector2(-va.x, -va.y)
end

Vector2.__eq = function(va, vb)
    local v = va - vb
    local delta = v:pow2()
    return delta < 1e-5
end

function Vector2:equals(x, y)
    return self.x == x and self.y == y
end

function Vector2:set(x, y)
    self.x = x or 0
    self.y = y or 0
    return self
end

function Vector2:clone()
    return Vector2(self.x, self.y)
end

function Vector2:normalize()
    local clone = self:clone()
    clone:setNormalize()
    return clone
end

function Vector2:setNormalize()
    local length = self:length()
    if length > 1e-05 then
        self.x = self.x / length
        self.y = self.y / length
    else
        self.x = 0
        self.y = 0
    end
    return self
end

function Vector2:pow2()
    return self.x * self.x + self.y * self.y
end

function Vector2:length()
    return math.sqrt(self:pow2())
end

--内部加减乘除，不产生新的对象.
function Vector2:mul(d)
    self.x = self.x * d
    self.y = self.y * d
    return self
end

function Vector2:div(d)
    self.x = self.x / d
    self.y = self.y / d
    return self
end

function Vector2:add(vb)
    self.x = self.x + vb.x
    self.y = self.y + vb.y
    return self
end

function Vector2:sub(vb)
    self.x = self.x - vb.x
    self.y = self.y - vb.y
    return self
end
---------------------------


function Vector2.distance(va, vb)
    local ver = va - vb
    return ver:length()
end

function Vector2.dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y
end

function Vector2.cross(lhs, rhs)
    return lhs.x * rhs.y - lhs.y * rhs.x
end

function Vector2.lerp(from, to, t)
    if t <= 0 then
        return from
    elseif t >= 1 then
        return to
    else
        return Vector2(from.x + ((to.x - from.x) * t),
                from.y + ((to.y - from.y) * t))
    end
end

function Vector2.reflect(dir, normal)
    local dx = dir.x
    local dy = dir.y
    local nx = normal.x
    local ny = normal.y
    local s = -2 * (dx * nx + dy * ny)

    return Vector2(s * nx + dx, s * ny + dy)
end

function Vector2.angle(from, to)
    local x1, y1 = from.x, from.y
    local d = math.sqrt(x1 * x1 + y1 * y1)

    if d > 1e-5 then
        x1 = x1 / d
        y1 = y1 / d
    else
        x1, y1 = 0, 0
    end

    local x2, y2 = to.x, to.y
    d = math.sqrt(x2 * x2 + y2 * y2)

    if d > 1e-5 then
        x2 = x2 / d
        y2 = y2 / d
    else
        x2, y2 = 0, 0
    end

    d = x1 * x2 + y1 * y2

    if d < -1 then
        d = -1
    elseif d > 1 then
        d = 1
    end

    return math.acos(d) * 57.29578
end

function Vector2.angleSigned(v1, v2)
    return math.atan2(Vector2.cross(v1, v2), Vector2.dot(v1, v2)) * math.rad2Deg
end

function Vector2.angleBeyond360(v1, v2)
    local angle = Vector2.angleSigned(v1, v2)
    return angle < 0 and angle + 360 or angle
end

function Vector2.fromUnity(other)
    return Vector2(other.x, other.y)
end

getter.zero = function()
    return Vector2(0, 0)
end
getter.one = function()
    return Vector2(1, 1)
end
getter.up = function()
    return Vector2(0, 1)
end
getter.down = function()
    return Vector2(0, -1)
end
getter.left = function()
    return Vector2(-1, 0)
end
getter.right = function()
    return Vector2(1, 0)
end

-- const将getter里的值复制一份,但不可修改
Vector2.const = {}
local constSet = function(info, k, v)
    printError("const Vector2 should not be changed!!!")
end
if not __DEBUG__ then
    -- 外网不会报错,请小心!!
    for key, getFunc in pairs(getter) do
        Vector2.const[key] = getFunc()
    end
else
    for key, getFunc in pairs(getter) do
        local constVector = getFunc()
        Vector2.const[key] = {
            _x = constVector.x,
            _y = constVector.y,
        }
        local metatable = {}
        for k, v in pairs(Vector2) do
            metatable[k] = Vector2[k]
        end
        metatable.__index = constVector
        metatable.__newindex = constSet
        setmetatable(Vector2.const[key], metatable)
    end
end
