//Lever: Do I really need to explain this?
/obj/structure/destructible/clockwork/trap/trigger/lever
	name = "lever"
	desc = "A fancy lever made of wood and capped with brass."
	clockwork_desc = "A fancy lever.that activates when pulled."
	max_integrity = 75
	icon_state = "lever"

/obj/structure/destructible/clockwork/trap/trigger/lever/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.visible_message(span_notice("[user] pulls [src]!"), span_notice("You pull [src]. It clicks, then lifts back upwards."))
	if(wired_to.len)
		audible_message("<i>You hear gears clanking.</i>")
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	activate()
