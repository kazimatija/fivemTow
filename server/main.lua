local QBCore = exports[Config.Core]:GetCoreObject()

local cachedTow = {}
local usedPlates = {}
local calls = 0

local cooldowns = {} -- [citizenid] = expiration_timestamp

function markForTow(car, plate)
    local car = NetworkGetEntityFromNetworkId(car)
    Entity(car).state.marked = {
        markedForTow = true,
        plate = plate,
    }
end

local function FindAttachedVehicle(towTruck)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if GetEntityAttachedTo(vehicle) == towTruck then
            return vehicle
        end
    end
    return 0
end

function isMissionEntity(vehicle)
    local syncedVehicle = NetworkGetEntityFromNetworkId(vehicle)
    local syncedState = Entity(syncedVehicle).state.tow
    if not syncedState then return end

    if syncedState.missionVehicle then
        return true
    end
end

function isVehicleMarked(vehicle)
    local syncedMarked = NetworkGetEntityFromNetworkId(vehicle)
    local syncedState = Entity(syncedMarked).state.marked
    if not syncedState then return end
    if not syncedState.markedForTow then return end

    return true
end

local function forceSignOut(source, group, resetAll)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if DoesEntityExist(NetworkGetEntityFromNetworkId(cachedTow[group].towtruck)) then
        DeleteEntity(NetworkGetEntityFromNetworkId(cachedTow[group].towtruck))
        if Config.DepositRequired then
            Player.Functions.AddMoney('bank', Config.DepositAmount)
            TriggerClientEvent('QBCore:Notify', src, Config.Lang['primary'][9])
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Config.Lang['error'][13], 'error')
    end

    usedPlates[cachedTow[group].plate] = nil
    cachedTow[group] = nil

    if not Config.RenewedPhone then return TriggerClientEvent("brazzers-tow:client:forceSignOut", src) end

    if resetAll then
        local members = exports[Config.Phone]:getGroupMembers(group)
        for i = 1, #members do
            if members[i] then
                TriggerClientEvent("brazzers-tow:client:forceSignOut", members[i])
            end
        end
    end

    if exports[Config.Phone]:isGroupTemp(group) then
        exports[Config.Phone]:DestroyGroup(group)
    end
end

local function generatePlate()
    local string = "TOW" .. QBCore.Shared.RandomInt(5)
    if usedPlates[string] then
        return generatePlate()
    else
        usedPlates[string] = true
        return string
    end
end

local function spawnVehicle(source, carType, group, coords)
    if not group then return end
    local src = source
    local CreateAutomobile = joaat('CREATE_AUTOMOBILE')
    local car = Citizen.InvokeNative(CreateAutomobile, joaat(carType), coords, true, false)

    while not DoesEntityExist(car) do
        Wait(25)
    end

    local NetID = NetworkGetNetworkIdFromEntity(car)
    local plate = generatePlate()

    SetVehicleNumberPlateText(car, plate)

    Entity(car).state.FlatBed = {
        carAttached = false,
        carEntity = nil,
    }

    if Config.Fuel == 'ox' and GetResourceState('ox_fuel') == "started" then
        Entity(car).state.fuel = 100.0
    end

    if Config.RenewedPhone then
        local members = exports[Config.Phone]:getGroupMembers(group)
        if not members then return end

        for i = 1, #members do
            if members[i] then
                TriggerClientEvent("brazzers-tow:client:truckSpawned", members[i], NetID, plate)
            end
        end
    else
        TriggerClientEvent("brazzers-tow:client:truckSpawned", src, NetID, plate)
    end
    return NetID, plate
end

RegisterNetEvent('brazzers-tow:server:syncHook', function(index, NetID, hookedVeh)
    local src = source
    local car = NetworkGetEntityFromNetworkId(NetID)
    local targetVeh = NetworkGetEntityFromNetworkId(hookedVeh)
    local state = Entity(car).state.FlatBed
    if not state then return end

    if DoesEntityExist(car) and DoesEntityExist(targetVeh) then
        -- Mark vehicle as towed by this tow truck
        Entity(targetVeh).state:set('towedBy', NetID, true)
    end

    local newState = {
        carAttached = index,
        carEntity = hookedVeh,
    }

    Entity(car).state:set('FlatBed', newState, true)

    -- if doing a mission, this checks entity for state bag then removes blip
    if index then
        local Player = QBCore.Functions.GetPlayer(src)
        local group = Player.PlayerData.citizenid

        if Config.RenewedPhone then
            group = exports[Config.Phone]:GetGroupByMembers(source)
            if not group then return end

            local members = exports[Config.Phone]:getGroupMembers(group)
            if not members then return end

            if isMissionEntity(hookedVeh) then
                for i = 1, #members do
                    if members[i] then
                        TriggerClientEvent('brazzers-tow:client:sendMissionBlip', members[i], false)
                    end
                end
            end
            return
        end

        if isMissionEntity(hookedVeh) then
            TriggerClientEvent('brazzers-tow:client:sendMissionBlip', src, false)
        end
    end
end)

RegisterNetEvent('brazzers-tow:server:forceSignOut', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local group = Player.PlayerData.citizenid

    if Config.RenewedPhone then
        group = exports[Config.Phone]:GetGroupByMembers(src)
        if not group then return end

        local members = exports[Config.Phone]:getGroupMembers(group)
        if not members then return end

        if Config.OnlyLeader and not exports[Config.Phone]:isGroupLeader(src, group) then
            return TriggerClientEvent(
                'QBCore:Notify', src, "You must be the group leader to sign out", "error")
        end

        for i = 1, #members do
            if members[i] then
                local groupMembers = QBCore.Functions.GetPlayer(members[i])
                forceSignOut(members[i], group, true)
                if Config.ToggleDuty then
                    groupMembers.Functions.SetJobDuty(false)
                end
                return
            end
        end
    end

    forceSignOut(src, group, false)
    if Config.ToggleDuty then
        Player.Functions.SetJobDuty(false)
    end
end)

RegisterNetEvent('brazzers-tow:server:signIn', function(coords)
    local src = source
    if not coords then return end

    local ped = GetPlayerPed(src)
    if #(GetEntityCoords(ped) - vector3(Config.LaptopCoords.x, Config.LaptopCoords.y, Config.LaptopCoords.z)) > 5 then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local group = Player.PlayerData.citizenid

    if Config.RenewedPhone then
        group = exports[Config.Phone]:GetGroupByMembers(src) or
            exports[Config.Phone]:CreateGroup(src, "Tow-" .. Player.PlayerData.citizenid)
        local size = exports[Config.Phone]:getGroupSize(group)

        if size > Config.GroupLimit then
            return TriggerClientEvent('QBCore:Notify', src, Config.Lang['error'][14],
                "error")
        end
        if exports[Config.Phone]:getJobStatus(group) ~= "WAITING" then
            return TriggerClientEvent('QBCore:Notify', src,
                Config.Lang['error'][15], "error")
        end
        if Config.OnlyLeader and not exports[Config.Phone]:isGroupLeader(src, group) then
            return TriggerClientEvent(
                'QBCore:Notify', src, Config.Lang['error'][16], "error")
        end
    end
    if not group then return end
    if cachedTow[group] then return TriggerClientEvent('QBCore:Notify', src, Config.Lang['error'][17], "error") end

    if Config.DepositRequired then
        local deposit = {
            cash = Player.PlayerData.money['cash'],
            bank = Player.PlayerData.money['bank'],
        }
        if deposit.cash >= Config.DepositAmount then
            Player.Functions.RemoveMoney("cash", Config.DepositAmount)
        elseif deposit.bank >= Config.DepositAmount then
            Player.Functions.RemoveMoney("bank", Config.DepositAmount)
        else
            TriggerClientEvent('QBCore:Notify', src, Config.Lang['error'][18], 'error')
            return
        end
    end

    local vehicle, plate = spawnVehicle(src, Config.TowTruck, group, coords)
    if not vehicle or not plate then return TriggerClientEvent('QBCore:Notify', src, Config.Lang['error'][19], "error") end

    if Config.RenewedPhone then
        local members = exports[Config.Phone]:getGroupMembers(group)
        if not members then return end

        for i = 1, #members do
            if members[i] then
                local groupMembers = QBCore.Functions.GetPlayer(members[i])
                if not Config.WhitelistedJob then
                    groupMembers.Functions.SetJob(Config.Job, Config.JobGrade)
                end
                if Config.ToggleDuty then
                    groupMembers.Functions.SetJobDuty(true)
                end
            end
        end
    end

    if not Config.WhitelistedJob then
        Player.Functions.SetJob(Config.Job, Config.JobGrade)
    end
    if Config.ToggleDuty then
        Player.Functions.SetJobDuty(true)
    end

    cachedTow[group] = {
        towtruck = vehicle,
        plate = plate,
    }
end)

RegisterNetEvent('brazzers-tow:server:markForTow', function(netID, vehName, plate)
    if not plate then return end
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))

    markForTow(netID, plate)
    calls = calls + 1

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Employees = QBCore.Functions.GetPlayer(v)
        if Employees then
            if Employees.PlayerData.job.name == Config.Job and Employees.PlayerData.job.onduty then
                if not Config.RenewedPhone then
                    return TriggerClientEvent('brazzers-tow:client:receiveTowRequest',
                        Employees.PlayerData.source, coords, plate, calls)
                end

                local info = { Receiver = Employees, Sender = src }
                local group = exports[Config.Phone]:GetGroupByMembers(Employees.PlayerData.source)
                if not group then return end

                if exports[Config.Phone]:isGroupLeader(Employees.PlayerData.source, group) then
                    TriggerClientEvent('brazzers-tow:client:sendTowRequest', Employees.PlayerData.source, info, vehName,
                        plate, coords)
                end
            end
        end
    end
end)

RegisterNetEvent("brazzers-tow:server:sendTowRequest", function(info, vehicle, plate, pos)
    local group = exports[Config.Phone]:GetGroupByMembers(info.Receiver.PlayerData.source)
    if not group then return end

    local members = exports[Config.Phone]:getGroupMembers(group)
    if not members then return end

    calls = calls + 1

    for i = 1, #members do
        if members[i] then
            TriggerClientEvent('brazzers-tow:client:receiveTowRequest', members[i], pos, plate, calls) -- SEND BLIP
        end
    end

    if not Config.RenewedPhone then return TriggerClientEvent('QBCore:Notify', info.Sender, Config.Lang['primary'][10]) end
    TriggerClientEvent('qb-phone:client:CustomNotification', info.Sender, Config.Lang['current'],
        Config.Lang['primary'][10], 'fas fa-map-pin', '#b3e0f2', 7500)
end)

RegisterNetEvent('brazzers-tow:server:syncDetach', function(flatbed)
    local src = source
    local towTruck = NetworkGetEntityFromNetworkId(flatbed)
    local targetVeh = FindAttachedVehicle(towTruck)

    if DoesEntityExist(targetVeh) then
        -- Check if detached in impound zone
        local vehCoords = GetEntityCoords(targetVeh)
        local inZone = false
        for _, zone in pairs(Config.DepotLot) do
            if #(vehCoords - zone) <= 20.0 then
                inZone = true
                break
            end
        end

        if inZone then
            -- Mark as eligible for 15 minutes
            Entity(targetVeh).state:set('impoundEligible', true, true)
            SetTimeout(900000, function() -- 15 minutes
                if DoesEntityExist(targetVeh) then
                    Entity(targetVeh).state:set('impoundEligible', false, true)
                end
            end)
        end
    end
    TriggerClientEvent('brazzers-tow:client:syncDetach', -1, flatbed)
end)

if Config.RenewedPhone then
    AddEventHandler('qb-phone:server:GroupDeleted', function(group, players)
        if not cachedTow[group] then return end
        if cachedTow[group].plate then usedPlates[cachedTow[group].plate] = nil end
        cachedTow[group] = nil
        for i = 1, #players do
            TriggerClientEvent("brazzers-tow:client:groupDeleted", players[i])
        end
    end)
else
    AddEventHandler('playerDropped', function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local cid = Player.PlayerData.citizenid
            cachedTow[cid] = nil
        end
    end)
end

-- Check cooldown status
QBCore.Functions.CreateCallback('brazzers-tow:server:canImpound', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= Config.Impound.RequiredJob then
        cb(false)
        return
    end

    local cid = Player.PlayerData.citizenid
    local currentTime = os.time()
    local remaining = (cooldowns[cid] or 0) - currentTime

    cb({
        allowed = remaining <= 0,
        timeLeft = remaining > 0 and remaining or 0
    })
end)

-- Check cooldown status
QBCore.Functions.CreateCallback('brazzers-tow:server:canTow', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= Config.Impound.RequiredJob then
        cb(false)
        return
    end

    local cid = Player.PlayerData.citizenid
    local currentTime = os.time()
    local remaining = (cooldowns[cid] or 0) - currentTime

    cb({
        allowed = remaining <= 0,
        timeLeft = remaining > 0 and remaining or 0
    })
end)

-- Start cooldown
RegisterNetEvent('brazzers-tow:server:startCooldown', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == Config.Impound.RequiredJob then
        cooldowns[Player.PlayerData.citizenid] = os.time() + Config.Impound.Cooldown
    end
end)

-- Clear cooldown on job exit
-- RegisterNetEvent('brazzers-tow:server:clearCooldown', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if Player then
--         cooldowns[Player.PlayerData.citizenid] = nil
--     end
-- end)

-- Auto-create table on resource start
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `tow_blacklist` (
            `citizenid` VARCHAR(50) NOT NULL PRIMARY KEY,
            `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
        )
    ]], nil, function()
        print("[BRAZZERS-TOW] Tow blacklist table initialized")
    end)
end)

QBCore.Commands.Add("blocktow", "Blacklist player from tow job", { { name = "citizenid", help = "Player CitizenID" } },
    true, function(source, args)
    local src = source
    local citizenid = args[1]:upper()

    if not string.match(citizenid, "^[%u%d]+$") then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid CitizenID format!', 'error')
        return
    end

    MySQL.Async.fetchScalar('SELECT citizenid FROM tow_blacklist WHERE citizenid = ?', { citizenid }, function(exists)
        if exists then
            TriggerClientEvent('QBCore:Notify', src, 'Player is already blocked!', 'error')
            return
        end

        MySQL.Async.execute('INSERT INTO tow_blacklist (citizenid) VALUES (?)', { citizenid }, function()
            TriggerClientEvent('QBCore:Notify', src, 'Successfully blocked: ' .. citizenid, 'success')

            local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Target then
                -- Revoke tow job
                Target.Functions.SetJob('unemployed', 0)

                -- Delete their tow truck if exists
                if cachedTow[Target.PlayerData.citizenid] then
                    local vehicle = NetworkGetEntityFromNetworkId(cachedTow[Target.PlayerData.citizenid].towtruck)
                    if DoesEntityExist(vehicle) then
                        DeleteEntity(vehicle)
                    end
                    cachedTow[Target.PlayerData.citizenid] = nil
                end

                -- Force sign out
                TriggerClientEvent('brazzers-tow:client:forceSignOut', Target.PlayerData.source)
            end
        end)
    end)
end, 'admin')

-- Unblock command
QBCore.Commands.Add("unblocktow", "Unblacklist player", { { name = "citizenid", help = "Player CitizenID" } }, true,
    function(source, args)
        local src = source
        local citizenid = args[1]:upper()

        MySQL.Async.execute('DELETE FROM tow_blacklist WHERE citizenid = ?', { citizenid }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Successfully unblocked: ' .. citizenid, 'success')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Player is not blocked!', 'error')
            end
        end)
    end, 'admin')

-- Check blacklist status
QBCore.Functions.CreateCallback('brazzers-tow:server:isBlacklisted', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    MySQL.Async.fetchScalar('SELECT citizenid FROM tow_blacklist WHERE citizenid = ?', { Player.PlayerData.citizenid },
        function(result)
            cb(result ~= nil)
        end)
end)
