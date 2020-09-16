/obj/vehicle/ridden/wheelchair/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gun_barrel) && !istype(src, /obj/vehicle/ridden/wheelchair/wheelchair_assembly))
		new /obj/vehicle/ridden/wheelchair/wheelchair_assembly(src.loc)
		to_chat(user, "<span class='notice'>You attach the barrel to the wheelchair.</span>")
		qdel(I)
		qdel(src)

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/weldingtool) && !istype(src, /obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon))
		var/obj/item/weldingtool/weldy = I 
		if(weldy.isOn())
			new /obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon(src.loc)
			to_chat(user, "<span class='notice'>You weld the barrel to the wheelchair.</span>")
			qdel(I)
			qdel(src)

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon
	name = "cannon"
	desc = "A makeshift cannon. This primitive weapon uses centuries-old technology."
	icon = 'modular_skyrat/icons/obj/vg_items.dmi'
	icon_state = "cannon"
	var/obj/item/loaded_item
	var/obj/item/reagent_containers/glass/beaker/reservoir/boomtank  //shh just take it as a fuel reservoir
	var/sound/firesound = 'sound/effects/explosion3.ogg'
	var/cooldowntime = 50
	var/cooldown = 0
	var/flawless = 0
	density = TRUE

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/Initialize()
	. = ..()
	boomtank = new /obj/item/reagent_containers/glass/beaker/reservoir(src)

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers))
		if(user.a_intent == INTENT_HELP)
			var/obj/item/reagent_containers/R = I
			var/datum/reagent/fuel/F
			for(var/datum/reagent/Re in R.reagents.reagent_list)
				if(istype(Re, /datum/reagent/fuel))
					F = Re
			if(F)
				if(R.reagents.trans_id_to(boomtank, F.type, F.volume))
					to_chat(user, "<span class='notice'>You transfer all of [R]'s possible fuel to \the [src].</span>")
				else
					to_chat(user, "<span class='notice'>\The [src] is already full.</span>")
			else 
				to_chat(user, "<span class='notice'>\The [R] has no fuel.</span>")
		else 
			if(I.w_class <= WEIGHT_CLASS_NORMAL && !loaded_item)
				I.forceMove(src)
				loaded_item = I
				to_chat(user, "<span class='notice'>You load \the [I] on [src].</span>")
			else if(loaded_item)
				to_chat(user, "<span class='warning'>[src] is already loaded!</span>")
			else
				to_chat(user, "<span class='warning'>[I] is too bulky to be shot!</span>")
	else if(istype(I, /obj/item/assembly/igniter))
		addtimer(CALLBACK(src, .proc/Fire, user, get_edge_target_turf(src, dir)), 30)
		visible_message("<span class='danger'>[user] sets the [src]'s wick on fire! Get back!</span>")
	else if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/L = I
		if(L.isOn())
			addtimer(CALLBACK(src, .proc/Fire, user, get_edge_target_turf(src, dir)), 30)
			visible_message("<span class='danger'>[user] sets the [src]'s wick on fire! Get back!</span>")
	else if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/L = I
		if(L.lit)
			addtimer(CALLBACK(src, .proc/Fire, user, get_edge_target_turf(src, dir)), 30)
			visible_message("<span class='danger'>[user] sets the [src]'s wick on fire! Get back!</span>")
	else
		if(I.w_class <= WEIGHT_CLASS_NORMAL && !loaded_item)
			I.forceMove(src)
			loaded_item = I
		else if(loaded_item)
			to_chat(user, "<span class='warning'>[src] is already loaded!</span>")
		else
			to_chat(user, "<span class='warning'>[I] is too bulky to be shot!</span>")

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has <b>[boomtank.reagents.get_reagent_amount(/datum/reagent/fuel)]</b> units of fuel.</span>"
	. += "<span class='notice'>[src] has <b>[loaded_item ? loaded_item.name : "nothing"]</b> loaded on it.</span>"
	. += "<span class='notice'>[src] can be lit with a lighter, igniter or welding tool.</span>"

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/attack_hand(mob/living/user)
	. = ..()
	if(loaded_item)
		to_chat(user, "<span class='notice'>You pull [loaded_item] out of \the [src].</span>")
		loaded_item.forceMove(user.loc)
		loaded_item = null
	else if(!loaded_item && boomtank.reagents.total_volume)
		to_chat(user, "<span class='notice'>You empty \the [src]'s fuel reservoir.</span>")
		boomtank.reagents.remove_all(boomtank.reagents.total_volume)

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/get_target(turf/target, turf/starting)
	var/x_o = (target.x - starting.x)
	var/y_o = (target.y - starting.y)
	var/range_multiplier = 1
	if(boomtank.reagents.total_volume<=10)
		range_multiplier *= 1
	if(boomtank.reagents.total_volume>10 && boomtank.reagents.total_volume<=20)
		range_multiplier *= 2
	if(boomtank.reagents.total_volume>20)
		range_multiplier *= 3
	var/new_x = clamp(starting.x + (x_o * range_multiplier), 0, world.maxx)
	var/new_y = clamp(starting.y + (y_o * range_multiplier), 0, world.maxy)
	var/turf/newtarget = locate(new_x, new_y, starting.z)
	return newtarget

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/get_fucked(var/i = 0)
	if(!i)
		return FALSE
	if(boomtank.reagents.total_volume<=10)
		return 0
	if(boomtank.reagents.total_volume>10 && boomtank.reagents.total_volume<=20)
		return 1
	if(boomtank.reagents.total_volume>20)
		return 2

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/explode()
	if(!flawless)
		visible_message("<span class='userdanger'>\The [src]'s barrel gets too pressurized and explodes!</span>")
		if(loaded_item)
			loaded_item.forceMove(src.loc)
			loaded_item = null
		explosion(src, -1, -1, 4, 2)
		qdel(src)
		return TRUE
	else
		return FALSE

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/Fire(var/atom/target)
	if(!loaded_item)
		visible_message("<span class='warning'>\The [src] shoots out a puff of smoke! It wasn't loaded!</span>")
		return
	if(!boomtank)
		visible_message("<span class='warning'>\The [src] dribbles out [loaded_item]! It wasn't fueled!</span>")
		loaded_item.forceMove(src.loc)
		loaded_item = null
		return
	if(boomtank && (boomtank.reagents.total_volume < 10))
		visible_message("<span class='warning'>\The [src] dribbles out [loaded_item]! It wasn't fueled enough!</span>")
		loaded_item.forceMove(src.loc)
		loaded_item = null
		return
	var/turf/T = get_target(target, get_turf(src))
	var/howfucked = get_fucked(boomtank.reagents.total_volume)
	playsound(src, firesound, rand(100, 150), 0)
	fire_items(T, howfucked)

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/fire_items(turf/target, var/howfucked = 0)
	if(!loaded_item || (boomtank.reagents.total_volume < 10))
		return
	boomtank.reagents.remove_all(boomtank.reagents.total_volume)
	var/obj/item/I
	I = loaded_item
	if(!throw_item(target, I, howfucked))
		return
	var/chancetogetfucked = 0
	switch(howfucked)
		if(1)
			chancetogetfucked = 15
		if(2)
			chancetogetfucked = 30
	if(prob(chancetogetfucked))
		explode()

/obj/vehicle/ridden/wheelchair/wheelchair_assembly/cannon/proc/throw_item(turf/target, obj/item/I, var/range_multiplier)
	if(!istype(I))
		return FALSE
	loaded_item = null
	I.forceMove(get_turf(src))
	I.throw_at(target, 7 * (range_multiplier + 1), 4)
	return TRUE
