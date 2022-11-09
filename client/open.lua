local QBCore = exports[Config.Core]:GetCoreObject()

local PlayerJob = {}
local Blip 
local onDuty = false
local towtruck = 0
local CurrentTow = nil

-- Functions

local function spawnTowTruck()
    local plate = 'TOW'..math.random(10000, 99999)
    local loc = vector4(-209.16, -1169.05, 22.82, 130.91)
    QBCore.Functions.TriggerCallback('5life-garbage:server:SpawnVehicle', function(netId)
        while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(10) end
        towtruck = NetworkGetEntityFromNetworkId(netId)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(towtruck))
        exports['5life-fuel']:SetFuel(towtruck, 100.0)
    end, Config.TowTruck, loc, plate)
end

local function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Wait( 0 )
    end
end

local function getRandomVehicleLocation()
    local randomVehicle = math.random(1, #Config.Locations["towspots"])
    while (randomVehicle == LastVehicle) do
        Wait(10)
        randomVehicle = math.random(1, #Config.Locations["towspots"])
    end
    return randomVehicle
end


local function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

local function isTowVehicle(vehicle)
    local retval = false
    if GetEntityModel(vehicle) == GetHashKey(Config.TowTruck) then
        retval = true
    end
    return retval
end

-- Job Update and checks
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    if JobInfo.name == "tow" and PlayerJob.name ~= 'tow' then
        if JobInfo.onduty then
            TriggerServerEvent("QBCore:ToggleDuty")
            onDuty = false
        end
    end
    PlayerJob = JobInfo
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerJob = QBCore.Functions.GetPlayerData()
    onDuty = PlayerJob.job.onduty
    if PlayerJob.job.name == "tow" and PlayerJob.job.onduty then
        TriggerServerEvent('QBCore:ToggleDuty')
    end
end)

RegisterNetEvent('5life-tow:client:UnlockVehicle', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(veh)
    local playerPed = PlayerPedId()

    QBCore.Functions.TriggerCallback("5life-tow:server:getTowStatus", function(result)
        if result then
            loadAnimDict("veh@break_in@0h@p_m_one@")
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
            QBCore.Functions.Progressbar("veh@break_in@0h@p_m_one@", "Breaking into vehicle", 3500, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                ClearPedTasks(GetPlayerPed(-1))
                SetVehicleDoorsLocked(veh, 1)
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
            end, function()
                ClearPedTasks(GetPlayerPed(-1))
            end)
        else
            TriggerEvent("DoLongHudText", 'This vehicle is not marked for tow!', 2)
        end
    end, plate)
end)

RegisterNetEvent('5life-tow:client:DepotVehicle', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(veh)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
    local class = GetVehicleClass(veh)

    QBCore.Functions.TriggerCallback("5life-tow:server:getTowStatus", function(result)
        if result then
            loadAnimDict("veh@break_in@0h@p_m_one@")
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
            QBCore.Functions.Progressbar("veh@break_in@0h@p_m_one@", "Sending vehicle to the depot!", 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                ClearPedTasks(GetPlayerPed(-1))
                TriggerServerEvent("5life-garages:server:sendVehicleToDepot", class, vehname, plate)
                QBCore.Functions.DeleteVehicle(veh)
                TriggerServerEvent("5life-tow:server:DeleteVehicle", plate)
            end, function()
                ClearPedTasks(GetPlayerPed(-1))
            end)
        else
            TriggerEvent("DoLongHudText", 'This vehicle is not marked for tow!', 2)
        end
    end, plate)
end)

RegisterNetEvent("5life-tow:client:requestTowTruck", function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    QBCore.Functions.TriggerCallback("5life-tow:enoughTow", function(amount)
        if amount >= 1 then
            TriggerEvent('animations:client:EmoteCommandStart', {"phonecall"})
            QBCore.Functions.Progressbar("searching-points", "Calling Tow", 6500, false, false, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                TriggerServerEvent("5life-tow:server:receiveTowRequest", vehname, plate)
            end, function() -- Cancel
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end)
        else
            TriggerEvent("DoLongHudText", 'No tow trucks available!', 2)
        end
    end)
end)

RegisterNetEvent('5life-tow:client:CheckTowStatus', function()
    local ped = PlayerPedId()
    local veh = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(veh)
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
    QBCore.Functions.Progressbar("CheckingTowStatus", "Checking Tow Status", 1500, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.TriggerCallback("5life-tow:server:getTowStatus", function(result)
            if result then
                TriggerEvent("DoLongHudText", 'Vehicle is marked for tow!')
            else
                TriggerEvent("DoLongHudText", 'Vehicle is not marked for tow!', 2)
            end
        end, plate)
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterNetEvent("5life-tow:client:sendTowRequest", function(info, vehicle, plate, pos)
    local success = exports['qb-phone']:PhoneNotification("JOB OFFER", ' Incoming Tow Request', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        TriggerServerEvent("5life-tow:server:sendTowRequest", info.Other, info.Player, vehicle, plate, pos)
    end
end)

local function CreateBlip(coords)
    Blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(Blip, 0.7)
	SetBlipColour(Blip, 3)
	SetBlipRoute(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Tow Call')
    EndTextCommandSetBlipName(Blip)
end

RegisterNetEvent("5life-tow:client:sendingTowRequest", function(pos, vehicle, plate)
    CreateBlip(pos)
    TriggerEvent('qb-phone:client:CustomNotification', 'CURRENT', "Location has been marked for the vehicle!", 'fas fa-map-pin', '#b3e0f2', 10000)

    callZone = CircleZone:Create(pos, 35.00, {
        name = "tow_call_zone",
        debugPoly = false
    })
    callZone:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            RemoveBlip(Blip)
            TriggerEvent('qb-phone:client:CustomNotification', 'CURRENT', "Vehicle: "..vehicle.." | Plate: "..plate, 'fas fa-map-pin', '#b3e0f2', 120000)
            callZone:destroy()
        end
    end)
end)

RegisterNetEvent('5life-tow:client:signIn', function()
    if exports['qb-phone']:hasPhone() then
        if not onDuty then
            TriggerEvent('qb-phone:client:CustomNotification', "JOB OFFER", "You have signed in!", 'fas fa-user', '#b3e0f2', 5000) 
            TriggerServerEvent('QBCore:ToggleDuty')
            onDuty = true
            -- Spawn Vehicle
            spawnTowTruck()
            TriggerEvent("DoLongHudText", 'Your vehicle is waiting outside!')
        else
            TriggerEvent('qb-phone:client:CustomNotification', "JOB OFFER", "You have signed out!", 'fas fa-user', '#b3e0f2', 5000) 
            TriggerServerEvent('QBCore:ToggleDuty')
            onDuty = false
            -- Delete Vehicle
            DeleteVehicle(towtruck)
        end
    else
        TriggerEvent("DoLongHudText", 'You do not have a phone!', 2)
    end
end)

-- Tow Vehicle Function

RegisterNetEvent('5life-tow:client:TowVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if isTowVehicle(vehicle) then
        if CurrentTow == nil then
            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)

            if not IsPedInAnyVehicle(PlayerPedId()) then
                if vehicle ~= targetVehicle then
                    NetworkRequestControlOfEntity(targetVehicle)
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
                            local vehicleHeightMin, vehicleHeightMax = GetModelDimensions(GetEntityModel(vehicle))
                            AttachEntityToEntity(targetVehicle, vehicle, GetEntityBoneIndexByName(vehicle, 'misc_a'), 0.0, 1.5, -0.25 - vehicleHeightMin.z, 0, 0, 0, 1, 1, 0, 1, 0, 1)
                            FreezeEntityPosition(targetVehicle, true)
                            CurrentTow = targetVehicle
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
                FreezeEntityPosition(CurrentTow, false)
                Wait(250)
                AttachEntityToEntity(CurrentTow, vehicle, 20, -0.0, -15.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                DetachEntity(CurrentTow, true, true)
                CurrentTow = nil
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
                QBCore.Functions.Notify("Canceled", "error")
            end)
        end
    else
        QBCore.Functions.Notify("You can\'t tow with this vehicle!", "error")
    end
end)

