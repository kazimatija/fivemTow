local QBCore = exports[Config.Core]:GetCoreObject()

local function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Wait( 0 )
    end
end

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

RegisterNetEvent('brazzers-tow:client:forceSignOut', function()
    forceSignOut()
end)

RegisterNetEvent('brazzers-tow:client:unlockVehicle', function()
    local veh = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(veh)

    QBCore.Functions.TriggerCallback("brazzers-tow:server:getTowStatus", function(isMarked)
        if not isMarked then return TriggerEvent("DoLongHudText", 'This vehicle is not marked for tow!', 2) end

        loadAnimDict("veh@break_in@0h@p_m_one@")
        TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
        QBCore.Functions.Progressbar("veh@break_in@0h@p_m_one@", "Breaking into vehicle", 3500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            ClearPedTasks(PlayerPedId())
            SetVehicleDoorsLocked(veh, 1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
        end, function()
            ClearPedTasks(PlayerPedId())
        end)
    end, plate)
end)