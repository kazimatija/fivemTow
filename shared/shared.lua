Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'qb-target'
Config.Fuel = 'LegacyFuel'
Config.Menu = 'qb-menu'

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

Config.DepotLot = vector3(-142.59, -1173.80, 23.76) -- Location
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
Config.BasePay = 100
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
    [1] = {
        ['coords'] = vector4(275.33, -2067.09, 16.53, 290.96),
        ['isBusy'] = false,
    },
}

Config.BlacklistedModels = {
}

Config.BlacklistedClasses = {
}