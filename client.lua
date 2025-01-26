local isNearNPC = false

Citizen.CreateThread(function()
    -- Crear el NPC
    RequestModel(GetHashKey(Config.NPCModel))
    while not HasModelLoaded(GetHashKey(Config.NPCModel)) do
        Wait(1)
    end

    local npc = CreatePed(4, GetHashKey(Config.NPCModel), Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z - 1.0, Config.NPCRotation, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports["qb-target"]:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                event = "qb-cocinero:showMenu",
                icon = "fas fa-utensils",
                label = "Hablar con el Cocinero"
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent("qb-cocinero:showMenu")
AddEventHandler("qb-cocinero:showMenu", function()
    local menuOptions = {
        {
            header = "Menú del Cocinero",
            isMenuHeader = true -- Encabezado del menú
        },
        {
            header = "Chuleta de ciervo",
            txt = "1x Carne Cruda",
            params = {
                event = "qb-cocinero:showIngredients"
            }
        },
        {
            header = "Cocinar Carne",
            txt = "Convertir carne cruda en carne cocida",
            params = {
                event = "qb-cocinero:startCooking"
            }
        }
    }
    exports['qb-menu']:openMenu(menuOptions)
end)

RegisterNetEvent("qb-cocinero:startCooking")
AddEventHandler("qb-cocinero:startCooking", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local distance = #(coords - Config.NPCLocation)

    if distance < 2.5 then
        TriggerServerEvent("qb-cocinero:cookMeat")
    else
        QBCore.Functions.Notify("No estás cerca del cocinero.", "error")
    end
end)

RegisterNetEvent("qb-cocinero:showIngredients")
AddEventHandler("qb-cocinero:showIngredients", function()
    QBCore.Functions.Notify("Necesitas: 1x Carne Cruda para cocinar.", "info")
end)
