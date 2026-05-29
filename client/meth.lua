local CookActive = false
local showingPrompt = false
local methPrompt = nil

local function IsMethVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    for _, v in ipairs(Config.Meth.Vehicles) do
        if model == v then
            return true
        end
    end
    return false
end

local function IsInBackSeat(vehicle)
    local ped = PlayerPedId()
    for i = 1, GetVehicleMaxNumberOfPassengers(vehicle) do
        if GetPedInVehicleSeat(vehicle, i - 1) == ped then
            return true
        end
    end
    return false
end

local function RunSkillCheck()
    local successCount = 0
    local failCount = 0
    local maxFails = 3
    local requiredSuccess = Config.Meth.SkillCheckCount
    
    for i = 1, requiredSuccess + 10 do
        if successCount >= requiredSuccess then
            break
        end
        
        local keyIndex = math.random(1, 4)
        local key = Config.Meth.SkillCheckKeys[keyIndex]
        
        local success = lib.skillCheck(
            { Config.Meth.SkillCheckSpeed },
            { key }
        )
        
        if success then
            successCount = successCount + 1
            lib.notify({ title = "Meth Cooking", description = "Success! (" .. successCount .. "/" .. requiredSuccess .. ")", type = "success" })
        else
            failCount = failCount + 1
            lib.notify({ title = "Meth Cooking", description = "Failed! (" .. failCount .. "/" .. maxFails .. ")", type = "error" })
            if failCount >= maxFails then
                return false
            end
        end
        
        Wait(100)
    end
    
    return successCount >= requiredSuccess
end

local function StartMethCook()
    if CookActive then
        lib.notify({ title = "Error", description = "Already cooking", type = "error" })
        return
    end
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or not IsMethVehicle(vehicle) then
        lib.notify({ title = "Error", description = "Must be in a Journey or Camper", type = "error" })
        return
    end
    
    if not IsInBackSeat(vehicle) then
        lib.notify({ title = "Error", description = "Must be in the back seat to cook", type = "error" })
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    
    local canStart, msg = lib.callback.await("drugs:server:startMethCook", false, netId)
    if not canStart then
        lib.notify({ title = "Error", description = msg or "Cannot start cooking", type = "error" })
        return
    end
    
    CookActive = true
    
    lib.notify({ title = "Meth", description = "Stage 1: Mixing chemicals...", type = "info" })
    
    local stage1Success = RunSkillCheck()
    if not stage1Success then
        local result, err = lib.callback.await("drugs:server:completeMethStage", false, 1, false)
        CookActive = false
        return
    end
    
    local stage1Result, stage1Msg = lib.callback.await("drugs:server:completeMethStage", false, 1, true)
    if not stage1Result then
        if stage1Msg == "EXPLOSION" then
            lib.notify({ title = "Meth", description = "The lab exploded!", type = "error" })
        else
            lib.notify({ title = "Error", description = stage1Msg or "Stage 1 failed", type = "error" })
        end
        CookActive = false
        return
    end
    
    lib.notify({ title = "Meth", description = "Stage 2: Heating mixture...", type = "info" })
    
    local stage2Success = RunSkillCheck()
    if not stage2Success then
        local result, err = lib.callback.await("drugs:server:completeMethStage", false, 2, false)
        CookActive = false
        return
    end
    
    local stage2Result, stage2Msg = lib.callback.await("drugs:server:completeMethStage", false, 2, true)
    if not stage2Result then
        if stage2Msg == "EXPLOSION" then
            lib.notify({ title = "Meth", description = "The lab exploded!", type = "error" })
        else
            lib.notify({ title = "Error", description = stage2Msg or "Stage 2 failed", type = "error" })
        end
        CookActive = false
        return
    end
    
    lib.notify({ title = "Meth", description = "Stage 3: Cooling process...", type = "info" })
    
    local stage3Success = RunSkillCheck()
    if not stage3Success then
        local result, err = lib.callback.await("drugs:server:completeMethStage", false, 3, false)
        CookActive = false
        return
    end
    
    local stage3Result, stage3Msg = lib.callback.await("drugs:server:completeMethStage", false, 3, true)
    if not stage3Result then
        if stage3Msg == "EXPLOSION" then
            lib.notify({ title = "Meth", description = "The lab exploded!", type = "error" })
        else
            lib.notify({ title = "Error", description = stage3Msg or "Stage 3 failed", type = "error" })
        end
        CookActive = false
        return
    end
    
    lib.notify({ title = "Meth", description = "Stage 4: Crystallization...", type = "info" })
    
    local stage4Success = RunSkillCheck()
    if not stage4Success then
        local result, err = lib.callback.await("drugs:server:completeMethStage", false, 4, false)
        CookActive = false
        return
    end
    
    local complete, msg, amount = lib.callback.await("drugs:server:completeMethStage", false, 4, true)
    CookActive = false
    
    if complete then
        lib.notify({ title = "Meth", description = "Cook complete! Produced " .. amount .. " meth", type = "success" })
    else
        if msg == "EXPLOSION" then
            lib.notify({ title = "Meth", description = "The lab exploded!", type = "error" })
        else
            lib.notify({ title = "Error", description = msg or "Cook failed", type = "error" })
        end
    end
end

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and IsMethVehicle(vehicle) and IsInBackSeat(vehicle) and not CookActive then
            if IsControlJustPressed(0, 38) then
                StartMethCook()
            end
            
            if not showingPrompt then
                lib.showTextUI("[E] Start Cooking Meth", {
                    position = "left-center",
                    icon = "fa-solid fa-flask"
                })
                showingPrompt = true
            end
        else
            if showingPrompt then
                lib.hideTextUI()
                showingPrompt = false
            end
        end
        
        if CookActive then
            local currentVehicle = GetVehiclePedIsIn(ped, false)
            if not currentVehicle or currentVehicle ~= vehicle then
                CookActive = false
                lib.notify({ title = "Meth", description = "Cook interrupted - left vehicle", type = "error" })
            end
        end
    end
end)
