//plasma magmite is exclusively used to upgrade mining equipment, by using it on a heated world anvil to make upgradeparts.
/obj/item/magmite
	name = "plasma magmite"
	desc = "A chunk of plasma magmite, crystallized deep under the planet's surface. It seems to lose strength as it gets further from the planet!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Magmite ore"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts
	name = "plasma magmite upgrade parts"
	desc = "Forged on the legendary World Anvil, these parts can be used to upgrade many kinds of mining equipment."
	icon = 'icons/obj/mining.dmi'
	icon_state = "upgrade_parts"
	w_class = WEIGHT_CLASS_NORMAL
	var/inert = FALSE

/obj/item/magmite_parts/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/go_inert), 10 MINUTES)

/obj/item/magmite_parts/proc/go_inert()
	if(inert)
		return
	visible_message(span_warning("The [src] loses it's glow!"))
	inert = TRUE
	name = "inert plasma magmite upgrade parts"
	icon_state = "upgrade_parts_inert"
	desc += "It appears to have lost its magma-like glow."

/obj/item/magmite_parts/proc/restore()
	if(!inert)
		return
	inert = FALSE
	name = initial(name)
	icon_state = initial(icon_state)
	desc = initial(desc)
	addtimer(CALLBACK(src, .proc/go_inert), 10 MINUTES)

/obj/item/magmite_parts/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(inert)
		to_chat(span_warning("[src] appears inert! Perhaps the World Anvil can restore it!"))
	switch(target.type)
		if(/obj/item/gun/energy/kinetic_accelerator) //basic kinetic accelerator
			var/obj/item/gun/energy/kinetic_accelerator/gun = target
			if(gun.bayonet)
				gun.remove_gun_attachment(item_to_remove = gun.bayonet)
			if(gun.gun_light)
				gun.remove_gun_attachment(item_to_remove = gun.gun_light)
			for(var/obj/item/borg/upgrade/modkit/kit in gun.modkits)
				kit.uninstall(gun)
			qdel(gun)
			var/obj/item/gun/energy/kinetic_accelerator/mega/newgun = new(get_turf(user))
			user.put_in_hand(newgun)
			to_chat(user,"Harsh tendrils wrap around the kinetic accelerator, merging the parts and kinetic accelerator to form a mega kinetic accelerator.")
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/adv)
			var/obj/item/gun/energy/plasmacutter/adv/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/adv/mega/newgun = new(get_turf(user))
			user.put_in_hand(newgun)
			to_chat(user,"Harsh tendrils wrap around the plasma cutter, merging the parts and cutter to form a mega plasma cutter.")
			qdel(src)
		if(/obj/item/gun/energy/plasmacutter/scatter) //holy fuck make a new system bro do a /datum/worldanvilrecipe DAMN
			var/obj/item/gun/energy/plasmacutter/scatter/gun = target
			qdel(gun)
			var/obj/item/gun/energy/plasmacutter/scatter/mega/newgun = new(get_turf(user))
			user.put_in_hand(newgun)
			to_chat(user,"Harsh tendrils wrap around the plasma cutter shotgun, merging the parts and cutter to form a mega plasma cutter shotgun.")
			qdel(src)


	