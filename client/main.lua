local SETTINGS = _G.CONTROL_SETTINGS
local CONTROLS = _G.CONTROL_MAPPING

local function GetSpeedMultiplier()
    local fastNormal = GetSmartControlNormal(CONTROLS.MOVE_FAST)
    local slowNormal = GetSmartControlNormal(CONTROLS.MOVE_SLOW)

    local baseSpeed = math.max(0.0, SETTINGS.BASE_MOVE_MULTIPLIER)
    local fastSpeed = 1.0 + ((math.max(1.0, SETTINGS.FAST_MOVE_MULTIPLIER) - 1.0) * fastNormal)
    local slowSpeed = 1.0 + ((math.max(1.0, SETTINGS.SLOW_MOVE_MULTIPLIER) - 1.0) * slowNormal)
    local frameMultiplier = GetFrameTime() * 60.0

    return (baseSpeed * fastSpeed / slowSpeed) * frameMultiplier
end

local function UpdateCamera()
    if IsPauseMenuActive() then
        return
    end

    if not IsFreecamFrozen() then
        local vecX, vecY = GetFreecamMatrix()
        local vecZ = vector3(0.0, 0.0, 1.0)
        local pos = GetFreecamPosition()
        local rot = GetFreecamRotation()

        if not vecX or not vecY or not pos or not rot then
            return
        end

        local speedMultiplier = GetSpeedMultiplier()

        local lookX = GetSmartControlNormal(CONTROLS.LOOK_X)
        local lookY = GetSmartControlNormal(CONTROLS.LOOK_Y)
        local moveX = GetSmartControlNormal(CONTROLS.MOVE_X)
        local moveY = GetSmartControlNormal(CONTROLS.MOVE_Y)
        local moveZ = GetSmartControlNormal(CONTROLS.MOVE_Z)

        local rotX = rot.x + (-lookY * SETTINGS.LOOK_SENSITIVITY_X)
        local rotZ = rot.z + (-lookX * SETTINGS.LOOK_SENSITIVITY_Y)

        pos = pos + (vecX * moveX * speedMultiplier)
        pos = pos + (vecY * -moveY * speedMultiplier)
        pos = pos + (vecZ * moveZ * speedMultiplier)

        SetFreecamPosition(pos)
        SetFreecamRotation(rotX, rot.y, rotZ)
    end

    TriggerEvent('freecam:onTick')
end

CreateThread(function()
    while true do
        if IsFreecamActive() then
            Wait(0)
            UpdateCamera()
        else
            Wait(250)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    SetFreecamActive(false)
end)
