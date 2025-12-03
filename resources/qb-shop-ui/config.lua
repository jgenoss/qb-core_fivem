Config = {}

-- Recurso de inventario para imágenes
Config.InventoryResource = 'qb-inventory'

-- Tabla de la base de datos (debe coincidir con qb-advanced-shops)
Config.ShopsTable = 'server_shops_v3'

-- Categorías de items (auto-clasificación)
Config.ItemCategories = {
    { id = "food", label = "Comida", icon = "utensils", keywords = {"tosti", "sandwich", "twerks", "snikkel", "bread", "baguette"} },
    { id = "drink", label = "Bebidas", icon = "wine-bottle", keywords = {"water", "coffee", "cola", "kurkakola", "beer", "whiskey", "vodka", "wine", "grape"} },
    { id = "weapons", label = "Armas", icon = "gun", keywords = {"weapon_pistol", "weapon_smg", "weapon_assault", "weapon_shotgun", "weapon_sniper", "weapon_revolver"} },
    { id = "melee", label = "Melee", icon = "gavel", keywords = {"weapon_knife", "weapon_bat", "weapon_hammer", "weapon_hatchet", "weapon_switchblade"} },
    { id = "ammo", label = "Munición", icon = "box", keywords = {"ammo", "clip_attachment"} },
    { id = "medical", label = "Médico", icon = "briefcase-medical", keywords = {"bandage", "firstaid", "ifaks", "painkillers", "walkstick"} },
    { id = "tools", label = "Herramientas", icon = "wrench", keywords = {"lockpick", "screwdriver", "repairkit", "drill", "advancedlockpick", "cleaningkit", "jerry_can"} },
    { id = "electronics", label = "Electrónica", icon = "mobile-alt", keywords = {"phone", "radio", "laptop", "tablet", "usb", "fitbit", "camera"} },
    { id = "illegal", label = "Ilegal", icon = "mask", keywords = {"weed", "coke", "meth", "joint", "baggy", "markedbills", "thermite", "handcuffs"} },
    { id = "mechanic", label = "Mecánico", icon = "car", keywords = {"veh_", "turbo", "engine", "brakes", "suspension", "tuner"} },
    { id = "materials", label = "Materiales", icon = "cubes", keywords = {"plastic", "metal", "copper", "iron", "steel", "glass", "aluminum"} },
    { id = "misc", label = "Otros", icon = "tag", keywords = {} }
}