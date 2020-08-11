//HONK HONK HONK HONK HONK HONK HONK
/obj/structure/destructible/honkmother
	name = "The Honkmother"
	desc = "HONK!"
	icon = 'icons/effects/288x288.dmi'
	icon_state = "honkmother"
	//Centers Her
	pixel_x = -144
	pixel_y = -144
	//She's immortal! Unkillable! Unmatched!
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = 0
	light_power = 0.7
	light_range = 15
	//Yellow, the color of bananas!
	light_color = "#FFFF000"
	//How far things are turned around Her are turned into bananium
	var/convert_range = 10
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/structure/destructible/honkmother/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	send_to_playing_players("<span class='reallybig'><span class='clown'>HONK!</span></span>")
	//mine now bitch
	sound_to_playing_players('sound/effects/ratvar_reveal.ogg')
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/items_and_weapons.dmi', "bike_horn")
	notify_ghosts("Pranks must be spread to the people! Touch The Honkmother at [get_area_name(src)] and become one of her glorious creations!", null, source = src, alert_overlay = alert_overlay)

/obj/structure/destructible/honkmother/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/honkmother/attack_ghost(mob/dead/observer/O)
	var/alertresult = alert(O, "Become a honking abomination? You can no longer be cloned!",,"Yes", "No")
	if(alertresult == "No" || QDELETED(O) || !istype(O) || !O.key)
		return FALSE
	var/list/L = list(
		"clown",
		"clown/lube",
		"clown/banana",
		"clown/afro",
		"clown/thin",
		"clown/honkling",
		"clown/fleshclown",
		"clown/longface",
		"clown/clownhulk",
		"clown/clownhulk/chlown",
		"clown/clownhulk/honcmunculus",
		"clown/clownhulk/destroyer",
		"clown/clownhulk/punisher",
		"clown/mutant",
		"clown/mutant/blob",
		"clown/mutant/thicc")
	var/MobType = text2path("/mob/living/simple_animal/hostile/retaliate/[pick(L)]"
	var/MobType/R = new/MobType(get_turf(src))
	R.visible_message("<span class='clown'>[R] awakens!</span>")
	R.key = O.key

/obj/structure/destructible/honkmother/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(T, dir) //NOTHING WILL STAND IN THE WAY OF PRANKS
	forceMove(T)

/obj/structure/destructible/honkmother/process()
	for(var/I in circlerangeturfs(src, convert_range))
		var/turf/T = I
		T.honk_act()
	for(var/I in circleviewturfs(src, round(convert_range * 0.5)))
		var/turf/T = I
		T.honk_act(TRUE)
	var/dir_to_step_in = pick(GLOB.cardinals)
	step(src, dir_to_step_in)