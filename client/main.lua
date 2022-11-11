local QBCore = exports[Config.Core]:GetCoreObject()

local signedIn = false
local CachedNet = nil
local blip = nil

-- Functions

function notification(title, msg, action)
    if Config.NotificationStyle == 'phone' then
        TriggerEvent('qb-phone:client:CustomNotification', title, msg, 'fas fa-user', '#b3e0f2', 5000)
    elseif Config.NotificationStyle == 'qbcore' then
        QBCore.Functions.Notify(title..': '..msg, action, 5000)
    end
end

local function CreateBlip(coords)
    blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 3)
	SetBlipRoute(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Tow Call')
    EndTextCommandSetBlipName(blip)
end

local function isTowVehicle(vehicle)
    local retval = false
    if GetEntityModel(vehicle) == GetHashKey("flatbed") then
        retval = true
    end
    return retval
end

local function getSpawn()
    for _, v in pairs(Config.VehicleSpawns) do
        if not IsAnyVehicleNearPoint(v.x, v.y, v.z, 4) then
            return v
        end
    end
end

local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

local function signIn()
    local coords = getSpawn()
    if not coords then return QBCore.Functions.Notify("There's a vehicle in the way", 'error', 5000) end

    if Config.RenewedPhone and not exports[Config.Phone]:hasPhone() then return QBCore.Functions.Notify("You don\'t have a phone", 'error', 5000) end
    if signedIn then return end

    TriggerServerEvent('brazzers-tow:server:signIn', coords)
end

local function signOut()
    if not signedIn then return end
    TriggerServerEvent('brazzers-tow:server:forceSignOut')
end

local function forceSignOut()
    if not signedIn then return end

    signedIn = false
    notification("CURRENT", "You have signed out!", 'primary')
    RemoveBlip(blip)
end

RegisterNetEvent('brazzers-tow:client:truckSpawned', function(NetID, plate)
    if NetID and plate then
        CachedNet = NetID
        local vehicle = NetToVeh(NetID)
        exports[Config.Fuel]:SetFuel(vehicle, 100.0)
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
        notification("CURRENT", "You have signed in, vehicle outside", 'primary')
    end
    signedIn = true
end)

RegisterNetEvent('brazzers-tow:client:forceSignOut', function()
    forceSignOut()
end)

RegisterCommand('markfortow', function()
    TriggerEvent('brazzers-tow:client:requestTowTruck')
end)

RegisterCommand('checktow', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('brazzers-tow:server:towVehicle', plate)
end)

RegisterCommand('hookvehicle', function()
    TriggerEvent('brazzers-tow:client:hookVehicle')
end)

RegisterCommand('depotvehicle', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    TriggerServerEvent('brazzers-tow:server:depotVehicle', plate, false, 'check')
end)

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

RegisterNetEvent("brazzers-tow:client:depotVehicle", function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local class = GetVehicleClass(vehicle)
    QBCore.Functions.Progressbar("depot_vehicle", "Sending Vehicle To Depot", 1500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.DeleteVehicle(vehicle)
        TriggerServerEvent('brazzers-tow:server:depotVehicle', plate, class, 'depot')
    end, function()
        -- Cancel
    end)
end)

RegisterNetEvent("brazzers-tow:client:sendTowRequest", function(info, vehicle, plate, pos)
    local success = exports[Config.Phone]:PhoneNotification("JOB OFFER", 'Incoming Tow Request', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        TriggerServerEvent("brazzers-tow:server:sendTowRequest", info, vehicle, plate, pos)
    end
end)

RegisterNetEvent('brazzers-tow:client:receiveTowRequest', function(pos, vehicle, plate)
    CreateBlip(pos)
    TriggerEvent('qb-phone:client:CustomNotification', 'CURRENT', "Location has been marked for the vehicle!", 'fas fa-map-pin', '#b3e0f2', 2000)
    Wait(5000)
    TriggerEvent('qb-phone:client:CustomNotification', 'CURRENT', "Vehicle: "..vehicle.." | Plate: "..plate, 'fas fa-map-pin', '#b3e0f2', 120000)
end)

RegisterNetEvent('brazzers-tow:client:hookVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    local flatbed = NetworkGetEntityFromNetworkId(CachedNet)
    if vehicle ~= flatbed then return end

    local state = Entity(vehicle).state.FlatBed
    if not state then return end

    local playerped = PlayerPedId()
    local coordA = GetEntityCoords(playerped, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)

    if not isTowVehicle(vehicle) then return print('ENTER THE TOW VEHICLE AGAIN') end

    if not state.carAttached then
        if not IsPedInAnyVehicle(PlayerPedId()) then
            NetworkRequestControlOfEntity(targetVehicle)
            if vehicle ~= targetVehicle then
                local towPos = GetEntityCoords(vehicle)
                local targetPos = GetEntityCoords(targetVehicle)
                if #(towPos - targetPos) < 11.0 then
                    QBCore.Functions.Progressbar("towing_vehicle", "Towing Vehicle", 5000, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "mini@repair",
                        anim = "fixing_a_ped",
                        flags = 16,
                    }, {}, {}, function() -- Done
                        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                        AttachEntityToEntity(targetVehicle, flatbed, GetEntityBoneIndexByName(flatbed, 'bodyshell'), 0.0, -1.5 + -0.85, 0.0 + 1.15, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                        FreezeEntityPosition(targetVehicle, true)
                        print("ATTACH VEHICLE")
                        TriggerServerEvent('brazzers-tow:server:syncHook', true, CachedNet, NetworkGetNetworkIdFromEntity(targetVehicle))
                    end, function() -- Cancel
                        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                        QBCore.Functions.Notify("Canceled", "error")
                    end)
                end
            end
        end
    else
        QBCore.Functions.Progressbar("untowing_vehicle", "Removing Vehicle", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_ped",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
            FreezeEntityPosition(state.carNetId, false)
            Wait(250)
            AttachEntityToEntity(state.carNetId, flatbed, 20, -0.0, -15.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
            DetachEntity(state.carNetId, true, true)
            print("DEATTACH VEHICLE")
            TriggerServerEvent('brazzers-tow:server:syncHook', false, CachedNet, nil)
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
            QBCore.Functions.Notify("Canceled", "error")
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveBlip(blip)
    end
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
                    if not signedIn then return true end
                end,
            },
            {
                action = function()
                    signOut()
                end,
                icon = 'fas fa-hands',
                label = 'Sign Out',
                canInteract = function()
                    if signedIn then return true end
                end,
            },
        },
        distance = 1.0,
    })
end)
