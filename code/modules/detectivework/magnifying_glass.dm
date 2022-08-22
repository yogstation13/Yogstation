/// Magnifying Glass: A worse forensic scanner
/// Also ignites things at range instantly (with a cooldown) if you are within 2 tiles of visible space
/// Ignite cooldown is the same time it takes to examine something with the magnifying glass
/obj/item/magnifying_glass
	name = "magnifying glass"
	desc = "A magnifying glass with some basic processing power used to help you look at things up close. A warning tag says not to use it near space."
	icon = 'icons/obj/traitor.dmi'
	icon_state = "magnify"
	w_class = WEIGHT_CLASS_SMALL

	COOLDOWN_DECLARE(fire_cooldown)
	var/fire_strength = 0.5 /// Strength of the ignition
	var/cooldown_define = 6 SECONDS /// How fast you can ignite and examine things
	// Slower than a forensic scanner
	var/clockwork = FALSE /// Usable by non-clockies?
	var/range = 9 /// examine/fire range

/obj/item/magnifying_glass/syndicate
	name = "suspicious magnifying glass"
	desc = "A sleek magnifying glass. Has a Syndicate logo emblazoned on the handle."
	icon_state = "magnify_syndie"
	fire_strength = 2
	cooldown_define = 3 SECONDS

/obj/item/magnifying_glass/clockwork
	name = "zealot's magnifying glass"
	desc = "A strange yellow investigation device."
	icon_state = "magnify_clock"
	fire_strength = 5 // Ratvar's light engulfs you, heretic!
	cooldown_define = 5 SECONDS
	clockwork = TRUE

/obj/item/magnifying_glass/examine(mob/user)
	. = ..()
	if(!clockwork || is_clockcult(user))
		. += span_notice("It has a magnification rating of <B>[fire_strength * 2]</B>.")
		. += span_notice("The glass is smudged a bit. It will take <B>[cooldown_define/10]</B> second[cooldown_define == 1 ? "" : "s"] to get a good look at something.")
	else
		. += span_brass("You can't quite seem to figure out how to use this.")

/obj/item/magnifying_glass/proc/add_log(msg, broadcast = 1) // some sense of modularity with forensic scanner
	if(broadcast && ismob(loc))
		var/mob/M = loc
		to_chat(M, msg)

/obj/item/magnifying_glass/afterattack(atom/target, mob/living/user, proximity_flag)
	. = ..()
	if(!target)
		return
	
	if(get_dist(src, target) > range)
		to_chat(user, span_warning("\The [target] is too far away to inspect!"))
		return

	
	if(clockwork && !is_clockcult(user)) // whoops
		to_chat(user, span_heavy_brass("\The [src] redirects its light into your eyes!"))
		user.blind_eyes(30)
		user.Dizzy(30)
		user.adjust_fire_stacks(fire_strength + 1)
		user.IgniteMob()
		return


	to_chat(user, span_notice("You carefully focus \the [src] on \the [target]..."))

	var/can_see_space = FALSE
	if(isspaceturf(user.loc))
		can_see_space = 2 // Slightly stronger focus if we're literally in space
	else
		for(var/turf/open/T in oview(2, user)) // Every turf up to 2 tiles away
			if(isspaceturf(T))
				can_see_space = 1
				break

	if(can_see_space && COOLDOWN_FINISHED(src, fire_cooldown))
		to_chat(user, span_danger("\The [src] directs starlight at \the [target]!"))
		if(isliving(target))
			var/mob/living/L = target
			if(!clockwork || !is_clockcult(L))
				L.adjust_fire_stacks(fire_strength + can_see_space - 1)
				L.IgniteMob()
			else
				to_chat(user, span_danger("\The [src] cannot attack other servants!"))
			COOLDOWN_START(src, fire_cooldown, cooldown_define)
		else if(isobj(target))
			var/obj/O = target
			O.fire_act()
			COOLDOWN_START(src, fire_cooldown, cooldown_define)
	// HERE ONWARDS IS FORENSIC SCANNER
	else if(do_after_mob(user, list(target), cooldown_define, TRUE))
		// GATHER INFORMATION
		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = target.return_blood_DNA()
		var/list/fibers = target.return_fibers()
		var/list/reagents = list()

		var/found_something = FALSE

		var/target_name = target.name

		// Start gathering

		if(ishuman(target))

			var/mob/living/carbon/human/H = target
			if(!H.gloves)
				fingerprints += md5(H.dna.uni_identity)

		else if(!ismob(target))

			fingerprints = target.return_fingerprints()

			// Only get reagents from non-mobs.
			if(target.reagents && target.reagents.reagent_list.len)

				for(var/datum/reagent/R in target.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							LAZYINITLIST(blood)
							blood[blood_DNA] = blood_type

		// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.
		found_something = 0
		add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", 0)

		// Fingerprints
		if(length(fingerprints))
			add_log(span_info("<B>Prints:</B>"))
			for(var/finger in fingerprints)
				add_log("[finger]")
			found_something = 1

		// Blood
		if (length(blood))
			add_log(span_info("<B>Blood:</B>"))
			for(var/B in blood)
				add_log("Type: <font color='red'>[blood[B]]</font> DNA: <font color='red'>[B]</font>")
				found_something = 1

		//Fibers
		if(length(fibers))
			add_log(span_info("<B>Fibers:</B>"))
			for(var/fiber in fibers)
				add_log("[fiber]")
			found_something = 1

		//Reagents
		if(length(reagents))
			add_log(span_info("<B>Reagents:</B>"))
			for(var/R in reagents)
				add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
			found_something = 1

		// Get a new user
		var/mob/holder = null
		if(ismob(src.loc))
			holder = src.loc

		if(!found_something)
			add_log("<I># No forensic traces found #</I>", 0) // Don't display this to the holder user
			if(holder)
				to_chat(holder, span_warning("Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!"))
		else
			if(holder)
				to_chat(holder, span_notice("You finish inspecting \the [target_name]."))

		add_log("---------------------------------------------------------")
	
