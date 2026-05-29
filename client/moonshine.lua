local MoonshineConfig = Config.Moonshine
local isHarvesting = false
local isCrafting = false
local stillProps = {}
local zones = {}

local function CreateMoonshineZones()
    for resourceType, zone in pairs(MoonshineConfig.HarvestZones) do
        local zoneId = exports.ox_target:addSphereZone({
            coords = zone.coords,
            radius = zone.radius,
            debug = Config.Debug,
            options = {
                {
                    name = 'moonshine_harvest_' .. resourceType,
                    label = zone.label,
                    icon = 'fa-solid fa-seedling',
                    onSelect = function()
                        HarvestMoonshineResource(resourceType)
                    end
                }
            }
        })
        zones['harvest_' .. resourceType] = zoneId
    end
end

local function CreateCraftingStill(locationIndex, location)
    local model = type(MoonshineConfig.Prop) == "function" and MoonshineConfig.Prop() or MoonshineConfig.Prop
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    local coords = location.coords
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, false)
    local spawnZ = found and groundZ or coords.z
    
    local still = CreateObject(model, coords.x, coords.y, spawnZ, false, false, false)
    PlaceObjectOnGroundProperly(still)
    if location.heading then
        SetEntityHeading(still, location.heading)
    end
    FreezeEntityPosition(still, true)
    SetEntityVisible(still, true, false)
    SetEntityAsMissionEntity(still, true, true)
    SetModelAsNoLongerNeeded(model)
    
    if Config.Debug then
        print(string.format("[Moonshine] Spawned still at %s: %.2f, %.2f, %.2f", location.name, coords.x, coords.y, spawnZ))
    end
    
    stillProps[locationIndex] = still
    
    exports.ox_target:addLocalEntity(still, {
        {
            name = 'moonshine_craft_' .. locationIndex,
            label = 'Craft Moonshine',
            icon = 'fa-solid fa-whiskey-bottle',
            onSelect = function()
                StartMoonshineCraft(locationIndex)
            end
        }
    })
end

function StartMoonshineCraft(locationIndex)
    if isCrafting then
        lib.notify({ title = 'Moonshine', description = 'Already crafting', type = 'error' })
        return
    end
    
    isCrafting = true
    
    local success, result = lib.callback.await('drugs:server:craftMoonshine', false, locationIndex)
    
    if not success then
        lib.notify({ title = 'Moonshine', description = result, type = 'error' })
        isCrafting = false
        return
    end
    
    local craftingTime = MoonshineConfig.CraftTime
    
    if lib.progressCircle({
        duration = craftingTime * 1000,
        position = 'bottom',
        label = 'Adding Ingredients to Still...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'timetable@ron@ig_4_smoking_meth', clip = 'chefiscookingup' }
    }) then
        lib.notify({ title = 'Moonshine', description = 'Crafted ' .. result .. ' bottles of Moonshine!', type = 'success' })
    else
        lib.notify({ title = 'Moonshine', description = 'Crafting cancelled', type = 'error' })
    end
    
    isCrafting = false
end

function HarvestMoonshineResource(resourceType)
    if isHarvesting then
        lib.notify({ title = 'Harvesting', description = 'Already harvesting', type = 'error' })
        return
    end
    
    isHarvesting = true
    
    local zone = MoonshineConfig.HarvestZones[resourceType]
    
    if lib.progressCircle({
        duration = 5000,
        position = 'bottom',
        label = zone.label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' }
    }) then
        local success, result = lib.callback.await('drugs:server:harvestMoonshine', false, resourceType)
        
        if success then
            lib.notify({ title = 'Harvested', description = 'Collected ' .. result .. ' items', type = 'success' })
        else
            lib.notify({ title = 'Harvest Failed', description = result, type = 'error' })
        end
    end
    
    isHarvesting = false
end

CreateThread(function()
    Wait(1000)
    CreateMoonshineZones()
    
    if MoonshineConfig.CraftingLocations then
        for i, location in ipairs(MoonshineConfig.CraftingLocations) do
            CreateCraftingStill(i, location)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, prop in pairs(stillProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    
    for _, zoneId in pairs(zones) do
        exports.ox_target:removeZone(zoneId)
    end
end)
