//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "cleanbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.3"
	pass_flags = PASSMOB
	path_image_color = "#993299"

	var/blood = 1
	var/trash = 0
	var/pests = 0
	var/drawn = 0

	var/base_icon = "cleanbot" /// icon_state to use in update_icon_state
	var/list/target_types
	var/atom/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

/mob/living/simple_animal/bot/cleanbot/Initialize()
	. = ..()
	get_targets()
	update_icon_state()

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/cleanbot/proc/update_icon_state()
	//. = ..()
	switch(mode)
		if(BOT_CLEANING)
			icon_state = "[base_icon]-c"
		else
			icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.GetID())
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] \the [src] behaviour controls."))
		else
			if(emagged)
				to_chat(user, span_warning("ERROR"))
			if(open)
				to_chat(user, span_warning("Please close the access panel before locking it."))
			else
				to_chat(user, span_notice("\The [src] doesn't seem to respect your authority."))
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged != 2)
		return

	if(user)
		to_chat(user, span_danger("[src] buzzes and beeps."))

	get_targets() //recalibrate target list

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/scan_target)
	if(iscarbon(scan_target))
		var/mob/living/carbon/scan_carbon = scan_target
		if(!(scan_carbon in view(DEFAULT_SCAN_RANGE, src)))
			return null
		if(scan_carbon.stat == DEAD) 
			return null
		if(scan_carbon.mobility_flags & MOBILITY_STAND)
			return null
		return scan_carbon
	else if(is_type_in_typecache(scan_target, target_types))
		return scan_target

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		var/mob/living/carbon/victim = locate(/mob/living/carbon) in loc
		if(victim && victim == target)
			UnarmedAttack(victim) // Acid spray

		if(isopenturf(loc) && prob(15)) // Wets floors and spawns foam randomly
			UnarmedAttack(src)
	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target) && isnull(process_scan(target)))
		target = null
	if(!target)
		target = scan(target_types)

	if(!target && auto_patrol) //Search for cleanables it can see.
		switch(mode)
			if(BOT_IDLE, BOT_START_PATROL)
				start_patrol()
			if(BOT_PATROL)
				bot_patrol()

	else if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(get_dist(src, target) <= 1)
			UnarmedAttack(target)	//Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
			if(QDELETED(target)) //We done here.
				target = null
				mode = BOT_IDLE
				return

		if(target && path.len == 0 && (get_dist(src,target) > 1))
			path = get_path_to(src, target, max_distance=30, mintargetdist=1, id=access_card)
			mode = BOT_MOVING
			if(length(path) == 0)
				add_to_ignore(target)
				target = null

		if(path.len > 0 && target)
			if(!bot_move(path[path.len]))
				target = null
				mode = BOT_IDLE
			return

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	if (emagged == 2)
		target_types = list(/mob/living/carbon)
		return

	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/glitter,
		/obj/effect/decal/remains,
		)

	if(blood)
		target_types += list(
			/obj/effect/decal/cleanable/xenoblood,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/trail_holder,
		)

	if(pests)
		target_types += list(
			/mob/living/simple_animal/cockroach,
			/mob/living/simple_animal/mouse,
		)

	if(drawn)
		target_types += list(/obj/effect/decal/cleanable/crayon)

	if(trash)
		target_types += list(
			/obj/item/trash,
			/obj/item/reagent_containers/food/snacks/deadmouse,
		)

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/attack_target)
	. = ..()
	if(ismopable(attack_target))
		mode = BOT_CLEANING
		update_icon_state()

		var/turf/T = get_turf(attack_target)
		if(do_after(src, 0.1 SECONDS, T))
			T.wash(CLEAN_WASH)
			visible_message(span_notice("[src] cleans \the [T]."))
			target = null
		
		mode = BOT_IDLE
		update_icon_state()
	else if(isitem(attack_target) || istype(attack_target, /obj/effect/decal))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [attack_target]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		attack_target.acid_act(75, 10)
		target = null
	else if(istype(attack_target, /mob/living/simple_animal/cockroach) || istype(attack_target, /mob/living/simple_animal/mouse))
		var/mob/living/living_target = attack_target
		if(!living_target.stat)
			visible_message(span_danger("[src] smashes [living_target] with its mop!"))
			living_target.death()
		target = null

	else if(emagged == 2) //Emag functions
		if(iscarbon(attack_target))
			var/mob/living/carbon/victim = attack_target
			if(victim.stat == DEAD)//cleanbots always finish the job
				target = null
				return

			victim.visible_message(span_danger("[src] sprays hydrofluoric acid at [victim]!"), span_userdanger("[src] sprays you with hydrofluoric acid!"))
			var/phrase = pick(
				"PURIFICATION IN PROGRESS.",
				"THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.",
				"THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.",
				"YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.",
				"FILTHY.",
				"DISGUSTING.",
				"PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.",
				"EXTERMINATING PESTS.",
			)
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			victim.acid_act(5, 100)
		else if(attack_target == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/current_floor = loc
				if(istype(current_floor))
					current_floor.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently, before releasing a plume of froth!"))
				new /obj/effect/particle_effect/foam(loc)

/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	new /obj/item/reagent_containers/glass/bucket(Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	..()

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"})
	if(!locked || issilicon(user)|| IsAdminGhost(user))
		dat += "<BR>Clean Blood: <A href='?src=[REF(src)];operation=blood'>[blood ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Trash: <A href='?src=[REF(src)];operation=trash'>[trash ? "Yes" : "No"]</A>"
		dat += "<BR>Clean Graffiti: <A href='?src=[REF(src)];operation=drawn'>[drawn ? "Yes" : "No"]</A>"
		dat += "<BR>Exterminate Pests: <A href='?src=[REF(src)];operation=pests'>[pests ? "Yes" : "No"]</A>"
		dat += "<BR><BR>Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"
	return dat

/mob/living/simple_animal/bot/cleanbot/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["operation"])
		switch(href_list["operation"])
			if("blood")
				blood = !blood
			if("pests")
				pests = !pests
			if("trash")
				trash = !trash
			if("drawn")
				drawn = !drawn
		get_targets()
		update_controls()

/mob/living/simple_animal/bot/cleanbot/medical
    name = "Scrubs, MD"
    desc = "A little cleaning robot, he looks so excited! This one can be configured by medbay staff."

/mob/living/simple_animal/bot/cleanbot/medical/Initialize()
    . = ..()
    bot_core.req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS, ACCESS_MEDICAL)

/mob/living/simple_animal/bot/cleanbot/spacebar
    name = "Frank Cleansington III"
    desc = "A little cleaning robot, he looks so excited! You still have no idea why your dad named it this."

/mob/living/simple_animal/bot/cleanbot/spacebar/Initialize()
	. = ..()
	bot_core.req_one_access = list(ACCESS_BAR)
