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

Config.WhitelistedJob = false -- If you wanna restrict sign in feature to only existing tow job people, set this to true. You will have to manually add the job below to the person then
Config.Job = 'tow' -- tow job name from QBCore.Shared.Jobs
Config.JobGrade = 0 -- grade level to assign the player when signing in
Config.DepositRequired = true -- If a deposit is required to take out a vehicle
Config.DepositAmount = 100 -- If above is true, then set the amount here

Config.DepotLot = vector3(-142.59, -1173.80, 23.76) -- Location
Config.AllowTowOnly = false -- set this to true if you want to only allow the tow job to use hook/ unhook vehicle on the tow truck

Config.LaptopCoords = vector3(471.58, -1310.89, 28.94) -- Location to sign in
Config.VehicleSpawns = { -- Vehicle spawns for the tow truck
    vector4(499.06, -1333.53, 29.42, 26.54),
    vector4(486.88, -1332.38, 29.38, 297.66),
    vector4(496.51, -1332.84, 29.42, 3.8),
    vector4(492.45, -1331.87, 29.41, 344.83)
}

Config.Payout = {
    [0] = { ['payout'] = 100 }, -- Compacts
    [1] = { ['payout'] = 100 }, -- Sedans
    [2] = { ['payout'] = 100 }, -- SUVs
    [3] = { ['payout'] = 100 }, -- Coupes
    [4] = { ['payout'] = 100 }, -- Muscle
    [5] = { ['payout'] = 100 }, -- Sports Classic
    [6] = { ['payout'] = 100 }, -- Sports
    [7] = { ['payout'] = 100 }, -- Super
    [8] = { ['payout'] = 100 }, -- Motorcycles
    [9] = { ['payout'] = 100 }, -- Off-road
    [10] = { ['payout'] = 100 }, -- Industrial
    [11] = { ['payout'] = 100 }, -- Utility
    [12] = { ['payout'] = 100 }, -- Vans
    [13] = { ['payout'] = 100 }, -- Cycles
    [14] = { ['payout'] = 100 }, -- Boats
    [15] = { ['payout'] = 100 }, -- Helicopters
    [16] = { ['payout'] = 100 }, -- Planes
    [17] = { ['payout'] = 100 }, -- Services
    [18] = { ['payout'] = 100 }, -- Emergency
    [19] = { ['payout'] = 100 }, -- Military
    [20] = { ['payout'] = 100 }, -- Commercial
}

Config.BlacklistedModels = {
}

Config.BlacklistedClasses = {
}