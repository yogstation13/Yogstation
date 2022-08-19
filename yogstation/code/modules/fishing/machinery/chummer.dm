/obj/machinery/chummer //pretty much a gibber that gives chum instead of meat 
	name = "chummer"
	desc = "Chum chum give me gum gum"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/chummer

	var/operating = FALSE //Is it on?
	var/chum_time = 4 SECONDS // Time from starting until chum appears
	var/chum_produced = 0 //how many chum per item, starts at 1 in RefreshParts()
	var/max_items = 4 //how many things you can put in here before you process it

/obj/machinery/chummer/Initialize()
	. = ..()
	add_overlay("grjam")

/obj/machinery/chummer/RefreshParts()
	chum_time = initial(chum_time)
	chum_produced = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		chum_produced += B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		chum_produced -= 5 * M.rating

/obj/machinery/chummer/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Outputting <b>[chum_produced]</b> chum after <b>[chum_time*0.1]</b> seconds of processing.<span>"

/obj/machinery/chummer/update_icon()
	cut_overlays()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!contents.len)
		add_overlay("grjam")
	else if (operating)
		add_overlay("gruse")
	else
		add_overlay("gridle")

/obj/machinery/chummer/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/chummer/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, span_danger("It's locked and running."))
		return

	if(!anchored)
		to_chat(user, span_notice("[src] cannot be used unless bolted to the ground."))
		return
	
	if(!contents.len)
		to_chat("[src] is empty!")
		return
	
	start_chumming(user)

/obj/machinery/chummer/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	else if(default_pry_open(P))
		return

	else if(default_unfasten_wrench(user, P))
		return

	else if(default_deconstruction_crowbar(P))
		return
	else if(!istype(P,/obj/item/reagent_containers/food/snacks))
		return ..()

	if(contents.len >= max_items)
		to_chat("[src] is full!")
		return
	var/obj/item/reagent_containers/food/snacks/food_input = P
	if(food_input.foodtype & MEAT || food_input.foodtype & SEAFOOD)
		food_input.forceMove(src)
		to_chat(user,"You put [food_input] in [src].")
	else
		to_chat(user,span_notice("Only food made of meat and seafood can be chummed!"))

/obj/machinery/chummer/proc/start_chumming(user)
	use_power(1000)
	visible_message(span_italics("You hear a loud squelchy grinding sound."))
	playsound(src.loc, 'sound/machines/juicer.ogg', 25, 1)
	operating = TRUE
	update_icon()

	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.02 SECONDS, loop = 200) //start shaking

	addtimer(CALLBACK(src, .proc/chum, user, chum_time))

/obj/machinery/chummer/proc/chum(user)
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	operating = FALSE
	pixel_x = initial(pixel_x) //return to its spot after shaking
	update_icon()
	var/turf/T = get_turf(src)
		for(var/obj/item/I in contents)
			new/obj/item/reagent_containers/food/snacks/chum(T)
			qdel(I)



