/obj/item/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters_map"
	item_state = "cutters"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=80)
	attack_verb = list("pinched", "nipped")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/wirecutter_drop.ogg'
	pickup_sound =  'sound/items/handling/wirecutter_pickup.ogg'

	tool_behaviour = TOOL_WIRECUTTER
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	var/random_color = TRUE
	var/static/list/wirecutter_colors = list(
		"blue" = "#1861d5",
		"red" = "#951710",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#d58c18"
	)


/obj/item/wirecutters/Initialize()
	. = ..()
	if(random_color) //random colors!
		icon_state = "cutters"
		var/our_color = pick(wirecutter_colors)
		add_atom_colour(wirecutter_colors[our_color], FIXED_COLOUR_PRIORITY)
		update_icon()

/obj/item/wirecutters/update_icon()
	if(!random_color) //icon override
		return
	cut_overlays()
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "cutters_cutty_thingy")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)

/obj/item/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/restraints/handcuffs/cable))
		user.visible_message(span_notice("[user] cuts [C]'s restraints with [src]!"))
		qdel(C.handcuffed)
		return
	else if(istype(C) && C.has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
		to_chat(C, span_notice("You attempt to remove the durathread strand from around your neck."))
		if(do_after(user, 1.5 SECONDS, C))
			to_chat(C, span_notice("You succesfuly remove the durathread strand."))
			C.remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
	else if(!(user.a_intent == INTENT_HARM) && attempt_initiate_surgery(src, C, user))
		return
	else
		..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is cutting at [user.p_their()] arteries with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, usesound, 50, 1, -1)
	return (BRUTELOSS)

/obj/item/wirecutters/brass
	name = "brass wirecutters"
	desc = "A pair of wirecutters made of brass. The handle feels freezing cold to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "cutters_brass"
	random_color = FALSE
	toolspeed = 0.5

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters_alien"
	toolspeed = 0.1

	random_color = FALSE

/obj/item/wirecutters/cyborg
	name = "wirecutters"
	desc = "This cuts wires."
	toolspeed = 0.5

/obj/item/wirecutters/makeshift
	name = "makeshift wirecutters"
	desc = "Mind your fingers."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "cutters_makeshift"
	toolspeed = 0.5
	random_color = FALSE

/obj/item/wirecutters/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
