/// Base sight
/obj/item/attachment/scope
	name = "sight"
	desc = "It's a sight."
	attachment_type = TYPE_SIGHT
	var/accuracy = 0

/obj/item/attachment/scope/on_attach(obj/item/gun/G, mob/user = null)
	. = ..()
	G.spread -= accuracy

/obj/item/attachment/scope/on_detach(obj/item/gun/G, mob/living/user = null)
	. = ..()
	G.spread += accuracy

/obj/item/attachment/scope/simple
	name = "simple sight"
	desc = "A simple yet elegant scope. Better than ironsights."
	icon_state = "simple_sight"
	accuracy = 3

/obj/item/attachment/scope/holo
	name = "holographic sight"
	desc = "A highly advanced sight that projects a holographic design onto its lens, providing unobscured and precise view of your target."
	icon_state = "holo_sight"
	accuracy = 6
