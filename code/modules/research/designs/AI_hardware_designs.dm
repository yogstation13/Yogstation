/datum/design/ram
	name = "RAM design"
	desc = "This is a bug!"
	id = "default_ram"
	build_type = RACK_CREATOR
	category = list()
	research_icon ='icons/obj/module.dmi'
	research_icon_state = "std_mod"
	var/capacity = 0
	materials = list(/datum/material/glass = 1000)

/datum/design/ram/ram1
	name = "standard memory"
	desc = "Salvaged from decommisioned experiments at NT-CONLAB."
	id = "ram1"
	
	capacity = 1
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000)

/datum/design/ram/ram2
	name = "high-capacity memory"
	desc = "Further refinements allow high-capacity memory at normal performance."
	id = "ram2"

	capacity = 2
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 2000, /datum/material/silver = 1000)

/datum/design/ram/ram3
	name = "hyper-capacity memory"
	desc = "Understanding and manipulation of near-atomic matter allows increased capacity with no noticeable performance degradation."
	id = "ram3"

	capacity = 3
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 4000, /datum/material/silver = 2000, /datum/material/gold = 1000)

/datum/design/ram/ram4
	name = "bluespace memory"
	desc = "Using bluespace based technology it's possible to make increase RAM capacity without decreasing speed."
	id = "ram4"

	capacity = 4
	materials = list(/datum/material/glass = 8000, /datum/material/iron = 8000, /datum/material/silver = 4000, /datum/material/gold = 2000, /datum/material/bluespace = 1000)




/datum/design/cpu_basic
	name = "neural processing unit"
	id = "basic_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 2000)
	build_path = /obj/item/ai_cpu
	construction_time = 5 SECONDS
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_NETMIN

/datum/design/cpu_advanced
	name = "advanced neural processing unit"
	id = "advanced_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 4000, /datum/material/gold = 2000)
	build_path = /obj/item/ai_cpu/advanced
	construction_time = 7.5 SECONDS
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_NETMIN

/datum/design/cpu_bluespace
	name = "bluespace neural processing unit"
	id = "bluespace_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 8000, /datum/material/iron = 4000, /datum/material/gold = 4000, /datum/material/bluespace = 2000)
	build_path = /obj/item/ai_cpu/bluespace
	construction_time = 10 SECONDS
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_NETMIN

/datum/design/cpu_experimental
	name = "experimental neural processing unit"
	id = "experimental_ai_cpu"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 6000, /datum/material/iron = 4000, /datum/material/gold = 6000)
	build_path = /obj/item/ai_cpu/experimental
	construction_time = 7.5 SECONDS
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_NETMIN
