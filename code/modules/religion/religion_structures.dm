/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	reflect_sect_in_icons()

/obj/structure/altar_of_gods/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, .proc/reflect_sect_in_icons))

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
		return ..()
	to_chat(user, span_notice("You try to coax [pushed_mob] onto [src]..."))
	if(!do_after(user, (5 SECONDS), pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/proc/reflect_sect_in_icons()
	if(GLOB.religious_sect)
		sect_to_altar = GLOB.religious_sect
		if(sect_to_altar.altar_icon)
			icon = sect_to_altar.altar_icon
		if(sect_to_altar.altar_icon_state)
			icon_state = sect_to_altar.altar_icon_state

//****Old Gods sect structures****//

/obj/structure/holyfountain //reskinned healing fountain, but different enough i guess
	name = "blessed fountain"
	desc = "A dark fountain filled with some kind of strange liquid."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain-black"
	anchored = TRUE
	density = TRUE
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/holyfountain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(last_process + time_between_uses > world.time)
		to_chat(user, span_notice("The fountain appears to be empty."))
		return
	last_process = world.time
	to_chat(user, span_notice("The liquid feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards."))
	user.reagents.add_reagent(/datum/reagent/medicine/omnizine/godblood,10) //Hurts your brain and makes you go insane
	user.reagents.add_reagent(/datum/reagent/toxin/mindbreaker,10) //However, it gives rather potent healing.
	update_icon()
	addtimer(CALLBACK(src, .proc/update_icon), time_between_uses)


/obj/structure/holyfountain/update_icon()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-black"
