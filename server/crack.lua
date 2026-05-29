local CrackConfig = Config.Crack

lib.callback.register('drugs:server:processCrack', function(source, locationIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    if not locationIndex or locationIndex < 1 or locationIndex > #CrackConfig.ProcessingLocations then
        return false, "Invalid location"
    end
    
    for _, ingredient in ipairs(CrackConfig.Ingredients) do
        local hasItem = exports.ox_inventory:GetItem(source, ingredient.item, nil, true)
        if not hasItem or hasItem < ingredient.amount then
            return false, "Not enough " .. ingredient.item
        end
    end
    
    for _, ingredient in ipairs(CrackConfig.Ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount)
    end
    
    local amount = math.random(CrackConfig.BatchAmount.min, CrackConfig.BatchAmount.max)
    exports.ox_inventory:AddItem(source, "crack", amount)
    
    local resourceName = GetCurrentResourceName()
    local locationName = CrackConfig.ProcessingLocations[locationIndex].name
    exports[resourceName]:LogProcessing(source, "crack", "cocaine_powder", CrackConfig.Ingredients[1].amount, "crack", amount, locationName)
    
    return true, amount
end)
