---@class Vector3
---@field zero Vector3
Vector3 = { __typename = 'Vector3' }
setmetatable(Vector3, Vector3)
local getter = {}
Vector3.__getter = getter

Vector3.__index = function(t, k)
    local value = rawget(Vector3, k)
    if value then
        return value
    end

    if getter[k] then
        return getter[k]()
    end
end

-- 将table转成Vector3
Vector3.table2Vector3 = function(vector)
    return Vector3(vector.x, vector.y, vector.z)
end

Vector3.__call = function(t, x, y, z)
    local v = { x = x or 0, y = y or 0, z = z or 0 }
    setmetatable(v, Vector3)
    return v
end

Vector3.__tostring = function(self)
    return string.format("(%0.1f, %0.1f, %0.1f)", self.x, self.y, self.z)
end

Vector3.__div = function(va, d)
    return Vector3(va.x / d, va.y / d, va.z / d)
end

Vector3.__mul = function(va, d)
    if type(va) == "number" then
        va, d = d, va
    end
    return Vector3(va.x * d, va.y * d, va.z * d)
end

Vector3.__add = function(va, vb)
    return Vector3(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

Vector3.__sub = function(va, vb)
    return Vector3(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

Vector3.__unm = function(va)
    return Vector3(-va.x, -va.y, -va.z)
end

-- 不允许重载，影响pool比较地址重复，导致报错
--Vector3.__eq = function(va, vb)
--    local v = va - vb
--    local delta = v:pow2()
--    return delta < 1e-5
--end

function Vector3:equals(x, y, z)
    return self.x == x and self.y == y and self.z == z
end

function Vector3:equalsAnother(v)
    return ((self.x - v.x) ^ 2 + (self.y - v.y) ^ 2 + (self.z - v.z) ^ 2) < 0.1
end

function Vector3:set(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

function Vector3:copyFrom(v)
    self.x = v.x or 0
    self.y = v.y or 0
    self.z = v.z or 0
    return self
end

function Vector3:clone()
    return Vector3(self.x, self.y, self.z)
end

function Vector3:pow2()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector3:length()
    return math.sqrt(self:pow2())
end

function Vector3:normalize()
    local clone = self:clone()
    clone:setNormalize()
    return clone
end

function Vector3:setNormalize()
    local len = self:length()
    if len > 1e-5 then
        self.x = self.x / len
        self.y = self.y / len
        self.z = self.z / len
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end
    return self
end

--内部加减乘除，不产生新的对象.
function Vector3:mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    return self
end

function Vector3:div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    return self
end

function Vector3:add(vb)
    self.x = self.x + vb.x
    self.y = self.y + vb.y
    self.z = self.z + vb.z
    return self
end

function Vector3:addXYZ(x, y, z)
    self.x = self.x + x
    self.y = self.y + y
    self.z = self.z + z
    return self
end

function Vector3:sub(vb)
    self.x = self.x - vb.x
    self.y = self.y - vb.y
    self.z = self.z - vb.z
    return self
end
---------------------------

function Vector3.distance(va, vb)
    return math.sqrt((va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2)
end

function Vector3.distancePow2(va, vb)
    if not vb then
        printWarning("Vector3 vb nil")
        printTraceback()
        return 0
    end
    return (va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2
end

function Vector3.dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function Vector3.turnTo(vector, quat)
    local ret = UnityEngine_Quaternion:MultiplyVector3(quat, vector)--UnityEngine_Vector3:TurnTo(vector, quat)
    return Vector3(ret.x, ret.y, ret.z)
end

function Vector3.lerp(from, to, t)
    if t <= 0 then
        return from
    elseif t >= 1 then
        return to
    else
        return Vector3(from.x + ((to.x - from.x) * t),
                from.y + ((to.y - from.y) * t),
                from.z + ((to.z - from.z) * t))
    end
end

function Vector3.cross(lhs, rhs)
    return Vector3((lhs.y * rhs.z) - (lhs.z * rhs.y), (lhs.z * rhs.x) - (lhs.x * rhs.z), (lhs.x * rhs.y) - (lhs.y * rhs.x))
end

-- 带符号v1-->v2夹角 范围（-180-180）
function Vector3.angleSigned(v1, v2)
    return math.atan2(Vector3.dot(Vector3.up, Vector3.cross(v1, v2)), Vector3.dot(v1, v2)) * math.rad2Deg
end

-- v1-->v2夹角 范围（0-360）
function Vector3.angleBeyond360(v1, v2)
    local angle = Vector3.angleSigned(v1, v2)
    return angle < 0 and angle + 360 or angle
end

---@param v1 Vector3
---@param v2 Vector3
function Vector3.eulerAngle(v1, v2)
    local deltaX = v1.x - v2.x
    local deltaZ = v1.z - v2.z
    return math.atan(deltaZ, deltaX) * 180 / math.pi
end

function Vector3.reflect(inDirection, inNormal)
    local num = -2 * Vector3.dot(inNormal, inDirection)
    return inNormal * num + inDirection
end

function Vector3.project(vector, inNormal)
    local num = inNormal:pow2()
    if num < 1.175494e-38 then
        return Vector3(0, 0, 0)
    end

    local num2 = Vector3.dot(vector, inNormal)
    return inNormal * num2 / num
end

function Vector3.fromUnity(other)
    return Vector3(other.x, other.y, other.z)
end

function Vector3.clear(vector)
    vector.x = 0
    vector.y = 0
    vector.z = 0
end

function Vector3:destroy()
    -- 实现逻辑在Vector3Pool
end

getter.forward = function()
    return Vector3(0, 0, 1)
end
getter.back = function()
    return Vector3(0, 0, -1)
end

getter.left = function()
    return Vector3(-1, 0, 0)
end
getter.right = function()
    return Vector3(1, 0, 0)
end

getter.up = function()
    return Vector3(0, 1, 0)
end
getter.down = function()
    return Vector3(0, -1, 0)
end

getter.one = function()
    return Vector3(1, 1, 1)
end
getter.zero = function()
    return Vector3(0, 0, 0)
end

getter.negativeInfinity = function()
    return Vector3(-0xffff, -0xffff, -0xffff)
end

-- const将getter里的值复制一份,但不可修改
---@type {back:Vector3,left:Vector3,right:Vector3,up:Vector3,down:Vector3,one:Vector3,zero:Vector3,forward:Vector3,back:Vector3,negativeInfinity:Vector3}
Vector3.const = {}
local constSet = function(info, k, v)
    printError("const Vector3 should not be changed!!!")
end
if not __DEBUG__ then
    -- 外网不会报错,请小心!!
    for key, getFunc in pairs(getter) do
        Vector3.const[key] = getFunc()
    end
else
    for key, getFunc in pairs(getter) do
        local constVector = getFunc()
        Vector3.const[key] = {
            _x = constVector.x,
            _y = constVector.y,
            _z = constVector.z,
        }
        local metatable = {}
        for k, v in pairs(Vector3) do
            metatable[k] = Vector3[k]
        end
        metatable.__index = constVector
        metatable.__newindex = constSet
        setmetatable(Vector3.const[key], metatable)
    end
end