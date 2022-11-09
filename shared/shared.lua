Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'qb-target'
Config.Fuel = 'LegacyFuel'

Config.NotificationStyle = 'phone' -- 'phone' for Renewed's Phone notifications | 'qbcore' for standard qbcore notifications
Config.TowTruck = 'flatbed' -- Tow truck model name
Config.MarkedVehicleOnly = true -- Allow only marked vehicles to be towed and not random vehicles around the street [RECOMMENDED: TRUE]

-- PHONE CONFIG --
Config.RenewedPhone = true -- If you use Renewed's Phone then leave this to true else put false
Config.Phone = 'qb-phone' -- If using Renewed's Phone then put your resource name here
Config.OnlyLeader = true -- Allow only the leader of the group to sign into the tow job [RECOMMENDED: TRUE]
Config.GroupLimit = 2 -- Amount of people allowed in a group to start a tow run

Config.Job = 'tow' -- tow job name from QBCore.Shared.Jobs
Config.JobGrade = 0 -- grade level to assign the player when signing in
Config.DepositRequired = true -- If a deposit is required to take out a vehicle
Config.DepositAmount = 100 -- If above is true, then set the amount here

Config.LaptopCoords = vector3(471.58, -1310.89, 28.94) -- Location to sign in
Config.VehicleSpawns = { -- Vehicle spawns for the tow truck
    vector4(499.06, -1333.53, 29.42, 26.54),
    vector4(486.88, -1332.38, 29.38, 297.66),
    vector4(496.51, -1332.84, 29.42, 3.8),
    vector4(492.45, -1331.87, 29.41, 344.83)
}