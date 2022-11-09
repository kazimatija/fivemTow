local QBCore = exports[Config.Core]:GetCoreObject()

local cachedTow = {}
local usedPlates = {}
local markedVehicles = {}

function notifyGroup(src, type, msg, group)
    if not group then return TriggerClientEvent('QBCore:Notify', src, msg, type) end
    exports[Config.Phone]:pNotifyGroup(group,
        "CURRENT",
        msg,
        "fas fa-user",
        "#2193eb",
        7500
    )
end

local function forceSignOut(source, group, resetAll)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if DoesEntityExist(NetworkGetEntityFromNetworkId(cachedTow[group].towtruck)) then
        DeleteEntity(NetworkGetEntityFromNetworkId(cachedTow[group].towtruck))
        if Config.DepositRequired then
            Player.Functions.AddMoney('bank', Config.DepositAmount)
            TriggerClientEvent('QBCore:Notify', src, "You have received your deposit back")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You did not receive your deposit back", 'error')
    end

    usedPlates[cachedTow[group].plate] = nil
    cachedTow[group] = nil

    if not Config.RenewedPhone then return TriggerClientEvent("brazzers-tow:client:forceSignOut", src) end

    if resetAll then
        local members = exports[Config.Phone]:getGroupMembers(group)
        for i=1, #members do
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
    local string = "TOW"..QBCore.Shared.RandomInt(5)
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

    if Config.RenewedPhone then
        local members = exports[Config.Phone]:getGroupMembers(group)
        if not members then return end

        for i=1, #members do
            if members[i] then
                TriggerClientEvent("brazzers-tow:client:truckSpawned", members[i], NetID, plate)
            end
        end
    else
        TriggerClientEvent("brazzers-tow:client:truckSpawned", src, NetID, plate)
    end
    return NetID, plate
end

local function isVehicleMarked(plate)
    if markedVehicles[plate] then
        return true
    end
end

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

        if Config.OnlyLeader and not exports[Config.Phone]:isGroupLeader(src, group) then return TriggerClientEvent('QBCore:Notify', src, "You must be the group leader to sign out", "error") end

        for i=1, #members do
            if members[i] then
                forceSignOut(members[i], group, true)
                return
            end
        end
    end

    forceSignOut(src, group, false)
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
        group = exports[Config.Phone]:GetGroupByMembers(src) or exports[Config.Phone]:CreateGroup(src, "Tow-"..Player.PlayerData.citizenid)
        local size = exports[Config.Phone]:getGroupSize(group)

        if size > Config.GroupLimit then return TriggerClientEvent('QBCore:Notify', src, "Your group can only have "..Config.GroupLimit..' members in it', "error") end
        if exports[Config.Phone]:getJobStatus(group) ~= "WAITING" then return TriggerClientEvent('QBCore:Notify', src, "Your group is currently busy doing something else", "error") end
        if Config.OnlyLeader and not exports[Config.Phone]:isGroupLeader(src, group) then return TriggerClientEvent('QBCore:Notify', src, "You must be the group leader to sign in", "error") end
    end

    if not group then return end
    if cachedTow[group] then return TriggerClientEvent('QBCore:Notify', src, "Your group is already signed in!", "error") end

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
            return
        end
    end

    local vehicle, plate = spawnVehicle(src, Config.TowTruck, group, coords)
    if not vehicle or not plate then return TriggerClientEvent('QBCore:Notify', src, "Error try again!", "error") end

    Player.Functions.SetJob(Config.Job, Config.JobGrade)

    cachedTow[group] = {
        towtruck = vehicle,
        plate = plate,
    }
end)

RegisterNetEvent('brazzers-tow:server:markForTow', function(vehicle, plate)
    if not plate then return end
    local src = source
    local coords = GetEntityCoords(GetPlayerPed(src))

    markedVehicles[plate] = true

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Employees = QBCore.Functions.GetPlayer(v)
        if Employees then
            if Employees.PlayerData.job.name == 'tow' and Employees.PlayerData.job.onduty then
                if not Config.RenewedPhone then return TriggerClientEvent('brazzers-tow:client:receiveTowRequest', Employees.PlayerData.source, coords, vehicle, plate) end

                local info = {Receiver = Employees, Sender = src}
                local group = exports[Config.Phone]:GetGroupByMembers(Employees.PlayerData.source)
                if not group then return end

                if exports[Config.Phone]:isGroupLeader(Employees.PlayerData.source, group) then
                    TriggerClientEvent('brazzers-tow:client:sendTowRequest', Employees.PlayerData.source, info, vehicle, plate, coords)
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

    for i=1, #members do
        if members[i] then
            TriggerClientEvent('brazzers-tow:client:receiveTowRequest', members[i], pos, vehicle, plate) -- SEND BLIP
        end
    end
   
    if not Config.RenewedPhone then return TriggerClientEvent('QBCore:Notify', info.Sender, "A driver accepted your tow request") end
    TriggerClientEvent('qb-phone:client:CustomNotification', info.Sender, "CURRENT", 'A driver accepted your tow request', 'fas fa-map-pin', '#b3e0f2', 7500)
end)

RegisterNetEvent('brazzers-tow:server:towVehicle', function(plate)
    if not plate then return end
    local src = source

    if Config.MarkedVehicleOnly and not isVehicleMarked(plate) then return TriggerClientEvent('QBCore:Notify', src, "This vehicle is not marked for tow") end

    -- further tow logic for hooking and shit, this is just a check to make sure the vehicle you're trying to tow is marked
    -- preventing players from just picking up random vehicles and towing them for no reason etc.
end)

RegisterNetEvent('brazzers-tow:server:depotVehicle', function(plate, class, action)
    if not plate or not action then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Config.MarkedVehicleOnly and not isVehicleMarked(plate) then return TriggerClientEvent('QBCore:Notify', src, "This vehicle is not marked for tow") end

    if action == 'check' then
        TriggerClientEvent('brazzers-tow:client:depotVehicle', src)
    elseif action == 'depot' then
        local payout = Config.Payout[class]['payout']

        if not Config.RenewedPhone then
            Player.Functions.AddMoney('cash', payout)
            TriggerClientEvent('QBCore:Notify', src, 'You received $'..payout)
            return
        end

        local group = exports[Config.Phone]:GetGroupByMembers(src)
        if not group then return end

        local members = exports[Config.Phone]:getGroupMembers(group)
        if not members then return end

        for i=1, #members do
            if members[i] then
                local groupMembers = QBCore.Functions.GetPlayer(members[i])
                groupMembers.Functions.AddMoney('cash', payout)
                TriggerClientEvent('QBCore:Notify', members[i], 'You received $'..payout)
            end
        end
    end
end)

-- Callbacks

