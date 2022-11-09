local QBCore = exports[Config.Core]:GetCoreObject()

local cachedTow = {}
local usedPlates = {}

local function forceSignOut(source, group, resetAll)
    local src = source
    if not src then return end

    if group then
        DeleteEntity(NetworkGetEntityFromNetworkId(cachedTow[group].towtruck))
        usedPlates[cachedTow[group].plate] = nil
        cachedTow[group] = nil
    end

    if not Config.RenewedPhone then return TriggerClientEvent("", src) end

    if resetAll then
        local members = exports[Config.Phone]:getGroupMembers(group)
        
        for i=1, #members do
            TriggerClientEvent("brazzers-tow:client:forceSignOut", members[i])
        end
    end

    if exports[Config.Phone]:isGroupTemp(group) then
        exports[Config.Phone]:DestroyGroup(group)
    end
end

local function generatePlate()
    local string = "TOW"..QBCore.Shared.RandomInt(5)
    if usedPlates[string] then
        return generatePlate()
    else
        usedPlates[string] = true
        return string
    end
end

local function spawnVehicle(carType, group, coords)
    local CreateAutomobile = joaat('CREATE_AUTOMOBILE')
    local car = Citizen.InvokeNative(CreateAutomobile, joaat(carType), coords, true, false)

    while not DoesEntityExist(car) do
        Wait(25)
    end
    
    local NetID = NetworkGetNetworkIdFromEntity(car)
    local plate = generatePlate()

    SetVehicleNumberPlateText(car, plate)

    if Config.RenewedPhone then
        local members = exports[Config.Phone]:getGroupMembers(group)
        for i=1, #members do
            TriggerClientEvent("brazzers-tow:client:truckSpawned", members[i], NetID, plate)
        end
    else
        TriggerClientEvent("brazzers-tow:client:truckSpawned", src, NetID, plate)
    end
    return NetID, plate
end

RegisterNetEvent('brazzers-tow:server:forceSignOut', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local group = Player.PlayerData.citizenid

    if Config.RenewedPhone then
        group = exports[Config.Phone]:GetGroupByMembers(src)
        local members = exports[Config.Phone]:getGroupMembers(group)
        for i=1, #members do
            return
            forceSignOut(members[i], group, true)
        end
    end

    forceSignOut(src, group, false)
end)

RegisterNetEvent('brazzers-tow:server:signIn', function(coords)
    local src = source
    if not coords then return end

    local ped = GetPlayerPed(src)
    if #(GetEntityCoords(ped) - vector3(Config.LaptopCoords.x, Config.LaptopCoords.y, Config.LaptopCoords.z)) > 5 then return forceSignOut(src, _, false) end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local group = Player.PlayerData.citizenid
    local size = nil

    if Config.RenewedPhone then
        group = exports[Config.Phone]:GetGroupByMembers(src) or exports[Config.Phone]:CreateGroup(src, "Tow-"..Player.PlayerData.citizenid)
        size = exports[Config.Phone]:getGroupSize(group)

        if size > Config.GroupLimit then
            TriggerClientEvent('QBCore:Notify', src, "Your group can only have "..Config.GroupLimit..' members in it', "error")
            forceSignOut(src, _, false)
            return
        end
        
        if exports[Config.Phone]:getJobStatus(group) ~= "WAITING" then
            TriggerClientEvent('QBCore:Notify', src, "Your group is currently busy doing something else", "error")
            forceSignOut(src, _, false)
            return
        end
        if not exports[Config.Phone]:isGroupLeader(src, group) then
            TriggerClientEvent('QBCore:Notify', src, "You must be the group leader to sign in", "error")
            forceSignOut(src, _, false)
            return
        end
    end

    if not group then return end
    if cachedTow[group] then
        TriggerClientEvent('QBCore:Notify', src, "Your group is already signed in!", "error")
        forceSignOut(src, _, false)
        return
    end

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
            TriggerClientEvent('QBCore:Notify', src, 'You need $'..Config.DepositAmount..' to be able to take a tow truck out!', 'error')
            forceSignOut(src, _, false)
            return
        end
    end

    local vehicle, plate = spawnVehicle(Config.TowTruck, group, coords)
    if not vehicle or not plate then 
        TriggerClientEvent('QBCore:Notify', src, "Error try again!", "error")
        forceSignOut(src, _, true)
        return
    end

    cachedTow[group] = {
        towtruck = vehicle,
        plate = plate,
        data = {
            car = nil,
            carPlate = nil,
            carLocation = nil,
            carHooked = nil,
        },
    }
end)

