/obj/structure/blob/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0, overmind_reagent_trigger = 1)
	. = ..()
	if(atom_integrity > 0)
		if(overmind) //we should have an overmind, but...
			to_chat(overmind, span_userdanger("Your core is under attack!"))
