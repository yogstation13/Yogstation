/obj/item/armorpolish
	name = "armor aolish"
	desc = "Some canned tuna... oh wait. That's armor polish."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "armor_polish"
	w_class = WEIGHT_CLASS_TINY

obj/item/armorpolish/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/I = target;
		//theos said 30/30/20/25
		//make sure it's not too strong already ((busted))
		if((I.armor.melee <= 30) || (I.armor.bullet <= 30) || (I.armor.laser <= 20) || (I.armor.energy <= 25))
			//it is weak enough to benefit
			I.armor = I.armor.setRating(melee = I.armor.melee < 30 ? 30 : I.armor.melee,bullet = I.armor.bullet < 30 ? 30 : I.armor.bullet,laser = I.armor.laser < 20 ? 20 : I.armor.laser,energy = I.armor.energy < 25 ? 25 : I.armor.energy)
			//delete dis
			to_chat(user, "<span class='warning'>The [src] disintegrates into nothing...</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>This suit is strong enough already! Try it on something weaker.</span>")
	else
		to_chat(user, "<span class='warning'>You can only polish suits!</span>")
