local QBCore = exports[Config.Core]:GetCoreObject()

local cachedQueue = {}
local cachedMission = {}

-- Functions

local function generateCall(groupLeader)
    local src = groupLeader
    if not src then return end

    TriggerClientEvent('brazzers-tow:client:sendCall', src)
end

local function generateMission(groupLeader)
    if not groupLeader then return end

    local group = exports[Config.Phone]:GetGroupByMembers(groupLeader)
    if not group then return end

    if cachedMission[group] then return print("CURRENT DOING A FUCKING MISSION") end
    
    local location = generateLocation()
    local vehicle, plate = generateVehicle()
    if not location then return end

    -- ADD SOME MORE BULLSHIT HERE

    cachedQueue[group].inQueue = false

    print("MISSION GENERATED")
end

-- Events

RegisterNetEvent('brazzers-tow:server:joinQueue', function(isAllowed)
    if not isAllowed then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local group = exports[Config.Phone]:GetGroupByMembers(src)
    if not group then return end

    local members = exports[Config.Phone]:getGroupMembers(group)
    if not members then return end

    if cachedQueue[group] and cachedQueue[group].inQueue then
        print("YOUR ALREADY IN QUEUE MORON")
        return
    end

    if cachedMission[group] then return print("CURRENTLY ON A MISSION") end
    if not exports[Config.Phone]:isGroupLeader(src, group) then return print("YOU MUST BE GROUP LEADER TO QUEUE") end
    
    if not cachedQueue[group] then cachedQueue[group] = {} end
    if not cachedMission[group] then cachedMission[group] = {} end

    cachedQueue[group] = {
        groupLeader = src,
        groupId = group,
        inQueue = true,
        available = true,
    }

    if cachedQueue[group].inQueue then
        for i=1, #members do
            if not members[i] then return end
            TriggerClientEvent('brazzers-tow:client:queueIndex', members[i], cachedQueue[group].inQueue)
            notification(members[i], 'TOWING', 'You have joined the queue', false)
        end
    end
end)

-- Threads

CreateThread(function()
    while true do
        if cachedQueue then
            for k, v in pairs(cachedQueue) do
                if cachedMission[k] then
                    if v.inQueue and v.available then
                        generateMission(v.groupLeader)
                    end
                end
            end
        end
        Wait(5000)
    end
end)