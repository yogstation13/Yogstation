
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	notreallyacloset = TRUE
	door_anim_time = 0 // no animation
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null
	var/tagged = 0 // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on [src]!"))
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "[initial(name)] - [t]"
			tagged = 1
			update_icon()
		else
			name = initial(name)
		return
	else if((I.tool_behaviour == TOOL_WIRECUTTER) && tagged)
		to_chat(user, span_notice("You cut the tag off [src]."))
		name = initial(name)
		tagged = 0
		update_icon()

/obj/structure/closet/body_bag/update_icon()
	..()
	if (tagged)
		add_overlay("bodybag_label")

/obj/structure/closet/body_bag/close()
	if(..())
		density = FALSE
		return 1
	return 0

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!attempt_fold(usr))
			return FALSE
		perform_fold(usr)
		qdel(src)

		/**
		  * Checks to see if we can fold. Return TRUE to actually perform the fold and delete.
			*
		  * Arguments:
		  * * the_folder - over_object of MouseDrop aka usr
		  */
/obj/structure/closet/body_bag/proc/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while unzipped."))
		return
	if(contents.len)
		to_chat(the_folder, span_warning("There are too many things inside of [src] to fold it up!"))
		return
	// toto we made it!
	return TRUE

	/**
		* Performs the actual folding. Deleting is automatic, please do not include.
		*
		* Arguments:
		* * the_folder - over_object of MouseDrop aka usr
		*/
/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/the_folder)
	visible_message(span_notice("[usr] folds up [src]."))
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	the_folder.put_in_hands(B)


/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	//copypaste zone, we do not want the content check so we don't want inheritance
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while unzipped.</span>"))
		return
	//end copypaste zone
	if(contents.len >= mob_storage_capacity / 2)
		to_chat(usr, span_warning("There are too many things inside of [src] to fold it up!"))
		return
	for(var/obj/item/bodybag/bluespace/B in src)
		to_chat(usr, span_warning("You can't recursively fold bluespace body bags!"))
		return
	return TRUE

/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/the_folder)
	visible_message("<span class='notice'>[usr] folds up [src].</span>")
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	var/max_weight_of_contents = initial(B.w_class)
	for(var/am in contents)
		var/atom/movable/content = am
		content.forceMove(B)
		if(isliving(content))
			to_chat(content, span_userdanger("You're suddenly forced into a tiny, compressed space!"))
		if(!isitem(content))
			max_weight_of_contents = max(WEIGHT_CLASS_BULKY, max_weight_of_contents)
			continue
		var/obj/item/A_is_item = content
		if(A_is_item.w_class < max_weight_of_contents)
			continue
		max_weight_of_contents = A_is_item.w_class
	B.w_class = max_weight_of_contents
	usr.put_in_hands(B)

/// Environmental bags

/obj/structure/closet/body_bag/environmental
	name = "environmental protection bag"
	desc = "An insulated, reinforced bag designed to protect against exoplanetary storms and other environmental factors."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "envirobag"
	mob_storage_capacity = 1
	contents_pressure_protection = 0.8
	contents_thermal_insulation = 0.5
	foldedbag_path = /obj/item/bodybag/environmental/
	weather_protection = list(WEATHER_ACID, WEATHER_ASH, WEATHER_RAD, WEATHER_SNOW, ) // Does not protect against lava or the The Floor Is Lava spell.

/obj/structure/closet/body_bag/environmental/nanotrasen
	name = "elite environmental protection bag"
	desc = "A heavily reinforced and insulated bag, capable of fully isolating its contents from external factors."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "ntenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/nanotrasen/
	weather_protection = list(WEATHER_ALL)

/// Securable enviro. bags

/obj/structure/closet/body_bag/environmental/prisoner
	name = "prisoner transport bag"
	desc = "Intended for transport of prisoners through hazardous environments, this environmental protection bag comes with straps to keep an occupant secure."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "prisonerenvirobag"
	foldedbag_path = /obj/item/bodybag/environmental/prisoner/
	breakout_time = 4 MINUTES // because it's probably about as hard to get out of this as it is to get out of a straightjacket.
	/// How long it takes to sinch the bag.
	var/sinch_time = 10 SECONDS
	/// Whether or not the bag is sinched. Starts unsinched.
	var/sinched = FALSE
	/// The sound that plays when the bag is done sinching.
	var/sinch_sound = 'sound/items/handling/toolbelt_equip.ogg'

/obj/structure/closet/body_bag/environmental/prisoner/attempt_fold(mob/living/carbon/human/the_folder)
	if(sinched)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while its straps are fastened."))
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/update_icon()
	. = ..()
	if(sinched)
		icon_state = initial(icon_state) + "_sinched"
	else
		icon_state = initial(icon_state)

/obj/structure/closet/body_bag/environmental/prisoner/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(sinched)
		to_chat(user, span_danger("The buckles on [src] are sinched down, preventing it from opening."))
		return FALSE
	. = ..()

/obj/structure/closet/body_bag/environmental/prisoner/open(mob/living/user, force = FALSE)
	if(!can_open(user, force))
		return
	if(opened)
		return
	sinched = FALSE
	playsound(loc, open_sound, 15, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
	dump_contents()
	update_icon()
	return TRUE

/obj/structure/closet/body_bag/environmental/prisoner/container_resist(mob/living/user)
	/// copy-pasted with changes because flavor text as well as some other misc stuff
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		return
	if(!sinched)
		open()
		return

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("Someone in [src] begins to wriggle!"), \
		span_notice("You start wriggling, attempting to loosen [src]'s buckles... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear straining cloth from [src]."))
	if(do_after(user,(breakout_time), src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || !sinched )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/body_bag/environmental/prisoner/bust_open()
	sinched = FALSE
	// We don't break the bag, because the buckles were backed out as opposed to fully broken.
	open()

/obj/structure/closet/body_bag/environmental/prisoner/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	if(!opened)
		togglelock(user)
	return TRUE

/obj/structure/closet/body_bag/environmental/prisoner/togglelock(mob/living/user, silent)
	if(user in contents)
		to_chat(user, span_warning("You can't reach the buckles from here!"))
		return
	if(iscarbon(user))
		add_fingerprint(user)
	if(!sinched)
		for(var/mob/living/target in contents)
			to_chat(target, span_userdanger("You feel the lining of [src] tighten around you! Soon, you won't be able to escape!"))
		user.visible_message(span_notice("You begin sinching down the buckles on [src]."))
		if(!(do_after(user, (sinch_time), src)))
			return
	sinched = !sinched
	if(sinched)
		playsound(loc, sinch_sound, 15, TRUE, -2)
	user.visible_message(span_notice("[user] [sinched ? null : "un"]sinches [src]."),
							span_notice("You [sinched ? null : "un"]sinch [src]."),
							span_hear("You hear stretching followed by metal clicking from [src]."))
	log_game("[key_name(user)] [sinched ? "sinched":"unsinched"] secure environmental bag [src] at [AREACOORD(src)]")
	update_icon()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate
	name = "syndicate prisoner transport bag"
	desc = "An alteration of Nanotrasen's environmental protection bag which has been used in several high-profile kidnappings. Designed to keep a victim unconscious, alive, and secured during transport."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "syndieenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/prisoner/syndicate
	weather_protection = list(WEATHER_ALL)
	breakout_time = 8 MINUTES
	sinch_time = 20 SECONDS

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/Initialize()
	. = ..()
	update_airtightness()


/obj/structure/closet/body_bag/environmental/prisoner/syndicate/update_airtightness()
	if(sinched && !air_contents)
		refresh_air()
	else if(!sinched && air_contents)
		air_contents = null

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/proc/refresh_air()
	air_contents = null
	air_contents = new(50) //liters
	air_contents.set_temperature(T20C)
	air_contents.set_moles(/datum/gas/oxygen, (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(/datum/gas/nitrous_oxide, (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/Destroy()
	if(air_contents)
		QDEL_NULL(air_contents)

	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/return_air()
	if(sinched)
		update_airtightness()
		return air_contents
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/remove_air(amount)
	if(sinched)
		update_airtightness()
		return air_contents // The internals for this bag are bottomless. Syndicate bluespace trickery.
	return ..(amount)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/analyzer_act(mob/living/user, obj/item/I)
	if(sinched)
		update_airtightness()
		atmosanalyzer_scan(air_contents, user, src)
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/togglelock(mob/living/user, silent)
	. = ..()
	if(sinched)
		for(var/mob/living/target in contents)
			to_chat(target, span_warning("You hear a faint hiss, and a white mist fills your vision..."))
