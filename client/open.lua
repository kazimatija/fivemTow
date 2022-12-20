local blips = {}

-- Commands

RegisterCommand('calltow', function() -- call tow command
    TriggerEvent('brazzers-tow:client:requestTowTruck')
end)

-- Functions

function notification(title, msg, action)
    if Config.NotificationStyle == 'phone' then
        TriggerEvent('qb-phone:client:CustomNotification', title, msg, 'fas fa-user', '#b3e0f2', 5000)
    elseif Config.NotificationStyle == 'qbcore' then
        if title then
            QBCore.Functions.Notify(title..': '..msg, action, 5000)
        else
            QBCore.Functions.Notify(msg, action, 5000)
        end
    end
end

local function depotVehicle(NetworkID)
    local entity = NetworkGetEntityFromNetworkId(NetworkID)
    local plate = QBCore.Functions.GetPlate(entity)
    local class = GetVehicleClass(entity)
    QBCore.Functions.Progressbar("depot_vehicle", "Sending Vehicle To Depot", 1500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('brazzers-tow:server:depotVehicle', plate, class, NetworkID)
    end, function()
    end)
end

-- Events

-- YOU CAN USE THIS EVENT TO INPUT INTO RADIAL MENU OR WHATEVER YOU WANT TO REQUEST TOW
RegisterNetEvent("brazzers-tow:client:requestTowTruck", function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    TriggerEvent('animations:client:EmoteCommandStart', {"phonecall"})
    QBCore.Functions.Progressbar("calling-tow", "Calling Tow", 1500, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent("brazzers-tow:server:markForTow", vehname, plate)
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterNetEvent("brazzers-tow:client:sendTowRequest", function(info, vehicle, plate, pos)
    local success = exports[Config.Phone]:PhoneNotification("JOB OFFER", 'Incoming Tow Request', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if not success then return end
    TriggerServerEvent("brazzers-tow:server:sendTowRequest", info, vehicle, plate, pos)
end)

RegisterNetEvent('brazzers-tow:client:receiveTowRequest', function(pos, vehicle, plate, blipId)
    CreateThread(function()
        local alpha = 255
        local blip = nil
        local radius = nil
        local radiusAlpha = 128
        local sprite, colour, scale = 280, 17, 1.0

        blip = AddBlipForCoord(pos.x, pos.y, pos.z)
        blips[blipId] = blip
        -- Extra Shit
        SetBlipSprite(blip, sprite)
        SetBlipHighDetail(blip, true)
        SetBlipScale(blip, scale)
        SetBlipColour(blip, colour)
        SetBlipAlpha(blip, alpha)
        SetBlipAsShortRange(blip, false)
        SetBlipCategory(blip, 2)
        SetBlipColour(radius, colour)
        SetBlipAlpha(radius, radiusAlpha)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Tow Request: '..plate)
        EndTextCommandSetBlipName(blip)

        while radiusAlpha ~= 0 do
            Wait(Config.BlipLength * 1000)
            radiusAlpha = radiusAlpha - 1
            SetBlipAlpha(radius, radiusAlpha)	
            if radiusAlpha == 0 then
                RemoveBlip(radius)
                RemoveBlip(blip)
                return
            end
        end
    end)
end)

-- Threads

CreateThread(function()
    exports[Config.Target]:AddBoxZone("tow_signin", Config.LaptopCoords, 0.2, 0.4, {
        name = "tow_signin",
        heading = 117.93,
        debugPoly = false,
        minZ = Config.LaptopCoords.z,
        maxZ = Config.LaptopCoords.z + 1.0,
        }, {
            options = {
            {
                action = function()
                    signIn()
                end,
                icon = 'fas fa-hands',
                label = 'Sign In',
                canInteract = function()
                    if Config.WhitelistedJob and not isTow() then return end
                    if signedIn then return end
                    return true
                end,
            },
            {
                action = function()
                    signOut()
                end,
                icon = 'fas fa-hands',
                label = 'Sign Out',
                canInteract = function()
                    if not signedIn then return end
                    return true
                end,
            },
        },
        distance = 1.0,
    })
end)

CreateThread(function()
    exports[Config.Target]:AddGlobalVehicle({
        options = {
            {
                label = "Depot Vehicle",
                icon = "fas fa-car-rear",
                action = function(entity)
                    depotVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    return isTow() and inZone()
                end
            }
        },
        distance = 1.5
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, _ in pairs(blips) do
            RemoveBlip(blips[k])
        end
    end
end)