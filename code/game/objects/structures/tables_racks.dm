/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.")
	max_integrity = 100
	integrity_failure = 30
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/metal
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = 1

/obj/structure/table/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep_override, priority = STEP_SOUND_TABLE_PRIORITY)
	AddElement(/datum/element/climbable)
	AddComponent(/datum/component/surgery_bed, \
		success_chance = 0.8, \
	)

/** Performs a complex check for toe stubbing as people would scream "IMPROVE DONT REMOVE" if I had my way.
  * Uses an early probability based return for to save cycles which is perfectly valid since the highest probability is 20 anyway.
  * Chance of getting your toe stubbed: (regular = 0.033%, running = 0.1%, blind = 20%, blurry_eyes = 2%, congenitally blind = 1%  )
  * Chance goes up if you go fast, such as with meth. So does damage.
  */
/obj/structure/table/Bumped(mob/living/carbon/human/H)
	. = ..()
	if(prob(80))
		return
	if(!istype(H) || H.shoes || !(H.mobility_flags & MOBILITY_STAND) || !H.dna.species.has_toes())
		return
	var/speed_multiplier = 2/H.cached_multiplicative_slowdown
	var/blindness_multiplier = 1
	if(H.eye_blurry)
		blindness_multiplier = 4
	if(H.eye_blind)
		blindness_multiplier = 200
	if(HAS_TRAIT_FROM(H, "blind", ROUNDSTART_TRAIT))
		blindness_multiplier = 2
	var/chance = 0.5*blindness_multiplier*speed_multiplier
	if(prob(chance))
		to_chat(H, span_warning("You stub your toe on the [name]!"))
		H.visible_message("[H] stubs their toe on the [name].")
		H.emote("scream")
		var/shiddedleg = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
		H.apply_damage(2*speed_multiplier, BRUTE, def_zone = shiddedleg)
		H.apply_damage(30*speed_multiplier, STAMINA, def_zone = shiddedleg)
		H.Paralyze(10*speed_multiplier)

/obj/structure/table/examine(mob/user)
	. = ..()
	if(!(flags_1 & NODECONSTRUCT_1))
		. += deconstruction_hints(user)

/obj/structure/table/proc/deconstruction_hints(mob/user)
	return span_notice("The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.")

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/table/narsie_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/wood(A)

/obj/structure/table/ratvar_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/reinforced/brass(A)

/obj/structure/table/honk_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/bananium(A)

/obj/structure/table/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/table/attack_hand(mob/living/user, modifiers)
	if(Adjacent(user) && user.pulling)
		if(isliving(user.pulling))
			var/mob/living/pushed_mob = user.pulling
			if(pushed_mob.buckled)
				to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
				return
			if(user.combat_mode)
				switch(user.grab_state)
					if(GRAB_PASSIVE)
						to_chat(user, span_warning("You need a better grip to do that!"))
						return
					if(GRAB_AGGRESSIVE to GRAB_KILL)
						if(do_after(user, 3.5 SECONDS, pushed_mob))
							tablepush(user, pushed_mob)
			else
				pushed_mob.visible_message(span_notice("[user] begins to place [pushed_mob] onto [src]..."), \
									span_userdanger("[user] begins to place [pushed_mob] onto [src]..."))
				if(do_after(user, 3.5 SECONDS,pushed_mob))
					tableplace(user, pushed_mob)
				else
					return
			user.stop_pulling()
		else if(user.pulling.pass_flags & PASSTABLE)
			user.Move_Pulled(src)
			if (user.pulling.loc == loc)
				user.visible_message(span_notice("[user] places [user.pulling] onto [src]."),
					span_notice("You place [user.pulling] onto [src]."))
				user.stop_pulling()
	return ..()

/obj/structure/table/attack_tk()
	return FALSE

/obj/structure/table/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()

	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		var/obj/item/tank/jetpack/jetpacktable = C.get_jetpack()
		if(jetpacktable && jetpacktable.on && !has_gravity(C))
			return 1
	if(mover.throwing)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

/obj/structure/table/CanAStarPass(ID, dir, caller_but_not_a_byond_built_in_proc)
	. = !density
	if(ismovable(caller_but_not_a_byond_built_in_proc))
		var/atom/movable/mover = caller_but_not_a_byond_built_in_proc
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/table/proc/tableplace(mob/living/user, mob/living/pushed_mob)
	SEND_SIGNAL(user, COMSIG_MOB_TABLING)
	pushed_mob.forceMove(loc)
	pushed_mob.set_resting(TRUE, TRUE)
	pushed_mob.visible_message(span_notice("[user] places [pushed_mob] onto [src]."), \
								span_notice("[user] places [pushed_mob] onto [src]."))
	log_combat(user, pushed_mob, "places", null, "onto [src]")

/obj/structure/table/proc/tablepush(mob/living/user, mob/living/pushed_mob)
	var/added_passtable = FALSE
	if(!(pushed_mob.pass_flags & PASSTABLE))
		added_passtable = TRUE
		pushed_mob.pass_flags |= PASSTABLE
	SEND_SIGNAL(user, COMSIG_MOB_TABLING)
	pushed_mob.Move(src.loc)
	if(added_passtable)
		pushed_mob.pass_flags &= ~PASSTABLE
	if(pushed_mob.loc != loc) //Something prevented the tabling
		return
	pushed_mob.Paralyze(40)
	pushed_mob.visible_message(span_danger("[user] pushes [pushed_mob] onto [src]."), \
								span_userdanger("[user] pushes [pushed_mob] onto [src]."))
	log_combat(user, pushed_mob, "tabled", null, "onto [src]")
	if(!ishuman(pushed_mob))
		return
	var/mob/living/carbon/human/H = pushed_mob
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)

/obj/structure/table/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rsf)) // Stops RSF from placing itself instead of glasses
		return

	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY, drop_location())
			user.visible_message("[user] empties [I] on [src].")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(!user.combat_mode && !HAS_TRAIT(I, TRAIT_NODROP) && !(I.item_flags & ABSTRACT)) // if you can't drop it, you can't place it on the table
		if(user.transferItemToLoc(I, drop_location()))
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return 1
	else if(!user.combat_mode && !(I.item_flags & ABSTRACT)) // can't drop the item but not in combat mode, try deconstructing instead
		return attackby_secondary(I, user, params)
	else
		return ..()

/obj/structure/table/attackby_secondary(obj/item/weapon, mob/user, params) // right click to deconstruct
	if(!(flags_1 & NODECONSTRUCT_1) && deconstruction_ready)
		if(weapon.tool_behaviour == TOOL_SCREWDRIVER)
			to_chat(user, span_notice("You start disassembling [src]..."))
			if(weapon.use_tool(src, user, 20, volume=50))
				deconstruct(TRUE)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		if(weapon.tool_behaviour == TOOL_WRENCH)
			to_chat(user, span_notice("You start deconstructing [src]..."))
			if(weapon.use_tool(src, user, 40, volume=50))
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				deconstruct(TRUE, 1)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		new buildstack(T, buildstackamount)
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)

/obj/structure/table/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.construction_mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 24, "cost" = 16)
	return FALSE

/obj/structure/table/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the table."))
			qdel(src)
			return TRUE
	return FALSE

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"
	buildstack = /obj/item/stack/sheet/glass
	smoothing_groups = SMOOTH_GROUP_GLASS_TABLES
	canSmoothWith = SMOOTH_GROUP_GLASS_TABLES
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100)
	var/list/debris = list()

/obj/structure/table/glass/Initialize(mapload)
	. = ..()
	debris += new frame
	debris += new /obj/item/shard
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/glass/Destroy()
	QDEL_LIST(debris)
	. = ..()

/obj/structure/table/glass/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!isliving(AM))
		return
	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, PROC_REF(throw_check), AM), 5)
	else
		check_break(AM)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL && !(M.movement_type & FLYING))
		table_shatter(M)

/obj/structure/table/glass/proc/table_shatter(mob/living/L)
	visible_message(span_warning("[src] breaks!"),
		span_danger("You hear breaking glass."))
	var/turf/T = get_turf(src)
	playsound(T, "shatter", 50, 1)
	for(var/I in debris)
		var/atom/movable/AM = I
		AM.forceMove(T)
		debris -= AM
		if(istype(AM, /obj/item/shard))
			AM.throw_impact(L)
	L.Paralyze(100)
	qdel(src)

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, 1)
			for(var/X in debris)
				var/atom/movable/AM = X
				AM.forceMove(T)
				debris -= AM
	qdel(src)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/shard/S in debris)
		S.color = NARSIE_WINDOW_COLOUR

/*
 * Wooden tables
 */

/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/mineral/wood
	buildstack = /obj/item/stack/sheet/mineral/wood
	resistance_flags = FLAMMABLE
	max_integrity = 70
	smoothing_groups = SMOOTH_GROUP_WOOD_TABLES //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_WOOD_TABLES

/obj/structure/table/wood/narsie_act(total_override = TRUE)
	if(!total_override)
		..()

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table-0"
	base_icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	base_icon_state = "fancy_table"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	smoothing_groups = SMOOTH_GROUP_FANCY_WOOD_TABLES //Don't smooth with SMOOTH_GROUP_TABLES or SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = SMOOTH_GROUP_FANCY_WOOD_TABLES
	var/smooth_icon = 'icons/obj/smooth_structures/fancy_table.dmi' // see Initialize()


/obj/structure/table/wood/fancy/Initialize(mapload)
	. = ..()
	// Needs to be set dynamically because table smooth sprites are 32x34,
	// which the editor treats as a two-tile-tall object. The sprites are that
	// size so that the north/south corners look nice - examine the detail on
	// the sprites in the editor to see why.
	icon = smooth_icon

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black"
	base_icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue"
	base_icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan"
	base_icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green"
	base_icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange"
	base_icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple"
	base_icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red"
	base_icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack"
	base_icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue"
	base_icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblue.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"
	deconstruction_ready = 0
	buildstack = /obj/item/stack/sheet/plasteel
	max_integrity = 200
	integrity_failure = 50
	armor = list(MELEE = 10, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 20, BIO = 0, RAD = 0, FIRE = 80, ACID = 70, ELECTRIC = 100)

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		return span_notice("The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.")
	else
		return span_notice("The top cover is firmly <b>welded</b> on.")

/obj/structure/table/reinforced/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_WELDER)
		if(!weapon.tool_start_check(user, amount=0))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		if(deconstruction_ready)
			to_chat(user, span_notice("You start strengthening the reinforced table..."))
			if (weapon.use_tool(src, user, 50, volume=50))
				to_chat(user, span_notice("You strengthen the table."))
				deconstruction_ready = 0
		else
			to_chat(user, span_notice("You start weakening the reinforced table..."))
			if (weapon.use_tool(src, user, 50, volume=50))
				to_chat(user, span_notice("You weaken the table."))
				deconstruction_ready = 1
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/table/reinforced/brass
	name = "brass table"
	desc = "A solid, slightly beveled brass table."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/brass
	framestack = /obj/item/stack/tile/brass
	buildstack = /obj/item/stack/tile/brass
	framestackamount = 1
	buildstackamount = 1
	smoothing_groups = SMOOTH_GROUP_BRONZE_TABLES //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_BRONZE_TABLES

/obj/structure/table/reinforced/brass/Initialize(mapload)
	. = ..()
	change_construction_value(2)

/obj/structure/table/reinforced/brass/Destroy()
	change_construction_value(-2)
	return ..()

/obj/structure/table/reinforced/brass/tablepush(mob/living/user, mob/living/pushed_mob)
	.= ..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/obj/structure/table/reinforced/brass/narsie_act()
	take_damage(rand(15, 45), BRUTE)
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 0.8 SECONDS)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 0.8 SECONDS)

/obj/structure/table/reinforced/brass/ratvar_act()
	update_integrity(max_integrity)

/obj/structure/table/bronze
	name = "bronze table"
	desc = "A solid table made out of bronze."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstack = /obj/item/stack/tile/bronze
	smoothing_groups = SMOOTH_GROUP_BRONZE_TABLES //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_BRONZE_TABLES

/obj/structure/table/bronze/tablepush(mob/living/user, mob/living/pushed_mob)
	..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_buckle = TRUE

/obj/structure/table/optable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_bed, \
		success_chance = 1, \
		op_computer_linkable = TRUE, \
	)

/obj/structure/table/optable/tablepush(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(loc)
	pushed_mob.set_resting(TRUE, TRUE)
	visible_message(span_notice("[user] lays [pushed_mob] on [src]."))

/obj/structure/table/optable/debug/Initialize(mapload)
	. = ..()
	var/datum/component/surgery_bed/SB = GetComponent(/datum/component/surgery_bed)
	SB.extra_surgeries = subtypesof(/datum/surgery)

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.
	max_integrity = 20

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/rack/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

/obj/structure/rack/CanAStarPass(ID, dir, caller_but_not_a_byond_built_in_proc)
	. = !density
	if(ismovable(caller_but_not_a_byond_built_in_proc))
		var/atom/movable/mover = caller_but_not_a_byond_built_in_proc
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	. = ..()
	if ((!( istype(O, /obj/item) ) || user.get_active_held_item() != O))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/rack/attackby(obj/item/W, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(user.transferItemToLoc(W, drop_location()))
		return TRUE

/obj/structure/rack/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_WRENCH && !(flags_1 & NODECONSTRUCT_1))
		weapon.play_tool_sound(src)
		deconstruct(TRUE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/structure/rack/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/rack/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!(user.mobility_flags & MOBILITY_STAND) || user.get_num_legs() < 2)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_danger("[user] kicks [src]."), null, null, COMBAT_MESSAGE_RANGE)
	take_damage(rand(4,8), BRUTE, MELEE, 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, 1)

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags_1&NODECONSTRUCT_1))
		density = FALSE
		var/obj/item/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)


/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/frame.dmi'
	icon_state = "rack_parts"
	flags_1 = CONDUCT_1
	materials = list(/datum/material/iron=2000)
	var/building = FALSE
	var/obj/construction_type = /obj/structure/rack

/obj/item/rack_parts/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/metal(user.loc)
		qdel(src)
	else
		. = ..()

/obj/item/rack_parts/attack_self(mob/user)
	if(locate(construction_type) in get_turf(user))
		balloon_alert(user, "no room!")
		return
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("You start assembling [src]..."))
	if(do_after(user, 5 SECONDS, user))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/R = new construction_type(user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", span_notice("You assemble \a [R]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
