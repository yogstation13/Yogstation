
//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/ghost_role/human/oldcmo
	name = "old command cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a Chief Medical Officer's uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	prompt_name = "the Chief Medical Officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/human
	you_are_text = "You are a Chief Medical Officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_text = "Work as a team with your fellow survivors and do not abandon them. You are expected to be familiar with Old station for this role."
	outfit = /datum/outfit/oldcmo
	spawner_job_path = /datum/job/ancient_crew

/obj/effect/mob_spawn/ghost_role/human/oldcmo/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/datum/outfit/oldcmo
	name = "Ancient Chief Medical Officer"
	id = /obj/item/card/id/advanced/old
	id_trim = /datum/id_trim/away/old/cmo
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/flashlight/pen/paramedic
	r_pocket = /obj/item/pinpointer/crew
	implants = list(/obj/item/implant/mindshield)
	skillchips = list(/obj/item/skillchip/entrails_reader)
	ears = /obj/item/radio/headset/heads/headset_old

/datum/outfit/oldcmo/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
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
