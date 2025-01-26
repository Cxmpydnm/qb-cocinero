Config = {}

-- Coordenadas donde se generan los animales
Config.HuntingZone = {
    {x = -1523.77, y = 4688.45, z = 39.61},
    {x = -1468.26, y = 4741.40, z = 57.66}
}

-- Tiempo para despellejar en segundos
Config.SkinningTime = 5

-- Recompensa al despellejar
Config.Rewards = {
    meat = {item = "raw_meat", amount = 2},
}

-- Armas necesarias
Config.RequiredWeapons = {
    huntingGun = "WEAPON_MUSKET",
    knife = "WEAPON_KNIFE",
}

-- Modelo de ciervo
Config.AnimalModel = "a_c_deer"

-- Tiempo entre spawns en segundos
Config.SpawnInterval = 30 -- Ahora más frecuente

-- Configuración adicional para radio y cantidad máxima de animales
Config.SpawnRadius = 50 -- Radio de aparición en metros alrededor de cada coordenada
Config.MaxAnimals = 5 -- Número máximo de animales por zona
Config.SpawnInterval = 30 -- Intervalo de aparición en segundos

-- Coordenadas del NPC para comprar herramientas
Config.ShopNPC = {
    coords = {x = -1492.04, y = 4976.83, z = 63.62},
    heading = 50.0,
    model = "a_m_m_farmer_01",
    items = {
        {
            name = "WEAPON_MUSKET",
            label = "Mosquete",
            materials = {
                {item = "metalscrap", amount = 20},
                {item = "plastic", amount = 15}
            }
        },
        {
            name = "WEAPON_KNIFE",
            label = "Cuchillo de caza",
            materials = {
                {item = "metalscrap", amount = 10},
                {item = "plastic", amount = 5}
            }
        }
    }
}

-- Blips para las zonas de caza y el NPC
Config.Blips = {
    Shop = {
        coords = Config.ShopNPC.coords,
        sprite = 52,
        color = 1,
        scale = 0.8,
        text = "Tienda de Caza"
    },
    HuntingZones = {
        {
            coords = Config.HuntingZone[1],
            sprite = 141,
            color = 2,
            scale = 0.8,
            text = "Zona de Caza"
        },
        {
            coords = Config.HuntingZone[2],
            sprite = 141,
            color = 2,
            scale = 0.8,
            text = "Zona de Caza"
        }
    }
}
