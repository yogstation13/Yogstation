/obj/item/organ/brain
	var/real_name = null //the name we use for MMIs, only used by changelings
	var/brain_name = "brain"

/obj/item/organ/brain/transfer_identity(mob/living/L)
	real_name = L.real_name
	.=..()

/obj/item/organ/brain/proc/get_mmi_brain_sprite()
	return "mmi_brain"

/obj/item/organ/brain/alien/get_mmi_brain_sprite()
	return "mmi_brain_alien"

/obj/item/organ/brain/vox
	name = "cortical stack"
	brain_name = "cortical stack"
	desc = "A peculiarly advanced bio-electronic device that seems to hold the memories and identity of a Vox."
	icon_state = "cortical-stack"
	decay_factor = 0

/obj/item/organ/brain/vox/get_mmi_brain_sprite()
	return "mmi_cortical_stack"

/obj/item/organ/brain/vox/emp_act(severity)
	to_chat(owner, span_warning("Your head hurts."))
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, clamp(severity*5, 5, 50))
