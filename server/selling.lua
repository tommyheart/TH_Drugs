local DrugPrices = Config.SellPrices
local AlertChance = Config.PoliceAlertChance
local resourceName = GetCurrentResourceName()

local DrugTypes = {
    bagged_weed = "weed",
    cocaine_powder = "cocaine", cocaine_brick = "cocaine", cocaine = "cocaine",
    meth = "meth",
    crack = "crack",
    shine = "moonshine"
}

local function GetDrugType(itemName)
    return DrugTypes[itemName]
end

local function GetPoliceCount()
    local count = 0
    local players = exports.qbx_core:GetQBPlayers()
    local policeJobs = Config.Police.Jobs
    
    for _, player in pairs(players) do
        if player.PlayerData and player.PlayerData.job then
            for _, jobName in ipairs(policeJobs) do
                if player.PlayerData.job.name == jobName and player.PlayerData.job.onduty then
                    count = count + 1
                    break
                end
            end
        end
    end
    
    return count
end

local function AlertPolice(source, drugType, coords)
    local alertChance = AlertChance[drugType] or 25
    local roll = math.random(1, 100)
    
    if roll <= alertChance then
        local policeJobs = Config.Police.Jobs
        TriggerEvent("cd_dispatch:AddNotification", {
            job_table = policeJobs,
            coords = coords,
            title = "10-31 - Drug Activity",
            message = "Suspicious drug activity reported",
            flash = true,
            blip = {
                sprite = 51,
                scale = 1.2,
                colour = 2,
                flashes = true,
                text = "Drug Activity"
            }
        })
        return true
    end
    return false
end

lib.callback.register("drugs:server:sellDrug", function(source, itemName, amount)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local policeCount = GetPoliceCount()
    if policeCount < Config.Police.MinimumOnDuty then
        return false, "Not enough police on duty"
    end
    
    local drugType = GetDrugType(itemName)
    if not drugType then
        return false, "This item cannot be sold"
    end
    
    local canSell, msg = exports[resourceName]:CanSellDrug(source, drugType)
    if not canSell then
        return false, msg or "You haven't unlocked this drug type yet"
    end
    
    local hasItem = exports.ox_inventory:GetItem(source, itemName, nil, true)
    if not hasItem or hasItem < amount then
        return false, "Not enough of this item"
    end
    
    local priceConfig = DrugPrices[drugType] and DrugPrices[drugType][itemName]
    if not priceConfig then
        return false, "No price set for this item"
    end
    
    local unitPrice = math.random(priceConfig.min, priceConfig.max)
    local totalPrice = unitPrice * amount
    
    exports.ox_inventory:RemoveItem(source, itemName, amount)
    exports.qbx_core:AddMoney(source, "cash", totalPrice, "drug-sale")
    
    local xpGain = 0
    if Config.XP.SellXP[itemName] then
        xpGain = Config.XP.SellXP[itemName] * amount
        exports[resourceName]:AddDrugXP(source, xpGain, drugType)
    end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local alerted = AlertPolice(source, drugType, coords)

    exports[resourceName]:LogSale(source, itemName, amount, totalPrice, drugType, alerted)

    return true, totalPrice, alerted, xpGain
end)

lib.callback.register("drugs:server:getSellableItems", function(source)
    local items = exports.ox_inventory:GetInventoryItems(source)
    local sellable = {}
    local unlocks = exports[resourceName]:GetDrugUnlocks(source)
    
    for _, item in pairs(items) do
        local drugType = GetDrugType(item.name)
        if drugType then
            local canSell = false
            for _, unlockedType in ipairs(unlocks) do
                if unlockedType == drugType then
                    canSell = true
                    break
                end
            end
            
            if canSell then
                local priceConfig = DrugPrices[drugType] and DrugPrices[drugType][item.name]
                if priceConfig then
                    table.insert(sellable, {
                        name = item.name,
                        label = item.label,
                        count = item.count,
                        priceMin = priceConfig.min,
                        priceMax = priceConfig.max,
                        drugType = drugType,
                        xpGain = Config.XP.SellXP[item.name] or 0
                    })
                end
            end
        end
    end
    
    return sellable
end)

lib.callback.register("drugs:server:getPoliceCount", function(source)
    return GetPoliceCount()
end)
