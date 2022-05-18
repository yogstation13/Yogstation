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

	var/obj/item/gps/internal

/obj/item/gps/internal/world_anvil
	icon_state = null
	gpstag = "Tempered Signal"
	desc = "An ancient anvil rests at this location."
	invisibility = 100

/obj/structure/world_anvil/Initialize()
	. = ..()
	internal = new /obj/item/gps/internal/world_anvil(src)

/obj/structure/world_anvil/Destroy()
	QDEL_NULL(internal)
	. = ..()

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

/obj/structure/world_anvil/proc/crafting_check(mob/user)
	if(!forge_charges)
		return
	var/crafted = FALSE
	for(var/obj/item/magmite/placed_magmite in placed_objects)
		crafted = TRUE
		var/obj/item/upgrade_parts = new /obj/item/magmite_parts(src)
		vis_contents += upgrade_parts
		placed_objects += upgrade_parts
		RegisterSignal(upgrade_parts, COMSIG_MOVABLE_MOVED, .proc/ItemMoved,TRUE)
		placed_objects -= placed_magmite
		qdel(placed_magmite)
		forge_charges--
		update_icon()
		if(!forge_charges)
			break
	if(crafted)
		to_chat(user, "You forge the plasma magmite into plasma magmite upgrade parts.")
	if(!forge_charges)
		visible_message("The world anvil cools down.")

/obj/structure/world_anvil/attack_hand(mob/user)
	if(!LAZYLEN(placed_objects))
		to_chat(user,"You must place plasma magmite on the anvil to forge it!")
		return ..()
	if(forge_charges <= 0)
		to_chat(user,"The anvil is not heated enough to be usable!")
		return ..()
	if(do_after(user,10 SECONDS, target = src))
		crafting_check()

		//instead of doing it like this, make it so when you press on a heated anvil with a plasma magmite you wait 5-10 seconds and it will then be forged into parts. simpler.
