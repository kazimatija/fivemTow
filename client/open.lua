local QBCore = exports[Config.Core]:GetCoreObject()

local blips = {}

-- Functions

function getRep()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local repAmount = PlayerData.metadata['jobrep'][Config.RepName]

    for k, _ in pairs(Config.RepLevels) do
        if repAmount >= Config.RepLevels[k]['repNeeded'] then
            return Config.RepLevels[k]['label'], repAmount
        end
    end
end

function notification(title, msg, action)
    if Config.NotificationStyle == 'phone' then
        TriggerEvent('qb-phone:client:CustomNotification', title, msg, 'fas fa-user', '#b3e0f2', 5000)
    elseif Config.NotificationStyle == 'qbcore' then
        QBCore.Functions.Notify(msg, action, 5000)
    end
end

local function generateCustomClass(entity)
    local model = GetEntityModel(entity)
    for k, _ in pairs(QBCore.Shared.Vehicles) do
        if QBCore.Shared.Vehicles[k]['hash'] == model then
            return QBCore.Shared.Vehicles[k][Config.SharedTierName]
        end
    end
end

function depotVehicle(NetworkID)
    local entity = NetworkGetEntityFromNetworkId(NetworkID)
    local plate = QBCore.Functions.GetPlate(entity)
    local class = GetVehicleClass(entity)

    if Config.PayoutType == 'custom' then
        class = generateCustomClass(entity)
    end
    QBCore.Functions.Progressbar("depot_vehicle", Config.Lang['progressBar']['depotVehicle'].title, Config.Lang['progressBar']['depotVehicle'].time, false, true, {
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
    QBCore.Functions.Progressbar("calling_tow", Config.Lang['progressBar']['callingTow'].title, Config.Lang['progressBar']['callingTow'].time, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent("brazzers-tow:server:markForTow", NetworkGetNetworkIdFromEntity(vehicle), vehname, plate)
    end, function() -- Cancel
        TriggerEvent('DoLongHudText', Config.Lang['error'][10], 2)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterNetEvent("brazzers-tow:client:sendTowRequest", function(info, vehicle, plate, pos)
    local success = exports[Config.Phone]:PhoneNotification("JOB OFFER", 'Incoming Tow Request', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if not success then return end
    TriggerServerEvent("brazzers-tow:server:sendTowRequest", info, vehicle, plate, pos)
end)

RegisterNetEvent('brazzers-tow:client:receiveTowRequest', function(pos, plate, blipId)
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
        AddTextComponentString(Config.Lang['blip']['towRequest']..''..plate)
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

-- Global Blip
local mainBlip = nil
local depotBlip = nil

CreateThread(function()
    mainBlip = AddBlipForCoord(Config.LaptopCoords.xyz)
    SetBlipSprite(mainBlip, 68)
    SetBlipDisplay(mainBlip, 4)
    SetBlipScale(mainBlip, 0.7)
    SetBlipAsShortRange(mainBlip, true)
    SetBlipColour(mainBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Tow Lot")
    EndTextCommandSetBlipName(mainBlip)

    for _, v in pairs(Config.DepotLot) do
        depotBlip = AddBlipForCoord(v.xyz)
        SetBlipSprite(depotBlip, 68)
        SetBlipDisplay(depotBlip, 4)
        SetBlipScale(depotBlip, 0.7)
        SetBlipAsShortRange(depotBlip, true)
        SetBlipColour(depotBlip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Depot Lot")
        EndTextCommandSetBlipName(depotBlip)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, _ in pairs(blips) do
            RemoveBlip(blips[k])
        end
    end
end)