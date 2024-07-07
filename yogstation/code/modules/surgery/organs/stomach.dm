/obj/item/organ/stomach/vox
	name = "gizzard"
	icon_state = "stomach-vox"
	desc = "Mechanical digestion."
	decay_factor = 0

/obj/item/organ/stomach/vox/emp_act()
	owner.adjust_disgust(10)
