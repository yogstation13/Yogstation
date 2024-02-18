/obj/item/raisedhands
	name = "raised hands"
	desc = "What are you, French?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_HUGE
	item_flags = DROPDEL | ABSTRACT

/obj/item/raisedhands/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/raisedhands/dropped(mob/user)
	user.visible_message(span_userdanger(("[user] lowers their hands!")))
	return ..()
