/datum/outfit/oldsec
	ears = /obj/item/radio/headset/headset_old/alt
	implants = list(/obj/item/implant/mindshield)
	id = /obj/item/card/id/advanced/old
	id_trim = /datum/id_trim/job/away/old/sec
	belt = /obj/item/gun/energy/laser/retro/old

/datum/outfit/oldsec/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_UNCOMMON)
	R.freqlock = RADIO_FREQENCY_LOCKED
	R.independent = TRUE
	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label()
		W.update_icon()
	..()
