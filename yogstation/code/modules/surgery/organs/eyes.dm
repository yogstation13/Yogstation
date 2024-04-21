/obj/item/organ/eyes/vox
	name = "vox eyes"
	desc = "A keen eye is essential for successful raiding and trading."
	icon_state = "eyes-vox"
	decay_factor = 0

/obj/item/organ/eyes/vox/emp_act()
	owner.adjust_hallucinations(10 SECONDS)
