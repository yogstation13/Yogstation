/mob/living/carbon/human/proc/handle_bandaged_limbs()
	for(var/obj/item/bodypart/L in bodyparts)
		if (L.bandaged)
			var/obj/item/medical/bandage/B = L.bandaged
			B.handle_bandage(src)