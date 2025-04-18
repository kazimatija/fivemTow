Config = Config or {}

Config.Debug = true

Config.Core = 'qb-core'
Config.Target = 'ox' -- ox or resource name (ex. 'qb-target' )
Config.Fuel = 'ox'   -- ox or resource name (ex. 'qb-fuel' )
Config.Menu = 'ox'   -- 'ox' or resource name (ex. 'qb-menu')

Config.NotificationStyle =
'phone'                            -- 'phone' for Renewed's Phone notifications | 'qbcore' for standard qbcore notifications
Config.TowTruck = 'flatbed'        -- Tow truck model name
Config.MarkedVehicleOnly = true    -- Allow only marked vehicles to be towed and not random vehicles around the street [RECOMMENDED: TRUE]
Config.CallTowThroughTarget = true -- Adds a global vehicle option to call tow drivers by targeting the vehicle entity

Config.UseTierVehicles = true      -- If you want to use tier class system. This requires extra steps so check readme
Config.SharedTierName =
'tier'                             -- [ABOVE MUST BE TRUE] Name of QBCore.Shared.Vehicles that targets the classes. For me personally I use 'category' but I know others may use 'tier' because of jl-laptop

-- PHONE CONFIG --
Config.RenewedPhone = false         -- If you use Renewed's Phone then leave this to true else put false
Config.Phone = 'qb-phone'           -- If using Renewed's Phone then put your resource name here
Config.OnlyLeader = true            -- Allow only the leader of the group to sign into the tow job [RECOMMENDED: TRUE]
Config.GroupLimit = 1               -- Amount of people allowed in a group to start a tow run/ get mission rewards

Config.WhitelistedJob = false       -- If you wanna restrict sign in feature to only existing tow job people, set this to true. You will have to manually add the job below to the person then
Config.Job = 'tow'                  -- tow job name from QBCore.Shared.Jobs
Config.JobGrade = 0                 -- grade level to assign the player when signing in
Config.ToggleDuty = true            -- Toggle duty when signing in and signing out
Config.DepositRequired = true       -- If a deposit is required to take out a vehicle
Config.DepositAmount = 100          -- If above is true, then set the amount here
Config.CanRequestTow = { 'police' } -- All jobs here that can request a tow driver ( I don't recommend to put 'tow' here or people will farm your shit )

Config.DepotLot = {                 -- Location
    vector3(402.0139, -1632.3669, 29.2919),
}
Config.AllowTowOnly = false                                  -- set this to true if you want to only allow the tow job to use hook/ unhook vehicle on the tow truck
Config.BlipLength = 5                                        -- Amount of time in minutes a calls blip stays on the map

Config.LaptopCoords = vector3(407.6891, -1624.8713, 28.2919) -- Location to sign in
Config.VehicleSpawns = {                                     -- Vehicle spawns for the tow truck
    vector4(402.8550, -1631.9324, 29.3798, 174.3085),
    vector4(407.4576, -1647.6146, 29.3797, 227.7593),
}

-- QUEUE CONFIG --
Config.UseQueue = true -- Set to false if you want to receive contracts instantly when requested
Config.QueueTimer = 5  -- Amount of time to wait in queue in minutes for a AI mission (above must be true)
Config.ReQueue = true  -- Do you want to auto requeue when completing a mission (this is basically if you want to auto get another job after completing one so you don't have to go back to the laptop and request)

-- REPUTATION CONFIG --
Config.AllowRep = true                  -- Do you want reputation system in general for this ?
Config.RepForMissionsOnly = true        -- Only earn reputation for mission vehicles or allow rep earnings for all tows
Config.RepName = 'tow'                  -- Meta data name for reputation
Config.GroupExtraRep = 0.5              -- 'false' or percentage of total (ex. base rep of 50 + 50 / 0.5 )
Config.RepLevels = {                    -- All reputation levels, min rep needed for that rank, and reward per ranking ( I dont recommend removing or adding any (leave a suggestion) )
    ['S'] = {
        ['label'] = 'Expert',           -- Label Name
        ['repNeeded'] = 800,            -- Amount of rep to be this level
        ['reward'] = math.random(5, 8), -- Meta reward for turning a vehicle in with this class
        ['multiplier'] = 2.0,           -- Multiplier to receive extra money (ex $50 + $50 * 2.0)
        ['chance'] = 5,                 -- percentage for getting one of these vehicles when at that class level
    },
    ['A'] = {
        ['label'] = 'Pro',
        ['repNeeded'] = 500,
        ['reward'] = math.random(4, 7),
        ['multiplier'] = 1.5,
        ['chance'] = 15,
    },
    ['B'] = {
        ['label'] = 'Intermediate',
        ['repNeeded'] = 250,
        ['reward'] = math.random(3, 6),
        ['multiplier'] = 1.0,
        ['chance'] = 35,
    },
    ['C'] = {
        ['label'] = 'Novice',
        ['repNeeded'] = 20,
        ['reward'] = math.random(2, 5),
        ['multiplier'] = 0.7,
        ['chance'] = 50,
    },
    ['D'] = {
        ['label'] = 'Beginner',
        ['repNeeded'] = 0,
        ['reward'] = math.random(1, 4),
        ['multiplier'] = 0.3,
        ['chance'] = 100,
    },
}

-- PAYOUT CONFIG --
Config.BasePay = 100         -- if payout type is custom and for some reason you don't have the vehicle you towed in shared.lua, it cannot find a class hence will give this default pay
Config.PayoutType =
'custom'                     -- 'custom' payout is based off the class defined in QBCore.Shared.Vehicles | 'standard' is utilizing payout based on GTA native class
Config.GroupExtraMoney = 0.5 -- 'false' or percentage of total (ex. base price of $50 + $50 / 0.5 )
Config.Payout = {
    ['standard'] = {
        [0] = { ['payout'] = 100 },  -- Compacts
        [1] = { ['payout'] = 100 },  -- Sedans
        [2] = { ['payout'] = 100 },  -- SUVs
        [3] = { ['payout'] = 100 },  -- Coupes
        [4] = { ['payout'] = 100 },  -- Muscle
        [5] = { ['payout'] = 100 },  -- Sports Classic
        [6] = { ['payout'] = 100 },  -- Sports
        [7] = { ['payout'] = 100 },  -- Super
        [8] = { ['payout'] = 100 },  -- Motorcycles
        [9] = { ['payout'] = 100 },  -- Off-road
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
    -- YOU CAN ONLY USE CUSTOM PAYOUT IF Config.UseTierVehicles == true
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
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true
}

Config.Lang = {
    ['current'] = 'Current',
    ['missionRequest'] = { title = 'Job Offer', desc = 'Vehicle Towing Request', icon = 'fas fa-map-pin', color = '#b3e0f2' },
    ['missionBoard'] = {
        ['header'] = { label = 'Tow Truck Missions', repLabel = 'x Reputation', icon = 'fas fa-building' },
        ['firstMenu'] = { title = 'Start Mission', icon = 'fas fa-briefcase', desc = 'Queue into missions dispatched by Bon Joe' },
        ['secondMenu'] = { title = 'Leave Queue', icon = 'fas fa-briefcase' },
        ['thirdMenu'] = { title = 'Close', icon = 'fas fa-angle-left' },
    },
    ['primary'] = {
        [1] = 'Vehicle location marked',
        [2] = 'Tow the vehicle back to the parking lot',
        [3] = 'Your group has been removed from the queue',
        [4] = 'You have signed out!',
        [5] = 'You have signed in, check the laptop!',
        [6] = 'You were not automatically requeued and must queue again',
        [7] = 'You have joined the queue, the vehicle is ahead!',
        [8] = 'You have automatic requeue enabled!',
        [9] = 'You have received your deposit back',
        [10] = 'The driver has accepted your towing request',
        [11] = 'You have received $',
        [12] = 'You have earned '
    },
    ['error'] = {
        [1] = 'A vehicle is on the way',
        [2] = 'You don’t have a phone',
        [3] = 'Tow truck does not exist',
        [4] = 'Vehicle not found',
        [5] = 'You cannot tow this type of vehicle',
        [6] = 'The vehicle must be empty',
        [7] = 'You don’t have a tow truck',
        [8] = 'The vehicle is already attached',
        [9] = 'There cannot be a driver in the truck',
        [10] = 'Cancelled',
        [11] = 'No car attached to the truck',
        [12] = 'No attached vehicle',
        [13] = 'Your deposit was not returned',
        [14] = 'A group can have ' .. Config.GroupLimit .. ' members',
        [15] = 'Group is active',
        [16] = 'You must be the leader',
        [17] = 'The group is already signed in!',
        [18] = 'You need $' .. Config.DepositAmount .. ' to take out the tow truck!',
        [19] = 'Error, please try again!',
        [20] = 'This vehicle is not marked for towing',
        [21] = 'Your group can only have ' .. Config.GroupLimit .. ' members in order to reward everyone in the group',
        [22] = "No vehicle detected behind the tow truck!",
        [23] = "Invalid URL format! URLs must start with http:// or https://",
        [24] = "You cannot do this job! (You are blocked)",
        [25] = "This vehicle has not been towed!"
    },
    ['progressBar'] = {
        ['hookVehicle'] = { title = 'Hooking the vehicle', time = 2500 },
        ['towVehicle'] = { title = 'Towing the vehicle', time = 2500 },
        ['unTowVehicle'] = { title = 'Unhooking the vehicle', time = 2500 },
        ['unHookVehicle'] = { title = 'Detaching the vehicle', time = 2500 },
        ['depotVehicle'] = { title = 'Sending the vehicle to the depot', time = 1500 },
        ['callingTow'] = { title = 'Calling tow truck', time = 3500 },
    },
    ['target'] = {
        ['signIn'] = { title = 'Sign in', icon = 'fas fa-hands' },
        ['signOut'] = { title = 'Sign out', icon = 'fas fa-hands' },
        ['missionBoard'] = { title = 'View tasks', icon = 'fas fa-hands' },
        ['hookVehicle'] = { title = 'Attach vehicle', icon = 'fas fa-car-rear' },
        ['unHookVehicle'] = { title = 'Detach vehicle', icon = 'fas fa-car-rear' },
        ['depotVehicle'] = { title = 'Send to depot', icon = 'fas fa-car-rear' },
        ['markVehicle'] = { title = 'Call tow truck', icon = 'fas fa-hands' },
        ['submitPhotos'] = { title = "Submit photos", icon = "fas fa-camera" },
        ['impound'] = { title = "Impound vehicle", icon = "fas fa-car-crash" }
    },
    ['blip'] = {
        ['towRequest'] = 'Towing request: ',
    },
    ['photoDialog'] = {
        title = "Submit Towing Photos",
        licensePlate = "License plate photo URL",
        fullCar = "Full vehicle photo URL"
    },
    ['success'] = {
        [1] = "Vehicle successfully impounded ($%s)",
        [2] = "You can now attach the vehicle!",
        [3] = "Time remaining until the next impound: %s minutes"
    }
}

Config.DiscordWebhook =
"https://discord.com/api/webhooks/..."

Config.Impound = {
    Payout = 100,
    RequiredJob = 'tow',    -- Player must have this job
    Radius = 3.0,           -- Interaction distance from vehicle
    AllowAnyVehicle = true, -- Impound any vehicle (no prior marking needed)
    DeleteOnImpound = true, -- Delete vehicle after impound
    Cooldown = 900,         -- 15 minutes in seconds
    CooldownMessageTow = "You must wait %s before you can attach another vehicle.",
    CooldownMessageImpound = "You must wait %s before you can impound another vehicle."
}
