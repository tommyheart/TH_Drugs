local DrugXP = {}

local function GetPlayerXP(citizenid)
    local result = MySQL.query.await('SELECT * FROM player_drug_xp WHERE citizenid = ?', { citizenid })
    if result and result[1] then
        return result[1]
    end
    return nil
end

local function CreatePlayerXP(citizenid)
    MySQL.insert.await('INSERT INTO player_drug_xp (citizenid, xp, level) VALUES (?, 0, 1)', { citizenid })
    return { citizenid = citizenid, xp = 0, level = 1, total_sales = 0, weed_sold = 0, cocaine_sold = 0, meth_sold = 0, crack_sold = 0, moonshine_sold = 0 }
end

local function CalculateLevel(xp)
    local levels = Config.XP.Levels
    for i = #levels, 1, -1 do
        if xp >= levels[i].xpRequired then
            return levels[i].level
        end
    end
    return 1
end

local function GetLevelUnlocks(level)
    local levels = Config.XP.Levels
    for _, levelData in ipairs(levels) do
        if levelData.level == level then
            return levelData.unlocks
        end
    end
    return { "weed" }
end

function DrugXP.GetPlayerData(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return nil end
    
    local citizenid = Player.PlayerData.citizenid
    local data = GetPlayerXP(citizenid)
    
    if not data then
        data = CreatePlayerXP(citizenid)
    end
    
    return data
end

function DrugXP.AddXP(source, amount, drugType)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end
    
    local citizenid = Player.PlayerData.citizenid
    local data = GetPlayerXP(citizenid)
    
    if not data then
        data = CreatePlayerXP(citizenid)
    end
    
    local newXP = data.xp + amount
    local newLevel = CalculateLevel(newXP)
    local leveledUp = newLevel > data.level
    
    MySQL.update.await(
        'UPDATE player_drug_xp SET xp = ?, level = ?, total_sales = total_sales + 1 WHERE citizenid = ?',
        { newXP, newLevel, citizenid }
    )
    
    if drugType then
        local column = drugType .. "_sold"
        MySQL.update.await(
            'UPDATE player_drug_xp SET ?? = ?? + 1 WHERE citizenid = ?',
            { column, column, citizenid }
        )
    end
    
    if leveledUp then
        local unlocks = GetLevelUnlocks(newLevel)
        exports.qbx_core:Notify(source, 'Drug Level Up! You are now level ' .. newLevel, 'success', 5000)
        TriggerClientEvent('drugs:client:levelUp', source, newLevel, unlocks)
    end
    
    return true, newXP, newLevel, leveledUp
end

function DrugXP.CanSellDrug(source, drugType)
    local data = DrugXP.GetPlayerData(source)
    if not data then return false, "No data found" end
    
    local unlocks = GetLevelUnlocks(data.level)
    
    for _, unlockedType in ipairs(unlocks) do
        if unlockedType == drugType then
            return true
        end
    end
    
    local requiredLevel = 1
    for _, levelData in ipairs(Config.XP.Levels) do
        for _, unlock in ipairs(levelData.unlocks) do
            if unlock == drugType then
                requiredLevel = levelData.level
                break
            end
        end
    end
    
    return false, "You need to be level " .. requiredLevel .. " to sell " .. drugType
end

function DrugXP.GetLevel(source)
    local data = DrugXP.GetPlayerData(source)
    return data and data.level or 1
end

function DrugXP.GetXP(source)
    local data = DrugXP.GetPlayerData(source)
    return data and data.xp or 0
end

function DrugXP.GetUnlocks(source)
    local data = DrugXP.GetPlayerData(source)
    if not data then return { "weed" } end
    return GetLevelUnlocks(data.level)
end

lib.callback.register('drugs:server:getPlayerXP', function(source)
    local data = DrugXP.GetPlayerData(source)
    if not data then return nil end
    
    return {
        xp = data.xp,
        level = data.level,
        total_sales = data.total_sales,
        unlocks = GetLevelUnlocks(data.level)
    }
end)

exports('GetPlayerDrugData', DrugXP.GetPlayerData)
exports('AddDrugXP', DrugXP.AddXP)
exports('CanSellDrug', DrugXP.CanSellDrug)
exports('GetDrugLevel', DrugXP.GetLevel)
exports('GetDrugXP', DrugXP.GetXP)
exports('GetDrugUnlocks', DrugXP.GetUnlocks)

print("[drugs] Drug system loaded with XP progression")
