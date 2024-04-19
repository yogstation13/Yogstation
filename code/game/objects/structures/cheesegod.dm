//The big cheese
/obj/structure/destructible/cheesegod
	name = "The Gouda of All Cheese"
	desc = "Looks Delicious!"
	icon = 'icons/effects/512x512.dmi'
	//Sprite made by Missatessatessy
	icon_state = "gouda"
	pixel_x = -235
	pixel_y = -248
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = 0
	light_power = 0.7
	light_range = 15
	light_color = "#FFD000"
	var/convert_range = 8
	layer = RIPPLE_LAYER
	movement_type = PHASING
	break_sound = 'sound/effects/splosh.ogg'
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/structure/destructible/cheesegod/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	send_to_playing_players(span_clown("You feel a dairy-like presence.."))
	sound_to_playing_players('sound/effects/gouda_rises.ogg')
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/food/cheese.dmi', "cheesewheel")
	notify_ghosts("The cheese must be enjoyed! Touch Gouda at [get_area_name(src)] and become one with the cheese", null, source = src, alert_overlay = alert_overlay)

/obj/structure/destructible/cheesegod/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/cheesegod/attack_ghost(mob/dead/observer/O)
	var/alertresult = tgui_alert(O, "Become one with the cheese? You can no longer be cloned!",,list("Yes", "No"))
	if(alertresult == "No" || QDELETED(O) || !istype(O) || !O.key)
		return FALSE
	var/mob/living/simple_animal/cheese/R = new/mob/living/simple_animal/cheese(get_turf(src))
	R.visible_message(span_warning("[R] awakens!"))
	R.key = O.key

//moves and spawns cheese - not yet added turning things into cheese
/obj/structure/destructible/cheesegod/process()
	/*for(var/I in circle_range_turfs(src, convert_range))
		var/turf/T = I
		if(prob(20))
			T.cheese_act()
	for(var/F in circleviewturfs(src, round(convert_range * 0.5)))
		var/turf/T = F
		T.cheese_act(TRUE)
		for(var/I in T)
			var/atom/A = I
			A.cheese_act() */
	if(prob(25))
		var/type = pick(typesof(/obj/item/reagent_containers/food/snacks/store/cheesewheel))
		new type(get_turf(src))
	var/dir_to_step_in = pick(GLOB.cardinals)
	step(src, dir_to_step_in)
	sound_to_playing_players('sound/misc/soggy.ogg', 100, TRUE)
