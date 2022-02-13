/obj/structure/mjollnir
	name = "Mjolnir"
	desc = "This once powerful hammer feels cold to the touch, but a thrum of magic inside tells you its only a matter of time until it awakens again."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "mjollnir-inert"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = FALSE

/obj/structure/mjollnir/attack_hand(mob/living/user)
	. = ..()
	to_chat(user, span_notice("You place your hands firmly around the handle of the hammer and begin to pull with all your might!"))
	if(do_after(user, 5 SECONDS, target = src))
		to_chat(user, span_userdanger("You successfully free Mjolnir from the ground and can feel its power returning once more!"))
		var/obj/item/twohanded/mjollnir/M = new /obj/item/twohanded/mjollnir
		playsound(user, 'sound/magic/lightningbolt.ogg', 50, 1)
		user.put_in_hands(M)
		qdel(src)
	else
		to_chat(user, span_danger("You let go of the handle and the hammer sinks back into its resting position."))
