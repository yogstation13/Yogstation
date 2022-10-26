//Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bluespace_crystal"
	singular_name = "bluespace crystal"
	dye_color = DYE_COSMIC
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT)
	points = 75
	var/blink_range = 8 // The teleport range when crushed/thrown at someone.
	refined_type = /obj/item/stack/sheet/bluespace_crystal
	grind_results = list(/datum/reagent/bluespace = 20)

/obj/item/stack/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	points = 0
	refined_type = null

/obj/item/stack/ore/bluespace_crystal/refined/nt // NT's telecrystal
	name = "warpcrystal"
	desc = "The culmination of Nanotrasen's sacrifices in pursuing technological advancement. Highly top-secret."
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT*2.5) // more potent

/obj/item/stack/ore/bluespace_crystal/refined/nt/five
	amount = 5

/obj/item/stack/ore/bluespace_crystal/refined/nt/twenty
	amount = 20

/obj/item/stack/ore/bluespace_crystal/refined/nt/attack_self(mob/user)
	if(!isliving(user))
		return
	
	var/mob/living/L = user

	var/turf/destination = get_teleport_loc(loc, L, rand(3,6)) // Gets 3-6 tiles in the user's direction

	if(!istype(destination))
		return

	L.visible_message(span_warning("[L] crushes [src]!"), span_danger("You crush [src]!"))
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)

	if(!do_teleport(L, destination, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE))
		L.visible_message(span_warning("[src] refuses to be crushed by [L]! There must be something interfering!"), span_danger("[src] suddenly hardens in your hand! There must be something interfering!"))
		return

	// Throws you one additional tile, giving it that cool "exit portal" effect and also throwing people very far if they are in space
	L.throw_at(get_edge_target_turf(L, L.dir), 1, 3, spin = FALSE, diagonals_first = TRUE)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		// Half as debilitating than a bluespace crystal, as this is a precious resource you're using
		C.adjust_disgust(15)
	
	use(1)

/obj/item/stack/ore/bluespace_crystal/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/bluespace_crystal/get_part_rating()
	return 1

/obj/item/stack/ore/bluespace_crystal/attack_self(mob/user)
	user.visible_message(span_warning("[user] crushes [src]!"), span_danger("You crush [src]!"))
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)
	blink_mob(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.adjust_disgust(30)	//Won't immediately make you vomit, just dont use more than one or two at a time
		C.confused += 7
	use(1)

/obj/item/stack/ore/bluespace_crystal/proc/blink_mob(mob/living/L)
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/stack/ore/bluespace_crystal/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) // not caught in mid-air
		visible_message(span_notice("[src] fizzles and disappears upon impact!"))
		var/turf/T = get_turf(hit_atom)
		new /obj/effect/particle_effect/sparks(T)
		playsound(loc, "sparks", 50, 1)
		if(isliving(hit_atom))
			blink_mob(hit_atom)
		use(1)

//Artificial bluespace crystal, doesn't give you much research.
/obj/item/stack/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT*0.5)
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 //nice try
	refined_type = null
	grind_results = list(/datum/reagent/bluespace = 10, /datum/reagent/silicon = 20)

//Polycrystals, aka stacks
/obj/item/stack/sheet/bluespace_crystal
	name = "bluespace polycrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "polycrystal"
	item_state = "sheet-polycrystal"
	singular_name = "bluespace polycrystal"
	desc = "A stable polycrystal, made of fused-together bluespace crystals. You could probably break one off."
	materials = list(/datum/material/bluespace=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("bluespace polybashed", "bluespace polybattered", "bluespace polybludgeoned", "bluespace polythrashed", "bluespace polysmashed")
	novariants = TRUE
	grind_results = list(/datum/reagent/bluespace = 20)
	point_value = 30
	var/crystal_type = /obj/item/stack/ore/bluespace_crystal/refined

/obj/item/stack/sheet/bluespace_crystal/attack_self(mob/user)// to prevent the construction menu from ever happening
	to_chat(user, span_warning("You cannot crush the polycrystal in-hand, try breaking one off."))

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/sheet/bluespace_crystal/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		var/BC = new crystal_type(src)
		user.put_in_hands(BC)
		use(1)
		if(!amount)
			to_chat(user, span_notice("You break the final crystal off."))
		else
			to_chat(user, span_notice("You break off a crystal."))
	else
		..()
