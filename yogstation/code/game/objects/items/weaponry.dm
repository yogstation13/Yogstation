/obj/item/highfive
	name = "raised hand"
	desc = "Slap my hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "latexballon"
	item_state = "nothing"
	hitsound = 'sound/weapons/punchmiss.ogg'
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("is left hanging by")

/obj/item/highfive/attack(mob/target, mob/user)
	if(target == user)
		to_chat(user, span_notice("You can't high-five yourself! Go get a friend!"))
	else if(ishuman(target) && (target.stat == CONSCIOUS) && (istype(target.get_active_held_item(), /obj/item/highfive)) )
		var/obj/item/highfive/downlow = target.get_active_held_item()
		user.visible_message("[user] and [target] high five!", span_notice("You high five with [target]!"), span_italics("You hear a slap!"))
		user.do_attack_animation(target)
		target.do_attack_animation(user)
		playsound(src, 'sound/weapons/punch2.ogg', 50, 0)
		qdel(src)
		qdel(downlow)
	else
		user.visible_message("[user] is left hanging by [target].", span_notice("[target] leaves you hanging."))
		playsound(src, 'sound/weapons/punchmiss.ogg', 50, 0)

/obj/item/handholding
	name = "hand for holding"
	desc = "You rapscallion, how scandalous!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "latexballon"
	item_state = "nothing"
	hitsound = 'sound/weapons/punchmiss.ogg'
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("offers to hold the hand of")

/obj/item/handholding/attack(mob/target, mob/user)
	if(target == user)
		to_chat(user, span_notice("You can't hold your own hands! Go get a friend!"))
	else if(ishuman(target) && (target.stat == CONSCIOUS) && (istype(target.get_active_held_item(), /obj/item/handholding)) )
		var/obj/item/handholding/downlow = target.get_active_held_item() //this should get a new name but like hell im doing that
		user.visible_message(span_notice("[user] and [target] hold hands."), span_notice("You hold hands with [target]!"))
		var/mob/living/T = target
		var/mob/living/U = user
		if(!U.pulling == T) //give everyone a passive grab on eachother if they dont have one already
			U.grabbedby(T, 1)
		if(!T.pulling == U)
			T.grabbedby(U, 1)
		qdel(src)
		qdel(downlow)
	else
		user.visible_message("[user] offers to hold the hand of [target].", span_notice("You offer to hold hands with [target]."))
		playsound(src, 'sound/weapons/punchmiss.ogg', 50, 0)
