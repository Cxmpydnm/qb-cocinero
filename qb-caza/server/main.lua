local QBCore = exports['qb-core']:GetCoreObject()

-- Verificar y comprar ítems
RegisterNetEvent("qb-hunting:checkAndBuyItem")
AddEventHandler("qb-hunting:checkAndBuyItem", function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasMaterials = true

    for _, material in ipairs(item.materials) do
        local count = Player.Functions.GetItemByName(material.item)
        if not count or count.amount < material.amount then
            hasMaterials = false
            TriggerClientEvent("QBCore:Notify", src, "No tienes suficiente " .. (material.item == "metalscrap" and "chatarra" or material.item == "plastic" and "plástico" or material.item), "error")
            break
        end
    end

    if hasMaterials then
        for _, material in ipairs(item.materials) do
            Player.Functions.RemoveItem(material.item, material.amount)
        end
        Player.Functions.AddItem(item.name, 1) -- Añade el arma al inventario
        TriggerClientEvent("QBCore:Notify", src, "Has comprado un " .. item.label, "success")
    end
end)

-- Entregar carne tras despellejar
RegisterNetEvent("qb-hunting:giveReward")
AddEventHandler("qb-hunting:giveReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local reward = Config.Rewards.meat
        if reward and reward.item and reward.amount then
            Player.Functions.AddItem(reward.item, reward.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], 'add')
            TriggerClientEvent("QBCore:Notify", src, "Has recibido carne.", "success")
        else
            print("[qb-hunting] Recompensa no configurada correctamente en Config.Rewards")
        end
    end
end)
