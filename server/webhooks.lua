local Webhooks = {
    Selling = "",

    Weed = "",
    Cocaine = "",
    Meth = "",
    Crack = "",
    Moonshine = "",

    Farming = "",

    General = ""
}

local WebhookColors = {
    green = 3066993,
    red = 15158332,
    blue = 3447003,
    yellow = 15844367,
    purple = 10181046,
    orange = 15105570
}

local function SendWebhook(webhookUrl, title, description, color, fields)
    if not webhookUrl or webhookUrl == "" then return end

    local embed = {
        {
            title = title,
            description = description,
            color = color or WebhookColors.blue,
            footer = {
                text = os.date("%Y-%m-%d %H:%M:%S"),
                icon_url = "https://via.placeholder.com/20"
            }
        }
    }

    if fields then
        embed[1].fields = fields
    end

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, "POST", json.encode({
        username = "Drug System",
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end

local function GetPlayerInfo(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return nil end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    return {
        name = Player.PlayerData.name or "Unknown",
        citizenid = Player.PlayerData.citizenid or "Unknown",
        identifier = Player.PlayerData.license or "Unknown",
        coords = string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z)
    }
end

exports("LogSale", function(source, itemName, amount, price, drugType, alerted)
    local info = GetPlayerInfo(source)
    if not info then return end

    local fields = {
        { name = "Player", value = info.name, inline = true },
        { name = "Citizen ID", value = info.citizenid, inline = true },
        { name = "Item", value = itemName, inline = true },
        { name = "Amount", value = tostring(amount), inline = true },
        { name = "Price", value = "$" .. price, inline = true },
        { name = "Police Alerted", value = alerted and "Yes" or "No", inline = true },
        { name = "Location", value = info.coords, inline = false }
    }

    SendWebhook(Webhooks.Selling, "Drug Sale", string.format("%s sold %sx %s for $%s", info.name, amount, itemName, price), WebhookColors.green, fields)
end)

exports("LogProcessing", function(source, drugType, inputItem, inputAmount, outputItem, outputAmount, location)
    local info = GetPlayerInfo(source)
    if not info then return end

    local webhookUrl = Webhooks[drugType:gsub("^%l", string.upper)] or Webhooks.General

    local fields = {
        { name = "Player", value = info.name, inline = true },
        { name = "Citizen ID", value = info.citizenid, inline = true },
        { name = "Input", value = string.format("%sx %s", inputAmount, inputItem), inline = true },
        { name = "Output", value = string.format("%sx %s", outputAmount, outputItem), inline = true },
        { name = "Location", value = location or info.coords, inline = false }
    }

    SendWebhook(webhookUrl, string.format("%s Processing", drugType:gsub("^%l", string.upper)), string.format("%s processed %s", info.name, drugType), WebhookColors.blue, fields)
end)

exports("LogFarming", function(source, action, plantType, coords, details)
    local info = GetPlayerInfo(source)
    if not info then return end

    local fields = {
        { name = "Player", value = info.name, inline = true },
        { name = "Citizen ID", value = info.citizenid, inline = true },
        { name = "Action", value = action, inline = true },
        { name = "Plant Type", value = plantType or "Unknown", inline = true },
        { name = "Location", value = string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z), inline = false }
    }

    if details then
        for k, v in pairs(details) do
            table.insert(fields, { name = k, value = tostring(v), inline = true })
        end
    end

    SendWebhook(Webhooks.Farming, "Farming Activity", string.format("%s: %s", action, plantType or "Unknown"), WebhookColors.yellow, fields)
end)

exports("LogMethCook", function(source, success, amount, vehicle, exploded)
    local info = GetPlayerInfo(source)
    if not info then return end

    local color = success and WebhookColors.green or WebhookColors.red
    local desc = success and string.format("%s successfully cooked %sx meth", info.name, amount) or string.format("%s failed meth cook", info.name)

    if exploded then
        desc = desc .. " (EXPLOSION!)"
    end

    local fields = {
        { name = "Player", value = info.name, inline = true },
        { name = "Citizen ID", value = info.citizenid, inline = true },
        { name = "Success", value = success and "Yes" or "No", inline = true },
        { name = "Amount", value = success and tostring(amount) or "0", inline = true },
        { name = "Vehicle", value = vehicle or "Unknown", inline = true },
        { name = "Exploded", value = exploded and "Yes" or "No", inline = true },
        { name = "Location", value = info.coords, inline = false }
    }

    SendWebhook(Webhooks.Meth, "Meth Cook", desc, color, fields)
end)

exports("LogHarvest", function(source, resourceType, amount, location)
    local info = GetPlayerInfo(source)
    if not info then return end

    local locationStr = type(location) == "string" and location or info.coords

    local fields = {
        { name = "Player", value = info.name, inline = true },
        { name = "Citizen ID", value = info.citizenid, inline = true },
        { name = "Resource", value = resourceType, inline = true },
        { name = "Amount", value = tostring(amount), inline = true },
        { name = "Location", value = locationStr, inline = false }
    }

    SendWebhook(Webhooks.General, "Resource Harvest", string.format("%s harvested %sx %s", info.name, amount, resourceType), WebhookColors.orange, fields)
end)
