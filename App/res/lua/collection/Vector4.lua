Vector4 = { __typename = 'Vector4' }
setmetatable(Vector4, Vector4)
local getter = {}
Vector4.__getter = getter

Vector4.__index = function(t, k)
    local value = rawget(Vector4, k)
    if value then
        return value
    end

    if getter[k] then
        return getter[k]()
    end
end

Vector4.__call = function(t, x, y, z, w)
    local v = { x = x or 0, y = y or 0, z = z or 0, w = w or 0 }
    setmetatable(v, Vector4)
    return v
end

Vector4.__tostring = function(self)
    return string.format("(%0.1f, %0.1f, %0.1f, %0.1f)", self.x, self.y, self.z, self.w)
end

Vector4.__div = function(va, d)
    return Vector4(va.x / d, va.y / d, va.z / d, va.w / d)
end

Vector4.__mul = function(va, d)
    if type(va) == "number" then
        va, d = d, va
    end
    return Vector4(va.x * d, va.y * d, va.z * d, va.w * d)
end

Vector4.__add = function(va, vb)
    return Vector4(va.x + vb.x, va.y + vb.y, va.z + vb.z, va.w + vb.w)
end

Vector4.__sub = function(va, vb)
    return Vector4(va.x - vb.x, va.y - vb.y, va.z - vb.z, va.w - vb.w)
end

Vector4.__unm = function(va)
    return Vector4(-va.x, -va.y, -va.z, -va.w)
end

Vector4.__eq = function(va, vb)
    local v = va - vb
    local delta = v:pow2()
    return delta < 1e-5
end

function Vector4:equals(x, y, z, w)
    return self.x == x and self.y == y and self.z == z and self.w == w
end

function Vector4:set(x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
    return self
end

function Vector4:clone()
    return Vector4(self.x, self.y, self.z, self.w)
end

function Vector4:pow2()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function Vector4:length()
    return math.sqrt(self:pow2())
end

function Vector4:normalize()
    local clone = self:clone()
    clone:setNormalize()
    return clone
end

function Vector4:setNormalize()
    local len = self:pow2()
    if len > 1e-05 then
        self.x = self.x / len
        self.y = self.y / len
        self.z = self.z / len
        self.w = self.w / len
    else
        self.x = 0
        self.y = 0
        self.z = 0
        self.w = 0
    end
    return self
end

--内部加减乘除，不产生新的对象.
function Vector4:div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    self.w = self.w / d
    return self
end

function Vector4:mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    self.w = self.w * d
    return self
end

function Vector4:add(b)
    self.x = self.x + b.x
    self.y = self.y + b.y
    self.z = self.z + b.z
    self.w = self.w + b.w
    return self
end

function Vector4:sub(b)
    self.x = self.x - b.x
    self.y = self.y - b.y
    self.z = self.z - b.z
    self.w = self.w - b.w
    return self
end
---------------------------

function Vector4.dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function Vector4.distance(a, b)
    local ver = a - b
    return ver:length()
end

function Vector4.lerp(from, to, t)
    if t <= 0 then
        return from
    elseif t >= 1 then
        return to
    else
        return Vector4(from.x + ((to.x - from.x) * t),
                from.y + ((to.y - from.y) * t),
                from.z + ((to.z - from.z) * t),
                from.w + ((to.w - from.w) * t))
    end
end

function Vector4.project(a, b)
    local s = Vector4.dot(a, b) / Vector4.dot(b, b)
    return b * s
end

function Vector4.fromUnity(other)
    return Vector4(other.x, other.y, other.z, other.w)
end

getter.one = function()
    return Vector4(1, 1, 1, 1)
end
getter.zero = function()
    return Vector4(0, 0, 0, 0)
end

-- const将getter里的值复制一份,但不可修改
Vector4.const = {}
local constSet = function(info, k, v)
    printError("const Vector4 should not be changed!!!")
end
if not __DEBUG__ then
    -- 外网不会报错,请小心!!
    for key, getFunc in pairs(getter) do
        Vector4.const[key] = getFunc()
    end
else
    for key, getFunc in pairs(getter) do
        local constVector = getFunc()
        Vector4.const[key] = {
            _x = constVector.x,
            _y = constVector.y,
            _z = constVector.z,
            _w = constVector.w,
        }
        local metatable = {}
        for k, v in pairs(Vector4) do
            metatable[k] = Vector4[k]
        end
        metatable.__index = constVector
        metatable.__newindex = constSet
        setmetatable(Vector4.const[key], metatable)
    end
end