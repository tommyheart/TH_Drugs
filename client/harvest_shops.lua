local HarvestProps = {}
local ShopPeds = {}

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

local function CreateBlackMarketDealer(shopName, data)
    local pedModel = type(data.ped) == "function" and data.ped() or data.ped
    local hash = type(pedModel) == "number" and pedModel or GetHashKey(pedModel)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    
    local ped = CreatePed(4, hash, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(hash)
    
    if Config.Debug then
        print(string.format("[Shop] Spawned %s dealer at: %.2f, %.2f, %.2f", shopName, data.coords.x, data.coords.y, data.coords.z))
    end
    
    ShopPeds[shopName] = ped
    
    local options = {}
    for _, item in ipairs(data.items) do
        table.insert(options, {
            name = "buy_" .. item.name,
            label = "Buy " .. item.label .. " ($" .. item.price .. ")",
            icon = "fa-solid fa-cart-shopping",
            onSelect = function()
                BuyItem(shopName, item)
            end
        })
    end
    
    exports.ox_target:addLocalEntity(ped, options)
end

function BuyItem(shopName, item)
    local input = lib.inputDialog("Buy " .. item.label, {
        { type = "number", label = "Quantity", default = 1, min = 1, max = 50 }
    })
    
    if not input then return end
    
    local quantity = input[1]
    local totalPrice = item.price * quantity
    
    local success, msg = lib.callback.await("drugs:server:buyFromShop", false, shopName, item.name, quantity, totalPrice)
    
    if success then
        lib.notify({ title = "Shop", description = "Bought " .. quantity .. "x " .. item.label, type = "success" })
    else
        lib.notify({ title = "Error", description = msg or "Purchase failed", type = "error" })
    end
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
    
    if Config.BlackMarkets then
        for shopName, data in pairs(Config.BlackMarkets) do
            CreateBlackMarketDealer(shopName, data)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, prop in pairs(HarvestProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    
    for _, ped in pairs(ShopPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
