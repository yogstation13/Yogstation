/obj/item/highfive
	name = "raised hand"
	desc = "Slap my hand."
	icon_state = "latexballon"
	item_state = "nothing"
	hitsound = 'sound/weapons/punchmiss.ogg'
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("is left hanging by")

/mob/proc/thisisnotatrick()
	var/obj/item/highfive/H = locate() in src
	if(!get_active_held_item())
		return FALSE
	if(get_active_held_item() == H)
		return TRUE
	return FALSE

obj/item/highfive/attack(mob/target, mob/user)
	if(target == user)
		to_chat(user, "<span class='notice'>You can't high-five yourself! Go get a friend!</span>")
	else if(ishuman(target) && (target.stat == CONSCIOUS) && (target.thisisnotatrick() == TRUE) )
		var/obj/item/highfive/downlow = target.get_active_held_item()
		user.visible_message("[user] and [target] high five!", "<span class='notice'>You high five with [target]!</span>", "<span class='italics'>You hear a slap!</span>")
		user.do_attack_animation(target)
		target.do_attack_animation(user)
		playsound(src, 'sound/weapons/punch2.ogg', 50, 0)
		qdel(src)
		qdel(downlow)
	else
		user.visible_message("[user] is left hanging by [target].", "<span class='notice'>[target] leaves you hanging.</span>")
		playsound(src, 'sound/weapons/punchmiss.ogg', 50, 0)