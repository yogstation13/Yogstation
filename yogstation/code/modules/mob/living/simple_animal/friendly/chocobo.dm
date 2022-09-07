/mob/living/simple_animal/chocobo
	name = "\improper chocobo"
	desc = "Where the hell does this come from?"
	gender = MALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	icon = 'yogstation/icons/mob/chocobo.dmi'
	icon_state = "chocobo"
	icon_living = "chocobo"
	icon_dead = "chocobo_dead"
	speak_emote = list("clucks","croons","warks")
	emote_hear = list("clucks.","warks.")
	emote_see = list("warks violently.","flaps its wings viciously.")
	density = TRUE
	speak_chance = 2
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 60
	maxHealth = 60
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
	D.vehicle_move_delay = 1

/mob/living/simple_animal/chocobo/(gibbed)
	. = ..()
	update_icon()
	for(var/mob/living/N in buckled_mobs)
		unbuckle_mob(N)
	can_buckle = FALSE

/mob/living/simple_animal/chocobo/revive(full_heal, admin_revive)
	. = ..()
	if(.)
		can_buckle = initial(can_buckle)
	update_icon()

/mob/living/simple_animal/chocobo/proc/update_icon()
	if(!random_color) //icon override
		return
	cut_overlays()
	if(stat == DEAD)
		var/mutable_appearance/base_overlay = mutable_appearance(icon, "chocobo_limbs_dead")
		base_overlay.appearance_flags = RESET_COLOR
		add_overlay(base_overlay)
	else
		var/mutable_appearance/base_overlay = mutable_appearance(icon, "chocobo_limbs")
		base_overlay.appearance_flags = RESET_COLOR
		add_overlay(base_overlay)
