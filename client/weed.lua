local WeedConfig = Config.Weed
local isHarvesting = false
local isProcessing = false
local harvestZones = {}
local processZones = {}
local harvestProps = {}

local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function GetRandomPositionInZone(zone)
    local angle = math.random() * 2.0 * math.pi
    local distance = math.random() * zone.radius * 0.8
    local offsetX = math.cos(angle) * distance
    local offsetY = math.sin(angle) * distance
    
    return zone.coords.x + offsetX, zone.coords.y + offsetY, zone.coords.z
end

local function SpawnSingleProp(zoneIndex, propIndex)
    local zone = WeedConfig.HarvestZones[zoneIndex]
    local propModel = WeedConfig.HarvestProp
    
    LoadModel(propModel)
    
    local x, y, z = GetRandomPositionInZone(zone)
    
    local prop = CreateObject(propModel, x, y, z, false, false, false)
    SetEntityAsMissionEntity(prop, true, false)
    FreezeEntityPosition(prop, true)
    SetEntityVisible(prop, true)
    PlaceObjectOnGroundProperly(prop)
    
    SetModelAsNoLongerNeeded(propModel)
    
    if not harvestProps[zoneIndex] then
        harvestProps[zoneIndex] = {}
    end
    
    harvestProps[zoneIndex][propIndex] = prop
    
    exports.ox_target:addLocalEntity(prop, {
        {
            name = 'weed_harvest_' .. zoneIndex .. '_' .. propIndex,
            label = zone.label,
            icon = 'fa-solid fa-cannabis',
            onSelect = function()
                HarvestWeedProp(zoneIndex, propIndex)
            end
        }
    })
    
    if Config.Debug then
        print(string.format("[Weed] Spawned prop %d in zone %d at %s", propIndex, zoneIndex, zone.name))
    end
    
    return prop
end

local function DeleteProp(zoneIndex, propIndex)
    local prop = harvestProps[zoneIndex] and harvestProps[zoneIndex][propIndex]
    
    if prop and DoesEntityExist(prop) then
        exports.ox_target:removeLocalEntity(prop, 'weed_harvest_' .. zoneIndex .. '_' .. propIndex)
        DeleteEntity(prop)
        harvestProps[zoneIndex][propIndex] = nil
        
        if Config.Debug then
            print(string.format("[Weed] Deleted prop %d in zone %d", propIndex, zoneIndex))
        end
    end
end

local function CreateHarvestProps()
    for i, zone in ipairs(WeedConfig.HarvestZones) do
        local propCount = zone.propCount or 3
        harvestProps[i] = {}
        
        for j = 1, propCount do
            SpawnSingleProp(i, j)
        end
    end
end

local function RemoveHarvestProps()
    for zoneIndex, props in pairs(harvestProps) do
        for propIndex, prop in pairs(props) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
    end
    harvestProps = {}
end

local function CreateProcessingZones()
    for i, location in ipairs(WeedConfig.ProcessingLocations) do
        local zoneId = exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = location.radius,
            debug = Config.Debug,
            options = {
                {
                    name = 'weed_process_' .. i,
                    label = 'Process Weed',
                    icon = 'fa-solid fa-cannabis',
                    items = { "weed_nug", "baggies" },
                    onSelect = function()
                        StartWeedProcessing(i)
                    end
                }
            }
        })
        processZones[i] = zoneId
        
        if Config.Debug then
            print(string.format("[Weed] Created processing zone at %s: %.2f, %.2f, %.2f", location.name, location.coords.x, location.coords.y, location.coords.z))
        end
    end
end

function HarvestWeedProp(zoneIndex, propIndex)
    if isHarvesting then
        lib.notify({ title = 'Harvesting', description = 'Already harvesting', type = 'error' })
        return
    end
    
    isHarvesting = true
    
    local zone = WeedConfig.HarvestZones[zoneIndex]
    
    if lib.progressCircle({
        duration = 5000,
        position = 'bottom',
        label = zone.label,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' }
    }) then
        local success, result = lib.callback.await('drugs:server:harvestWeed', false, zoneIndex)
        
        if success then
            lib.notify({ title = 'Harvested', description = 'Collected ' .. result .. ' weed nugs', type = 'success' })
            
            DeleteProp(zoneIndex, propIndex)
            
            Wait(500)
            
            SpawnSingleProp(zoneIndex, propIndex)
        else
            lib.notify({ title = 'Harvest Failed', description = result, type = 'error' })
        end
    end
    
    isHarvesting = false
end

function StartWeedProcessing(locationIndex)
    if isProcessing then
        lib.notify({ title = 'Weed', description = 'Already processing', type = 'error' })
        return
    end
    
    isProcessing = true
    
    local success, result = lib.callback.await('drugs:server:processWeed', false, locationIndex)
    
    if not success then
        lib.notify({ title = 'Weed Processing', description = result, type = 'error' })
        isProcessing = false
        return
    end
    
    local processingTime = WeedConfig.ProcessingTime
    
    if lib.progressCircle({
        duration = processingTime * 1000,
        position = 'bottom',
        label = 'Processing Weed...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' }
    }) then
        lib.notify({ title = 'Weed', description = 'Processed ' .. result .. ' bagged weed!', type = 'success' })
    else
        lib.notify({ title = 'Weed', description = 'Processing cancelled', type = 'error' })
    end
    
    isProcessing = false
end

CreateThread(function()
    Wait(1000)
    CreateHarvestProps()
    CreateProcessingZones()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    RemoveHarvestProps()
    for _, zoneId in pairs(processZones) do
        exports.ox_target:removeZone(zoneId)
    end
end)
