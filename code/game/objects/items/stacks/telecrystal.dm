/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON

/obj/item/stack/telecrystal/attack_self(mob/user)
	if(!isliving(user))
		return
	
	var/mob/living/L = user

	var/turf/destination = get_teleport_loc(loc, L, rand(3,6)) // Gets 3-6 tiles in the user's direction

	if(!istype(destination))
		return

	L.visible_message(span_warning("[L] crushes [src]!"), span_danger("You crush [src]!"))
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)

	if(do_teleport(L, destination, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE))
		L.visible_message(span_warning("[src] refuses to be crushed by [L]! There must be something interfering!"), span_danger("[src] suddenly hardens in your hand! There must be something interfering!"))
		return

	// Throws you one additional tile, giving it that cool "exit portal" effect and also throwing people very far if they are in space
	L.throw_at(get_edge_target_turf(L, L.dir), 1, 3, spin = FALSE, diagonals_first = TRUE)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		// Half as debilitating than a bluespace crystal, as this is a precious resource you're using
		C.adjust_disgust(15)
	
	use(1)

/obj/item/stack/telecrystal/attack(mob/target, mob/user)
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/implant/uplink/I in target)
			if(I && I.imp_in)
				var/datum/component/uplink/hidden_uplink = I.GetComponent(/datum/component/uplink)
				if(hidden_uplink)
					hidden_uplink.telecrystals += amount
					use(amount)
					to_chat(user, span_notice("You press [src] onto yourself and charge your hidden uplink."))
	else
		return ..()

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(istype(I, /obj/item/cartridge/virus/frame))
		var/obj/item/cartridge/virus/frame/cart = I
		if(!cart.charges)
			to_chat(user, span_notice("[cart] is out of charges, it's refusing to accept [src]."))
			return
		cart.telecrystals += amount
		use(amount)
		to_chat(user, span_notice("You slot [src] into [cart].  The next time it's used, it will also give telecrystals."))

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20
