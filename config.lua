Config = {}

Config.Debug = true

Config.Police = {
    Jobs = { "police", "bcso" },
    MinimumOnDuty = 0
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
    BatchAmount = { min = 5, max = 10 },
    Ingredients = {
        { item = "weed_nug", amount = 5 },
        { item = "baggies", amount = 10 }
    },
    Tools = { "trimmers", "grinder", "scale" },
    HarvestProp = `bkr_prop_weed_lrg_01a`,
    HarvestZones = {
        { coords = vector3(2276.17, 1514.14, 66.50), radius = 20.0, name = "Weed Farm 1", amount = { min = 1, max = 3 }, cooldown = 5, label = "Harvest Weed", propCount = 15 },
        --{ coords = vector3(2276.17, 1514.14, 66.50), radius = 20.0, name = "Weed Farm 2", amount = { min = 1, max = 3 }, cooldown = 300, label = "Harvest Weed", propCount = 15 }
    },
    ProcessingLocations = {
        { coords = vector3(1038.40, -3205.89, -37.28), radius = 2.0, name = "Weed Shack 1" },
        { coords = vector3(1033.87, -3206.04, -37.28), radius = 2.0, name = "Weed Shack 2" },
    }
}

Config.Cocaine = {
    ProcessingTime = 30,
    BatchAmount = { min = 5, max = 10 },
    Ingredients = {
        { item = "cocaine_leaf", amount = 5 },
        { item = "baggies", amount = 10 }
    },
    Tools = { "trimmers", "grinder", "scale" },
    HarvestProp = `bzzz_plant_coca_c`,
    HarvestZones = {
        { coords = vector3(2789.45, 1512.34, 23.0), radius = 3.0, name = "Raton Canyon Jungle", amount = { min = 1, max = 3 }, cooldown = 5, label = "Harvest Coca Leaves", propCount = 15 }
    },
    ProcessingLocations = {
        { coords = vector3(1092.06, -3195.82, -38.20), radius = 2.0, name = "Coke Lab" }
    }
}

Config.Meth = {
    ProcessingTime = 60,
    BatchAmount = { min = 10, max = 20 },
    Ingredients = {
        { item = "acetone", amount = 2 },
        { item = "pseudoephedrine", amount = 2 },
        { item = "meth_lithium", amount = 3 },
        { item = "meth_redpowder", amount = 1 }
    },
    Tools = { "meth_kit" },
    HarvestZones = {
        { coords = vector3(1250.0, -3100.0, 30.0), radius = 3.0, name = "Port of LS Warehouse", amount = { min = 1, max = 3 }, cooldown = 600, label = "Siphon Acetone" },
        { coords = vector3(-150.0, -1600.0, 35.0), radius = 3.0, name = "Del Perro Industrial", amount = { min = 1, max = 3 }, cooldown = 600, label = "Siphon Acetone" }
    },
    ProcessingLocations = {
        { coords = vector3(978.12, -145.89, 74.0), radius = 2.0, name = "Braddock Pass Lab" },
        --{ coords = vector3(-680.45, -2450.33, 13.0), radius = 2.0, name = "Airport Warehouse" },
        --{ coords = vector3(2830.11, -1450.78, 23.0), radius = 2.0, name = "Senora Desert Lab" }
    }
}

Config.Crack = {
    ProcessingTime = 30,
    BatchAmount = { min = 5, max = 10 },
    Ingredients = {
        { item = "cocaine_powder", amount = 5 },
        { item = "limestone_dust", amount = 1 }
    },
    ProcessingLocations = {
        { coords = vector3(51.89, -1839.11, 22.0), radius = 2.0, name = "Crack Lab" }
    }
}

Config.Moonshine = {
    CraftTime = 30,
    BatchAmount = { min = 3, max = 6 },
    Prop = `fury_potstill_01`,
    Ingredients = {
        { item = "shinegrain", amount = 2 },
        { item = "shinesugar", amount = 1 },
        { item = "shinewater", amount = 2 },
        { item = "shineyeast", amount = 1 }
    },
    CraftingLocations = {
        { coords = vector3(-1079.59, 4889.18, 213.59), heading = 357.0, name = "Nudist Camp" },
        --{ coords = vector3(1585.23, 6430.11, 24.0), heading = 180.0, name = "Paleto Bay Shed" },
        --{ coords = vector3(1745.89, 3314.45, 41.0), heading = 270.0, name = "Sandy Shores Barn" }
    },
    HarvestZones = {
        grain = {
            coords = vector3(2419.22, 4985.83, 47.72),
            radius = 3.0,
            amount = { min = 2, max = 4 },
            cooldown = 1200,
            label = "Harvest Grain",
            prop = `prop_sack_farm_01`
        },
        sugar = {
            coords = vector3(2372.15, 4945.25, 42.53),
            radius = 3.0,
            amount = { min = 2, max = 3 },
            cooldown = 1200,
            label = "Harvest Sugar Cane",
            prop = `xm3_prop_xm3_sacks_grain_01a`
        },
        water = {
            coords = vector3(2490.98, 4960.83, 44.75),
            radius = 3.0,
            amount = { min = 3, max = 5 },
            cooldown = 900,
            label = "Collect Water",
            prop = `prop_barrel_02a`
        },
        yeast = {
            coords = vector3(2306.56, 4867.78, 41.81),
            radius = 3.0,
            amount = { min = 1, max = 2 },
            cooldown = 1500,
            label = "Harvest Yeast",
            prop = `prop_conc_sacks_02a`
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
