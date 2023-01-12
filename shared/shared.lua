Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'qb-target' -- ox or resource name (ex. 'qb-target' )
Config.Fuel = 'qb-fuel' -- ox or resource name (ex. 'qb-fuel' )
Config.Menu = 'qb-menu' -- 'ox' or resource name (ex. 'qb-menu')

Config.NotificationStyle = 'phone' -- 'phone' for Renewed's Phone notifications | 'qbcore' for standard qbcore notifications
Config.TowTruck = 'flatbed' -- Tow truck model name
Config.MarkedVehicleOnly = true -- Allow only marked vehicles to be towed and not random vehicles around the street [RECOMMENDED: TRUE]

-- PHONE CONFIG --
Config.RenewedPhone = true -- If you use Renewed's Phone then leave this to true else put false
Config.Phone = 'qb-phone' -- If using Renewed's Phone then put your resource name here
Config.OnlyLeader = true -- Allow only the leader of the group to sign into the tow job [RECOMMENDED: TRUE]
Config.GroupLimit = 2 -- Amount of people allowed in a group to start a tow run/ get mission rewards

Config.WhitelistedJob = false -- If you wanna restrict sign in feature to only existing tow job people, set this to true. You will have to manually add the job below to the person then
Config.Job = 'tow' -- tow job name from QBCore.Shared.Jobs
Config.JobGrade = 0 -- grade level to assign the player when signing in
Config.DepositRequired = true -- If a deposit is required to take out a vehicle
Config.DepositAmount = 100 -- If above is true, then set the amount here

Config.DepotLot = { -- Location
    vector3(-142.59, -1173.80, 23.76),
}
Config.AllowTowOnly = false -- set this to true if you want to only allow the tow job to use hook/ unhook vehicle on the tow truck
Config.BlipLength = 5 -- Amount of time in minutes a calls blip stays on the map

Config.LaptopCoords = vector3(471.58, -1310.89, 28.94) -- Location to sign in
Config.VehicleSpawns = { -- Vehicle spawns for the tow truck
    vector4(499.06, -1333.53, 29.42, 26.54),
    vector4(486.88, -1332.38, 29.38, 297.66),
    vector4(496.51, -1332.84, 29.42, 3.8),
    vector4(492.45, -1331.87, 29.41, 344.83)
}

Config.ReQueue = true -- Do you want to auto requeue when completing a mission

-- REPUTATION CONFIG --
Config.AllowRep = true -- Do you want reputation system in general for this ? 
Config.RepForMissionsOnly = true -- Only earn reputation for mission vehicles or allow rep earnings for all tows
Config.RepName = 'trucking' -- Meta data name for reputation
Config.RepLevels = { -- All reputation levels, min rep needed for that rank, and reward per ranking ( I dont recommend removing or adding any (leave a suggestion) )
    ['S'] = { 
        ['label'] = 'Expert',
        ['repNeeded'] = 800,
        ['reward'] = math.random(5, 8),
        ['multiplier'] = 2.0,
        ['class'] = 'S',
        ['chance'] = 5,
    },
    ['A'] = { 
        ['label'] = 'Pro',
        ['repNeeded'] = 500,
        ['reward'] = math.random(4, 7),
        ['multiplier'] = 1.5,
        ['class'] = 'A',
        ['chance'] = 15,
    },
    ['B'] = { 
        ['label'] = 'Intermediate',
        ['repNeeded'] = 250,
        ['reward'] = math.random(3, 6),
        ['multiplier'] = 1.0,
        ['class'] = 'B',
        ['chance'] = 35,
    },
    ['C'] = { 
        ['label'] = 'Novice',
        ['repNeeded'] = 20,
        ['reward'] = math.random(2, 5),
        ['multiplier'] = 0.7,
        ['class'] = 'C',
        ['chance'] = 50,
    },
    ['D'] = { 
        ['label'] = 'Beginner',
        ['repNeeded'] = 0,
        ['reward'] = math.random(1, 4),
        ['multiplier'] = 0.3,
        ['class'] = 'D',
        ['chance'] = 100,
    },
}

-- PAYOUT CONFIG --
Config.BasePay = 100 -- if payout type is custom and for some reason you don't have the vehicle you towed in shared.lua, it cannot find a class hence will give this default pay
Config.PayoutType = 'custom' -- 'custom' payout is based off the class defined in QBCore.Shared.Vehicles | 'standard' is utilizing payout based on GTA native class
Config.Payout = {
    ['standard'] = {
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
    },
    ['custom'] = {
        ['D'] = { ['payout'] = 150 },
        ['C'] = { ['payout'] = 250 },
        ['B'] = { ['payout'] = 350 },
        ['A'] = { ['payout'] = 450 },
        ['S'] = { ['payout'] = 550 },
    }
}

Config.Locations = {
    [1] = { ['coords'] = vector4(275.33, -2067.09, 16.53, 290.96), ['isBusy'] = false },
    [2] = { ['coords'] = vector4(-228.29, -1692.08, 33.18, 181.56), ['isBusy'] = false },
    [3] = { ['coords'] = vector4(115.92, -1936.77, 20.02, 19.78), ['isBusy'] = false },
    [4] = { ['coords'] = vector4(1395.46, -1533.2, 56.96, 46.1), ['isBusy'] = false },
    [5] = { ['coords'] = vector4(1120.71, -783.52, 57.11, 359.17), ['isBusy'] = false },
    [6] = { ['coords'] = vector4(1274.56, -367.65, 68.45, 54.21), ['isBusy'] = false },
    [7] = { ['coords'] = vector4(550.93, -145.62, 57.84, 91.59), ['isBusy'] = false },
    [8] = { ['coords'] = vector4(-94.98, 82.26, 70.95, 330.24), ['isBusy'] = false },
    [9] = { ['coords'] = vector4(-1184.98, -930.07, 2.16, 210.79), ['isBusy'] = false },
    [10] = { ['coords'] = vector4(-1274.67, -1155.28, 5.62, 114.63), ['isBusy'] = false },
    [11] = { ['coords'] = vector4(-1236.97, -1228.85, 6.24, 292.03), ['isBusy'] = false },
    [12] = { ['coords'] = vector4(-576.53, -1005.13, 21.57, 90.64), ['isBusy'] = false },
    [13] = { ['coords'] = vector4(-232.78, -1481.73, 30.77, 141.49), ['isBusy'] = false },
    [14] = { ['coords'] = vector4(360.92, 293.76, 102.91, 248.97), ['isBusy'] = false },
    [15] = { ['coords'] = vector4(-1003.28, 380.81, 71.43, 57.75), ['isBusy'] = false },
    [16] = { ['coords'] = vector4(-1817.64, 772.42, 135.86, 40.79), ['isBusy'] = false },
    [17] = { ['coords'] = vector4(-2967.7, 74.12, 10.85, 105.44), ['isBusy'] = false },
    [18] = { ['coords'] = vector4(-3051.29, 446.32, 5.74, 38.7), ['isBusy'] = false },
    [19] = { ['coords'] = vector4(-2568.12, 2344.62, 32.47, 334.55), ['isBusy'] = false },
    [20] = { ['coords'] = vector4(-2201.97, 2288.24, 32.34, 292.14), ['isBusy'] = false },
    [21] = { ['coords'] = vector4(-1133.66, 2695.75, 18.2, 338.79), ['isBusy'] = false },
    [22] = { ['coords'] = vector4(610.7, 2723.08, 41.28, 349.04), ['isBusy'] = false },
    [23] = { ['coords'] = vector4(1136.63, 2653.84, 37.4, 238.16), ['isBusy'] = false },
    [24] = { ['coords'] = vector4(1874.97, 2674.25, 45.1, 247.19), ['isBusy'] = false },
    [25] = { ['coords'] = vector4(1814.81, 3719.76, 33.13, 43.63), ['isBusy'] = false },
    [26] = { ['coords'] = vector4(1976.29, 3835.86, 31.43, 183.28), ['isBusy'] = false },
    [27] = { ['coords'] = vector4(2375.26, 3889.33, 35.02, 309.63), ['isBusy'] = false },
    [28] = { ['coords'] = vector4(1989.71, 4652.34, 40.51, 57.03), ['isBusy'] = false },
    [29] = { ['coords'] = vector4(1638.68, 4836.84, 41.41, 12.89), ['isBusy'] = false },
    [30] = { ['coords'] = vector4(2493.77, 5615.31, 44.26, 23.68), ['isBusy'] = false },
    [31] = { ['coords'] = vector4(192.66, 6634.04, 30.98, 15.1), ['isBusy'] = false },
    [32] = { ['coords'] = vector4(33.22, 6608.59, 31.86, 77.17), ['isBusy'] = false },
    [33] = { ['coords'] = vector4(-74.12, 6569.52, 30.88, 198.72), ['isBusy'] = false },
    [34] = { ['coords'] = vector4(-154.68, 6356.69, 30.88, 239.23), ['isBusy'] = false },
    [35] = { ['coords'] = vector4(-339.48, 6018.2, 30.7, 315.75), ['isBusy'] = false },
}

Config.BlacklistedModels = {
    [`stockade`] = true,
}

Config.BlacklistedClasses = {
    [15] = true,
    [16] = true,
}