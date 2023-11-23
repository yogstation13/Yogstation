/**
 * Golf hole machine
 * Used to play golf using golfballs and golf sticks.
 * Does not need power to operate, it's more like a structure.
 */
/obj/machinery/golfhole
	name = "golf hole"
	desc = "A hole for the game of golf. Try to score a hole in one."
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state = "redgolfhole"
	base_icon_state = "redgolfhole"
	use_power = NO_POWER_USE
	anchored = FALSE

/obj/machinery/golfhole/blue
	name = "blue golf hole"
	icon_state = "bluegolfhole"

/obj/machinery/golfhole/puttinggreen
	name = "green golf hole"
	desc = "The captain's putting green for the game of golf. Try to score a hole in one."
	icon_state = "puttinggreen"
	anchored = TRUE

/obj/machinery/golfhole/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	update_appearance(UPDATE_ICON)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/golfhole/update_icon_state()
	. = ..()
	if(anchored)
		icon_state = "[base_icon_state]_w"
	else
		icon_state = base_icon_state

/obj/machinery/golfhole/Crossed(atom/movable/mover, oldloc)
	. = ..()
	if(!istype(mover, /obj/item/golfball) || !mover.throwing || !anchored)
		return ..()
	if (contents.len >= 3)
		balloon_alert_to_viewers("rolls over...")
		return FALSE

	if(prob(75))
		mover.forceMove(src)
		balloon_alert_to_viewers("landed!")
	else
		balloon_alert_to_viewers("bounced off...")


/obj/machinery/golfhole/attack_hand(mob/living/user)
	. = ..()
	if(!user.resting)
		balloon_alert(user, "lie down first!")
		return
	var/obj/item/golfball/ball = locate(/obj/item/golfball) in contents
	if(!ball)
		balloon_alert(user, "empty...")
		return
	user.put_in_hands(ball)

/**
 * The golfball used to play.
 */
/obj/item/golfball
	desc = "A ball for the game of golf."
	name = "golfball"
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state ="golfball"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 12
	attack_verb = list("hit", "balled")

/obj/item/golfball/attackby(obj/item/hitby, mob/user, params)
	if(!istype(hitby, /obj/item/golfclub))
		return ..()
	var/turf/throw_at = get_ranged_target_turf(src, get_dir(user, src), 3)
	throw_at(throw_at, 3, 2)
	user.changeNext_move(CLICK_CD_RANGE)

/obj/item/golfclub
	desc = "A club for the game of golf."
	name = "golfclub"
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/golfclub_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/golfclub_righthand.dmi'
	icon = 'yogstation/icons/code/game/golf/golfstuff.dmi'
	icon_state ="golfclub"
	force = 8
	damtype = BRUTE
	attack_verb = list("smacked", "struck")

/obj/structure/closet/golf
	name = "golf supplies closet"
	desc = "This unit contains all the supplies for golf."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "golf"

/obj/structure/closet/golf/PopulateContents()
	. = ..()
	for(var/i in 1 to 6)
		new /obj/item/golfball(src)
		new /obj/item/golfclub(src)
	for(var/i in 1 to 2)
		new /obj/machinery/golfhole(src)
		new /obj/machinery/golfhole/blue(src)
