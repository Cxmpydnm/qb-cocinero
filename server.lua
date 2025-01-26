-- server.lua
QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-cocinero:cookMeat")
AddEventHandler("qb-cocinero:cookMeat", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.GetItemByName(Config.RawMeatItem) then
        local rawMeatCount = Player.Functions.GetItemByName(Config.RawMeatItem).amount

        if rawMeatCount >= Config.RequiredQuantity then
            Player.Functions.RemoveItem(Config.RawMeatItem, Config.RequiredQuantity)
            Player.Functions.AddItem(Config.CookedMeatItem, Config.GiveQuantity)
            TriggerClientEvent("QBCore:Notify", src, "Has cocinado carne exitosamente.", "success")
        else
            TriggerClientEvent("QBCore:Notify", src, "No tienes suficiente carne cruda.", "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "No tienes carne cruda.", "error")
    end
end)
