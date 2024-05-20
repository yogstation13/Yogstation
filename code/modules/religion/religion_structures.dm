/obj/structure/table/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags = LETPASSTHROW
	can_buckle = TRUE
	smoothing_flags = null
	canSmoothWith = null
	flags_1 = NODECONSTRUCT_1 // no, don't
	buckle_lying = 90 //we turn to you!
	max_integrity = 300
	integrity_failure = 0
	buildstackamount = 6
	buildstack = /obj/item/stack/sheet/ruinous_metal
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/table/altar_of_gods/Initialize(mapload)
	. = ..()
	reflect_sect_in_icons()
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, PROC_REF(reflect_sect_in_icons)))

/obj/structure/table/altar_of_gods/attackby(obj/item/I, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY, I, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE // this signal needs to be sent early so the bible can actually be used on it
	return ..()

/obj/structure/table/altar_of_gods/proc/reflect_sect_in_icons()
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
	update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_icon)), time_between_uses)


/obj/structure/holyfountain/update_icon_state()
	. = ..()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-black"
