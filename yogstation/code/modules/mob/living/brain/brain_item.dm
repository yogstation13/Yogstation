/obj/item/organ/brain
	var/real_name = null //the name we use for MMIs, only used by changelings

/obj/item/organ/brain/transfer_identity(mob/living/L)
	real_name = L.real_name
	.=..()