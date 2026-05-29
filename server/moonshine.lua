local MoonshineConfig = Config.Moonshine

local function GetDrugType(itemName)
    if itemName == "shine" then
        return "moonshine"
    end
    return nil
end

lib.callback.register('drugs:server:craftMoonshine', function(source, locationIndex)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    for _, ingredient in ipairs(MoonshineConfig.Ingredients) do
        local hasItem = exports.ox_inventory:GetItem(source, ingredient.item, nil, true)
        if not hasItem or hasItem < ingredient.amount then
            return false, "Not enough " .. ingredient.item
        end
    end
    
    for _, ingredient in ipairs(MoonshineConfig.Ingredients) do
        exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.amount)
    end
    
    local amount = math.random(MoonshineConfig.BatchAmount.min, MoonshineConfig.BatchAmount.max)
    exports.ox_inventory:AddItem(source, "shine", amount)
    
    exports['' .. GetCurrentResourceName()]:LogProcessing(source, 'moonshine', amount, 'shine')
    
    return true, amount
end)

lib.callback.register('drugs:server:harvestMoonshine', function(source, resourceType)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local harvestZone = MoonshineConfig.HarvestZones[resourceType]
    if not harvestZone then
        return false, "Invalid resource type"
    end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local distance = #(coords - harvestZone.coords)
    
    if distance > harvestZone.radius + 5.0 then
        return false, "Too far from harvest zone"
    end
    
    local amount = math.random(harvestZone.amount.min, harvestZone.amount.max)
    local itemName = "shine" .. resourceType
    
    exports.ox_inventory:AddItem(source, itemName, amount)
    
    return true, amount
end)
