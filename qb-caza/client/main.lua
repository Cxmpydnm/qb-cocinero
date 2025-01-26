-- client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local spawnedAnimals = {}
local skinningInProgress = false -- Variable para evitar múltiples interacciones
local lastSkinningAttempt = 0 -- Tiempo del último intento de despelleje

-- Función para generar un ciervo en una posición aleatoria dentro de una zona
function SpawnDeerRandom(zone)
    RequestModel(GetHashKey(Config.AnimalModel))
    while not HasModelLoaded(GetHashKey(Config.AnimalModel)) do
        Wait(10)
    end

    local xOffset = math.random(-Config.SpawnRadius, Config.SpawnRadius)
    local yOffset = math.random(-Config.SpawnRadius, Config.SpawnRadius)
    local spawnCoords = vector3(zone.x + xOffset, zone.y + yOffset, zone.z)

    local deer = CreatePed(28, GetHashKey(Config.AnimalModel), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
    TaskWanderStandard(deer, 10.0, 10)
    SetEntityAsMissionEntity(deer, true, true)
    table.insert(spawnedAnimals, deer)
end

-- Generar ciervos aleatoriamente en las zonas de caza
CreateThread(function()
    while true do
        for _, zone in pairs(Config.HuntingZone) do
            local nearbyAnimalCount = 0

            for _, animal in pairs(spawnedAnimals) do
                if DoesEntityExist(animal) then
                    local animalCoords = GetEntityCoords(animal)
                    if #(vector3(zone.x, zone.y, zone.z) - animalCoords) < Config.SpawnRadius then
                        nearbyAnimalCount = nearbyAnimalCount + 1
                    end
                end
            end

            if nearbyAnimalCount < Config.MaxAnimals then
                SpawnDeerRandom(zone)
            end
        end

        Wait(math.random(2000, 5000)) -- Aparición más frecuente
    end
end)

-- Crear el NPC de la tienda
CreateThread(function()
    local shopNPC = Config.ShopNPC
    RequestModel(GetHashKey(shopNPC.model))

    while not HasModelLoaded(GetHashKey(shopNPC.model)) do
        Wait(10)
    end

    local npc = CreatePed(4, GetHashKey(shopNPC.model), shopNPC.coords.x, shopNPC.coords.y, shopNPC.coords.z - 1.0, shopNPC.heading, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Añadir animación al NPC
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    -- Añadir blip para el NPC
    local blip = AddBlipForCoord(shopNPC.coords.x, shopNPC.coords.y, shopNPC.coords.z)
    SetBlipSprite(blip, Config.Blips.Shop.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blips.Shop.scale)
    SetBlipColour(blip, Config.Blips.Shop.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blips.Shop.text)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                event = "qb-hunting:openShop",
                icon = "fas fa-store",
                label = "Comprar herramientas de caza",
            }
        },
        distance = 2.5
    })
end)

-- Añadir blips para las zonas de caza
CreateThread(function()
    for _, zone in ipairs(Config.Blips.HuntingZones) do
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, zone.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, zone.scale)
        SetBlipColour(blip, zone.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.text)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Abrir la tienda
RegisterNetEvent("qb-hunting:openShop")
AddEventHandler("qb-hunting:openShop", function()
    local shopItems = Config.ShopNPC.items

    local menu = {
        {
            header = "Tienda de herramientas de caza",
            isMenuHeader = true
        }
    }

    for _, item in ipairs(shopItems) do
        menu[#menu + 1] = {
            header = item.label,
            txt = "Requiere: " .. item.materials[1].amount .. " chatarra y " .. item.materials[2].amount .. " plástico",
            params = {
                event = "qb-hunting:buyItem",
                args = item
            }
        }
    end

    menu[#menu + 1] = {
        header = "Cerrar",
        txt = "Salir del menú",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

    TriggerEvent("qb-menu:client:openMenu", menu)
end)

-- Comprar un ítem
RegisterNetEvent("qb-hunting:buyItem")
AddEventHandler("qb-hunting:buyItem", function(item)
    TriggerServerEvent("qb-hunting:checkAndBuyItem", item)
end)

-- Detectar si estás cerca de un animal muerto
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local nearDeadAnimal = false
        local animalEntity = nil

        for _, animal in pairs(spawnedAnimals) do
            if DoesEntityExist(animal) and IsEntityDead(animal) then
                local animalCoords = GetEntityCoords(animal)
                local distance = #(coords - animalCoords)

                if distance < 2.0 then
                    nearDeadAnimal = true
                    animalEntity = animal
                    DrawText3D(animalCoords.x, animalCoords.y, animalCoords.z + 1.0, "[E] Despellejar")
                end
            end
        end

        if nearDeadAnimal and animalEntity ~= nil then
            if IsControlJustReleased(0, 38) then -- Tecla E
                local currentTime = GetGameTimer()
                if skinningInProgress then
                    QBCore.Functions.Notify("Ya estás despellejando un animal, espera.", "error")
                elseif currentTime - lastSkinningAttempt < 2000 then
                    QBCore.Functions.Notify("No pulses tan rápido, espera un momento.", "error")
                else
                    skinningInProgress = true -- Evitar múltiples interacciones
                    lastSkinningAttempt = currentTime
                    TriggerEvent("qb-hunting:startSkinning", animalEntity)
                end
            end
        end

        Wait(nearDeadAnimal and 0 or 500)
    end
end)

-- Despellejar animales
RegisterNetEvent("qb-hunting:startSkinning")
AddEventHandler("qb-hunting:startSkinning", function(entity)
    local playerPed = PlayerPedId()
    local weapon = GetSelectedPedWeapon(playerPed)

    if weapon == GetHashKey(Config.RequiredWeapons.knife) then
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_BUM_WASH", Config.SkinningTime * 1000, true)
        QBCore.Functions.Notify("Despellejando el animal...", "success")

        Wait(Config.SkinningTime * 1000)

        ClearPedTasksImmediately(playerPed) -- Detener la animación al finalizar
        TriggerServerEvent("qb-hunting:giveReward")
        DeleteEntity(entity)
        QBCore.Functions.Notify("Has despellejado el animal y obtenido carne.", "success")
    else
        QBCore.Functions.Notify("Necesitas un cuchillo para despellejar el animal.", "error")
    end

    skinningInProgress = false -- Permitir nuevas interacciones
end)

-- Función para dibujar texto en 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 150)
end
