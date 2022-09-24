//Tendril chest artifacts and ruin loot. Includes ash drake loot since they drop two sets of armor + random item
//Consumable or one-use items like the magic D20 and gluttony's blessing are omitted

/datum/export/lavaland/minor
	cost = 10000
	unit_name = "minor lava planet artifact"
	export_types = list(/obj/item/immortality_talisman,
						/obj/item/book_of_babel,
						/obj/item/gun/magic/hook,
						/obj/item/wisp_lantern,
						/obj/item/reagent_containers/glass/bottle/potion/flight,
						/obj/item/clothing/glasses/godeye,
						/obj/item/melee/ghost_sword,
						/obj/item/clothing/suit/space/hardsuit/cult,
						/obj/item/voodoo,
						/obj/item/grenade/clusterbuster/inferno,
						/obj/item/clothing/neck/necklace/memento_mori,
						/obj/item/organ/heart/cursed/wizard,
						/obj/item/clothing/suit/hooded/cloak/drake,
						/obj/item/dragons_blood,
						/obj/item/lava_staff,
						/obj/item/ship_in_a_bottle,
						/obj/item/clothing/shoes/clown_shoes/banana_shoes,
						/obj/item/gun/magic/staff/honk,
						/obj/item/kitchen/knife/envy,
						/obj/item/gun/ballistic/revolver/russian/soul,
						/obj/item/veilrender/vealrender,
						/obj/item/keycard/necropolis,
						/obj/item/clothing/gloves/gauntlets)

/datum/export/lavaland/major //valuable chest/ruin loot and staff of storms
	cost = 20000
	unit_name = "lava planet artifact"
	export_types = list(/obj/item/guardiancreator,
						/obj/item/rod_of_asclepius,
						/obj/item/clothing/suit/space/hardsuit/powerarmor_advanced,
						/obj/item/prisoncube,
						/obj/item/staff/storm,
						/obj/item/clothing/under/drip, //Drip is very valuable to many investors in high fashion
						/obj/item/clothing/shoes/drip,
						/obj/item/gun/energy/plasmacutter/adv/robocutter,
						/obj/item/twohanded/bonespear/stalwartpike)

//Megafauna loot, except for stalwart, ash drakes, and legion

/datum/export/lavaland/megafauna
	cost = 40000
	unit_name = "major lava planet artifact"
	export_types = list(/obj/item/hierophant_club,
						/obj/item/melee/transforming/cleaving_saw,
						/obj/item/organ/vocal_cords/colossus,
						/obj/machinery/anomalous_crystal,
						/obj/item/mayhem,
						/obj/item/blood_contract,
						/obj/item/gun/magic/staff/spellblade)

/datum/export/lavaland/megafauna/total_printout(datum/export_report/ex, notes = TRUE) //in the unlikely case a miner feels like selling megafauna loot
	. = ..()
	if(. && notes)
		. += " On behalf of the Nanotrasen RnD division: Thank you for your hard work."

/datum/export/lavaland/megafauna/hev/suit
	cost = 30000
	unit_name = "H.E.C.K. suit"
	export_types = list(/obj/item/clothing/suit/space/hostile_environment)

/datum/export/lavaland/megafauna/hev/helmet
	cost = 10000
	unit_name = "H.E.C.K. helmet"
	export_types = list(/obj/item/clothing/head/helmet/space/hostile_environment)

//Gemstones, because they are unstackable

/datum/export/lavaland/gems/rupee
	cost = 3300
	unit_name = "Ruperium"
	export_types = list(/obj/item/gem/rupee)

/datum/export/lavaland/gems/magma
	cost = 4500
	unit_name = "Calcified Auric"
	export_types = list(/obj/item/gem/magma)

/datum/export/lavaland/gems/diamond
	cost = 4500
	unit_name = "Frost Diamond"
	export_types = list(/obj/item/gem/fdiamond)

/datum/export/lavaland/gems/plasma
	cost = 7500
	unit_name = "Stabilized Baroxuldium"
	export_types = list(/obj/item/gem/phoron)

/datum/export/lavaland/gems/purple
	cost = 8400
	unit_name = "Densified Dilithium"
	export_types = list(/obj/item/gem/purple)

/datum/export/lavaland/gems/amber
	cost = 9600
	unit_name = "Draconic Amber"
	export_types = list(/obj/item/gem/amber)

/datum/export/lavaland/gems/void
	cost = 10000
	unit_name = "Null Crystal"
	export_types = list(/obj/item/gem/void)

/datum/export/lavaland/gems/blood
	cost = 12000
	unit_name = "Ichorium Crystal"
	export_types = list(/obj/item/gem/bloodstone)

/datum/export/lavaland/gems/dark
	cost = 20000
	unit_name = "Dark Salt Lick"
	export_types = list(/obj/item/gem/dark)

/datum/export/lavaland/gems/minor
	cost = 1000
	unit_name = "Minor Lavaland Gems"
	export_types = list(/obj/item/gem/ruby,/obj/item/gem/sapphire,/obj/item/gem/emerald,/obj/item/gem/topaz)

/datum/export/lavaland/gems/stalwart
	cost = 9800
	unit_name = "Bluespace Data Crystal"
	export_types = list(/obj/item/ai_cpu/stalwart)
