local ActiveCooks = {}

lib.callback.register("drugs:server:startMethCook", function(source, vehicleNetId)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end
    
    if ActiveCooks[source] then
        return false, "You are already cooking"
    end
    
    local hasKit = exports.ox_inventory:GetItem(source, "meth_kit", nil, true)
    local hasCooler = exports.ox_inventory:GetItem(source, "meth_cooler", nil, true)
    local hasPseudo = exports.ox_inventory:GetItem(source, "pseudoephedrine", nil, true)
    local hasRedPowder = exports.ox_inventory:GetItem(source, "meth_redpowder", nil, true)
    local hasLithium = exports.ox_inventory:GetItem(source, "meth_lithium", nil, true)
    
    if not hasKit or hasKit < 1 then
        return false, "You need a lab kit"
    end
    if not hasCooler or hasCooler < 1 then
        return false, "You need a meth cooler"
    end
    if not hasPseudo or hasPseudo < 1 then
        return false, "You need pseudoephedrine"
    end
    if not hasRedPowder or hasRedPowder < 1 then
        return false, "You need red phosphorus"
    end
    if not hasLithium or hasLithium < 1 then
        return false, "You need lithium strips"
    end
    
    ActiveCooks[source] = {
        vehicleNetId = vehicleNetId,
        startTime = os.time(),
        stage = 1
    }
    
    return true
end)

lib.callback.register("drugs:server:completeMethStage", function(source, stage, success)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end
    
    local cook = ActiveCooks[source]
    if not cook then
        return false, "No active cook session"
    end
    
    if not success then
        ActiveCooks[source] = nil
        
        if math.random() <= Config.Meth.ExplosionChance then
            local vehicle = NetworkGetEntityFromNetworkId(cook.vehicleNetId)
            local coords = nil
            if DoesEntityExist(vehicle) then
                coords = GetEntityCoords(vehicle)
                AddExplosion(coords.x, coords.y, coords.z, 29, Config.Meth.ExplosionDamage, true, false, 0.5)
            end
            
            exports.ox_inventory:RemoveItem(source, "meth_kit", 1)
            exports.ox_inventory:RemoveItem(source, "meth_cooler", 1)
            
            local policeJobs = Config.Police.Jobs
            local alertData = {
                job_table = policeJobs,
                coords = coords,
                title = "10-70 - Explosion",
                message = "Explosion reported at location",
                flash = true,
                blip = {
                    sprite = 445,
                    scale = 1.5,
                    colour = 1,
                    flashes = true,
                    text = "Explosion"
                }
            }
            TriggerEvent("cd_dispatch:AddNotification", alertData)
            
            return false, "EXPLOSION"
        else
            lib.notify(source, { title = "Meth", description = "Process failed but avoided explosion. Try again.", type = "warning" })
            return false, "FAILED"
        end
    end
    
    cook.stage = stage + 1
    
    if cook.stage > 4 then
        exports.ox_inventory:RemoveItem(source, "pseudoephedrine", 1)
        exports.ox_inventory:RemoveItem(source, "meth_redpowder", 1)
        exports.ox_inventory:RemoveItem(source, "meth_lithium", 1)
        
        local amount = math.random(Config.Meth.SuccessAmount.min, Config.Meth.SuccessAmount.max)
        exports.ox_inventory:AddItem(source, "meth", amount)
        
        ActiveCooks[source] = nil
        
        return true, "COMPLETE", amount
    end
    
    return true
end)

lib.callback.register("drugs:server:finishMethCook", function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end
    
    local cook = ActiveCooks[source]
    if not cook then
        return false, "No active cook session"
    end
    
    local amount = math.random(Config.Meth.SuccessAmount.min, Config.Meth.SuccessAmount.max)
    exports.ox_inventory:AddItem(source, "meth", amount)
    
    exports.ox_inventory:RemoveItem(source, "pseudoephedrine", 1)
    exports.ox_inventory:RemoveItem(source, "meth_redpowder", 1)
    exports.ox_inventory:RemoveItem(source, "meth_lithium", 1)
    
    ActiveCooks[source] = nil
    
    return true, amount
end)
