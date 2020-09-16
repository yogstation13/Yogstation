
/obj/item/blunderbuss
	name = "blunderbuss"
	desc = "A muzzle-loaded firearm powered by welding fuel. It might not be a good idea to use more than 10u of fuel in one shot."
	icon = 'icons/obj/vg_items.dmi'
	icon_state = "blunderbuss"
	righthand_file = 'icons/mob/inhands/vg/vg_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/vg/vg_lefthand.dmi'
	attack_verb = list("strikes", "hits", "bashes")
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/loaded_item
	var/obj/item/reagent_containers/glass/beaker/reservoir/boomtank  //shh just take it as a fuel reservoir
	var/sound/firesound = 'sound/weapons/gunshot2.ogg'
	var/cooldowntime = 50
	var/cooldown = 0
	var/flawless = 0

/obj/item/reagent_containers/glass/beaker/reservoir/Initialize(mapload, vol)
	. = ..()
	vol = 30

/obj/item/blunderbuss/Initialize()
	. = ..()
	boomtank = new /obj/item/reagent_containers/glass/beaker/reservoir(src)

/obj/item/blunderbuss/attackby(obj/item/I, mob/user, params)
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
	else if(I.w_class <= WEIGHT_CLASS_NORMAL && !loaded_item)
		I.forceMove(src)
		loaded_item = I
		to_chat(user, "<span class='notice'>You load \the [I] on [src].</span>")
	else if(loaded_item)
		to_chat(user, "<span class='warning'>[src] is already loaded!</span>")
	else
		to_chat(user, "<span class='warning'>[I] is too bulky to be shot!</span>")

/obj/item/blunderbuss/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has <b>[boomtank.reagents.get_reagent_amount(/datum/reagent/fuel)]</b> units of fuel.</span>"
	. += "<span class='notice'>[src] has <b>[loaded_item ? loaded_item.name : "nothing"]</b> loaded on it.</span>"

/obj/item/blunderbuss/attack_self(mob/user)
	. = ..()
	if(loaded_item)
		to_chat(user, "<span class='notice'>You pull [loaded_item] out of \the [src].</span>")
		loaded_item.forceMove(user.loc)
		loaded_item = null
	else if(!loaded_item && boomtank.reagents.total_volume)
		to_chat(user, "<span class='notice'>You empty \the [src]'s fuel reservoir.</span>")
		boomtank.reagents.remove_all(boomtank.reagents.total_volume)

/obj/item/blunderbuss/proc/explode(mob/user)
	if(!flawless)
		to_chat(user, "<span class='danger'>\The [src]'s firing mechanism fails!</span>")
		if(loaded_item)
			loaded_item.forceMove(user.loc)
			loaded_item = null
		explosion(user, -1, -1, 2, 1)
		qdel(src)
		return TRUE
	else
		return FALSE

/obj/item/blunderbuss/proc/get_target(turf/target, turf/starting)
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

/obj/item/blunderbuss/proc/get_fucked(var/i = 0)
	if(!i)
		return FALSE
	if(i<=10)
		return 0
	if(i>10 && i<=20)
		return 1
	if(i>20)
		return 2

/obj/item/blunderbuss/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	Fire(user, target)

/obj/item/blunderbuss/proc/Fire(mob/living/user, var/atom/target)
	if(!istype(user) && !target)
		return
	var/discharge = 0
	if(!can_trigger_gun(user))
		return
	if(!loaded_item)
		to_chat(user, "<span class='warning'>\The [src] has nothing loaded.</span>")
		return
	if(!boomtank)
		to_chat(user, "<span class='warning'>\The [src] can't fire without a source of fuel.</span>")
		return
	if(boomtank && (boomtank.reagents.total_volume < 10))
		to_chat(user, "<span class='warning'>\The [src] lets out a weak hiss and doesn't fire!</span>")
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(75) && iscarbon(user))
		var/mob/living/carbon/C = user
		C.visible_message("<span class='warning'>[C] loses [C.p_their()] grip on [src], causing it to go off!</span>", "<span class='userdanger'>[src] slips out of your hands and goes off!</span>")
		C.dropItemToGround(src, TRUE)
		if(prob(10))
			target = get_turf(user)
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
		discharge = 1
	if(!discharge)
		user.visible_message("<span class='danger'>[user] fires \the [src]!</span>", \
				    		 "<span class='danger'>You fire \the [src]!</span>")
	log_combat(user, target, "fired at", src)
	var/turf/T = get_target(target, get_turf(src))
	var/howfucked = get_fucked(boomtank.reagents.total_volume)
	playsound(src, firesound, rand(50, 100), 0)
	fire_items(T, user, howfucked)

/obj/item/blunderbuss/proc/fire_items(turf/target, mob/user, var/howfucked = 0)
	if(!loaded_item || (boomtank.reagents.total_volume < 10))
		return
	boomtank.reagents.remove_all(boomtank.reagents.total_volume)
	var/obj/item/I
	I = loaded_item
	if(!throw_item(target, I, user, howfucked))
		return
	var/chancetogetfucked = 0
	switch(howfucked)
		if(1)
			chancetogetfucked = 15
		if(2)
			chancetogetfucked = 30
	if(prob(chancetogetfucked))
		explode(user)

/obj/item/blunderbuss/proc/throw_item(turf/target, obj/item/I, mob/user, var/range_multiplier)
	if(!istype(I))
		return FALSE
	loaded_item = null
	I.forceMove(get_turf(src))
	I.throw_at(target, 7 * (range_multiplier + 1), 3, user)
	return TRUE
