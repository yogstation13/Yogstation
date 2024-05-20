/datum/eldritch_transmutation/knock_knife
	name = "Key Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/crowbar)
	result_atoms = list(/obj/item/melee/sickly_blade/knock)
	required_shit_list = "A crowbar and a knife."

/datum/eldritch_transmutation/key_ring
	name = "Key Keeper’s Burden"
	required_atoms = list(/obj/item/storage/wallet,/obj/item/card/id,/obj/item/stack/rods)
	result_atoms = list(/obj/item/card/id/syndicate/heretic)
	required_shit_list = "A wallet, ID card, and metal rods."

/datum/eldritch_transmutation/final/knock_final
	name = "Many secrets behind the Spider Door"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/knock_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("Immense destabilization of the bluespace veil has been observed. Our scanners report a fiery entity of unknown power is quickly escalating the station temperature to unhabitable levels. Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	
	new /obj/structure/knock_tear(loc, user.mind)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod = 0
	H.physiology.stun_mod = 0
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	return ..()

/obj/structure/knock_tear
	name = "???"
	desc = "It stares back. Theres no reason to remain. Run."
	max_integrity = 10000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	light_range = 20
	anchored = TRUE
	density = FALSE
	move_resist = INFINITY
	/// Who is our daddy?
	var/datum/mind/ascendee
	/// True if we're currently checking for ghost opinions
	var/gathering_candidates = TRUE
	///a static list of heretic summons we cam create, automatically populated from heretic monster subtypes
	var/static/list/monster_types
	/// A static list of heretic summons which we should not create
	var/static/list/monster_types_blacklist = list(
		/mob/living/simple_animal/hostile/eldritch/armsy,
		/mob/living/simple_animal/hostile/eldritch/armsy/prime,
		/mob/living/simple_animal/hostile/eldritch/star_gazer,
	)

/obj/structure/knock_tear/Initialize(mapload, datum/mind/ascendant_mind)
	. = ..()
	transform *= 3
	if(isnull(monster_types))
		monster_types = subtypesof(/mob/living/simple_animal/hostile/eldritch) - monster_types_blacklist
	if(!isnull(ascendant_mind))
		ascendee = ascendant_mind
		RegisterSignals(ascendant_mind.current, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(end_madness))
	INVOKE_ASYNC(src, PROC_REF(poll_ghosts))

/// Ask ghosts if they want to make some noise
/obj/structure/knock_tear/proc/poll_ghosts()
	var/list/candidates = pollCandidatesForMob("Would you like to be a random eldritch monster attacking the crew?", ROLE_SENTIENCE, ROLE_SENTIENCE, 10 SECONDS, POLL_IGNORE_HERETIC_MONSTER)
	while(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		ghost_to_monster(candidate, should_ask = FALSE)
	gathering_candidates = FALSE

/// Destroy the rift if you kill the heretic
/obj/structure/knock_tear/proc/end_madness(datum/former_master)
	SIGNAL_HANDLER
	var/turf/our_turf = get_turf(src)
	playsound(our_turf, 'sound/magic/castsummon.ogg', vol = 100, vary = TRUE)
	visible_message(span_boldwarning("The rip in space spasms and disappears!"))
	UnregisterSignal(former_master, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING)) // Just in case they die THEN delete
	new /obj/effect/temp_visual/destabilising_tear(our_turf)
	qdel(src)

/obj/structure/knock_tear/attack_ghost(mob/user)
	. = ..()
	if(. || gathering_candidates)
		return
	ghost_to_monster(user)

/obj/structure/knock_tear/examine(mob/user)
	. = ..()
	if (!isobserver(user) || gathering_candidates)
		return
	. += span_notice("You can use this to enter the world as a foul monster.")

/// Turn a ghost into an 'orrible beast
/obj/structure/knock_tear/proc/ghost_to_monster(mob/dead/observer/user, should_ask = TRUE)
	if(should_ask)
		var/ask = tgui_alert(user, "Become a monster?", "Ascended Rift", list("Yes", "No"))
		if(ask != "Yes" || QDELETED(src) || QDELETED(user))
			return FALSE
	var/monster_type = pick(monster_types)
	var/mob/living/monster = new monster_type(loc)
	monster.key = user.key
	monster.set_name()
	var/datum/antagonist/heretic_monster/woohoo_free_antag = new(src)
	monster.mind.add_antag_datum(woohoo_free_antag)
	if(ascendee)
		monster.faction = ascendee.current.faction
		woohoo_free_antag.set_owner(ascendee)
	var/datum/objective/kill_all_your_friends = new()
	kill_all_your_friends.owner = monster.mind
	kill_all_your_friends.explanation_text = "The station's crew must be culled."
	kill_all_your_friends.completed = TRUE
	woohoo_free_antag.objectives += kill_all_your_friends

/obj/structure/knock_tear/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/obj/structure/knock_tear/Destroy(force)
	if(ascendee)
		ascendee = null
	return ..()

/obj/effect/temp_visual/destabilising_tear
	name = "destabilised tear"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	light_range = 20
	duration = 1 SECONDS

/obj/effect/temp_visual/destabilising_tear/Initialize(mapload)
	. = ..()
	transform *= 3
	animate(src, transform = matrix().Scale(3.2), time = 0.15 SECONDS)
	animate(transform = matrix().Scale(0.2), time = 0.75 SECONDS)
	animate(transform = matrix().Scale(3, 0), time = 0.1 SECONDS)
	animate(src, color = COLOR_WHITE, time = 0.25 SECONDS, flags = ANIMATION_PARALLEL)
