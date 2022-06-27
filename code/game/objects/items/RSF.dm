/*
CONTAINS:
RSF

*/
///Extracts the related object from a associated list of objects and values, or lists and objects.
#define OBJECT_OR_LIST_ELEMENT(from, input) (islist(input) ? from[input] : input)
/obj/item/rsf
	name = "\improper Rapid Service Fabricator (RSF)"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf" 	///The icon state to revert to when the tool is empty (thanks TG)
	var/spent_icon_state = "rsf_empty"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = 0
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	var/matter = 0 	///The current matter count
	var/max_matter = 50 	///The max amount of matter in the device
	var/to_dispense 	///The type of the object we are going to dispense
	var/dispense_cost = 0 	///The cost of the object we are going to dispense
	w_class = WEIGHT_CLASS_NORMAL
	///An associated list of atoms and charge costs. This can contain a seperate list, as long as it's associated item is an object
	var/list/cost_by_item = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 20,
								/obj/item/paper = 10,
								/obj/item/storage/pill_bottle/dice = 200,
								/obj/item/pen = 50,
								/obj/item/clothing/mask/cigarette = 10,
								/obj/item/plate = 25,
								)
	var/list/allowed_surfaces = list(/obj/structure/table) 	///A list of surfaces that we are allowed to place things on.
	var/action_type = "Dispensing" 	///The verb that describes what we're doing, for use in text

/obj/item/rsf/Initialize()
	. = ..()
	to_dispense = cost_by_item[1]
	dispense_cost = cost_by_item[to_dispense]

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += span_notice("It currently holds [matter]/[max_matter] matter-units.")

/obj/item/rsf/cyborg
	matter = 50

/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	var/loaded = FALSE
	if(istype(W, /obj/item/rcd_ammo))//If the thing we got hit by is in our matter list
		var/tempMatter = matter + 10
		if(tempMatter > max_matter)
			to_chat(user, span_warning("\The [src] can't hold any more matter-units!"))
			return
		qdel(W)
		matter = tempMatter //We add its value
		loaded = TRUE

	else if(istype(W, /obj/item/stack))
		loaded = loadwithsheets(W, user)
		
	else
		return ..()

	if(loaded)
		to_chat(user, span_notice("[src] now holds [matter]/[max_matter] matter-units."))
		icon_state = initial(icon_state)//and set the icon state to the initial value it had
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	var/target = cost_by_item
	var/cost = 0
	//Warning, prepare for bodgecode
	while(islist(target))//While target is a list we continue the loop
		var/picked = show_radial_menu(user, src, formRadial(target), custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE)
		if(!check_menu(user) || picked == null)
			return
		for(var/emem in target)//Back through target agian
			var/atom/test = OBJECT_OR_LIST_ELEMENT(target, emem)
			if(picked == initial(test.name))//We try and find the entry that matches the radial selection
				cost = target[emem]//We cash the cost
				target = emem
				break
		//If we found a list we start it all again, this time looking through its contents.
	to_dispense = target 	//This allows for sublists
	dispense_cost = cost
	// Change mode

/obj/item/rsf/proc/loadwithsheets(obj/item/stack/S, mob/user)
	var/value = S.matter_amount
	if(value <= 0)
		to_chat(user, span_notice("You can't insert [S.name] into [src]!"))
		return FALSE
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		to_chat(user, span_notice("You insert [amount_to_use] [S.name] sheets into [src]. "))
		return TRUE
	to_chat(user, span_warning("You can't insert any more [S.name] sheets into [src]!"))
	return FALSE

///Forms a radial menu based off an object in a list, or a list's associated object
/obj/item/rsf/proc/formRadial(from)
	var/list/radial_list = list()
	for(var/meme in from)//We iterate through all of targets entrys
		var/atom/temp = OBJECT_OR_LIST_ELEMENT(from, meme)
		//We then add their data into the radial menu
		radial_list[initial(temp.name)] = image(icon = initial(temp.icon), icon_state = initial(temp.icon_state))
	return radial_list

/obj/item/rsf/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!is_allowed(A, user))
		return
	if(use_matter(dispense_cost, user))//If we can charge that amount of charge, we do so and return true
		playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
		var/atom/meme = new to_dispense(get_turf(A))
		to_chat(user, span_notice("[action_type] [meme.name]..."))

///A helper proc. checks to see if we can afford the amount of charge that is passed, and if we can docs the charge from our base, and returns TRUE. If we can't we return FALSE
/obj/item/rsf/proc/use_matter(charge, mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		var/end_charge = R.cell.charge - charge
		if(end_charge < 0)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			icon_state = spent_icon_state
			return FALSE
		R.cell.charge = end_charge
		return TRUE
	else
		if(matter - 1 < 0)
			to_chat(user, span_warning("\The [src] doesn't have enough matter-units left."))
			icon_state = spent_icon_state
			return FALSE
		matter--
		to_chat(user, span_notice("\The [src] now holds [matter]/[max_matter] matter-units."))
		return TRUE

///Helper proc that iterates through all the things we are allowed to spawn on, and sees if the passed atom is one of them
/obj/item/rsf/proc/is_allowed(atom/to_check, mob/user)
	for(var/sort in allowed_surfaces)
		if(istype(to_check, sort))
			return TRUE

	to_chat(user, span_warning("\The [src] is unable to place this here!"))
	return FALSE

/obj/item/rsf/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon_state = "rcd"
	spent_icon_state = "rcd"
	max_matter = 10
	cost_by_item = list(/obj/item/reagent_containers/food/snacks/cookie = 100)
	dispense_cost = 100
	action_type = "Fabricating"
	///Tracks whether or not the cookiesynth is about to print a poisoned cookie
	var/toxin = FALSE //This might be better suited to some initialize fuckery, but I don't have a good "poisoned" sprite
	var/cooldown = 0 	///Holds a copy of world.time taken the last time the synth gained a charge. Used with cooldowndelay to track when the next charge should be gained
	var/cooldowndelay = 10 	///The period between recharges

/obj/item/rsf/cookiesynth/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/rsf/cookiesynth/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/rsf/cookiesynth/attackby()
	return

/obj/item/rsf/cookiesynth/emag_act(mob/user)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("You short out [src]'s reagent safety checker!"))
	else
		to_chat(user, span_warning("You reset [src]'s reagent safety checker!"))

/obj/item/rsf/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if(((obj_flags & EMAGGED) || (P && P.emagged)) && !toxin)
		toxin = TRUE
		to_dispense = /obj/item/reagent_containers/food/snacks/cookie/sleepy
	else
		toxin = FALSE
		to_dispense = /obj/item/reagent_containers/food/snacks/cookie
		to_chat(user, "Cookie Synthesizer Reset")

/obj/item/rsf/cookiesynth/process()
	matter = min(matter + 1, max_matter) //We add 1 up to a point
	if(matter >= max_matter)
		STOP_PROCESSING(SSprocessing, src)

/obj/item/rsf/cookiesynth/afterattack(atom/A, mob/user, proximity)
	. = ..()
	cooldown = world.time + cooldowndelay
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprocessing, src)

/obj/item/donutsynth
	name = "Donut Synthesizer"
	desc = "A self-recharging device used to rapidly deploy donuts."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	var/matter = 10
	var/cooldown = 0
	var/cooldowndelay = 10
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/donutsynth/attackby()
	return

/obj/item/donutsynth/process()
	if(matter < 10)
		matter++

/obj/item/donutsynth/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(matter < 1)
		to_chat(user, span_warning("[src] doesn't have enough matter left. Wait for it to recharge!"))
		return
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user, span_warning("You do not have enough power to use [src]."))
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	to_chat(user, "Fabricating Donut..")
	new /obj/item/reagent_containers/food/snacks/donut(T)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay
