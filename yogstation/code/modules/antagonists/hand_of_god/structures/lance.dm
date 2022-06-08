/obj/structure/hog_structure/lance
	name = "Prismatic lance"
	desc = "A defensive structure, used to... well... kill everyone.."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 65

/obj/structure/hog_structure/lance/Initialize()
	. = ..()
	if(!weapon)
		weapon = new /obj/item/hog_item/prismatic_lance/guardian(src)
	weapon.cult = cult 

/obj/structure/hog_structure/update_hog_icons()
	. = ..()
	if(weapon.overcharged)
		add_overlay("overchange_[cult.cult_color]"
	
/obj/structure/hog_structure/handle_team_change(var/datum/team/hog_cult/new_cult)
	. = ..()
	weapon.cult = cult 
