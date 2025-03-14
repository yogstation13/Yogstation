///The cooldown between messages when attempting to break out of a morgue tray.
#define BREAKOUT_COOLDOWN (5 SECONDS)
///The amount of time it takes to break out of a morgue tray.
#define BREAKOUT_TIME (60 SECONDS)


/obj/item/paper/guides/jobs/medical/morgue
	name = "morgue memo"
	info = "<font size='2'>Since this station's medbay never seems to fail to be staffed by the mindless monkeys meant for genetics experiments, \
		I'm leaving a reminder here for anyone handling the pile of cadavers the quacks are sure to leave. \
		</font><BR><BR><font size='4'><font color=red>Red lights mean there's a plain ol' dead body inside.</font><BR><BR>\
		<font color=orange>Yellow lights mean there's non-body objects inside.</font><BR><font size='2'>Probably stuff pried off a \
		corpse someone grabbed, or if you're lucky it's stashed booze.</font><BR><BR><font color=green>Green lights mean the morgue \
		system detects the body may be able to be brought back to life.</font></font><BR><font size='2'>I don't know how that works, \
		but keep it away from the kitchen and go yell at the medical doctors.</font><BR><BR>- CentCom medical inspector"


/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue tray
 *		Crematorium
 *		Creamatorium
 *		Crematorium tray
 *		Crematorium button
 */

/*
 * Bodycontainer
 * Parent class for morgue and crematorium
 * For overriding only
 */
GLOBAL_LIST_EMPTY(bodycontainers) //Let them act as spawnpoints for revenants and other ghosties.


/obj/structure/bodycontainer
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = TRUE
	anchored = TRUE
	max_integrity = 400
	dir = SOUTH

	///The morgue tray this container will open/close to put/take things in/out.
	var/obj/structure/tray/connected = null
	///Boolean on whether we're locked and will not allow the tray to be opened.
	var/locked = FALSE

	///Cooldown between breakout msesages.
	COOLDOWN_DECLARE(breakout_message_cooldown)
	/// Cooldown between being able to slide the tray in or out.
	COOLDOWN_DECLARE(open_close_cd)


/obj/structure/bodycontainer/Initialize(mapload)
	. = ..()
	if(connected)
		connected = new connected(src)
		connected.connected = src
	GLOB.bodycontainers += src
	recursive_organ_check(src)

/obj/structure/bodycontainer/Destroy()
	GLOB.bodycontainers -= src
	open()
	if(connected)
		qdel(connected)
		connected = null
	return ..()

/obj/structure/bodycontainer/on_log(login)
	..()
	update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(COOLDOWN_FINISHED(src, breakout_message_cooldown))
			COOLDOWN_START(src, breakout_message_cooldown, BREAKOUT_COOLDOWN)
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open()

/obj/structure/bodycontainer/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, span_danger("It's locked."))
		return
	if(!connected)
		to_chat(user, "That doesn't appear to have a tray.")
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)
	
/obj/structure/bodycontainer/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bodycontainer/attack_robot(mob/user)
	if(!user.Adjacent(src))
		return
	return attack_hand(user)

/obj/structure/bodycontainer/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(loc, 5)
	recursive_organ_check(src)
	qdel(src)

/obj/structure/bodycontainer/container_resist(mob/living/user)
	if(!locked)
		open()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(null, \
		span_notice("You lean on the back of [src] and start pushing the tray open... (this will take about [DisplayTimeText(BREAKOUT_TIME)].)"), \
		span_italics("You hear a metallic creaking from [src]."))
	if(!do_after(user, BREAKOUT_TIME, target = src))
		return
	if(!user || user.stat != CONSCIOUS || user.loc != src)
		return
	user.visible_message(
		span_warning("[user] successfully broke out of [src]!"),
		span_notice("You successfully break out of [src]!"),
	)
	open()

/obj/structure/bodycontainer/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/structure/bodycontainer/proc/open()
	recursive_organ_check(src)
	if(!COOLDOWN_FINISHED(src, open_close_cd))
		return FALSE

	COOLDOWN_START(src, open_close_cd, 0.25 SECONDS)
	playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
	playsound(src, 'sound/effects/roll.ogg', 5, 1)
	var/turf/dump_turf = get_step(src, dir)
	connected?.setDir(dir)
	for(var/atom/movable/moving in src)
		moving.forceMove(dump_turf)
		animate_slide_out(moving)
	recursive_organ_check(src)
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/bodycontainer/proc/close()
	if(!COOLDOWN_FINISHED(src, open_close_cd))
		return FALSE

	COOLDOWN_START(src, open_close_cd, 0.5 SECONDS)
	playsound(src, 'sound/effects/roll.ogg', 5, 1)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	var/turf/close_loc = connected.loc
	for(var/atom/movable/entering in close_loc)
		if(entering.anchored && entering != connected)
			continue
		if(isliving(entering))
			var/mob/living/living_mob = entering
			if(living_mob.incorporeal_move)
				continue
		else if(istype(entering, /obj/effect/dummy/phased_mob) || isdead(entering))
			continue
		animate_slide_in(entering, close_loc)
		entering.forceMove(src)
	update_appearance(UPDATE_ICON)

#define SLIDE_LENGTH (0.3 SECONDS)

/// Slides the passed object out of the morgue tray.
/obj/structure/bodycontainer/proc/animate_slide_out(atom/movable/animated)
	var/old_layer = animated.layer
	animated.layer = layer - (animated == connected ? 0.03 : 0.01)
	animated.pixel_x = animated.base_pixel_x + (x * 32) - (animated.x * 32)
	animated.pixel_y = animated.base_pixel_y + (y * 32) - (animated.y * 32)
	animate(
		animated,
		pixel_x = animated.base_pixel_x,
		pixel_y = animated.base_pixel_y,
		time = SLIDE_LENGTH,
		easing = CUBIC_EASING|EASE_OUT,
		flags = ANIMATION_PARALLEL,
	)
	addtimer(VARSET_CALLBACK(animated, layer, old_layer), SLIDE_LENGTH)

/// Slides the passed object into the morgue tray from the passed turf.
/obj/structure/bodycontainer/proc/animate_slide_in(atom/movable/animated, turf/from_loc)
	// It's easier to just make a visual for entering than to animate the object itself
	var/obj/effect/temp_visual/morgue_content/visual = new(from_loc, animated)
	visual.layer = layer - (animated == connected ? 0.03 : 0.01)
	animate(
		visual,
		pixel_x = visual.base_pixel_x + (x * 32) - (visual.x * 32),
		pixel_y = visual.base_pixel_y + (y * 32) - (visual.y * 32),
		time = SLIDE_LENGTH,
		easing = CUBIC_EASING|EASE_IN,
		flags = ANIMATION_PARALLEL,
	)

/// Used to mimic the appearance of an object sliding into a morgue tray.
/obj/effect/temp_visual/morgue_content
	duration = SLIDE_LENGTH

/obj/effect/temp_visual/morgue_content/Initialize(mapload, atom/movable/sliding_in)
	. = ..()
	if(isnull(sliding_in))
		return

	appearance = sliding_in.appearance
	dir = sliding_in.dir
	alpha = sliding_in.alpha
	base_pixel_x = sliding_in.base_pixel_x
	base_pixel_y = sliding_in.base_pixel_y

#undef SLIDE_LENGTH

#define MORGUE_EMPTY 1
#define MORGUE_NO_MOBS 2
#define MORGUE_ONLY_BRAINDEAD 3
#define MORGUE_HAS_REVIVABLE 4

/*
 * Morgue
 */
/obj/structure/bodycontainer/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them. Includes a high-tech alert system."
	icon_state = "morgue1"
	dir = EAST
	var/beeper = TRUE
	var/beep_cooldown = 50
	var/next_beep = 0

	connected = /obj/structure/tray/morgue

/obj/structure/bodycontainer/morgue/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance(UPDATE_ICON)
	if(!istype(arrived, /obj/structure/closet/body_bag))
		return
	var/obj/structure/closet/body_bag/arrived_bag = arrived
	if(!arrived_bag.tag_name)
		return
	name = "[initial(name)] - ([arrived_bag.tag_name])"

/obj/structure/bodycontainer/morgue/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/structure/closet/body_bag))
		name = initial(name)
	update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/morgue/examine(mob/user)
	. = ..()
	. += span_notice("The speaker is [beeper ? "enabled" : "disabled"]. Alt-click to toggle it.")

/obj/structure/bodycontainer/morgue/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	beeper = !beeper
	to_chat(user, span_notice("You turn the speaker function [beeper ? "on" : "off"]."))

/obj/structure/bodycontainer/morgue/update_icon_state()
	if(!connected || connected.loc != src) // Open or tray is gone
		icon_state = "morgue0"
		return ..()

	if(contents.len == 1)  // Empty
		icon_state = "morgue1"
		return ..()

	var/list/compiled = get_all_contents_type(/mob/living) // Search for mobs in all contents
	if(!length(compiled)) // No mobs?
		icon_state = "morgue3"
		return ..()

	for(var/mob/living/M in compiled)
		var/mob/living/mob_occupant = get_mob_or_brainmob(M)
		if(mob_occupant.client && !(HAS_TRAIT(mob_occupant, TRAIT_SUICIDED))&& !(HAS_TRAIT(mob_occupant, TRAIT_BADDNA)))
			icon_state = "morgue4" // Revivable
			if(mob_occupant.stat == DEAD && beeper && COOLDOWN_FINISHED(src, next_beep))
				playsound(src, 'sound/weapons/smg_empty_alarm.ogg', 50, FALSE) // Revive them you blind fucks
				COOLDOWN_START(src, next_beep, beep_cooldown)
			return ..()

	icon_state = "morgue2" // Dead, brainded mob.
	return ..()

#undef MORGUE_EMPTY
#undef MORGUE_NO_MOBS
#undef MORGUE_ONLY_BRAINDEAD
#undef MORGUE_HAS_REVIVABLE

/*
 * Crematorium
 */

GLOBAL_LIST_EMPTY(crematoriums)

/obj/structure/bodycontainer/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbecue nights."
	icon_state = "crema1"
	dir = SOUTH
	var/cremate_time = 3 SECONDS
	var/cremate_timer
	var/id = 1

/obj/structure/bodycontainer/crematorium/Destroy()
	GLOB.crematoriums.Remove(src)
	return ..()

/obj/structure/bodycontainer/crematorium/attack_robot(mob/user) //Borgs can't use crematoriums without help
	to_chat(user, span_warning("[src] is locked against you."))
	return

/obj/structure/bodycontainer/crematorium/New()
	GLOB.crematoriums.Add(src)
	..()

/obj/structure/bodycontainer/crematorium/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/update_icon_blocker)
	connected = new /obj/structure/tray/cremator(src)
	connected.connected = src

/obj/structure/bodycontainer/crematorium/update_icon_state()
	. = ..()
	if(!connected || connected.loc != src)
		icon_state = "crema0"
		return
	if(locked)
		icon_state = "crema_active"
		return
	if(contents.len > 1)
		icon_state = "crema2"
		return
	icon_state = "crema1"

/obj/structure/bodycontainer/crematorium/proc/cremate(mob/user)
	if(locked)
		return //don't let you cremate something twice or w/e
	if(is_synth(user))
		return
	// Make sure we don't delete the actual morgue and its tray
	var/list/conts = get_all_contents() - src - connected

	if(!conts.len)
		audible_message(span_italics("You hear a hollow crackle."))
		return

	else
		audible_message(span_italics("You hear a roar as the crematorium fires up."))
		locked = TRUE
		update_appearance(UPDATE_ICON)
		cremate_timer = addtimer(CALLBACK(src, PROC_REF(finish_cremate), user), (BREAKOUT_TIME + cremate_time ), TIMER_STOPPABLE)
		

/obj/structure/bodycontainer/crematorium/open()
	. = ..()
	if(cremate_timer)
		locked = FALSE
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //you horrible people
		deltimer(cremate_timer)
		cremate_timer = null
		update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/crematorium/proc/finish_cremate(mob/user)
	var/list/conts = get_all_contents() - src - connected
	audible_message(span_italics("You hear a roar as the crematorium reaches its maximum temperature."))
	for(var/mob/living/M in conts)
		if(M.status_flags & GODMODE)
			to_chat(M, span_userdanger("A strange force protects you!"))
			M.adjust_fire_stacks(40)
			M.ignite_mob()
			continue
		if(M.stat != DEAD)
			M.emote("scream")
		if(M.client)
			if(M.stat != DEAD)
				SSachievements.unlock_achievement(/datum/achievement/cremated_alive, M.client) //they are in body and alive, give achievement
			SSachievements.unlock_achievement(/datum/achievement/cremated, M.client) //they are in body, but dead, they can have one achievement
		else if(M.oobe_client) //they might be ghosted if they are dead, we'll allow it.
			SSachievements.unlock_achievement(/datum/achievement/cremated, M.oobe_client) //no burning alive achievement if you are ghosted though
		if(user)
			log_combat(user, M, "cremated")
		else
			M.log_message("was cremated", LOG_ATTACK)

		M.death(1)
		if(M) //some animals get automatically deleted on death.
			M.ghostize()
			qdel(M)

	for(var/obj/O in conts) //conts defined above, ignores crematorium and tray
		if(O.resistance_flags & INDESTRUCTIBLE)
			continue
		
		if(istype(O, /obj/item/grenade))
			log_bomber(user, "cremated a ", O, ", detonating it.")
			var/obj/item/grenade/nade = O
			nade.prime()
		else if(istype(O, /obj/item/tank))
			log_bomber(user, "cremated a ", O, ", igniting it.")
			var/obj/item/tank/tank = O
			tank.ignite()
		else if(istype(O, /obj/item/bombcore))
			log_bomber(user, "cremated a ", O, ", detonating it.")
			var/obj/item/bombcore/bomb = O
			bomb.detonate()
		else if(isitem(O))
			var/obj/item/I = O
			if(I.cryo_preserve)
				log_combat(user, O, "cremated")
		qdel(O)

	if(!locate(/obj/effect/decal/cleanable/ash) in get_step(src, dir))//prevent pile-up
		new/obj/effect/decal/cleanable/ash/crematorium(src)

	if(!QDELETED(src))
		locked = FALSE
		update_appearance(UPDATE_ICON)
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1) //you horrible people

/*
 * Generic Tray
 * Parent class for morguetray and crematoriumtray
 * For overriding only
 */
/obj/structure/tray
	icon = 'icons/obj/stationobjs.dmi'
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW
	layer = TABLE_LAYER
	max_integrity = 350

	///The bodycontainer we are a tray to.
	var/obj/structure/bodycontainer/connected

/obj/structure/tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_appearance(UPDATE_ICON)
		connected = null
	return ..()

/obj/structure/tray/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/structure/tray/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/tray/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if (connected)
		connected.close()
	else
		to_chat(user, span_warning("That's not connected to anything!"))

/obj/structure/tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user)
	if(!ismovable(O) || O.anchored || !Adjacent(user) || !user.Adjacent(O) || O.loc == user)
		return
	if(!ismob(O))
		if(!istype(O, /obj/structure/closet/body_bag))
			return
	else
		var/mob/M = O
		if(M.buckled)
			return
	if(!ismob(user) || user.incapacitated())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	O.forceMove(src.loc)
	if (user != O)
		visible_message(span_warning("[user] stuffs [O] into [src]."))
	return

//Crematorium tray
/obj/structure/tray/cremator
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "cremat"
	layer = /obj/structure/bodycontainer/crematorium::layer - 0.03

// Morgue tray
/obj/structure/tray/morgue
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon_state = "morguet"
	layer = /obj/structure/bodycontainer/morgue::layer - 0.03

/obj/structure/tray/morgue/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

/obj/structure/tray/morgue/CanAStarPass(ID, dir, caller_but_not_a_byond_built_in_proc)
	. = !density
	if(ismovable(caller_but_not_a_byond_built_in_proc))
		var/atom/movable/mover = caller_but_not_a_byond_built_in_proc
		. = . || (mover.pass_flags & PASSTABLE)

#undef BREAKOUT_COOLDOWN
#undef BREAKOUT_TIME
