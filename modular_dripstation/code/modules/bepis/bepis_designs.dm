/datum/design/bright_helmet
	name = "Workplace-Ready Firefighter Helmet"
	desc = "By applying state of the art lighting technology to a fire helmet with industry standard photo-chemical hardening methods, this hardhat will protect you from robust workplace hazards."
	id = "bright_helmet"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/plastic = 3000, /datum/material/silver = 500)
	build_path = /obj/item/clothing/head/hardhat/red/upgraded
	category = list("Equipment")
	departmental_flags =  DEPARTMENTAL_FLAG_SCIENCE |  DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/rld_mini
	name = "Mini Rapid Light Device (MRLD)"
	desc = "A tool that can deploy portable and standing lighting orbs and glowsticks."
	id = "rld_mini"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 10000, /datum/material/plastic = 8000, /datum/material/gold = 2000)
	build_path = /obj/item/construction/rld/mini
	category = list("Tool Designs")
	departmental_flags =  DEPARTMENTAL_FLAG_ENGINEERING |  DEPARTMENTAL_FLAG_CARGO |  DEPARTMENTAL_FLAG_SERVICE

/datum/design/eng_gloves
	name = "Tinkers Gloves"
	desc = "Overdesigned engineering gloves that have automated construction subroutines dialed in, allowing for faster construction while worn."
	id = "eng_gloves"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 2000, /datum/material/silver= 1500, /datum/material/gold = 1000)
	build_path = /obj/item/clothing/gloves/tinkerer
	category = list("Equipment")
	departmental_flags =  DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/lavarods
	name = "Lava-Resistant Iron Rods"
	id = "lava_rods"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron= 1000, /datum/material/plasma= 500, /datum/material/titanium= 2000)
	build_path = /obj/item/stack/rods/lava
	category = list("Equipment")
	departmental_flags =  DEPARTMENTAL_FLAG_CARGO |  DEPARTMENTAL_FLAG_SCIENCE |  DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/pin_explorer
	name = "Outback Firing Pin"
	desc = "This firing pin only shoots while ya ain't on station, fair dinkum!"
	id = "pin_explorer"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 1000, /datum/material/gold = 1000, /datum/material/iron = 500)
	build_path = /obj/item/firing_pin/explorer
	category = list("Firing Pins")
	departmental_flags =  DEPARTMENTAL_FLAG_SECURITY

/datum/design/stun_boomerang
	name = "OZtek Boomerang"
	desc = "Uses reverse flow gravitodynamics to flip its personal gravity back to the thrower mid-flight. Also functions similar to a stun baton."
	id = "stun_boomerang"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 10000, /datum/material/gold = 2000)
	build_path = /obj/item/melee/baton/boomerang
	category = list("Weapons")
	departmental_flags =  DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/hypnochair
	name = "Enhanced Interrogation Chamber Board"
	desc = "Allows for the construction of circuit boards used to build an Enhanced Interrogation Chamber."
	id = "hypnochair"
	build_path = /obj/item/circuitboard/machine/hypnochair
	category = list("Misc. Machinery")
	departmental_flags =  DEPARTMENTAL_FLAG_SECURITY