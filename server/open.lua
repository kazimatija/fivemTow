local QBCore = exports[Config.Core]:GetCoreObject()

local function getReward(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local repAmount = Player.PlayerData.metadata[Config.RepName]

    for k, _ in pairs(Config.RepLevels) do
        if repAmount >= Config.RepLevels[k]['repNeeded'] then
            return Config.RepLevels[k]['reward']
        end
    end
end

local function getMultiplier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local repAmount = Player.PlayerData.metadata[Config.RepName]

    for k, _ in pairs(Config.RepLevels) do
        if repAmount >= Config.RepLevels[k]['repNeeded'] then
            return Config.RepLevels[k]['reward']
        end
    end
end

function notification(source, title, msg, action)
    if Config.NotificationStyle == 'phone' then
        TriggerClientEvent('qb-phone:client:CustomNotification', source, title, msg, 'fas fa-user', '#b3e0f2', 5000)
    elseif Config.NotificationStyle == 'qbcore' then
        if title then
            TriggerClientEvent('QBCore:Notify', source, title..': '..msg, action)
        else
            TriggerClientEvent('QBCore:Notify', source, msg, action)
        end
    end
end

function createVehicle(source)
    while not QBCore do Wait(250) end

    local Player = QBCore.Functions.GetPlayer(source)
    local metaData = Player.PlayerData.metadata[Config.RepName] or 0

    local vehicle = {}
    local class = nil
    local chance = math.random(1, 100)

    if chance <= Config.RepLevels['S']['chance'] then
        if metaData >= Config.RepLevels['S']['repNeeded'] then
            class = 'S'
        else
            createVehicle(source)
        end
    elseif chance <= Config.RepLevels['A']['chance'] then
        if metaData >= Config.RepLevels['A']['repNeeded'] then
            class = 'A'
        else
            createVehicle(source)
        end
    elseif chance <= Config.RepLevels['B']['chance'] then
        if metaData >= Config.RepLevels['B']['repNeeded'] then
            class = 'B'
        else
            createVehicle(source)
        end
    elseif chance <= Config.RepLevels['C']['chance'] then
        if metaData >= Config.RepLevels['C']['repNeeded'] then
            class = 'C'
        else
            createVehicle(source)
        end
    else
        class = 'D'
    end

    Wait(0)

    if not class then return createVehicle(source) end
    print(class)

    for k, v in pairs(QBCore.Shared.Vehicles) do
        if v['category'] and v['category'] == class then
            vehicle[#vehicle + 1] = k
        end
    end
    if vehicle == 0 then return false end
    local index = vehicle[math.random(1, #vehicle)]
    local vehicle = QBCore.Shared.Vehicles[index]['model']
    print(vehicle)
    return vehicle
end

function moneyEarnings(source, class)
    print('Vehicle Class: '..class)
    local Player = QBCore.Functions.GetPlayer(source)
    local payout = Config.Payout[Config.PayoutType][class]['payout']
    if not payout then payout = Config.BasePay end
    
    if Config.AllowRep then
        local extra = getMultiplier(source)
        payout += extra
    end

    Player.Functions.AddMoney('cash', math.ceil(payout))
    TriggerClientEvent('QBCore:Notify', source, 'You received $'..payout)
end

function metaEarnings(source)
    local Player = QBCore.Functions.GetPlayer(source)

    local curRep = Player.PlayerData.metadata[Config.RepName]
    local reward = getReward(source)
    Player.Functions.SetMetaData(Config.RepName, (curRep + reward))
    TriggerClientEvent('QBCore:Notify', source, 'You received '..reward..' reputation with a total of '..(curRep + reward))
end