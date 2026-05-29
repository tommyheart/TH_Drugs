lib.callback.register("drugs:server:harvestResource", function(source, zoneName, amount)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local itemName = "shine" .. zoneName
    
    if not exports.ox_inventory:Items(itemName) then
        return false, "Invalid resource type"
    end
    
    exports.ox_inventory:AddItem(source, itemName, amount)
    
    return true
end)
