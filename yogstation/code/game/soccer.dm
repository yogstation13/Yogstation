//Used for a soccer game in the holodeck
/obj/structure/goalnet
	desc = "A goal net for various indoor sports"
	name = "goal net"
	icon = 'yogstation/icons/code/game/soccer.dmi'
	icon_state = "goal_net"
	anchored = TRUE

/obj/structure/goalnet/goalpost
	desc = "Just move these around wherever."
	name = "goal post"
	density = TRUE

/obj/structure/goalnet/goalpost/left
	icon_state = "goal_post_left"

/obj/structure/goalnet/goalpost/right
	icon_state = "goal_post_right"

/obj/structure/goalnet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE,CALLBACK(src, PROC_REF(can_user_rotate)),CALLBACK(src, PROC_REF(can_be_rotated)),null)

/obj/structure/goalnet/proc/can_be_rotated(mob/user)
	return TRUE

/obj/structure/goalnet/proc/can_user_rotate(mob/user)
	var/mob/living/L = user
	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
			return FALSE
		else
			return TRUE
	else if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/obj/structure/goalnet/wrench_act(mob/user, obj/item/tool)
	setAnchored(!anchored)
	if(anchored)
		to_chat(user, span_notice("You fasten [src]"))
	else
		to_chat(user, span_notice("You unfasten [src]"))
	tool.play_tool_sound(src)
	return TRUE

/obj/structure/goalnet/Crossed(atom/movable/AM, oldloc)
	if (isitem(AM) && istype(AM,/obj/item/soccerball))
		if(prob(50))
			AM.forceMove(get_turf(src))
			var/obj/item/soccerball/A = AM
			A.bumptarget = get_turf(src)
			visible_message(span_warning("GOOOAAALLL! [AM] lands in the net!"))
			return
		else
			visible_message(span_danger("[AM] bounces off of the post!"))
			return ..()
	else
		return ..()

/obj/item/soccerball
	desc = "A soccer ball."
	name = "soccer ball"
	icon = 'yogstation/icons/code/game/soccer.dmi'
	icon_state = "soccer_ball"
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 0
	var/turf/bumptarget = null
	var/bounce = FALSE

//you have to be able to kick it with an open hand even
/obj/item/soccerball/attack_hand(mob/user)
	attackby(user)

/obj/item/soccerball/attackby(mob/user)
	var/turf/throw_at = get_ranged_target_turf(src, get_dir(user,src),4)
	throw_at(throw_at,4,1)
	//user.changeNext_move(CLICK_CD_RANGE) - not sure if this would be necessary for an item that doesn't have throwforce

//stolen from deck of cards code in order to make it portable
/obj/item/soccerball/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || !(M.mobility_flags & MOBILITY_PICKUP))
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			to_chat(usr, span_notice("You pick up the soccer ball."))

		else if(istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
				to_chat(usr, span_notice("You pick up the soccer ball."))
	else
		to_chat(usr, span_warning("You can't reach it from here!"))

//collision code, currently acts silly when hitting a wall from above or below but it's playable, and left and right are fine
obj/item/soccerball/Bump(atom/A)
	dir = get_dir(A,src)
	if(dir == get_cardinal_dir(A,src))
		dir = turn(dir,4)
	else
		dir = turn(dir,2)
	bumptarget = get_ranged_target_turf(src,dir,1)
	if(istype(A,/mob/living) || istype(A,/obj/structure/goalnet/goalpost))
		throw_at(bumptarget,0,0)
	else
		//if it doesn't attempt this both now and in after_throw it simply sticks to horizontal walls
		throw_at(bumptarget,1,1,null,0,TRUE)
		bounce = TRUE

obj/item/soccerball/after_throw(datum/callback/callback)
	if(bounce)
		throw_at(bumptarget,1,1,null,0,TRUE)
		bounce = FALSE

//when a player walks into the ball, move with the player
obj/item/soccerball/Crossed(atom/movable/AM, oldloc)
	. = ..()
	var/mob/living/carbon/A = AM
	if(istype(AM,/mob/living) && (istype(AM,/mob/living/simple_animal) || A.a_intent != INTENT_HELP))
		Move(get_step(AM,AM.dir),AM.dir)
