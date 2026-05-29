Config = {}

Config.Debug = true

Config.Police = {
    Jobs = { "police", "bcso" },
    MinimumOnDuty = 2
}

Config.PoliceAlertChance = {
    weed = 25,
    cocaine = 35,
    meth = 45,
    crack = 40,
    moonshine = 30
}

Config.SellPrices = {
    weed = {
        bagged_weed = { min = 100, max = 150 }
    },
    cocaine = {
        cocaine = { min = 150, max = 200 }
    },
    meth = {
        meth = { min = 200, max = 300 }
    },
    crack = {
        crack = { min = 180, max = 280 }
    },
    moonshine = {
        shine = { min = 250, max = 400 }
    }
}

Config.Weed = {
    ProcessingTime = 30,
    BatchAmount = { min = 1, max = 1 },
    Ingredients = {
        { item = "weed_nug", amount = 1 },
        { item = "baggies", amount = 1 }
    },
    Tools = { "trimmers", "grinder", "scale" },
    HarvestProp = `prop_weed_01`,
    HarvestZones = {
        { coords = vector3(2345.12, 2570.45, 45.0), radius = 3.0, name = "Sandy Shores Field", amount = { min = 3, max = 6 }, cooldown = 300, label = "Harvest Weed", propCount = 5 },
        { coords = vector3(-1215.89, -890.34, 12.0), radius = 3.0, name = "Banham Canyon", amount = { min = 3, max = 6 }, cooldown = 300, label = "Harvest Weed", propCount = 4 },
        { coords = vector3(423.56, 6521.78, 28.0), radius = 3.0, name = "Paleto Bay Farm", amount = { min = 3, max = 6 }, cooldown = 300, label = "Harvest Weed", propCount = 6 }
    },
    ProcessingLocations = {
        { coords = vector3(-1227.84, -884.62, 12.0), radius = 2.0, name = "Banham Canyon Warehouse" },
        { coords = vector3(281.03, -999.56, 29.0), radius = 2.0, name = "Del Perro Garage" },
        { coords = vector3(1565.31, 6373.61, 24.0), radius = 2.0, name = "Paleto Bay Shed" }
    }
}

Config.Cocaine = {
    ProcessingTime = 45,
    BatchAmount = { min = 1, max = 1 },
    Ingredients = {
        { item = "cocaine_leaf", amount = 1 },
        { item = "baggies", amount = 1 }
    },
    Tools = { "trimmers", "grinder", "scale" },
    HarvestProp = `prop_plant_fern_01a`,
    HarvestZones = {
        { coords = vector3(2789.45, 1512.34, 23.0), radius = 3.0, name = "Raton Canyon Jungle", amount = { min = 4, max = 8 }, cooldown = 400, label = "Harvest Coca Leaves", propCount = 6 },
        { coords = vector3(-1678.23, 4521.67, 18.0), radius = 3.0, name = "Chiliad Forest", amount = { min = 4, max = 8 }, cooldown = 400, label = "Harvest Coca Leaves", propCount = 5 },
        { coords = vector3(1867.89, 3245.12, 44.0), radius = 3.0, name = "Sandy Shores Grove", amount = { min = 4, max = 8 }, cooldown = 400, label = "Harvest Coca Leaves", propCount = 4 }
    },
    ProcessingLocations = {
        { coords = vector3(-1461.22, -424.89, 35.0), radius = 2.0, name = "Pacific Bluffs Lab" },
        { coords = vector3(686.15, -2110.42, 29.0), radius = 2.0, name = "La Mesa Warehouse" },
        { coords = vector3(-264.21, -2043.54, 27.0), radius = 2.0, name = "Vespucci Garage" }
    }
}

Config.Meth = {
    SkillCheckCount = 40,
    SkillCheckSpeed = "medium",
    SkillCheckKeys = { "1", "2", "3", "4" },
    ExplosionDamage = 100,
    ExplosionRadius = 15.0,
    SuccessAmount = { min = 20, max = 40 },
    Vehicles = {
        `journey`,
        `camper`
    },
    BackSeatIndex = 0
}

Config.Crack = {
    ProcessingTime = 45,
    BatchAmount = { min = 5, max = 10 },
    Ingredients = {
        { item = "cocaine_powder", amount = 5 },
        { item = "limestone_dust", amount = 1 }
    },
    ProcessingLocations = {
        { coords = vector3(51.89, -1839.11, 22.0), radius = 2.0, name = "Terminal Bunker" },
        { coords = vector3(-999.73, -1872.61, 25.0), radius = 2.0, name = "Rancho Lab" },
        { coords = vector3(-653.78, -881.72, 23.0), radius = 2.0, name = "Little Seoul Garage" }
    }
}

Config.Moonshine = {
    CraftTime = 120,
    BatchAmount = { min = 3, max = 6 },
    Prop = `prop_still_01`,
    Ingredients = {
        { item = "shinegrain", amount = 2 },
        { item = "shinesugar", amount = 1 },
        { item = "shinewater", amount = 2 },
        { item = "shineyeast", amount = 1 }
    },
    CraftingLocations = {
        { coords = vector3(-1820.54, 4593.01, 25.0), heading = 90.0, name = "Raton Canyon Still" },
        { coords = vector3(1585.23, 6430.11, 24.0), heading = 180.0, name = "Paleto Bay Shed" },
        { coords = vector3(1745.89, 3314.45, 41.0), heading = 270.0, name = "Sandy Shores Barn" }
    },
    HarvestZones = {
        grain = {
            coords = vector3(2423.44, 4984.04, 45.0),
            radius = 10.0,
            amount = { min = 2, max = 4 },
            cooldown = 1200,
            label = "Harvest Grain",
            prop = `prop_sack_farm_01`
        },
        sugar = {
            coords = vector3(2378.15, 5017.82, 45.0),
            radius = 10.0,
            amount = { min = 2, max = 3 },
            cooldown = 1200,
            label = "Harvest Sugar Cane",
            prop = `prop_plant_cane_01`
        },
        water = {
            coords = vector3(-885.44, 4368.11, 38.0),
            radius = 5.0,
            amount = { min = 3, max = 5 },
            cooldown = 900,
            label = "Collect Water",
            prop = `prop_barrel_02a`
        },
        yeast = {
            coords = vector3(2350.0, 5050.0, 45.0),
            radius = 8.0,
            amount = { min = 1, max = 2 },
            cooldown = 1500,
            label = "Harvest Yeast",
            prop = `prop_sack_linen_01`
        }
    }
}

Config.XP = {
    SellXP = {
        bagged_weed = 10,
        cocaine = 25,
        meth = 50,
        crack = 60,
        shine = 80
    },
    Levels = {
        { level = 1, xpRequired = 0, unlocks = { "weed" } },
        { level = 2, xpRequired = 100, unlocks = { "weed", "cocaine" } },
        { level = 3, xpRequired = 500, unlocks = { "weed", "cocaine", "meth" } },
        { level = 4, xpRequired = 1500, unlocks = { "weed", "cocaine", "meth", "crack" } },
        { level = 5, xpRequired = 3000, unlocks = { "weed", "cocaine", "meth", "crack", "moonshine" } }
    }
}
