//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 		= 75, // med borgs could try to unscrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]..."),
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_open/tool_check(mob/user, obj/item/tool)
	if(istype(tool))
		if(!tool.is_sharp())
			return FALSE
		if(tool.usesound)
			preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 		= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 2.4 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to screw the shell of [target]'s [parse_zone(target_zone)]..."),
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(istype(tool))
		if(!tool.is_sharp())
			return FALSE
		if(tool.usesound)
			preop_sound = tool.usesound

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics"
	implements = list(
		TOOL_MULTITOOL = 100,
		/obj/item/melee/touch_attack/shock = 90,
		/obj/item/gun/energy = 90,
		/obj/item/melee/baton = 90, // try to reboot internal controllers via short circuit with some conductor
		/obj/item/shockpaddles = 90,
		TOOL_HEMOSTAT = 20) //"safe" option, but super tedious
	time = 2.4 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder_close.ogg'
	failure_sound = 'sound/machines/defib_zap.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to prepare electronics in [target]'s [parse_zone(target_zone)]..."),
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].",
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/prepare_electronics/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!(tool.tool_behaviour == TOOL_MULTITOOL || tool.tool_behaviour == TOOL_HEMOSTAT))
		target.electrocute_act(10, tool, stun = FALSE)//reduced damage if successful
	return ..()

/datum/surgery_step/prepare_electronics/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!(tool.tool_behaviour == TOOL_MULTITOOL || tool.tool_behaviour == TOOL_HEMOSTAT))
		target.electrocute_act(20, tool, stun = FALSE)//reduced damage if successful
	return ..()

/datum/surgery_step/prepare_electronics/play_success_sound(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!success_sound)
		return
	var/sound_file_use
	if(islist(success_sound ))	
		for(var/typepath in success_sound )//iterate and assign subtype to a list, works best if list is arranged from subtype first and parent last
			if(istype(tool, typepath))
				sound_file_use = success_sound [typepath]	
				break	
	else
		sound_file_use = success_sound
	if(!sound_file_use)
		return
	if(tool.tool_behaviour == TOOL_MULTITOOL || tool.tool_behaviour == TOOL_HEMOSTAT)
		playsound(get_turf(target), sound_file_use, 30, TRUE, falloff_exponent = 2)
	else
		playsound(get_turf(target), 'sound/machines/defib_zap.ogg', 30, TRUE, falloff_exponent = 2)

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_CROWBAR = 100,//this sounds like a REALLY bad idea
		TOOL_RETRACTOR = 20)
	time = 2.4 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_CROWBAR)
		display_results(user, target, span_notice("You begin reefing on the bolts in [target]'s [parse_zone(target_zone)]..."),
				"[user] begins reefing on some bolts in [target]'s [parse_zone(target_zone)].",
				"[user] begins reefing on some bolts in [target]'s [parse_zone(target_zone)].")
	else
		display_results(user, target, span_notice("You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]..."),
				"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].",
				"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_unwrench/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_CROWBAR)
		target.apply_damage(10, BRUTE, target_zone)//reduced damage if successful
	return ..()

/datum/surgery_step/mechanic_unwrench/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_CROWBAR)
		target.apply_damage(20, BRUTE, target_zone)
	return ..()

/datum/surgery_step/mechanic_unwrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound
	return TRUE

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_WELDER = 100, //also a terrible idea
		TOOL_RETRACTOR = 20)
	time = 2.4 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_WELDER)
		display_results(user, target, span_notice("You begin to weld some bolts in [target]'s [parse_zone(target_zone)]..."),
				"[user] begins to weld some bolts in [target]'s [parse_zone(target_zone)].",
				"[user] begins to weld some bolts in [target]'s [parse_zone(target_zone)].")
	else
		display_results(user, target, span_notice("You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]..."),
				"[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].",
				"[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_wrench/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_WELDER)
		target.apply_damage(10, BURN, target_zone)//reduced damage if successful
	return ..()

/datum/surgery_step/mechanic_wrench/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool.tool_behaviour == TOOL_WELDER)
		target.apply_damage(20, BURN, target_zone)
	return ..()

/datum/surgery_step/mechanic_wrench/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound
	return TRUE

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch"
	accept_hand = TRUE
	time = 1 SECONDS
	bloody_chance = FALSE
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]..."),
		"[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].",
		"[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/open_hatch/tool_check(mob/user, obj/item/tool)
	if(tool.usesound)
		preop_sound = tool.usesound
	return TRUE
