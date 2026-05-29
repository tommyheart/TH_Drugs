local HarvestProps = {}

local function CreateHarvestProp(zoneName, data)
    local model = type(data.prop) == "function" and data.prop() or data.prop
    if not model then return end
    
    local hash = type(model) == "number" and model or GetHashKey(model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    
    local coords = data.coords
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, false)
    local spawnZ = found and groundZ or coords.z
    
    local prop = CreateObject(hash, coords.x, coords.y, spawnZ, false, false, false)
    PlaceObjectOnGroundProperly(prop)
    SetEntityAsMissionEntity(prop, true, true)
    FreezeEntityPosition(prop, true)
    SetEntityVisible(prop, true, false)
    SetModelAsNoLongerNeeded(hash)
    
    if Config.Debug then
        print(string.format("[Harvest] Spawned %s prop at: %.2f, %.2f, %.2f", zoneName, coords.x, coords.y, spawnZ))
    end
    
    HarvestProps[zoneName] = prop
    
    exports.ox_target:addLocalEntity(prop, {
        {
            name = "harvest_" .. zoneName,
            label = data.label,
            icon = "fa-solid fa-hand-holding-seedling",
            distance = 3.0,
            onSelect = function()
                HarvestResource(zoneName, data)
            end
        }
    })
end

function HarvestResource(zoneName, data)
    if lib.progressCircle({
        duration = 5000,
        position = "bottom",
        label = data.label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = "amb@world_human_gardener_plant@male@base", clip = "base" }
    }) then
        local amount = math.random(data.amount.min, data.amount.max)
        local success, msg = lib.callback.await("drugs:server:harvestResource", false, zoneName, amount)
        
        if success then
            lib.notify({ title = "Harvest", description = "Harvested " .. amount .. "x", type = "success" })
        else
            lib.notify({ title = "Error", description = msg or "Harvest failed", type = "error" })
        end
    end
end

CreateThread(function()
    Wait(1000)
    
    for zoneName, data in pairs(Config.Moonshine.HarvestZones) do
        CreateHarvestProp(zoneName, data)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, prop in pairs(HarvestProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
end)
