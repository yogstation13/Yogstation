/datum/export/toolbox
	cost = 4
	unit_name = "toolbox"
	export_types = list(/obj/item/storage/toolbox)

// mechanical toolbox:	22cr
// emergency toolbox:	17-20cr
// electrical toolbox:	36cr
// robust: priceless

// Basic tools
/datum/export/screwdriver
	cost = 2
	unit_name = "screwdriver"
	export_types = list(/obj/item/screwdriver)
	include_subtypes = FALSE

/datum/export/wrench
	cost = 2
	unit_name = "wrench"
	export_types = list(/obj/item/wrench)

/datum/export/crowbar
	cost = 2
	unit_name = "crowbar"
	export_types = list(/obj/item/crowbar)

/datum/export/wirecutters
	cost = 2
	unit_name = "pair"
	message = "of wirecutters"
	export_types = list(/obj/item/wirecutters)


/datum/export/weldingtool
	cost = 5
	unit_name = "welding tool"
	export_types = list(/obj/item/weldingtool)
	include_subtypes = FALSE

/datum/export/weldingtool/emergency
	cost = 2
	unit_name = "emergency welding tool"
	export_types = list(/obj/item/weldingtool/mini)

/datum/export/weldingtool/industrial
	cost = 10
	unit_name = "industrial welding tool"
	export_types = list(/obj/item/weldingtool/largetank, /obj/item/weldingtool/hugetank)


/datum/export/extinguisher
	cost = 15
	unit_name = "fire extinguisher"
	export_types = list(/obj/item/extinguisher)
	include_subtypes = FALSE

/datum/export/extinguisher/mini
	cost = 2
	unit_name = "pocket fire extinguisher"
	export_types = list(/obj/item/extinguisher/mini)


/datum/export/flashlight
	cost = 5
	unit_name = "flashlight"
	export_types = list(/obj/item/flashlight)
	include_subtypes = FALSE

/datum/export/flashlight/flare
	cost = 2
	unit_name = "flare"
	export_types = list(/obj/item/flashlight/flare)

/datum/export/flashlight/seclite
	cost = 10
	unit_name = "seclite"
	export_types = list(/obj/item/flashlight/seclite)


/datum/export/analyzer
	cost = 5
	unit_name = "analyzer"
	export_types = list(/obj/item/analyzer)

/datum/export/analyzer/t_scanner
	cost = 10
	unit_name = "t-ray scanner"
	export_types = list(/obj/item/t_scanner)


/datum/export/radio
	cost = 5
	unit_name = "radio"
	export_types = list(/obj/item/radio)
	exclude_types = list(/obj/item/radio/mech)


/datum/export/rcd
	cost = 100
	unit_name = "rapid construction device"
	export_types = list(/obj/item/construction/rcd)

/datum/export/rcd_ammo
	cost = 60
	unit_name = "compressed matter cardridge"
	export_types = list(/obj/item/rcd_ammo)

/datum/export/rpd
	cost = 100
	unit_name = "rapid pipe dispenser"
	export_types = list(/obj/item/pipe_dispenser)

/datum/export/singulo //failsafe in case someone decides to ship a live singularity to CentCom without the corresponding bounty
	cost = 1
	unit_name = "singularity"
	export_types = list(/obj/singularity)
	include_subtypes = FALSE

/datum/export/singulo/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Invalid object detected."

/datum/export/singulo/tesla //see above
	unit_name = "energy ball"
	export_types = list(/obj/singularity/energy_ball)

/datum/export/singulo/tesla/total_printout(datum/export_report/ex, notes = TRUE)
	. = ..()
	if(. && notes)
		. += " ERROR: Unscheduled energy ball delivery detected."

/datum/export/singulo_shard1
	cost = 500 // come on, stage 1?
	unit_name = "stage 1 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage1)

/datum/export/singulo_shard2
	cost = 3500
	unit_name = "stage 2 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage2)

/datum/export/singulo_shard3
	cost = 8000
	unit_name = "stage 3 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage3)

/datum/export/singulo_shard4
	cost = 20000 // you got some guts kid, you deserve this
	unit_name = "stage 4 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage4)

/datum/export/singulo_shard5
	cost = 40000 // likely the outcome of something gone horribly wrong
	unit_name = "stage 5 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage5)

/datum/export/singulo_shard6
	cost = 80000 // the outcome of something gone devestatingly wrong, but hey drinks on me
	unit_name = "stage 6 singularity shard"
	export_types = list(/obj/item/singularity_shard/stage6)