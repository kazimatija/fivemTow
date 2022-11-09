Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'qb-target'
Config.Fuel = 'LegacyFuel'

Config.NotificationStyle = 'phone'
Config.TowTruck = 'flatbed'

-- PHONE CONFIG --
Config.RenewedPhone = true -- If you use Renewed's Phone then leave this to true else put false
Config.Phone = 'qb-phone' -- If using Renewed's Phone then put your resource name here
Config.OnlyLeader = true -- Allow only the leader of the group to sign into the tow job [RECOMMENDED: TRUE]
Config.GroupLimit = 2

Config.Job = 'tow'
Config.JobGrade = 0
Config.DepositRequired = true
Config.DepositAmount = 100

Config.LaptopCoords = vector3(471.58, -1310.89, 28.94)
Config.VehicleSpawns = {
    vector4(499.06, -1333.53, 29.42, 26.54),
    vector4(486.88, -1332.38, 29.38, 297.66),
    vector4(496.51, -1332.84, 29.42, 3.8),
    vector4(492.45, -1331.87, 29.41, 344.83)
}