local CrackConfig = Config.Crack
local isProcessing = false
local zones = {}

function StartCrackProcessing()
    if isProcessing then
        lib.notify({ title = 'Crack', description = 'Already processing', type = 'error' })
        return
    end
    
    isProcessing = true
    
    local success, result = lib.callback.await('drugs:server:processCrack', false)
    
    if not success then
        lib.notify({ title = 'Crack Processing', description = result, type = 'error' })
        isProcessing = false
        return
    end
    
    local processingTime = CrackConfig.ProcessingTime
    
    if lib.progressCircle({
        duration = processingTime * 1000,
        position = 'bottom',
        label = 'Cooking Crack...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'amb@prop_human_parking_meter@male@base', clip = 'base' }
    }) then
        lib.notify({ title = 'Crack', description = 'Processed ' .. result .. ' crack rocks!', type = 'success' })
    else
        lib.notify({ title = 'Crack', description = 'Processing cancelled', type = 'error' })
    end
    
    isProcessing = false
end

CreateThread(function()
    Wait(1000)
    for i, location in ipairs(CrackConfig.ProcessingLocations) do
        local zoneId = exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = location.radius or 2.0,
            options = {
                {
                    name = 'crack_process_' .. i,
                    label = 'Process Crack',
                    icon = 'fa-solid fa-fire',
                    items = { "cocaine_powder" },
                    onSelect = function()
                        StartCrackProcessing()
                    end
                }
            }
        })
        zones[i] = zoneId
        
        if Config.Debug then
            print(string.format("[Crack] Created zone at %s: %.2f, %.2f, %.2f (radius: %.1f)", 
                location.name, location.coords.x, location.coords.y, location.coords.z, location.radius or 2.0))
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, zoneId in pairs(zones) do
        exports.ox_target:removeZone(zoneId)
    end
end)
