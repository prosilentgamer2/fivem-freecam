function table.copy(value)
    local copy = {}

    for key, item in pairs(value) do
        copy[key] = type(item) == 'table' and table.copy(item) or item
    end

    return copy
end

function protect(value)
    local function unsupported(_, key)
        error(('Key `%s` is not supported.'):format(tostring(key)), 2)
    end

    return setmetatable(value, {
        __index = unsupported,
        __newindex = unsupported
    })
end

function CreateGamepadMetatable(keyboard, gamepad)
    return setmetatable({}, {
        __index = function(_, key)
            local source = IsGamepadControl() and gamepad or keyboard
            return source[key]
        end
    })
end

function Clamp(value, minimum, maximum)
    return math.min(math.max(value, minimum), maximum)
end

function ClampCameraRotation(rotX, rotY, rotZ)
    return Clamp(rotX, -90.0, 90.0), rotY % 360.0, rotZ % 360.0
end

function IsGamepadControl()
    return not IsInputDisabled(2)
end

function GetSmartControlNormal(control)
    if type(control) == 'table' then
        local positive = GetDisabledControlNormal(0, control[1])
        local negative = GetDisabledControlNormal(0, control[2])
        return positive - negative
    end

    return GetDisabledControlNormal(0, control)
end

function ResolveVector3(x, y, z, argumentName)
    if type(x) == 'vector3' then
        return x.x, x.y, x.z
    end

    assert(type(x) == 'number', ('%s x value must be a number or vector3.'):format(argumentName))
    assert(type(y) == 'number', ('%s y value must be a number.'):format(argumentName))
    assert(type(z) == 'number', ('%s z value must be a number.'):format(argumentName))

    return x + 0.0, y + 0.0, z + 0.0
end

function EulerToMatrix(rotX, rotY, rotZ)
    local radX = math.rad(rotX)
    local radY = math.rad(rotY)
    local radZ = math.rad(rotZ)

    local sinX = math.sin(radX)
    local sinY = math.sin(radY)
    local sinZ = math.sin(radZ)
    local cosX = math.cos(radX)
    local cosY = math.cos(radY)
    local cosZ = math.cos(radZ)

    local vecX = vector3(
        cosY * cosZ,
        cosY * sinZ,
        -sinY
    )

    local vecY = vector3(
        cosZ * sinX * sinY - cosX * sinZ,
        cosX * cosZ - sinX * sinY * sinZ,
        cosY * sinX
    )

    local vecZ = vector3(
        -cosX * cosZ * sinY + sinX * sinZ,
        -cosZ * sinX + cosX * sinY * sinZ,
        cosX * cosY
    )

    return vecX, vecY, vecZ
end
