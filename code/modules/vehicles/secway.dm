
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	key_type = /obj/item/key/security
	max_integrity = 60

/obj/vehicle/ridden/secway/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/obj/vehicle/ridden/secway/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(obj_integrity == max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return FALSE

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, span_notice("You repair [src]."))
		obj_integrity = min(max_integrity, obj_integrity + 20)
		if(obj_integrity == max_integrity)
			to_chat(user, span_notice("[src] looks to be fully repaired now."))

	return TRUE
