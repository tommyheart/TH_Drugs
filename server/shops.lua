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

lib.callback.register("drugs:server:buyFromShop", function(source, shopName, itemName, quantity, totalPrice)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false, "Player not found" end
    
    local shop = Config.BlackMarkets and Config.BlackMarkets[shopName]
    if not shop then
        return false, "Shop not found"
    end
    
    local foundItem = nil
    for _, item in ipairs(shop.items) do
        if item.name == itemName then
            foundItem = item
            break
        end
    end
    
    if not foundItem then
        return false, "Item not available"
    end
    
    local cash = exports.qbx_core:GetMoney(source, "cash")
    local bank = exports.qbx_core:GetMoney(source, "bank")
    
    if cash >= totalPrice then
        exports.qbx_core:RemoveMoney(source, "cash", totalPrice, "Bought " .. quantity .. "x " .. itemName)
    elseif bank >= totalPrice then
        exports.qbx_core:RemoveMoney(source, "bank", totalPrice, "Bought " .. quantity .. "x " .. itemName)
    else
        return false, "Not enough money. Need $" .. totalPrice
    end
    
    exports.ox_inventory:AddItem(source, itemName, quantity)
    
    if Config.Debug then
        print("[Shop] Player", source, "bought", quantity, "x", itemName, "for $" .. totalPrice)
    end
    
    return true
end)

