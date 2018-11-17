/mob/living/simple_animal/chocobo
	name = "\improper chocobo"
	desc = "Where the hell does this comes from?"
	gender = MALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	icon = 'yogstation/icons/mob/chocobo.dmi'
	icon_state = "chocobo"
	icon_living = "chocobo"
	icon_dead = "chocobo"
	del_on_death = TRUE //no sprites ;(
	speak_emote = list("clucks","croons","warks")
	emote_hear = list("clucks.","warks.")
	emote_see = list("warks violently.","flaps its wings viciously.")
	density = TRUE
	speak_chance = 2
	turns_per_move = 5
	loot = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 25
	maxHealth = 25
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	do_footstep = FALSE
	tame = 1
	can_buckle = 1
	buckle_lying = 0
	var/random_color = TRUE

/mob/living/simple_animal/chocobo/Initialize()
	. = ..()
	if(random_color)
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
		update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8, MOB_LAYER), TEXT_SOUTH = list(0, 8, MOB_LAYER), TEXT_EAST = list(0, 8, MOB_LAYER), TEXT_WEST = list( 0, 8, MOB_LAYER)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)

/mob/living/simple_animal/chocobo/proc/update_icon()
	if(!random_color) //icon override
		return
	cut_overlays()
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "chocobo_limbs")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)