//I am honkadias clown of clowns look upon my pranks and despair!
/obj/structure/destructible/honkmother
	name = "The Honkmother"
	desc = "HONK!"
	icon = 'icons/effects/288x288.dmi'
	//Sprite made by MerchantPixels
	icon_state = "honkmother"
	//Centers Her
	pixel_x = -128
	pixel_y = -128
	//She's immortal! Unkillable! Unmatched!
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = 0
	light_power = 0.7
	light_range = 15
	//Yellow, the color of bananas!
	light_color = "#FFFF000"
	///How far things around Her are turned into bananium
	var/convert_range = 8
	//She is above even fire
	layer = RIPPLE_LAYER
	movement_type = UNSTOPPABLE
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/structure/destructible/honkmother/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	send_to_playing_players(span_clown("HONK!"))
	//mine now bitch
	sound_to_playing_players('sound/effects/ratvar_reveal.ogg')
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/toy.dmi', "bike_horn")
	notify_ghosts("Pranks must be spread to the people! Touch The Honkmother at [get_area_name(src)] and become one of her glorious creations!", null, source = src, alert_overlay = alert_overlay)

/obj/structure/destructible/honkmother/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/honkmother/attack_ghost(mob/dead/observer/O)
	var/alertresult = alert(O, "Become a honking abomination? You can no longer be cloned!",,"Yes", "No")
	if(alertresult == "No" || QDELETED(O) || !istype(O) || !O.key)
		return FALSE
	var/type = pick(typesof(/mob/living/simple_animal/hostile/retaliate/clown))
	var/mob/R = new type(get_turf(src))
	R.visible_message(span_warning("[R] awakens!"))
	R.key = O.key

//moves and turns things into BANANIUM
/obj/structure/destructible/honkmother/process()
	for(var/I in circlerangeturfs(src, convert_range))
		var/turf/T = I
		if(prob(20))
			T.honk_act()
	for(var/F in circleviewturfs(src, round(convert_range * 0.5)))
		var/turf/T = F
		T.honk_act(TRUE)
		for(var/I in T)
			var/atom/A = I
			A.honk_act()
	var/dir_to_step_in = pick(GLOB.cardinals)
	step(src, dir_to_step_in)
