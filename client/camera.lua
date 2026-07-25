local camera = 0
local frozen = false

local position = nil
local rotation = nil
local fieldOfView = nil
local vectorX = nil
local vectorY = nil
local vectorZ = nil

local function cameraExists()
    return camera ~= 0 and DoesCamExist(camera)
end

function GetInitialCameraPosition()
    if _G.CAMERA_SETTINGS.KEEP_POSITION and position then
        return position
    end

    return GetGameplayCamCoord()
end

function GetInitialCameraRotation()
    if _G.CAMERA_SETTINGS.KEEP_ROTATION and rotation then
        return rotation
    end

    local gameplayRotation = GetGameplayCamRot(2)
    return vector3(gameplayRotation.x, 0.0, gameplayRotation.z)
end

function IsFreecamFrozen()
    return frozen
end

function SetFreecamFrozen(value)
    frozen = value == true
end

function GetFreecamPosition()
    return position
end

function SetFreecamPosition(x, y, z)
    x, y, z = ResolveVector3(x, y, z, 'position')
    position = vector3(x, y, z)

    if not cameraExists() then
        return
    end

    local interior = GetInteriorAtCoords(x, y, z)
    if interior ~= 0 then
        PinInteriorInMemory(interior)
    end

    SetFocusPosAndVel(x, y, z, 0.0, 0.0, 0.0)
    LockMinimapPosition(x, y)
    SetCamCoord(camera, x, y, z)
end

function GetFreecamRotation()
    return rotation
end

function SetFreecamRotation(x, y, z)
    x, y, z = ResolveVector3(x, y, z, 'rotation')

    local rotX, rotY, rotZ = ClampCameraRotation(x, y, z)
    vectorX, vectorY, vectorZ = EulerToMatrix(rotX, rotY, rotZ)
    rotation = vector3(rotX, rotY, rotZ)

    if not cameraExists() then
        return
    end

    LockMinimapAngle(math.floor(rotZ))
    SetCamRot(camera, rotX, rotY, rotZ, 2)
end

function GetFreecamFov()
    return fieldOfView
end

function SetFreecamFov(value)
    assert(type(value) == 'number', 'FOV must be a number.')

    fieldOfView = Clamp(value + 0.0, 1.0, 130.0)

    if cameraExists() then
        SetCamFov(camera, fieldOfView)
    end
end

function GetFreecamMatrix()
    return vectorX, vectorY, vectorZ, position
end

function GetFreecamTarget(distance)
    assert(type(distance) == 'number', 'Distance must be a number.')

    if not position or not vectorY then
        return nil
    end

    return position + (vectorY * distance)
end

function IsFreecamActive()
    return cameraExists() and IsCamActive(camera)
end

function SetFreecamActive(active)
    active = active == true

    if active == IsFreecamActive() then
        return
    end

    local enableEasing = _G.CAMERA_SETTINGS.ENABLE_EASING == true
    local easingDuration = math.max(0, math.floor(_G.CAMERA_SETTINGS.EASING_DURATION or 0))

    if active then
        local initialPosition = GetInitialCameraPosition()
        local initialRotation = GetInitialCameraRotation()

        camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        if camera == 0 then
            error('Failed to create the freecam camera.')
        end

        SetFreecamFov(_G.CAMERA_SETTINGS.FOV)
        SetFreecamPosition(initialPosition)
        SetFreecamRotation(initialRotation)

        SetPlayerControl(PlayerId(), false, 0)
        RenderScriptCams(true, enableEasing, easingDuration, true, true)
        TriggerEvent('freecam:onEnter')
        return
    end

    SetPlayerControl(PlayerId(), true, 0)
    RenderScriptCams(false, enableEasing, easingDuration, true, true)

    if cameraExists() then
        DestroyCam(camera, false)
    end

    camera = 0
    ClearFocus()
    UnlockMinimapPosition()
    UnlockMinimapAngle()
    TriggerEvent('freecam:onExit')
end
