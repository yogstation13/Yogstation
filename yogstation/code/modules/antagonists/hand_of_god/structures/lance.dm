/obj/structure/destructible/hog_structure/lance
	name = "prismatic lance"
	desc = "A defensive structure, used to... well... kill everyone.."
	break_message = span_warning("The prismatic lance fells apart, as it's defensive crystal shatters!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 65

/obj/structure/destructible/hog_structure/lance/Initialize()
	. = ..()
	if(!weapon)
		weapon = new /obj/item/hog_item/prismatic_lance/guardian(src)
	weapon.cult = cult 

/obj/structure/destructible/hog_structure/update_hog_icons()
	. = ..()
	if(weapon.overcharged)
		add_overlay("overchange_[cult.cult_color]")
	
/obj/structure/destructible/hog_structure/handle_team_change(var/datum/team/hog_cult/new_cult)
	. = ..()
	weapon.cult = cult 
