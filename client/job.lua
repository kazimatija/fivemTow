local QBCore = exports[Config.Core]:GetCoreObject()

-- Global Variables

local inQueue = false
local blip

local function getRep()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local repAmount = PlayerData.metadata[Config.RepName]

    for k, _ in pairs(Config.RepLevels) do
        if repAmount >= Config.RepLevels[k]['repNeeded'] then
            print(Config.RepLevels[k]['label'])
            return Config.RepLevels[k]['label'], repAmount
        end
    end
end

local function CreateBlip(coords)
    blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 3)
	SetBlipRoute(blip, true)
    return blip
end

local function doCarDamage(vehicle)
    -- Doors
    if math.random() > 0.1 then
        for i = 1, math.random(1, 6) do
            SetVehicleDoorBroken(vehicle, math.random(0, 6), true)
        end
    end
    -- Windows
    if math.random() > 0.1 then
        for i = 1, math.random(1, 5) do
            SmashVehicleWindow(vehicle, math.random(0, 4))
        end
    end
    -- Tyres
    if math.random() > 0.1 then
        for i = 1, math.random(1, 4) do
            SetVehicleTyreBurst(vehicle, math.random(1, 4), false, 990.0)
        end
    end
    -- Engine
    if math.random() > 0.1 then
        SetVehicleEngineHealth(vehicle, 100.0)
    end
    -- Body
    if math.random() > 0.1 then
        SetVehicleBodyHealth(vehicle, 100.0)
    end
end

function viewMissionBoard()
    local isSignedIn = false
    --if exports['brazzers-tow']:isSignedIn() then isSignedIn = false end
    local label = 'Tow Truck Missions'
    if Config.AllowRep then
        local repLevel, repAmount = getRep()
        label = repLevel..' | '..repAmount..'x Reputation'
    end
    QBCore.Functions.TriggerCallback('brazzers-tow:server:isOnMission', function(inQueue)
        if Config.Menu == 'ox' then
            local menu = {}
            menu[#menu+1] = {
                title = 'Start Mission',
                icon = "fas fa-briefcase",
                description = 'Queue into missions dispatched by Bon Joe',
                event = "brazzers-tow:client:joinQueue",
                disabled = isSignedIn,
            }
            if inQueue then
                menu[#menu+1] = {
                    title = 'Leave Queue',
                    icon = "fas fa-briefcase",
                    serverEvent = "brazzers-tow:server:leaveQueue",
                }
            end
            lib.registerContext({
                id = 'brazzers-tow:mainMenu',
                icon = "fas fa-building",
                title = label,
                options = menu
            })
            lib.showContext('brazzers-tow:mainMenu')
        else
            local menu = {
                {
                    header = label,
                    isMenuHeader = true,
                    icon = "fas fa-building",
                },
            }
            menu[#menu+1] = {
                header = 'Start Mission',
                isMenuHeader = isSignedIn,
                txt = 'Queue into missions dispatched by Bon Joe',
                icon = "fas fa-briefcase",
                params = {
                    event = "brazzers-tow:client:joinQueue",
                }
            }
            if inQueue then
                menu[#menu+1] = {
                    header = 'Leave Queue',
                    icon = "fas fa-briefcase",
                    params = {
                        isServer = true,
                        event = "brazzers-tow:server:leaveQueue",
                    }
                }
            end
            menu[#menu+1] = {
                header = "Close",
                icon = 'fas fa-angle-left',
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
            exports[Config.Menu]:openMenu(menu)
        end
    end)
end

RegisterNetEvent('brazzers-tow:client:joinQueue', function()
    --if not exports['brazzers-tow']:isSignedIn() then return end
    TriggerServerEvent('brazzers-tow:server:joinQueue', true)
end)

RegisterNetEvent('brazzers-tow:client:queueIndex', function(value)
    inQueue = value
end)

RegisterNetEvent('brazzers-tow:client:setCarDamage', function(netID, plate)
    Wait(1000)
    if netID and plate then
        local vehicle = NetToVeh(netID)
        if Config.Fuel ~= 'ox' then exports['rush-fuel']:SetFuel(vehicle, 0.0) end
        doCarDamage(vehicle)
    end
end)

RegisterNetEvent('brazzers-tow:client:sendMissionBlip', function(coords)
    if coords then
        CreateBlip(coords)
        notification('CURRENT', 'Vehicle location has been marked', 'primary')
        return
    end

    RemoveBlip(blip)
    notification('CURRENT', 'Tow the vehicle back to the lot', 'primary')
end)

RegisterNetEvent('brazzers-tow:client:reQueueSystem', function()
    TriggerServerEvent('brazzers-tow:server:reQueueSystem')
end)

RegisterNetEvent('brazzers-tow:client:leaveQueue', function(notify)
    print("CLEARING BLIP")
    RemoveBlip(blip)
    if notify then
        notification('CURRENT', 'Your group was removed from the queue', 'primary')
    end
end)

RegisterCommand('testtow', function()
    viewMissionBoard()
end)