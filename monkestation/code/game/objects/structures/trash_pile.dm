/// Maximum total pieces of trash that will be thrown by one person while digging through a trash pile.
/// Used to prevent infinite trash from canceling before you finish digging.
/// I consistently counted 7 across multiple times of me doing it, so 7 it is.
#define MAXIMUM_TRASH_THROWS 7

/obj/structure/trash_pile
	name = "trash pile"
	desc = "A heap of dense garbage. Perhaps there is something interesting inside?"
	icon = 'monkestation/icons/obj/trash_piles.dmi'
	icon_state = "randompile"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT
	pass_flags_self = LETPASSTHROW | LETPASSCLICKS

	max_integrity = 50

	var/hide_person_time = 3 SECONDS
	var/hide_item_time = 1 SECONDS

	/// Associative list of ckeys to TRUE if they have searched it.
	var/list/searched_by_ckeys = list()
	/// Associative list of ckeys to how many more pieces of trash they can throw out while digging.
	var/list/remaining_trash_throws = list()

	var/trash_delay = 0.5 SECONDS
	var/funny_sound_delay = 0.2 SECONDS

	COOLDOWN_DECLARE(trash_cooldown)
	COOLDOWN_DECLARE(funny_sound_cooldown)

	var/static/list/funny_sounds = list( //Assoc list of funny sounds (funny sound to weight)
		'sound/effects/adminhelp.ogg' = 1,
		'sound/effects/footstep/clownstep1.ogg' = 5,
		'sound/effects/footstep/clownstep2.ogg' = 5,
		'sound/effects/footstep/meowstep1.ogg' = 1,
		'sound/effects/attackblob.ogg' = 10,
		'sound/effects/bang.ogg' = 10,
		'sound/effects/bin_close.ogg' = 20,
		'sound/effects/bin_open.ogg' = 20,
		'sound/effects/boing.ogg' = 5,
		'sound/effects/cartoon_splat.ogg' = 1,
		'sound/effects/cashregister.ogg' = 1,
		'sound/effects/glassbash.ogg' = 50,
		'sound/effects/glassbr1.ogg' = 20,
		'sound/effects/glassbr2.ogg' = 20,
		'sound/effects/glassbr3.ogg' = 20,
		'sound/effects/grillehit.ogg' = 20,
		'sound/effects/hit_on_shattered_glass.ogg' = 20,
		'monkestation/sound/effects/jingle.ogg' = 50,
		'sound/effects/meatslap.ogg' = 50,
		'sound/effects/quack.ogg' = 20,
		'sound/effects/rustle1.ogg' = 100,
		'sound/effects/rustle2.ogg' = 100,
		'sound/effects/rustle3.ogg' = 100,
		'sound/effects/rustle4.ogg' = 100,
		'sound/effects/rustle5.ogg' = 100,
	)

/obj/structure/trash_pile/Destroy()
	var/drop_loc = drop_location()
	if(drop_loc)
		for(var/atom/movable/thing in contents)
			thing.forceMove(drop_loc)
	return ..()

/obj/structure/trash_pile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)
	icon_state = pick(
		"pile1",
		"pile2",
		"pilechair",
		"piletable",
		"pilevending",
		"brtrashpile",
		"microwavepile",
		"rackpile",
		"boxfort",
		"trashbag",
		"brokecomp",
	)

/obj/structure/trash_pile/attack_hand(mob/living/user)
	if(user in contents)
		eject_mob(user)
		return
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_TRASH_PILE))
		return
	if(!ishuman(user) || (user.istate & ISTATE_HARM) || !user.ckey)
		return ..()

	user.balloon_alert_to_viewers("digs through trash...")
	playsound(get_turf(src), pick('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg'), 50)

	if(!do_after(user, 3 SECONDS, src, extra_checks = CALLBACK(src, PROC_REF(throw_trash), user), interaction_key = DOAFTER_SOURCE_TRASH_PILE))
		return

	var/content_length = length(contents)
	if(content_length) //Something hidden inside (mob/item)
		var/atom/movable/hidden = contents[content_length] // Get the most recent hidden thing
		if(isliving(hidden))
			balloon_alert(user, "someone is inside!")
			eject_mob(hidden)
		else
			balloon_alert(user, "found something!")
			hidden.forceMove(drop_location())
		return
	if(searched_by_ckeys[user.ckey])
		balloon_alert(user, "empty...")
		return
	var/item_to_spawn = pick_weight_recursive(GLOB.maintenance_loot)
	var/obj/item/spawned_item = new item_to_spawn(drop_location())
	if(!QDELETED(spawned_item))
		balloon_alert(user, "found [spawned_item]!")
	else
		balloon_alert(user, "found nothing...")
	searched_by_ckeys[user.ckey] = TRUE

/obj/structure/trash_pile/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user in contents)
		eject_mob(user)
		return
	if((user.istate & ISTATE_HARM) || DOING_INTERACTION(user, DOAFTER_SOURCE_TRASH_PILE))
		return ..()
	if(length(contents) >= 10)
		balloon_alert(user, "it's full!")
		return
	balloon_alert(user, "hiding item...")
	if(!do_after(user, hide_item_time, user, interaction_key = DOAFTER_SOURCE_TRASH_PILE))
		return
	if(QDELETED(src) || QDELETED(attacking_item))
		return
	if(user.transferItemToLoc(attacking_item, src))
		balloon_alert(user, "item hidden!")

/obj/structure/trash_pile/MouseDrop_T(mob/living/carbon/dropped_mob, mob/user, params)
	if(user != dropped_mob || !iscarbon(dropped_mob))
		return ..()
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_TRASH_PILE) || !(dropped_mob.mobility_flags & MOBILITY_MOVE))
		return

	user.visible_message(
		span_warning("[user] starts diving into [src]."),
		span_notice("You start diving into [src]...")
	)

	var/adjusted_dive_time = hide_person_time
	if(HAS_TRAIT(user, TRAIT_RESTRAINED)) // hiding takes twice as long when restrained.
		adjusted_dive_time *= 2

	if(!do_after(user, adjusted_dive_time, user, interaction_key = DOAFTER_SOURCE_TRASH_PILE))
		return

	if(QDELETED(src))
		return

	for(var/mob/hidden_mob in contents)
		balloon_alert(user, "someone is inside!")
		eject_mob(hidden_mob)
		return

	user.forceMove(src)

/obj/structure/trash_pile/container_resist_act(mob/user)
	user.forceMove(drop_location())

/obj/structure/trash_pile/relaymove(mob/user)
	container_resist_act(user)

/obj/structure/trash_pile/proc/throw_trash(mob/user)
	if(QDELETED(src) || QDELETED(user)) //Check if valid.
		return FALSE

	var/ckey = user.ckey
	if(searched_by_ckeys[ckey]) //Don't spawn trash!
		return TRUE

	if(!user.CanReach(src)) //Distance check for TK fuckery
		return FALSE

	if(isnull(remaining_trash_throws[ckey]))
		remaining_trash_throws[ckey] = MAXIMUM_TRASH_THROWS
	else if(remaining_trash_throws[ckey] < 1)
		return TRUE

	if(COOLDOWN_FINISHED(src, trash_cooldown))
		COOLDOWN_START(src, trash_cooldown, trash_delay * 0.5 + rand() * trash_delay) // x0.5 to x1.5
		remaining_trash_throws[ckey]--
		var/item_to_spawn
		if(prob(0.1))
			item_to_spawn = pick(GLOB.oddity_loot - typesof(/obj/item/dice/d20/fate)) // die of fate are blacklisted bc it will be automatically rolled due to the throw, likely insta-RRing the user without any counter
		else
			item_to_spawn = pick_weight_recursive(GLOB.trash_pile_loot)
		var/obj/item/spawned_item = new item_to_spawn(drop_location())
		var/turf/throw_at = get_ranged_target_turf_direct(src, user, 7, rand(-60, 60))
		// this can totally be changed to use /datum/component/movable_physics to make it way more fun and expressive, but i can't be bothered to figure out good velocity/friction values right now
		if(spawned_item.safe_throw_at(throw_at, rand(2, 4), rand(1, 3), user, spin = TRUE))
			playsound(src, 'sound/weapons/punchmiss.ogg', 10)

	if(COOLDOWN_FINISHED(src, funny_sound_cooldown))
		COOLDOWN_START(src, funny_sound_cooldown, funny_sound_delay * 0.5 + rand() * funny_sound_delay) // x0.5 to x1.5
		playsound(src, pick_weight(funny_sounds), 25)

	return TRUE

/obj/structure/trash_pile/proc/eject_mob(mob/living/hidden_mob)
	playsound(src, 'sound/machines/chime.ogg', 50, FALSE, -5)
	hidden_mob.do_alert_animation(hidden_mob)
	return TRUE

#undef MAXIMUM_TRASH_THROWS
