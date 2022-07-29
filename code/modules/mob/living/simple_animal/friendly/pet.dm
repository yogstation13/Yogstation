/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	blood_volume = BLOOD_VOLUME_GENERIC
	var/unique_pet = FALSE // if the mob can be renamed
	var/obj/item/clothing/neck/petcollar/pcollar
	var/collar_type //if the mob has collar sprites, define them.

/mob/living/simple_animal/pet/handle_atom_del(atom/A)
	if(A == pcollar)
		pcollar = null
	return ..()

/mob/living/simple_animal/pet/proc/add_collar(obj/item/clothing/neck/petcollar/P, mob/user)
	if(QDELETED(P) || pcollar)
		return
	if(!user.transferItemToLoc(P, src))
		return
	pcollar = P
	regenerate_icons()
	to_chat(user, span_notice("You put the [P] around [src]'s neck."))
	if(P.tagname && !unique_pet)
		fully_replace_character_name(null, "\proper [P.tagname]")

/mob/living/simple_animal/pet/Move(NewLoc, direct)
	. = ..()

	if(!pcollar)
		return
	if (!(mobility_flags & MOBILITY_STAND))
		return
	if(loc != NewLoc)
		return
	if(!has_gravity(loc))
		return
		
	SEND_SIGNAL(pcollar, COMSIG_NECK_STEP_ACTION)

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/clothing/neck/petcollar) && !pcollar)
		add_collar(O, user)
		return

	if(istype(O, /obj/item/newspaper))
		if(!stat)
			user.visible_message("[user] baps [name] on the nose with the rolled up [O].")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					setDir(i)
					sleep(0.1 SECONDS)
	else
		..()

/mob/living/simple_animal/pet/Initialize()
	. = ..()
	if(pcollar)
		pcollar = new(src)
		regenerate_icons()

/mob/living/simple_animal/pet/Destroy()
	QDEL_NULL(pcollar)
	return ..()

/mob/living/simple_animal/pet/revive(full_heal = 0, admin_revive = 0)
	. = ..()
	if(.)
		if(collar_type)
			collar_type = "[initial(collar_type)]"
		regenerate_icons()

/mob/living/simple_animal/pet/death(gibbed)
	..(gibbed)
	if(collar_type)
		collar_type = "[initial(collar_type)]_dead"
	regenerate_icons()

/mob/living/simple_animal/pet/gib()
	if(pcollar)
		pcollar.forceMove(drop_location())
		pcollar = null
	..()

/mob/living/simple_animal/pet/regenerate_icons()
	cut_overlays()
	if(pcollar && collar_type)
		add_overlay("[collar_type]collar")
		add_overlay("[collar_type]tag")

/mob/living/simple_animal/pet/proc/wuv(mob/M, change = TRUE)
	if(change)
		if(M && stat != DEAD)
			new /obj/effect/temp_visual/heart(loc)
			emote("me", 1, "yaps happily!", TRUE)
			if(flags_1 & HOLOGRAM_1)
				return
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
	else
		if(M && stat != DEAD)
			emote("me", 1, "growls!", TRUE)
