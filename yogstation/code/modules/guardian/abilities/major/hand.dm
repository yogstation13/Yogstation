GLOBAL_LIST_INIT(guardian_hand_cooldown, list(
	1 = 10 SECONDS,
	2 = 7.5 SECONDS,
	3 = 5 SECONDS,
	4 = 2.5 SECONDS,
	5 = 1 SECONDS,
))

/datum/guardian_ability/major/hand
	name = "The Hand"
	desc = "The guardian can use it's hand(s) to erase the space in front of it, bring any desired target closer."
	cost = 4
	var/next_hand = 0

/datum/guardian_ability/major/hand/RangedAttack(atom/target)
	if (world.time < next_hand || guardian.Adjacent(target) || !isturf(guardian.loc) || !guardian.is_deployed() || !can_see(guardian, target))
		return ..()
	playsound(guardian, 'yogstation/sound/effects/zahando.ogg', 100, TRUE) // dubstep fart lol
	next_hand = world.time + GLOB.guardian_hand_cooldown[guardian.stats.potential]
	var/turf/hand_turf = get_step(guardian, get_dir(guardian, target))
	for (var/atom/movable/AM in get_turf(target))
		if (AM.anchored)
			continue
		AM.forceMove(hand_turf)
	guardian.face_atom(hand_turf)
	return ..()

/datum/guardian_ability/major/hand/StatusTab()
	. = ..()
	if (next_hand > world.time)
		. += "THE HAND Cooldown Remaining: [DisplayTimeText(next_hand - world.time)]"
