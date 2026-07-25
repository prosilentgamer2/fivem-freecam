# FiveM Freecam

A lightweight, standalone freecam API for FiveM. No framework or external dependency is required.

## Features

- Modern `fxmanifest.lua`
- Lua 5.4-compatible code
- Keyboard and controller support
- Frame-rate-independent movement speed
- Rebindable controls through FiveM key mappings
- Configurable speed, sensitivity, FOV, easing, and retained camera state
- Position, rotation, matrix, target, and lifecycle exports
- Automatic player-control and camera cleanup when the resource stops

## Installation

1. Download or clone this repository into your server's `resources` folder.
2. Keep the resource folder named `fivem-freecam`.
3. Add this to `server.cfg`:

```cfg
ensure fivem-freecam
```

## Basic usage

Add the dependency to the resource that will use the freecam:

```lua
-- fxmanifest.lua
dependency 'fivem-freecam'

client_script 'client.lua'
```

Then call the client exports:

```lua
-- client.lua
local Freecam = exports['fivem-freecam']

RegisterCommand('freecam', function()
    Freecam:SetActive(not Freecam:IsActive())
end, false)

RegisterKeyMapping('freecam', 'Toggle freecam', 'keyboard', 'F5')
```

`RegisterKeyMapping` lets each player change the toggle key under **Settings > Key Bindings > FiveM**.

## Default controls

### Keyboard

- Mouse: look
- W / S: forward and backward
- A / D: left and right
- Q / E: vertical movement
- Left Shift: faster movement
- Left Alt: slower movement

### Controller

- Left stick: move
- Right stick: look
- RB / LB: up and down
- RT: faster movement
- LT: slower movement

The movement and look inputs can also be changed through the configuration exports documented below.

## Export examples

```lua
local Freecam = exports['fivem-freecam']

Freecam:SetActive(true)
Freecam:SetFrozen(false)
Freecam:SetFov(60.0)
Freecam:SetPosition(vector3(215.0, -810.0, 40.0))
Freecam:SetRotation(vector3(-15.0, 0.0, 180.0))

local position = Freecam:GetPosition()
local rotation = Freecam:GetRotation()
local target = Freecam:GetTarget(100.0)
local right, forward, up, cameraPosition = Freecam:GetMatrix()
```

Both vector and numeric setter forms are supported:

```lua
Freecam:SetPosition(vector3(215.0, -810.0, 40.0))
Freecam:SetPosition(215.0, -810.0, 40.0)

Freecam:SetRotation(vector3(-15.0, 0.0, 180.0))
Freecam:SetRotation(-15.0, 0.0, 180.0)
```

## Events

```lua
AddEventHandler('freecam:onEnter', function()
    print('Freecam enabled')
end)

AddEventHandler('freecam:onTick', function()
    local target = exports['fivem-freecam']:GetTarget(50.0)
end)

AddEventHandler('freecam:onExit', function()
    print('Freecam disabled')
end)
```

## Documentation

- [Configuration](docs/CONFIGURING.md)
- [Exports](docs/EXPORTS.md)
- [Events](docs/EVENTS.md)

## Compatibility

This resource is client-side and framework-independent. It can be used with QBCore, ESX, standalone resources, or any other FiveM stack.

## License

MIT. See [LICENSE](LICENSE).
