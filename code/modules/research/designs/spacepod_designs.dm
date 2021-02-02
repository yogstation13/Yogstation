/datum/design/board/spacepod_main
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a spacepod mainboard."
	id = "spacepod_main"
	build_path = /obj/item/circuitboard/mecha/pod
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/pod_core
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=5000, /datum/material/uranium=1000, /datum/material/plasma=5000)
	build_path = /obj/item/pod_parts/core
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/pod_armor_civ
	name = "Spacepod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=15000,/datum/material/glass=5000,/datum/material/plasma=10000)
	build_path = /obj/item/pod_parts/armor
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/pod_armor_black
	name = "Spacepod Armor (dark)"
	desc = "Allows for the construction of spacepod armor. This is the dark civillian version."
	id = "podarmor_dark"
	build_type = PROTOLATHE
	build_path = /obj/item/pod_parts/armor/black
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron=15000,/datum/material/glass=5000,/datum/material/plasma=10000)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pod_armor_industrial
	name = "Spacepod Armor (industrial)"
	desc = "Allows for the construction of spacepod armor. This is the industrial grade version."
	id = "podarmor_industiral"
	build_type = PROTOLATHE
	build_path = /obj/item/pod_parts/armor/industrial
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron=15000,/datum/material/glass=5000,/datum/material/plasma=10000,/datum/material/diamond=5000,/datum/material/silver=7500)
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/pod_armor_sec
	name = "Spacepod Armor (security)"
	desc = "Allows for the construction of spacepod armor. This is the security version."
	id = "podarmor_sec"
	build_type = PROTOLATHE
	build_path = /obj/item/pod_parts/armor/security
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron=15000,/datum/material/glass=5000,/datum/material/plasma=10000,/datum/material/diamond=5000,/datum/material/silver=7500)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pod_armor_gold
	name = "Spacepod Armor (golden)"
	desc = "Allows for the construction of spacepod armor. This is the golden version."
	id = "podarmor_gold"
	build_type = PROTOLATHE
	build_path = /obj/item/pod_parts/armor/gold
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron=5000,/datum/material/glass=2500,/datum/material/plasma=7500,/datum/material/gold=10000)
	departmental_flags = DEPARTMENTAL_FLAG_ALL

//////////////////////////////////////////
//////SPACEPOD GUNS///////////////////////
//////////////////////////////////////////

/datum/design/pod_gun_disabler
	name = "Spacepod Equipment (Disabler)"
	desc = "Allows for the construction of a spacepod mounted disabler."
	id = "podgun_disabler"
	build_type = PROTOLATHE
	build_path = /obj/item/spacepod_equipment/weaponry/disabler
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron = 15000)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pod_gun_bdisabler
	name = "Spacepod Equipment (Burst Disabler)"
	desc = "Allows for the construction of a spacepod mounted disabler. This is the burst-fire model."
	id = "podgun_bdisabler"
	build_type = PROTOLATHE
	build_path = /obj/item/spacepod_equipment/weaponry/burst_disabler
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron = 15000,/datum/material/plasma=2000)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pod_gun_laser
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PROTOLATHE
	build_path = /obj/item/spacepod_equipment/weaponry/laser
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron=10000,/datum/material/glass=5000,/datum/material/gold=1000,/datum/material/silver=2000)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pod_ka_basic
	name = "Spacepod Equipment (Basic Kinetic Accelerator)"
	desc = "Allows for the construction of a weak spacepod Kinetic Accelerator"
	id = "pod_ka_basic"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/silver = 2000, /datum/material/uranium = 2000)
	build_path = /obj/item/spacepod_equipment/weaponry/basic_pod_ka
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/pod_ka
	name = "Spacepod Equipment (Kinetic Accelerator)"
	desc = "Allows for the construction of a spacepod Kinetic Accelerator."
	id = "pod_ka"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/silver = 2000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/spacepod_equipment/weaponry/pod_ka
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO


/datum/design/pod_plasma_cutter
	name = "Spacepod Equipment (Plasma Cutter)"
	desc = "Allows for the construction of a plasma cutter."
	id = "pod_plasma_cutter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/silver = 2000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/spacepod_equipment/weaponry/plasma_cutter
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/pod_adv_plasma_cutter
	name = "Spacepod Equipment (Advanced Plasma cutter)"
	desc = "Allows for the construction of an advanced plasma cutter."
	id = "pod_adv_plasma_cutter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/silver = 4000, /datum/material/gold = 4000, /datum/material/diamond = 4000)
	build_path = /obj/item/spacepod_equipment/weaponry/plasma_cutter/adv
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//////////////////////////////////////////
//////SPACEPOD MISC. ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_misc_tracker
	name = "Spacepod Tracking Module"
	desc = "Allows for the construction of a spacepod tracking module."
	id = "podmisc_tracker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=5000)
	build_path = /obj/item/spacepod_equipment/tracker
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

//////////////////////////////////////////
//////SPACEPOD CARGO ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_cargo_ore
	name = "Spacepod Ore Storage Module"
	desc = "Allows for the construction of a spacepod ore storage module."
	id = "podcargo_ore"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=20000, /datum/material/glass=2000)
	build_path = /obj/item/spacepod_equipment/cargo/large/ore
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/pod_cargo_crate
	name = "Spacepod Crate Storage Module"
	desc = "Allows the construction of a spacepod crate storage module."
	id = "podcargo_crate"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=25000)
	build_path = /obj/item/spacepod_equipment/cargo/large
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

//////////////////////////////////////////
//////SPACEPOD SEC CARGO ITEMS////////////
//////////////////////////////////////////

/datum/design/passenger_seat
	name = "Spacepod Passenger Seat"
	desc = "Allows the construction of a spacepod passenger seat module."
	id = "podcargo_seat"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=7500, /datum/material/glass=2500)
	build_path = /obj/item/spacepod_equipment/cargo/chair
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/*/datum/design/loot_box
	name = "Spacepod Loot Storage Module"
	desc = "Allows the construction of a spacepod auxillary cargo module."
	id = "podcargo_lootbox"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=7500, /datum/material/glass=2500)
	build_path = /obj/item/spacepod_equipment/cargo/loot_box
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL*/

//////////////////////////////////////////
//////SPACEPOD LOCK ITEMS////////////////
//////////////////////////////////////////
/datum/design/pod_lock_keyed
	name = "Spacepod Tumbler Lock"
	desc = "Allows for the construction of a tumbler style podlock."
	id = "podlock_keyed"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=4500)
	build_path = /obj/item/spacepod_equipment/lock/keyed
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/pod_key
	name = "Spacepod Tumbler Lock Key"
	desc = "Allows for the construction of a blank key for a podlock."
	id = "podkey"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=500)
	build_path = /obj/item/spacepod_key
	category = list("Spacepod Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/lockbuster
	name = "Spacepod Lock Buster"
	desc = "Allows for the construction of a spacepod lockbuster."
	id = "pod_lockbuster"
	build_type = PROTOLATHE
	build_path = /obj/item/device/lock_buster
	category = list("Spacepod Designs")
	materials = list(/datum/material/iron = 15000, /datum/material/diamond=2500) //it IS a drill!
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
