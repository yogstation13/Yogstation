/obj/item/organ/eyes/vox
	name = "vox eyes"
	icon_state = "eyes-vox"
	decay_factor = 0

/obj/item/organ/eyes/vox/emp_act()
	owner.adjust_hallucinations(10 SECONDS)
