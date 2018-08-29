/datum/outfit/job/warden/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	.=..()
	var/datum/martial_art/krav_maga/style = new
	style.teach(H)