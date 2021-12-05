/datum/design/chargepylon
	name = "Charging Pylon"
	desc = "A pylon that can recharge nearby powercells"
	id = "infection_charger"
	build_type = PROTOLATHE
	materials = list(/datum/material/bluespace = 4000, /datum/material/glass = 500, /datum/material/diamond = 1500, /datum/material/iron = 200)
	build_path = /obj/item/pylon_spawner/charger
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/turretpylon
	name = "Turret Pylon"
	desc = "A pylon that destroys nearby infection"
	id = "infection_turret"
	build_type = PROTOLATHE
	materials = list(/datum/material/bluespace = 4000, /datum/material/glass = 500, /datum/material/diamond = 1500, /datum/material/iron = 200)
	build_path = /obj/item/pylon_spawner/turret
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/sleeperup
	name = "Infection Sleeper Upgrade"
	desc = "An upgrade to increase the efficiency of sleepers"
	id = "infection_sleeper_upgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1200, /datum/material/glass = 1200, /datum/material/plastic = 5000, /datum/material/bluespace = 500, /datum/material/diamond = 250) //oh yes I A M going to do this
	build_path = /obj/item/sleeper_enhancer
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/healinjector
	name = "Infection Reusable Medical Injector"
	desc = "A reusable medical injector using infection-based technology"
	id = "infection_injector"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1200, /datum/material/glass = 1200, /datum/material/plastic = 500, /datum/material/bluespace = 1500, /datum/material/diamond = 500)
	build_path = /obj/item/healing_injector
	departmental_flags = DEPARTMENTAL_FLAG_ALL
