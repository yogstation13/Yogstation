/// Base grip
/obj/item/attachment/grip
	name = "grip"
	desc = "It's a grip."
	attachment_type = TYPE_FOREGRIP
	var/steady = 0

/obj/item/attachment/grip/on_attach(obj/item/gun/G, mob/user = null)
	. = ..()
	G.recoil -= steady

/obj/item/attachment/grip/on_detach(obj/item/gun/G, mob/living/user = null)
	. = ..()
	G.recoil += steady

/obj/item/attachment/grip/vertical
	name = "vertical grip"
	desc = "A tactile grip that increases the control and steadiness of your weapon."
	icon_state = "vert_grip"
	steady = 0.5
