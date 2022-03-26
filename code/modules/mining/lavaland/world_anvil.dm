/obj/structure/world_anvil
	name = "World Anvil"
	desc = "An anvil that is connected through lava reservoirs to the core of lavaland. Whoever was using this last was creating something powerful."
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/forge_charges = 0
	var/list/placed_objects = list()

/obj/structure/world_anvil/update_icon()
	icon_state = forge_charges > 0 ? "anvil_a" : "anvil"
	if(forge_charges > 0)
		set_light(4,1,LIGHT_COLOR_ORANGE)
	else
		set_light(0)

/obj/structure/world_anvil/examine(mob/user)
	. = ..()
	. += "It currently has [forge_charges] forge[forge_charges != 1 ? "s" : ""] remaining."

/obj/structure/world_anvil/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/twohanded/required/gibtonite))
		var/obj/item/twohanded/required/gibtonite/placed_ore = I
		forge_charges = forge_charges + placed_ore.quality
		to_chat(user,"You place down the gibtonite on the world anvil, and watch as the gibtonite melts into it. The world anvil is now heated enough for [forge_charges] forge[forge_charges > 1 ? "s" : ""].")
		qdel(placed_ore)
		update_icon()
	else //put everything else except gibtonite on the forge
		if(user.transferItemToLoc(I, src))
			vis_contents += I
			placed_objects += I
			RegisterSignal(I, COMSIG_MOVABLE_MOVED, .proc/ItemMoved,TRUE)

/obj/structure/world_anvil/proc/ItemMoved(obj/item/I, atom/OldLoc, Dir, Forced)
	vis_contents -= I
	placed_objects -= I
	UnregisterSignal(I, COMSIG_MOVABLE_MOVED)

/obj/structure/world_anvil/attack_hand(mob/user)
	if(!LAZYLEN(placed_objects))
		to_chat(user,"You must place a piece of plasma magmite and either a kinetic accelerator or advanced plasma cutter on the anvil!")
		return ..()
	if(forge_charges <= 0)
		to_chat(user,"The anvil is not heated enough to be usable!")
		return ..()
	var/magmite_amount = 0
	var/used_magmite = 0
	for(var/obj/item/magmite/placed_magmite in placed_objects)
		magmite_amount++
	if(magmite_amount <= 0)
		to_chat(user,"The anvil does not have any plasma magmite on it!")
		return ..()
	for(var/obj/item/I in placed_objects)
		if(istype(I,/obj/item/gun/energy/kinetic_accelerator) && forge_charges && used_magmite < magmite_amount)
			var/obj/item/gun/energy/kinetic_accelerator/gun = I
			if(gun.max_mod_capacity != 100)
				to_chat(user,"This is not a base kinetic accelerator!")
				break
			if(gun.bayonet)
				gun.remove_gun_attachment(item_to_remove = gun.bayonet)
			if(gun.gun_light)
				gun.remove_gun_attachment(item_to_remove = gun.gun_light)
			for(var/obj/item/borg/upgrade/modkit/kit in gun.modkits)
				kit.uninstall(gun)
			var/obj/item/gun/energy/kinetic_accelerator/mega/newgun = new(src)
			if(user.transferItemToLoc(newgun, src))
				vis_contents += newgun
				placed_objects += newgun
				RegisterSignal(newgun, COMSIG_MOVABLE_MOVED, .proc/ItemMoved,TRUE)
			ItemMoved(gun)
			qdel(gun)
			forge_charges--
			used_magmite++
			to_chat(user,"Harsh tendrils wrap around the kinetic accelerator, consuming the plasma magmite to form a mega kinetic accelerator.")
		if(istype(I,/obj/item/gun/energy/plasmacutter/adv) && forge_charges && used_magmite < magmite_amount)
			var/obj/item/gun/energy/plasmacutter/adv/gun = I
			if(gun.name != "advanced plasma cutter")
				to_chat(user,"This is not an advanced plasma cutter!")
				break
			var/obj/item/gun/energy/plasmacutter/adv/mega/newgun = new(src)
			if(user.transferItemToLoc(newgun, src))
				vis_contents += newgun
				placed_objects += newgun
				RegisterSignal(newgun, COMSIG_MOVABLE_MOVED, .proc/ItemMoved,TRUE)
			ItemMoved(gun)
			qdel(gun)
			forge_charges--
			used_magmite++
			to_chat(user,"Harsh tendrils wrap around the plasma cutter, consuming the plasma magmite to form a mega plasma cutter.")
	//time to clean up all the magmite we used
	for(var/obj/item/magmite in placed_objects)
		if(used_magmite)
			used_magmite--
			ItemMoved(magmite)
			qdel(magmite)
	update_icon()
	if(!forge_charges)
		to_chat(user,"The world anvil cools down.")
	
	
