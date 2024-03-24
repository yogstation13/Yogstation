/obj/item/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	item_state = "screwdriver"
	belt_icon_state = "screwdriver"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	greyscale_config = /datum/greyscale_config/screwdriver
	greyscale_config_belt = /datum/greyscale_config/screwdriver_belt
	greyscale_config_inhand_left = /datum/greyscale_config/screwdriver_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/screwdriver_inhand_right

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	demolition_mod = 0.5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=75)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg')
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound =  'sound/items/handling/screwdriver_pickup.ogg'

	tool_behaviour = TOOL_SCREWDRIVER
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	sharpness = SHARP_POINTY
	var/random_color = TRUE //if the screwdriver uses random coloring
	var/static/list/screwdriver_colors = list(
		COLOR_TOOL_BLUE,
		COLOR_TOOL_RED,
		COLOR_TOOL_PINK,
		COLOR_TOOL_BROWN,
		COLOR_TOOL_GREEN,
		COLOR_TOOL_CYAN,
		COLOR_TOOL_YELLOW,
	)

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is stabbing [src] into [user.p_their()] [pick("temple", "heart")]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(BRUTELOSS)

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	if(random_color) //random colors!
		set_greyscale(colors = list(pick(screwdriver_colors)))
	if(prob(75))
		pixel_y = rand(0, 16)

/obj/item/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!(user.a_intent == INTENT_HARM) && attempt_initiate_surgery(src, M, user))
		return
	if(!istype(M))
		return ..()
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return ..()
	if(!synth_check(user, SYNTH_ORGANIC_HARM))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm [M]!"))
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "A screwdriver made of brass. The handle feels freezing cold."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "screwdriver_brass"
	item_state = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver_alien"
	item_state = "screwdriver_nuke"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "An electrical screwdriver, designed to be both precise and quick."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5

/obj/item/screwdriver/makeshift
	name = "makeshift screwdriver"
	desc = "Crude driver of screws. A primitive way to screw things up."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "screwdriver_makeshift"
	item_state = "screwdriver_makeshift"
	toolspeed = 2
	random_color = FALSE

/obj/item/screwdriver/makeshift/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(prob(5))
		to_chat(user, span_danger("[src] crumbles apart in your hands!"))
		qdel(src)
		return
