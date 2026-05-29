local isProcessing = false

local function SetupHarvestZones()
    for i, zone in ipairs(Config.Meth.HarvestZones) do
        exports.ox_target:addSphereZone({
            name = "meth_harvest_" .. i,
            coords = zone.coords,
            radius = zone.radius,
            options = {
                {
                    name = "harvest_acetone",
                    label = zone.label,
                    icon = "fa-solid fa-droplet",
                    onSelect = function()
                        HarvestAcetone(zone)
                    end
                }
            }
        })
        if Config.Debug then
            print("[Meth Debug] Created harvest zone at", zone.name)
        end
    end
end

function HarvestAcetone(zone)
    lib.callback("drugs:server:harvestAcetone", false, function(success, message)
        if success then
            lib.notify({ title = "Meth", description = "Collected acetone", type = "success" })
        else
            lib.notify({ title = "Meth", description = message or "Cannot harvest", type = "error" })
        end
    end, zone.name)
end

local function SetupProcessingZones()
    for i, location in ipairs(Config.Meth.ProcessingLocations) do
        exports.ox_target:addSphereZone({
            name = "meth_processing_" .. i,
            coords = location.coords,
            radius = location.radius,
            options = {
                {
                    name = "process_meth",
                    label = "Cook Meth",
                    icon = "fa-solid fa-flask",
                    onSelect = function()
                        if isProcessing then
                            lib.notify({ title = "Meth", description = "Already processing", type = "error" })
                            return
                        end
                        StartMethProcess(location)
                    end
                }
            }
        })
        if Config.Debug then
            print("[Meth Debug] Created processing zone at", location.name)
        end
    end
end

function StartMethProcess(location)
    isProcessing = true
    
    local success, message = lib.callback.await("drugs:server:startMethProcess", false, location.name)
    
    if not success then
        lib.notify({ title = "Meth", description = message or "Cannot start cooking", type = "error" })
        isProcessing = false
        return
    end
    
    if lib.progressCircle({
        duration = Config.Meth.ProcessingTime * 1000,
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "anim@heists@meth@lab", clip = "idle_a" }
    }) then
        local complete, result, amount = lib.callback.await("drugs:server:completeMethProcess", false, location.name)
        
        if complete then
            lib.notify({ title = "Meth", description = "Cooked " .. amount .. " meth!", type = "success" })
        else
            lib.notify({ title = "Meth", description = result or "Processing failed", type = "error" })
        end
    else
        lib.callback.await("drugs:server:cancelMethProcess", false)
        lib.notify({ title = "Meth", description = "Cooking cancelled", type = "warning" })
    end
    
    isProcessing = false
end

CreateThread(function()
    Wait(1000)
    SetupHarvestZones()
    SetupProcessingZones()
end)
