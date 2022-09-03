/obj/structure/mjollnir
	name = "Mjolnir"
	desc = "This once powerful hammer feels cold to the touch, but a thrum of magic inside tells you its only a matter of time until someone awakens it again."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "mjollnir-inert"
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = FALSE
	var/pull_time = 15 SECONDS

/obj/structure/mjollnir/attack_hand(mob/living/user)
	. = ..()
	if(user.mind.assigned_role == ROLE_WIZARD || user.mind.special_role == ROLE_WIZARD) //check and see if the person tugging on the hammer is a wizard
		to_chat(user, span_notice("You place your hands firmly around the handle of the hammer and begin to pull with all your might!"))
	else
		to_chat(user, span_notice("You place your hands firmly around the handle of the hammer but feel it resist the pull of a nonmagical host! This will take a while."))
	if(do_after(user, pull_time * (user.mind.assigned_role == ROLE_WIZARD || user.mind.special_role == ROLE_WIZARD ? 1 : 2), src)) //if it is a wizard, it takes normal time
		to_chat(user, span_userdanger("You successfully free Mjolnir from the ground and can feel its power returning once more!")) //if it's crew, it takes twice as long
		var/obj/item/twohanded/mjollnir/M = new /obj/item/twohanded/mjollnir
		playsound(user, 'sound/magic/lightningbolt.ogg', 50, 1) //keep this at 50 for half volume it's so fucking loud
		user.put_in_hands(M) //firmly grasp it
		qdel(src) //byebye
	else
		to_chat(user, span_danger("You let go of the handle and the hammer sinks back into its resting position.")) //either you got bumped by an assistant, or you're the wizard and got shot trying to reclaim your hammer
