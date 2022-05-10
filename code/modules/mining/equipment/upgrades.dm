//plasma magmite is exclusively used to upgrade mining equipment, by using it on a heated world anvil to make upgradeparts.
/obj/item/magmite
	name = "plasma magmite"
	desc = "A chunk of plasma magmite, crystallized deep under lavaland's surface. Its strength seems to fluctuate depending on the distance to the planet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Magmite ore"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts
	name = "plasma magmite upgrade parts"
	desc = "Forged on the lavaland anvil, these parts can be used to upgrade many kinds of mining equipment."
	icon = 'icons/obj/mining.dmi'
	icon_state = "upgrade_parts"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target.type == /obj/item/gun/energy/kinetic_accelerator) //basic kinetic accelerator
		var/obj/item/gun/energy/kinetic_accelerator/gun = target
		if(gun.bayonet)
			gun.remove_gun_attachment(item_to_remove = gun.bayonet)
		if(gun.gun_light)
			gun.remove_gun_attachment(item_to_remove = gun.gun_light)
		for(var/obj/item/borg/upgrade/modkit/kit in gun.modkits)
			kit.uninstall(gun)
		qdel(gun)
		var/obj/item/gun/energy/kinetic_accelerator/mega/newgun = new(src)
		user.put_in_hand(newgun)
		to_chat(user,"Harsh tendrils wrap around the kinetic accelerator, merging the parts and kinetic accelerator to form a mega kinetic accelerator.")
	if(target.type == /obj/item/gun/energy/plasmacutter/adv)
		var/obj/item/gun/energy/plasmacutter/adv/gun = I
		qdel(gun)
		var/obj/item/gun/energy/plasmacutter/adv/mega/newgun = new(src)
		user.put_in_hand(newgun)
		to_chat(user,"Harsh tendrils wrap around the plasma cutter, merging the parts and cutter to form a mega plasma cutter.")


	