local ActiveProcesses = {}

lib.callback.register("drugs:server:harvestAcetone", function(source, zoneName)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local amount = math.random(Config.Meth.HarvestZones[1].amount.min, Config.Meth.HarvestZones[1].amount.max)
    for _, zone in ipairs(Config.Meth.HarvestZones) do
        if zone.name == zoneName then
            amount = math.random(zone.amount.min, zone.amount.max)
            break
        end
    end
    
    exports.ox_inventory:AddItem(source, "acetone", amount)
    
    if Config.Debug then
        print("[Meth Debug] Player", source, "harvested", amount, "acetone at", zoneName)
    end
    
    return true
end)

lib.callback.register("drugs:server:startMethProcess", function(source, locationName)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    if ActiveProcesses[source] then
        return false, "Already processing"
    end
    
    for _, tool in ipairs(Config.Meth.Tools) do
        local hasTool = exports.ox_inventory:GetItem(source, tool, nil, true)
        if not hasTool or hasTool < 1 then
            return false, "You need a " .. exports.ox_inventory:Items(tool).label
        end
    end
    
    for _, ingredient in ipairs(Config.Meth.Ingredients) do
        local hasItem = exports.ox_inventory:GetItem(source, ingredient.item, nil, true)
        if not hasItem or hasItem < ingredient.amount then
            return false, "You need " .. ingredient.amount .. "x " .. exports.ox_inventory:Items(ingredient.item).label
        end
    end
    
    ActiveProcesses[source] = {
        location = locationName,
        startTime = os.time()
    }
    
    return true
end)

lib.callback.register("drugs:server:completeMethProcess", function(source, locationName)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local process = ActiveProcesses[source]
    if not process then
        return false, "No active process"
    end
    
    for _, ingredient in ipairs(Config.Meth.Ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount)
    end
    
    local amount = math.random(Config.Meth.BatchAmount.min, Config.Meth.BatchAmount.max)
    exports.ox_inventory:AddItem(source, "meth", amount)
    
    exports["" .. GetCurrentResourceName() .. ""]:LogProcessing(source, "meth", locationName, amount)
    
    ActiveProcesses[source] = nil
    return true, "COMPLETE", amount
end)

lib.callback.register("drugs:server:cancelMethProcess", function(source)
    ActiveProcesses[source] = nil
    return true
end)
