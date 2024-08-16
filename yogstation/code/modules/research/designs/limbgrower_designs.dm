/datum/design/vox_tail
	name = "Vox Tail"
	id = "voxtail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tail/vox/fake
	category = list("vox")

/datum/design/vox_tongue
	name = "Vox Tongue"
	id = "voxtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/tongue/vox
	category = list("vox")

/datum/design/vox_eyes
	name = "Vox Eyes"
	id = "voxeyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/eyes/vox
	category = list("vox")

/datum/design/vox_liver
	name = "Vox Liver"
	id = "voxliver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/liver/vox
	category = list("vox")

/datum/design/vox_lungs
	name = "Vox Lungs"
	id = "voxlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/lungs/vox
	category = list("vox")

/obj/item/disk/design_disk/limbs/vox
	name = "Vox Limb Design Disk"
	limb_designs = list(/datum/design/vox_tail, /datum/design/vox_tongue, /datum/design/vox_eyes, /datum/design/vox_liver, /datum/design/vox_lungs)

/datum/design/limb_disk/vox
	name = "Vox Limb Design Disk"
	desc = "Contains designs for vox organs for the limbgrower - Vox tail, tongue, eyes, liver, and lungs."
	id = "limbdesign_vox"
	build_path = /obj/item/disk/design_disk/limbs/vox
