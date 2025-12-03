Config = {}

-- Recurso de inventario
Config.InventoryResource = 'qb-inventory'
Config.ImgDirectory = "nui://"..Config.InventoryResource.."/html/images/"

-- Tipos de tienda
Config.ShopTypes = {
    { label = "Tienda General (24/7)", value = "general", icon = "fa-store" },
    { label = "Armería", value = "weapon", icon = "fa-gun" },
    { label = "Restaurante", value = "food", icon = "fa-utensils" },
    { label = "Electrónica", value = "electronics", icon = "fa-mobile-screen" },
    { label = "Ferretería", value = "hardware", icon = "fa-wrench" },
    { label = "Farmacia", value = "pharmacy", icon = "fa-pills" },
    { label = "Ilegal / Mercado Negro", value = "illegal", icon = "fa-mask" }
}

-- Categorías de items
Config.ItemCategories = {
    { id = "food", label = "Comida", keywords = {"tosti", "sandwich", "twerks", "snikkel", "bread", "baguette"} },
    { id = "drink", label = "Bebidas", keywords = {"water", "coffee", "cola", "kurkakola", "beer", "whiskey", "vodka", "wine", "grape"} },
    { id = "weapons", label = "Armas de Fuego", keywords = {"weapon_pistol", "weapon_smg", "weapon_assault", "weapon_shotgun", "weapon_sniper", "weapon_revolver"} },
    { id = "melee", label = "Armas Melee", keywords = {"weapon_knife", "weapon_bat", "weapon_hammer", "weapon_hatchet", "weapon_switchblade", "weapon_flashlight"} },
    { id = "ammo", label = "Munición", keywords = {"ammo", "clip_attachment"} },
    { id = "medical", label = "Médico", keywords = {"bandage", "firstaid", "ifaks", "painkillers", "walkstick"} },
    { id = "tools", label = "Herramientas", keywords = {"lockpick", "screwdriver", "repairkit", "drill", "advancedlockpick", "cleaningkit", "jerry_can"} },
    { id = "electronics", label = "Electrónica", keywords = {"phone", "radio", "laptop", "tablet", "usb", "fitbit", "camera"} },
    { id = "illegal", label = "Ilegal / Drogas", keywords = {"weed", "coke", "meth", "joint", "baggy", "markedbills", "thermite", "handcuffs"} },
    { id = "mechanic", label = "Piezas Mecánico", keywords = {"veh_", "turbo", "engine", "brakes", "suspension", "tuner"} },
    { id = "materials", label = "Materiales", keywords = {"plastic", "metal", "copper", "iron", "steel", "glass", "aluminum"} },
    { id = "misc", label = "Otros", keywords = {} }
}

-- 🎯 BLIPS PRESETS (Extendido y Completo)
Config.BlipPresets = {
    -- Tiendas
    { label = "Tienda 24/7 (Clásico)", sprite = 52, color = 2 },
    { label = "Tienda 24/7 (Verde)", sprite = 52, color = 25 },
    { label = "Tienda Premium", sprite = 59, color = 5 },
    { label = "Centro Comercial", sprite = 617, color = 0 },
    
    -- Armerías
    { label = "Armería AmmuNation", sprite = 110, color = 1 },
    { label = "Armería Clásica", sprite = 313, color = 1 },
    { label = "Armería Avanzada", sprite = 150, color = 6 },
    
    -- Comida & Bebida
    { label = "Restaurante", sprite = 93, color = 49 },
    { label = "Fast Food", sprite = 106, color = 46 },
    { label = "Bar/Cantina", sprite = 93, color = 48 },
    { label = "Cafetería", sprite = 52, color = 81 },
    
    -- Servicios
    { label = "Farmacia Cruz Verde", sprite = 51, color = 2 },
    { label = "Farmacia Cruz Roja", sprite = 51, color = 1 },
    { label = "Hospital", sprite = 61, color = 3 },
    { label = "Mecánico/Taller", sprite = 402, color = 46 },
    { label = "Ferretería", sprite = 446, color = 5 },
    
    -- Electrónica
    { label = "Tienda de Electrónica", sprite = 521, color = 37 },
    { label = "Computadoras", sprite = 521, color = 38 },
    
    -- Especiales/Ilegales
    { label = "Mercado Negro (Calavera)", sprite = 84, color = 1 },
    { label = "Punto de Venta (Ilegal)", sprite = 500, color = 40 },
    { label = "Contacto Discreto", sprite = 66, color = 40 },
    
    -- Otros
    { label = "Joyería", sprite = 617, color = 5 },
    { label = "Barbería", sprite = 71, color = 0 },
    { label = "Ropa", sprite = 73, color = 3 },
}

-- 🎭 MODELOS DE NPC (Extendido y Completo)
Config.PedModels = {
    {
        category = "Comerciantes Genéricos",
        peds = {
            { model = "mp_m_shopkeep_01", label = "Dependiente Hombre" },
            { model = "s_f_y_shop_low", label = "Dependiente Mujer (Básica)" },
            { model = "s_f_y_shop_mid", label = "Dependiente Mujer (Media)" },
            { model = "s_f_m_shop_high", label = "Dependiente Mujer (Elegante)" },
            { model = "mp_m_waremech_01", label = "Mecánico Almacén" },
        }
    },
    {
        category = "Armería",
        peds = {
            { model = "s_m_y_ammucity_01", label = "Vendedor AmmuNation" },
            { model = "ig_old_man1a", label = "Armero Veterano" },
            { model = "csb_customer", label = "Cliente Armería" },
        }
    },
    {
        category = "Comida y Restaurantes",
        peds = {
            { model = "u_m_y_burgerdrug_01", label = "Empleado BurgerShot" },
            { model = "s_m_m_lathandy_01", label = "Cocinero Mexicano" },
            { model = "s_f_y_waiter_01", label = "Mesera" },
            { model = "s_m_y_waiter_01", label = "Mesero" },
            { model = "s_f_y_bartender_01", label = "Cantinera" },
            { model = "s_m_m_cntrybar_01", label = "Cantinero" },
            { model = "ig_chef", label = "Chef" },
            { model = "csb_chef", label = "Chef 2" },
        }
    },
    {
        category = "Ropa y Moda",
        peds = {
            { model = "s_f_y_clubbar_01", label = "Empleada de Club" },
            { model = "ig_talina", label = "Vendedora de Moda" },
            { model = "mp_f_cocaine_01", label = "Vendedora Elegante" },
            { model = "u_f_y_princess", label = "Fashionista" },
        }
    },
    {
        category = "Negocios y Oficina",
        peds = {
            { model = "ig_bankman", label = "Banquero" },
            { model = "s_m_m_highsec_01", label = "Ejecutivo Seguridad" },
            { model = "s_m_m_highsec_02", label = "Ejecutivo Seguridad 2" },
            { model = "u_m_m_jesus_01", label = "Hombre de Negocios" },
            { model = "ig_barry", label = "Oficinista" },
        }
    },
    {
        category = "Médico y Farmacia",
        peds = {
            { model = "s_m_m_doctor_01", label = "Doctor" },
            { model = "s_f_y_scrubs_01", label = "Enfermera" },
            { model = "u_m_y_scientist_01", label = "Científico" },
        }
    },
    {
        category = "Taller y Mecánica",
        peds = {
            { model = "s_m_y_xmech_01", label = "Mecánico 1" },
            { model = "s_m_y_xmech_02", label = "Mecánico 2" },
            { model = "s_m_m_autoshop_01", label = "Mecánico Autoshop" },
            { model = "s_m_m_autoshop_02", label = "Mecánico Autoshop 2" },
        }
    },
    {
        category = "Urbano y Callejero",
        peds = {
            { model = "a_m_y_hipster_01", label = "Hipster 1" },
            { model = "a_m_y_hipster_02", label = "Hipster 2" },
            { model = "a_m_y_skater_01", label = "Skater" },
            { model = "a_m_y_downtown_01", label = "Downtown" },
            { model = "ig_claypain", label = "Hipster Barba" },
        }
    },
    {
        category = "Elegante y VIP",
        peds = {
            { model = "ig_sol", label = "Solomon (Empresario)" },
            { model = "u_m_m_aldinapoli", label = "Al Di Napoli" },
            { model = "ig_djsolmanager", label = "Manager de DJ" },
            { model = "ig_lifeinvad_01", label = "Ejecutivo Tech" },
        }
    },
    {
        category = "Asiáticos",
        peds = {
            { model = "g_m_y_korean_01", label = "Coreano 1" },
            { model = "g_m_y_korean_02", label = "Coreano 2" },
            { model = "a_f_y_eastsa_01", label = "Asiática 1" },
            { model = "a_f_y_eastsa_02", label = "Asiática 2" },
        }
    },
    {
        category = "Latinos",
        peds = {
            { model = "a_m_m_salton_01", label = "Latino 1" },
            { model = "a_m_m_salton_02", label = "Latino 2" },
            { model = "a_m_y_latino_01", label = "Latino Joven" },
            { model = "ig_rampboss_02", label = "Jefe Latino" },
        }
    },
    {
        category = "Afroamericanos",
        peds = {
            { model = "a_m_y_soucent_01", label = "South Central 1" },
            { model = "a_m_y_soucent_02", label = "South Central 2" },
            { model = "ig_d", label = "Devin Weston Asistente" },
            { model = "ig_g", label = "G (Franklin Tío)" },
        }
    },
    {
        category = "Ancianos",
        peds = {
            { model = "a_m_m_og_boss_01", label = "Jefe OG" },
            { model = "a_m_o_soucent_01", label = "Anciano South Central" },
            { model = "ig_old_man2", label = "Anciano 2" },
            { model = "u_m_o_taphillbilly", label = "Anciano Rural" },
        }
    },
    {
        category = "Especiales / Personajes",
        peds = {
            { model = "ig_talcc", label = "Taliana (Driver)" },
            { model = "ig_natalia", label = "Natalia" },
            { model = "ig_siemonyetarian", label = "Simeon" },
            { model = "csb_prolsec", label = "Guardia Prologue" },
            { model = "ig_kerrymcintosh", label = "Kerry McIntosh" },
        }
    }
}