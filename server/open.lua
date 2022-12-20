local QBCore = exports[Config.Core]:GetCoreObject()

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