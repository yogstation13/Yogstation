/obj/structure/ghostbeacon
	name = "Ghost Beacon"
	desc = "A beacon from which ghosts can materialize and dematerialize from."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/list/mob/living/carbon/ghosts = list()

/obj/structure/ghostbeacon/Initialize()
	. = ..()
	GLOB.poi_list |= src
	START_PROCESSING(SSprocessing, src)

/obj/structure/ghostbeacon/Destroy()
	. = ..()
	GLOB.poi_list -= src
	for(var/M in ghosts)
		qdel(M) // Destroy all mobs

	ghosts = list()
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/ghostbeacon/process()
	for(var/mob/living/M in ghosts)
		if(M.InCritical() || M.stat == DEAD)
			ghosts -= M
			M.visible_message(span_notice("[M] gets forcefully ripped from this plane"), span_notice("You feel your body forcefully get ripped back into the astral planes."))
			qdel(M)
		if(QDELETED(M)) // Admin fuckery check
			ghosts.Remove(M) // -= doesnt work with qdeled objects

/obj/structure/ghostbeacon/attack_ghost(mob/user)
	. = ..()
	if(is_banned_from(user.key, ROLE_GHOSTBEACON))
		to_chat(user, "You are banned from materializing")
		return
	var/response = alert("Materialize? (You will not be revivable)", "Beacon", "Yes", "No")
	if(response == "No")
		return
	var/mob/living/carbon/human/H = user.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	var/outfit = /datum/outfit/ghost
	if(isplasmaman(H))
		outfit = /datum/outfit/ghost/plasmaman
	H.equipOutfit(outfit)
	if(isplasmaman(H))
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
	H.regenerate_icons()
	ghosts |= H
	H.visible_message(span_notice("[H] decends into this plane"), span_notice("You decend into the living plane."))

/obj/structure/ghostbeacon/attack_hand(mob/user)
	. = ..()
	if(!(user in ghosts))
		return
	var/response = alert("Dematerialize?", "Beacon", "Yes", "No")
	if(response == "No")
		return
	ghosts -= user
	user.visible_message(span_notice("[user] ascends back into their plane"), span_notice("You ascend back into the astral planes."))
	qdel(user)

/datum/outfit/ghost
	name = "Ghost"
	id = /obj/item/card/id

	head = /obj/item/clothing/head/that
	uniform = /obj/item/clothing/under/assistantformal
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	back = /obj/item/storage/backpack

/datum/outfit/ghost/plasmaman
	name = "Plasmaman Ghost"
	head = /obj/item/clothing/head/helmet/space/plasmaman
	r_hand = /obj/item/tank/internals/plasmaman/belt/full
	mask = /obj/item/clothing/mask/breath
	uniform = /obj/item/clothing/under/plasmaman/enviroslacks
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	back = /obj/item/storage/backpack
