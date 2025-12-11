Config.Servicing = {
suspension = {
enableDamage = true,
lifespanInKm = 1000,
itemName = "suspension_parts",
itemQuantity = 1
},
tyres = {
enableDamage = true,
lifespanInKm = 250,
itemName = "tyre_replacement",
itemQuantity = 4
},
brakePads = {
enableDamage = true,
lifespanInKm = 500,
itemName = "brakepad_replacement",
itemQuantity = 4
},
--
-- Combustion engines only
--
engineOil = {
enableDamage = true,
lifespanInKm = 100,
itemName = "engine_oil",
itemQuantity = 1,
restricted = "combustion",
},
clutch = {
enableDamage = true,
lifespanInKm = 500,
itemName = "clutch_replacement",
itemQuantity = 1,
restricted = "combustion",
},
airFilter = {
enableDamage = true,
lifespanInKm = 250,
itemName = "air_filter",
itemQuantity = 1,
restricted = "combustion",
},
sparkPlugs = {
enableDamage = true,
lifespanInKm = 150,
itemName = "spark_plug",
itemQuantity = 4,
restricted = "combustion",
},
--
-- Electric vehicles only
--
evMotor = {
enableDamage = true,
electric = true,
lifespanInKm = 2000,
itemName = "ev_motor",
itemQuantity = 1,
restricted = "electric",
},
evBattery = {
enableDamage = true,
electric = true,
lifespanInKm = 500,
itemName = "ev_battery",
itemQuantity = 1,
restricted = "electric",
},
evCoolant = {
enableDamage = true,
electric = true,
lifespanInKm = 250,
itemName = "ev_coolant",
itemQuantity = 1,
restricted = "electric",
}
}