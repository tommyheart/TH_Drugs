local function HasSellableDrugs()
    local sellable = lib.callback.await("drugs:server:getSellableItems", false)
    return sellable and #sellable > 0
end

exports.ox_target:addGlobalPed({
    {
        name = "sell_drugs_to_npc",
        label = "Offer Drugs",
        icon = "fa-solid fa-pills",
        distance = 2.0,
        canInteract = function(entity)
            if IsPedAPlayer(entity) then return false end
            return HasSellableDrugs()
        end,
        onSelect = function(data)
            local policeCount = lib.callback.await("drugs:server:getPoliceCount", false)
            
            if policeCount < Config.Police.MinimumOnDuty then
                lib.notify({ 
                    title = "Drug Selling", 
                    description = "Not enough police on duty (need " .. Config.Police.MinimumOnDuty .. ")", 
                    type = "error" 
                })
                return
            end
            
            if lib.progressCircle({
                duration = 2000,
                position = "bottom",
                label = "Offering drugs...",
                useWhileDead = false,
                canCancel = true,
                disable = { move = true }
            }) then
                local sellable = lib.callback.await("drugs:server:getSellableItems", false)
                
                if sellable and #sellable > 0 then
                    local options = {}
                    for _, item in ipairs(sellable) do
                        table.insert(options, {
                            title = item.label,
                            description = "Amount: " .. item.count .. " | Price: $" .. item.priceMin .. "-$" .. item.priceMax,
                            icon = "fa-solid fa-cannabis",
                            onSelect = function()
                                local input = lib.inputDialog("Sell " .. item.label, {
                                    { type = "number", label = "Amount to sell", default = 1, min = 1, max = item.count }
                                })
                                
                                if input then
                                    local amount = tonumber(input[1])
                                    
                                    if lib.progressCircle({
                                        duration = 3000,
                                        position = "bottom",
                                        label = "Selling drugs...",
                                        useWhileDead = false,
                                        canCancel = true,
                                        disable = { move = true, car = true }
                                    }) then
                                        local success, result, alerted, xp = lib.callback.await("drugs:server:sellDrug", false, item.name, amount)
                                        
                                        if success then
                                            lib.notify({ title = "Selling", description = "Sold for $" .. result .. " (+" .. xp .. " XP)", type = "success" })
                                            if alerted then
                                                lib.notify({ title = "Warning", description = "Police have been alerted!", type = "warning" })
                                            end
                                        else
                                            lib.notify({ title = "Error", description = result or "Sale failed", type = "error" })
                                        end
                                    end
                                end
                            end
                        })
                    end
                    
                    lib.registerContext({
                        id = "drug_selling_menu",
                        title = "Sell Drugs",
                        options = options
                    })
                    lib.showContext("drug_selling_menu")
                else
                    lib.notify({ title = "Error", description = "No drugs to sell", type = "error" })
                end
            end
        end
    }
})
