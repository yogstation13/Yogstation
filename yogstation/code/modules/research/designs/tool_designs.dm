/datum/design/tool_switcher
	name = "Programmable Tool Switcher"
	desc = "An advanced programmable device capable of quickly swapping to the correct tool for performing repetitive tasks quickly."
	id = "tool_switcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/diamond = 1500, /datum/material/uranium = 200)
	build_path = /obj/item/storage/belt/tool_switcher
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/tricorder
	name = "Tricorder"
	desc = "A multifunction handheld device useful for data sensing, analysis, and recording."
	id = "tricorder"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=500,/datum/material/silver=300,/datum/material/gold=300)
	build_path = /obj/item/multitool/tricorder
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/holotool
	name = "Holotool"
	desc = "A basic holotool."
	id = "holotool"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=1000,/datum/material/silver=300,/datum/material/gold=300)
	build_path = /obj/item/holotool
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/holotool/advanced
	name = "Advanced Holotool"
	desc = "An advanced holotool."
	id = "advholotool"
	materials = list(/datum/material/iron=1200,/datum/material/silver=500,/datum/material/gold=500, /datum/material/uranium = 250)
	build_path = /obj/item/holotool/advanced

/datum/design/holotool/elite
	name = "Elite Holotool"
	desc = "An elite holotool."
	id = "eliteholotool"
	materials = list(/datum/material/iron=1200,/datum/material/silver=500,/datum/material/gold=500, /datum/material/uranium = 250, /datum/material/diamond = 200, /datum/material/bluespace = 200)
	build_path = /obj/item/holotool/elite


/datum/design/holoscrewdriver
	name = "Holotool Screwdriver card"
	id = "holoscrew"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/screwdriver

/datum/design/holocrowbar
	name = "Holotool Crowbar card"
	id = "holocrow"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/crowbar

/datum/design/holomultitool
	name = "Holotool Multitool card"
	id = "holomulti"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/multitool

/datum/design/holowrench
	name = "Holotool Wrench card"
	id = "holowrench"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/wrench

/datum/design/holosnips
	name = "Holotool Wirecutters card"
	id = "holosnips"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/snips

/datum/design/holowelder
	name = "Holotool Welder card"
	id = "holowelder"
	materials = list(/datum/material/iron=1000,/datum/material/glass=2000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/welder

/datum/design/holoadvscrewdriver
	name = "Advanced Holotool Screwdriver card"
	id = "holoscrewadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/screwdriver/advanced

/datum/design/holoadvcrowbar
	name = "Advanced Holotool Crowbar card"
	id = "holocrowadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/crowbar/advanced

/datum/design/holoadvmultitool
	name = "Advanced Holotool Multitool card"
	id = "holomultiadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/multitool/advanced

/datum/design/holoadvwrench
	name = "Advanced Holotool Wrench card"
	id = "holowrenchadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/wrench/advanced

/datum/design/holoadvsnips
	name = "Advanced Holotool Wirecutters card"
	id = "holosnipsadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/snips/advanced

/datum/design/holoadvwelder
	name = "Advanced Holotool Welder card"
	id = "holowelderadvanced"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=150,/datum/material/silver=250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/welder/advanced
	
/datum/design/holoelitescrewdriver
	name = "Elite Holotool Screwdriver card"
	id = "holoscrewelite"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/screwdriver/elite

/datum/design/holoelitecrowbar
	name = "Elite Holotool Crowbar card"
	id = "holocrowbasic"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/crowbar/elite

/datum/design/holoelitemultitool
	name = "Elite Holotool Multitool card"
	id = "holomultielite"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/multitool/elite

/datum/design/holoelitewrench
	name = "Elite Holotool Wrench card"
	id = "holowrenchelite"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/wrench/elite

/datum/design/holoelitesnips
	name = "Elite Holotool Wirecutters card"
	id = "holosnipselite"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/snips/elite

/datum/design/holoelitewelder
	name = "Elite Holotool Welder card"
	id = "holowelderelite"
	materials = list(/datum/material/iron=1500,/datum/material/glass=3000,/datum/material/gold=750, /datum/material/silver=500, /datum/material/diamond = 250)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	build_path = /obj/item/holotool_module/welder/elite