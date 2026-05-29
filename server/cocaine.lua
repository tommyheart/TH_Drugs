local CocaineConfig = Config.Cocaine
local cooldowns = {}

lib.callback.register('drugs:server:harvestCocaine', function(source, zoneIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local zone = CocaineConfig.HarvestZones[zoneIndex]
    if not zone then
        return false, "Invalid harvest zone"
    end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local distance = #(coords - zone.coords)
    
    if distance > zone.radius + 5.0 then
        return false, "Too far from harvest zone"
    end
    
    local cooldownKey = "cocaine_" .. zoneIndex .. "_" .. source
    if cooldowns[cooldownKey] and cooldowns[cooldownKey] > os.time() then
        local remaining = cooldowns[cooldownKey] - os.time()
        return false, "Cooldown: " .. remaining .. " seconds remaining"
    end
    
    local amount = math.random(zone.amount.min, zone.amount.max)
    exports.ox_inventory:AddItem(source, "cocaine_leaf", amount)
    
    cooldowns[cooldownKey] = os.time() + zone.cooldown
    
    local resourceName = GetCurrentResourceName()
    exports[resourceName]:LogHarvest(source, "cocaine_leaf", amount, zone.name)
    
    return true, amount
end)

lib.callback.register('drugs:server:processCocaine', function(source, locationIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    if not locationIndex or locationIndex < 1 or locationIndex > #CocaineConfig.ProcessingLocations then
        return false, "Invalid location"
    end
    
    for _, tool in ipairs(CocaineConfig.Tools) do
        local hasTool = exports.ox_inventory:GetItem(source, tool, nil, true)
        if not hasTool or hasTool < 1 then
            return false, "You need " .. tool .. " to process cocaine"
        end
    end
    
    for _, ingredient in ipairs(CocaineConfig.Ingredients) do
        local hasItem = exports.ox_inventory:GetItem(source, ingredient.item, nil, true)
        if not hasItem or hasItem < ingredient.amount then
            return false, "Not enough " .. ingredient.item
        end
    end
    
    for _, ingredient in ipairs(CocaineConfig.Ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount)
    end
    
    local amount = math.random(CocaineConfig.BatchAmount.min, CocaineConfig.BatchAmount.max)
    exports.ox_inventory:AddItem(source, "cocaine", amount)
    
    local resourceName = GetCurrentResourceName()
    local locationName = CocaineConfig.ProcessingLocations[locationIndex].name
    exports[resourceName]:LogProcessing(source, "cocaine", "cocaine_leaf", CocaineConfig.Ingredients[1].amount, "cocaine", amount, locationName)
    
    return true, amount
end)
