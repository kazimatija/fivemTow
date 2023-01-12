local QBCore = exports[Config.Core]:GetCoreObject()

local signedIn = false

-- Functions

exports('isSignedIn', function()
    return signedIn
end)

local function getSpawn()
    for _, v in pairs(Config.VehicleSpawns) do
        if not IsAnyVehicleNearPoint(v.x, v.y, v.z, 4) then
            return v
        end
    end
end

function isTow()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if (PlayerData.job.name == Config.Job) and PlayerData.job.onduty then
        return true
    end
end

function inZone()
    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)

    for _, v in pairs(Config.DepotLot) do
        if (#(pedPos - v.xyz) <= 20.0) then
            return true
        end
    end
end

function signIn()
    local coords = getSpawn()
    if not coords then return QBCore.Functions.Notify(Config.Lang['error'][1], 'error', 5000) end

    if Config.RenewedPhone and not exports[Config.Phone]:hasPhone() then return QBCore.Functions.Notify(Config.Lang['error'][2], 'error', 5000) end
    if signedIn then return end

    TriggerServerEvent('brazzers-tow:server:signIn', coords)
end

function signOut()
    if not signedIn then return end
    TriggerServerEvent('brazzers-tow:server:forceSignOut')
end

local function RayCast(origin, target, options, ignoreEntity, radius)
    local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius, options, ignoreEntity, 0)
    return GetShapeTestResult(handle)
end

local function ControlEntity(entity)
	local timeout = false
	if not NetworkHasControlOfEntity(entity) then
		NetworkRequestControlOfEntity(entity)

		SetTimeout(1000, function () timeout = true end)

		while not NetworkHasControlOfEntity(entity) and not timeout do
			NetworkRequestControlOfEntity(entity)
			Wait(100)
		end
	end
	return NetworkHasControlOfEntity(entity)
end

local function GetAttachOffset(pTarget)
	local model = GetEntityModel(pTarget)
	local minDim, maxDim = GetModelDimensions(model)
	local vehSize = maxDim - minDim
	return vector3(0, -(vehSize.y / 2), 0.4 - minDim.z)
end

local function GetEntityBehindTowTruck(towTruck, towDistance, towRadius)
    local forwardVector = GetEntityForwardVector(towTruck)
    local originCoords = GetEntityCoords(towTruck)
    local targetCoords = originCoords + (forwardVector * towDistance)

    local _, hit, _, _, targetEntity = RayCast(originCoords, targetCoords, 30, towTruck, towRadius or 0.2)

    return targetEntity
end

local function FindVehicleAttachedToVehicle(cFlatbed)
	local handle, vehicle = FindFirstVehicle()
    local success = nil

	repeat
		if GetEntityAttachedTo(vehicle) == cFlatbed then
			return vehicle
		end

        success, vehicle = FindNextVehicle(handle)
	until not success

	EndFindVehicle(handle)
end

local function attachVehicleToBed(flatbed, target)
    local distance = #(GetEntityCoords(target) - GetEntityCoords(flatbed)) 
    local speed = GetEntitySpeed(target)

    if distance <= 15 and speed <= 3.0 then
        local offset = GetAttachOffset(target)
        if not offset then return end

        local hasControlOfTow = ControlEntity(flatbed)
        local hasControlOfVehicle = ControlEntity(target)

        if hasControlOfTow and hasControlOfVehicle then
            AttachEntityToEntity(target, flatbed, GetEntityBoneIndexByName(flatbed, 'bodyshell'), offset.x, offset.y, offset.z, 0, 0, 0, 1, 1, 0, 0, 0, 1)
            SetCanClimbOnEntity(target, false)
        end
    end
end

local function isTowVehicle(vehicle)
    local retval = false
    if GetEntityModel(vehicle) == GetHashKey(Config.TowTruck) then
        retval = true
    end
    return retval
end

local function forceSignOut()
    if not signedIn then return end

    signedIn = false
    notification(Config.Lang['current'], Config.Lang['primary'][4], 'primary')
end

local function hookVehicle(NetworkID)
    local flatbed = NetworkGetEntityFromNetworkId(NetworkID)
    if not flatbed then return notification(false, Config.Lang['error'][3], 'error') end

    local target = GetEntityBehindTowTruck(flatbed, -8, 0.7)
    if not target or target == 0 then return notification(false, Config.Lang['error'][4], 'error') end

    local targetModel = GetEntityModel(target)
    local targetClass = GetVehicleClass(target)
    local towTruckDriver = GetPedInVehicleSeat(flatbed, -1)

    if (Config.BlacklistedModels[targetModel] or Config.BlacklistedClasses[targetClass]) then
        return notification(false, Config.Lang['error'][5], 'error')
    end

    local targetDriver = GetPedInVehicleSeat(target, -1)
    if targetDriver ~= 0 then return notification(false, Config.Lang['error'][6], 'error') end

    if flatbed == target then return end
    if not isTowVehicle(flatbed) then return notification(false, Config.Lang['error'][7], 'error') end
    if GetEntityType(target) ~= 2 then return end

    local state = Entity(flatbed).state.FlatBed
    if not state then return end
    if state.carAttached then return notification(false, Config.Lang['error'][8], 'error') end

    local towTruckCoords, targetCoords = GetEntityCoords(flatbed), GetEntityCoords(target)
    local distance = #(targetCoords - towTruckCoords)

    if distance <= 10 then
        TaskTurnPedToFaceCoord(PlayerPedId(), targetCoords, 1.0)
        Wait(1000)
        -- Animation
        QBCore.Functions.Progressbar("filling_nitrous", Config.Lang['progressBar']['hookVehicle'].title, Config.Lang['progressBar']['hookVehicle'].time, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            QBCore.Functions.Progressbar("filling_nitrous", Config.Lang['progressBar']['towVehicle'].title, Config.Lang['progressBar']['towVehicle'].time, false, false, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(towTruckDriver))
                if playerId and playerId ~= 0 then return notification(false, Config.Lang['error'][9], 'error') end

                attachVehicleToBed(flatbed, target)
                TriggerServerEvent('brazzers-tow:server:syncHook', true, NetworkGetNetworkIdFromEntity(flatbed), NetworkGetNetworkIdFromEntity(target))
            end, function()
                notification(false, Config.Lang['error'][10], 'error')
            end)
        end, function()
            notification(false, Config.Lang['error'][10], 'error')
        end)
    end
end

local function unHookVehicle(NetworkID)
    local flatbed = NetworkGetEntityFromNetworkId(NetworkID)
    if not flatbed then return notification(false, Config.Lang['error'][3], 'error') end

    local target = FindVehicleAttachedToVehicle(flatbed)
    if not target or target == 0 then return end
    if flatbed == target then return end

    local state = Entity(flatbed).state.FlatBed
    if not state then return end
    if not state.carAttached then return notification(false, Config.Lang['error'][11], 'error') end

    TaskTurnPedToFaceEntity(PlayerPedId(), flatbed, 1.0)
    Wait(1000)
    -- Animation
    QBCore.Functions.Progressbar("untowing_vehicle", Config.Lang['progressBar']['unTowVehicle'].title, Config.Lang['progressBar']['unTowVehicle'].time, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.Progressbar("unhooking_vehicle", Config.Lang['progressBar']['unHookVehicle'].title, Config.Lang['progressBar']['unHookVehicle'].time, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            if not IsEntityAttachedToEntity(target, flatbed) then return notification(false, Config.Lang['error'][12], 'error') end
            TriggerServerEvent('brazzers-tow:server:syncDetach', NetworkGetNetworkIdFromEntity(flatbed))
        end, function()
            notification(false, Config.Lang['error'][10], 'error')
        end)
    end, function()
        notification(false, Config.Lang['error'][10], 'error')
    end)
end

local function callTow()
    TriggerEvent('brazzers-tow:client:requestTowTruck')
end

RegisterNetEvent('brazzers-tow:client:syncDetach', function(flatbed)
    local cFlatbed = NetworkGetEntityFromNetworkId(flatbed)
    local state = Entity(cFlatbed).state.FlatBed
    if not state then return end

    local attachedVehicle = NetworkGetEntityFromNetworkId(state.carEntity)
    local drop = GetOffsetFromEntityInWorldCoords(attachedVehicle, 0.0,-5.5,0.0)

    DetachEntity(attachedVehicle, true, true)
    Wait(100)
    SetEntityCoords(attachedVehicle, drop)
    Wait(100)
    SetVehicleOnGroundProperly(attachedVehicle)
    TriggerServerEvent('brazzers-tow:server:syncHook', false, NetworkGetNetworkIdFromEntity(cFlatbed), nil)
end)

RegisterNetEvent('brazzers-tow:client:groupDeleted', function()
    TriggerServerEvent('brazzers-tow:server:forceSignOut')
end)

RegisterNetEvent('brazzers-tow:client:truckSpawned', function(NetID, plate)
    if NetID and plate then
        local vehicle = NetToVeh(NetID)
        exports[Config.Fuel]:SetFuel(vehicle, 100.0)
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
        notification(Config.Lang['current'], Config.Lang['primary'][5], 'primary')
    end
    signedIn = true
end)

RegisterNetEvent('brazzers-tow:client:forceSignOut', function()
    forceSignOut()
end)

-- Threads

CreateThread(function()
    if Config.Target == 'ox' then
        exports.ox_target:addBoxZone({
            coords = Config.LaptopCoords,
            size = vec3(0.2, 0.4, 1.0),
            rotation = 117,
            debug = Config.Debug,
            options = {
                {
                    name = 'tow_signin_laptop',
                    icon = Config.Lang['target']['signIn'].icon,
                    label = Config.Lang['target']['signIn'].title,
                    onSelect = function()
                        signIn()
                    end,
                    canInteract = function()
                        if Config.WhitelistedJob and not isTow() then return end
                        if signedIn then return end
                        return true
                    end,
                },
                {
                    name = 'tow_signout_laptop',
                    icon = Config.Lang['target']['signOut'].icon,
                    label = Config.Lang['target']['signOut'].title,
                    onSelect = function()
                        signOut()
                    end,
                    canInteract = function()
                        if not signedIn then return end
                        return true
                    end,
                },
                {
                    name = 'tow_missionboard_laptop',
                    icon = Config.Lang['target']['missionBoard'].icon,
                    label = Config.Lang['target']['missionBoard'].title,
                    onSelect = function()
                        viewMissionBoard()
                    end,
                    canInteract = function()
                        if Config.WhitelistedJob and not isTow() then return end
                        if not signedIn then return end
                        return true
                    end,
                },
            }
        })
        return
    end

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
                icon = Config.Lang['target']['signIn'].icon,
                label = Config.Lang['target']['signIn'].title,
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
                icon = Config.Lang['target']['signOut'].icon,
                label = Config.Lang['target']['signOut'].title,
                canInteract = function()
                    if not signedIn then return end
                    return true
                end,
            },
            {
                action = function()
                    viewMissionBoard()
                end,
                icon = Config.Lang['target']['missionBoard'].icon,
                label = Config.Lang['target']['missionBoard'].title,
                canInteract = function()
                    if Config.WhitelistedJob and not isTow() then return end
                    if not signedIn then return end
                    return true
                end,
            },
        },
        distance = 1.0,
    })
end)

CreateThread(function()
    if Config.Target == 'ox' then
        local options = {
            {
                name = 'tow_hook_vehicle',
                icon = Config.Lang['target']['hookVehicle'].icon,
                label = Config.Lang['target']['hookVehicle'].title,
                onSelect = function(entity)
                    hookVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTowVehicle(entity) then return end
                    if Config.AllowTowOnly and not isTow() then return end

                    local target = GetEntityBehindTowTruck(entity, -8, 0.7)
                    if not target or target == 0 then return end

                    local state = Entity(entity).state.FlatBed
                    if not state then return end
                    if state.carAttached then return end

                    return true
                end
            },
            {
                name = 'tow_unhook_vehicle',
                icon = Config.Lang['target']['unHookVehicle'].icon,
                label = Config.Lang['target']['unHookVehicle'].title,
                onSelect = function(entity)
                    unHookVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTowVehicle(entity) then return end
                    if Config.AllowTowOnly and not isTow() then return end

                    local state = Entity(entity).state.FlatBed
                    if not state then return end
                    if not state.carAttached then return end

                    return true
                end
            },
            {
                name = 'tow_depot_vehicle',
                icon = Config.Lang['target']['depotVehicle'].icon,
                label = Config.Lang['target']['depotVehicle'].title,
                onSelect = function(entity)
                    depotVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTow() then return end
                    if not inZone() then return end
                    local state = Entity(entity).state.FlatBed
                    if state and state.carAttached then return end
                    local markedState = Entity(entity).state.marked
                    if not markedState then return end
                    if not markedState.markedForTow then return end

                    return true
                end
            },
            {
                name = 'call_tow_vehicle',
                icon = Config.Lang['target']['markVehicle'].icon,
                label = Config.Lang['target']['markVehicle'].title,
                onSelect = function()
                    callTow()
                end,
                canInteract = function(entity)
                    if isTow() then return end
                    local markedState = Entity(entity).state.marked
                    if markedState and markedState.markedForTow then return end
                    if not Config.CallTowThroughTarget then return end
    
                    return true
                end
            },
        }
        exports.ox_target:addGlobalPed(options)
        return
    end

    exports[Config.Target]:AddGlobalVehicle({
        options = {
            {
                label = Config.Lang['target']['hookVehicle'].title,
                icon = Config.Lang['target']['hookVehicle'].icon,
                action = function(entity)
                    hookVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTowVehicle(entity) then return end
                    if Config.AllowTowOnly and not isTow() then return end

                    local target = GetEntityBehindTowTruck(entity, -8, 0.7)
                    if not target or target == 0 then return end

                    local state = Entity(entity).state.FlatBed
                    if not state then return end
                    if state.carAttached then return end

                    return true
                end
            },
            {
                label = Config.Lang['target']['unHookVehicle'].title,
                icon = Config.Lang['target']['unHookVehicle'].icon,
                action = function(entity)
                    unHookVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTowVehicle(entity) then return end
                    if Config.AllowTowOnly and not isTow() then return end

                    local state = Entity(entity).state.FlatBed
                    if not state then return end
                    if not state.carAttached then return end

                    return true
                end
            },
            {
                label = Config.Lang['target']['depotVehicle'].title,
                icon = Config.Lang['target']['depotVehicle'].icon,
                action = function(entity)
                    depotVehicle(NetworkGetNetworkIdFromEntity(entity))
                end,
                canInteract = function(entity)
                    if not isTow() then return end
                    if not inZone() then return end
                    local state = Entity(entity).state.FlatBed
                    if state and state.carAttached then return end
                    local markedState = Entity(entity).state.marked
                    if not markedState then return end
                    if not markedState.markedForTow then return end

                    return true
                end
            },
            {
                label = Config.Lang['target']['markVehicle'].title,
                icon = Config.Lang['target']['markVehicle'].icon,
                action = function()
                    callTow()
                end,
                canInteract = function(entity)
                    if isTow() then return end
                    local markedState = Entity(entity).state.marked
                    if markedState and markedState.markedForTow then return end
                    if not Config.CallTowThroughTarget then return end

                    return true
                end
            },
        },
        distance = 1.5
    })
end)
