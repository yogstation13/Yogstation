/obj/item/stack/scrap
	name = "scrap"
	desc = "get some help if you see this"
	icon = 'icons/obj/shipbreaking.dmi'
	icon_state = "ship_plating"
	var/point_value = 0 //how many shipbreaking points these give from recycling

/obj/item/stack/scrap/plating
	name = "ship plating"
	desc = "Rigid sheet plating used in the construction of ships."
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	point_value = 10

/obj/item/stack/scrap/electronics
	name = "scrap electronics"
	icon_state = "scrap_electronics"
	desc = "Piles of scrap electronics crowbarred out of ships. You can't seem to find the gibber board in this mess."
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT, /datum/material/gold = 100)
	point_value = 20

/obj/item/stack/scrap/framing
	name = "ship framing"
	icon_state = "ship_framing"
	desc = "Silver-Titanium alloy I-beams used in the construction of ships. Whoever designed this must have owned a silver mining planet."
	materials = list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT, /datum/material/titanium = 100)
	point_value = 30

/obj/item/stack/scrap/plasma
	name = "congealed plasma"
	icon_state = "congealed_plasma"
	desc = "A nasty bundle of congealed plasma gathered from ship innards. Nice and sticky!"
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT)
	point_value = 50

/obj/item/stack/scrap/core
	name = "ship core"
	icon_state = "ship_core"
	desc = "A radioactive core of a nuclear thruster. Make sure there's no assistants under your ship with a reciprocating saw."
	materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT, /datum/material/iron = 100)
	point_value = 45

/obj/item/stack/scrap/crystalline_matrix
	name = "crystalline matrix"
	icon_state = "crystalline_matrix"
	desc = "A crystalline matrix used in immense calculations to sheer ships. AGI by 2520!"
	materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT, /datum/material/bluespace = 100)
	point_value = 100
