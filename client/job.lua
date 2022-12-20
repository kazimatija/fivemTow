local QBCore = exports[Config.Core]:GetCoreObject()

-- Global Variables

local inQueue = false

local function getRep()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local repAmount = PlayerData.metadata[Config.RepName]

    for k, _ in pairs(Config.RepLevels) do
        if repAmount >= Config.RepLevels[k]['repNeeded'] then
            return Config.RepLevels[k]['label'], repAmount
        end
    end
end

RegisterNetEvent('brazzers-tow:client:viewRepBoard', function()
    local repLevel, repAmount = getRep()
    local isSignedIn = true

    if exports['brazzers-tow']:isSignedIn() then isSignedIn = false end

    local menu = {
        {
            header = repLevel..' | '..repAmount..'x Reputation',
            isMenuHeader = true,
            icon = "fas fa-building",
        },
    }
    menu[#menu+1] = {
        header = 'Start Mission',
        isMenuHeader = isSignedIn,
        txt = 'Queue into missions dispatched by Bon Joe',
        icon = "fas fa-briefcase",
        params = {
            event = "brazzers-tow:client:joinQueue",
        }
    }
    menu[#menu+1] = {
        header = "Close",
        icon = 'fas fa-angle-left',
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }
    exports[Config.Menu]:openMenu(menu)
end)

RegisterNetEvent('brazzers-tow:client:joinQueue', function()
    if not exports['brazzers-tow']:isSignedIn() then return end
    TriggerServerEvent('brazzers-tow:server:joinQueue', true)
end)

RegisterNetEvent('brazzers-tow:client:queueIndex', function(value)
    inQueue = value
end)

RegisterNetEvent('brazzers-tow:client:sendCall', function()
    local success = exports[Config.Phone]:PhoneNotification("JOB OFFER", 'Incoming Tow Request', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if not success then return end
    TriggerServerEvent("brazzers-tow:server:sendTowRequest", info, vehicle, plate, pos)
end)

RegisterCommand('testtow', function()
    TriggerEvent('brazzers-tow:client:viewRepBoard')
end)