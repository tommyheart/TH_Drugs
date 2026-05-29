local WeedConfig = Config.Weed
local cooldowns = {}

lib.callback.register('drugs:server:harvestWeed', function(source, zoneIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local zone = WeedConfig.HarvestZones[zoneIndex]
    if not zone then
        return false, "Invalid harvest zone"
    end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local distance = #(coords - zone.coords)
    
    if distance > zone.radius + 5.0 then
        return false, "Too far from harvest zone"
    end
    
    local cooldownKey = "weed_" .. zoneIndex .. "_" .. source
    if cooldowns[cooldownKey] and cooldowns[cooldownKey] > os.time() then
        local remaining = cooldowns[cooldownKey] - os.time()
        return false, "Cooldown: " .. remaining .. " seconds remaining"
    end
    
    local amount = math.random(zone.amount.min, zone.amount.max)
    exports.ox_inventory:AddItem(source, "weed_nug", amount)
    
    cooldowns[cooldownKey] = os.time() + zone.cooldown
    
    local resourceName = GetCurrentResourceName()
    exports[resourceName]:LogHarvest(source, "weed_nug", amount, zone.name)
    
    return true, amount
end)

lib.callback.register('drugs:server:processWeed', function(source, locationIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    if not locationIndex or locationIndex < 1 or locationIndex > #WeedConfig.ProcessingLocations then
        return false, "Invalid location"
    end
    
    for _, tool in ipairs(WeedConfig.Tools) do
        local hasTool = exports.ox_inventory:GetItem(source, tool, nil, true)
        if not hasTool or hasTool < 1 then
            return false, "You need " .. tool .. " to process weed"
        end
    end
    
    for _, ingredient in ipairs(WeedConfig.Ingredients) do
        local hasItem = exports.ox_inventory:GetItem(source, ingredient.item, nil, true)
        if not hasItem or hasItem < ingredient.amount then
            return false, "Not enough " .. ingredient.item
        end
    end
    
    for _, ingredient in ipairs(WeedConfig.Ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount)
    end
    
    local amount = math.random(WeedConfig.BatchAmount.min, WeedConfig.BatchAmount.max)
    exports.ox_inventory:AddItem(source, "bagged_weed", amount)
    
    local resourceName = GetCurrentResourceName()
    local locationName = WeedConfig.ProcessingLocations[locationIndex].name
    exports[resourceName]:LogProcessing(source, "weed", "weed_nug", WeedConfig.Ingredients[1].amount, "bagged_weed", amount, locationName)
    
    return true, amount
end)
