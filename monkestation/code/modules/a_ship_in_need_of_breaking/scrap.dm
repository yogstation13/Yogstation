/obj/item/proc/get_shipbreaking_reward()
	return null

/obj/item/stock_parts/get_shipbreaking_reward()
	if(prob(rating * 10)) //more chance to get better things if you have a higher rating
		switch(rand(1,10))
			if(1 to 6)
				return /obj/item/stack/scrap/electronics
			if(6 to 9)
				return /obj/item/stack/scrap/plasma
			if(10)
				return /obj/item/stack/scrap/crystalline_matrix
	return /obj/item/stack/scrap/electronics

/obj/item/circuitboard/machine/get_shipbreaking_reward()
	return /obj/item/stack/scrap/electronics

/obj/item/stack/scrap
	name = "scrap"
	singular_name = "scrap"
	merge_type = /obj/item/stack/scrap
	desc = "get some help if you see this"
	icon = 'monkestation/code/modules/a_ship_in_need_of_breaking/icons/shipbreaking.dmi'
	icon_state = "ship_plating"
	var/point_value = 0 //how many shipbreaking points these give from recycling

/obj/item/stack/scrap/plating
	name = "ship plating"
	singular_name = "ship plating"
	merge_type = /obj/item/stack/scrap/plating
	desc = "Rigid sheet plating used in the construction of ships."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	point_value = 10

/obj/item/stack/scrap/electronics
	name = "scrap electronics"
	singular_name = "scrap electronic"
	merge_type = /obj/item/stack/scrap/electronics
	icon_state = "scrap_electronics"
	desc = "Piles of scrap electronics crowbarred out of ships. You can't seem to find the gibber board in this mess."
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT, /datum/material/gold = 100)
	point_value = 20

/obj/item/stack/scrap/framing
	name = "ship framing"
	singular_name = "ship framing"
	merge_type = /obj/item/stack/scrap/framing
	icon_state = "ship_framing"
	desc = "Silver-Titanium alloy I-beams used in the construction of ships. Whoever designed this must have owned a silver mining planet."
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT, /datum/material/titanium = 100)
	point_value = 30

/obj/item/stack/scrap/plasma
	name = "congealed plasma"
	singular_name = "congealed plasma"
	merge_type = /obj/item/stack/scrap/plasma
	icon_state = "congealed_plasma"
	desc = "A nasty bundle of congealed plasma gathered from ship innards. Nice and sticky!"
	custom_materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT)
	point_value = 50

/obj/item/stack/scrap/core
	name = "ship core"
	singular_name = "ship core"
	merge_type = /obj/item/stack/scrap/core
	icon_state = "ship_core"
	desc = "A radioactive core of a nuclear thruster. Make sure there's no assistants under your ship with a reciprocating saw."
	custom_materials = list(/datum/material/uranium = SHEET_MATERIAL_AMOUNT, /datum/material/iron = 100)
	point_value = 45

/obj/item/stack/scrap/crystalline_matrix
	name = "crystalline matrix"
	singular_name = "crystalline matrix"
	merge_type = /obj/item/stack/scrap/crystalline_matrix
	icon_state = "crystalline_matrix"
	desc = "A crystalline matrix used in immense calculations to sheer ships. AGI by 2520!"
	custom_materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = 100)
	point_value = 100
