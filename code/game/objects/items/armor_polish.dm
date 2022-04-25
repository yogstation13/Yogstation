/obj/item/armorpolish
	name = "armor polish"
	desc = "Some canned tuna... oh wait. That's armor polish."
	icon = 'icons/obj/traitor.dmi'
	icon_state = "armor_polish"
	w_class = WEIGHT_CLASS_TINY
	var/remaining_uses = 2

/obj/item/armorpolish/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		. += "It has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."

obj/item/armorpolish/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/item/clothing/suit) || istype(target, /obj/item/clothing/head))
		var/obj/item/clothing/I = target;
		//theos said 30/30/20/25
		//make sure it's not too strong already ((busted))
		if((I.armor.melee < 30) || (I.armor.bullet < 30) || (I.armor.laser < 20) || (I.armor.energy < 25))
			//it is weak enough to benefit
			I.armor = I.armor.setRating(
				melee = I.armor.melee < 30 ? 30 : I.armor.melee,
				bullet = I.armor.bullet < 30 ? 30 : I.armor.bullet,
				laser = I.armor.laser < 20 ? 20 : I.armor.laser,
				energy = I.armor.energy < 25 ? 25 : I.armor.energy
			)
			remaining_uses -= 1
			to_chat(user, "You apply [src] to the [target.name].")
			if(remaining_uses <= 0) {
				to_chat(user, span_warning("The [src] disintegrates into nothing..."))
				qdel(src)
			} else {
				to_chat(user, span_warning("The [src] has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."))
			}
			
			
		else
			if(istype(target,/obj/item/clothing/suit)) {
				to_chat(user, span_warning("This suit is strong enough already! Try it on something weaker."))
			} else {
				to_chat(user, span_warning("This headgear is strong enough already! Try it on something weaker."))
			}
			
	else
		to_chat(user, span_warning("You can only polish suits and headgear!"))
