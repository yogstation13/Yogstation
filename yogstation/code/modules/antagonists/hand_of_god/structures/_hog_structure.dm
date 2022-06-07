/obj/structure/hog_structure
	name = "generic HoG structure"
	desc = "Cry at SuperSlayer if you see this."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "sex"
	anchored = TRUE
	density = TRUE
	var/datum/team/hog_team/cult
	var/list/god_actions = list()
	var/obj/item/hog_item/prismatic_lance/weapon = null
	var/shield_integrity = 0

/obj/structure/hog_structure/proc/update_icons()
	cut_overlays()
	icon_state = "[icon_originalname]_[cult.color]"
	if(weapon && !istype(weapon, /obj/item/hog_item/prismatic_lance/guardian))
		add_overlay("overchange_[cult.color]")
	if(shield_integrity > 0)
		add_overlay("shield_[cult.color]")
	
/obj/structure/hog_structure/proc/handle_owner_change(var/datum/team/hog_team/new_cult)
	shield_integrity = 0 
	if(weapon && !istype(weapon, /obj/item/hog_item/prismatic_lance/guardian))
		qdel(weapon)
	cult = new_cult
	update_icons()

/obj/structure/hog_structure/proc/special_interaction(mob/user)
	return
	
/obj/structure/hog_structure/attack_hand(mob/user)
	. = ..()
	if(iscyborg(user) || isalien(user))
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && (cultie.cult = src.cult))
		special_interaction(user)
		
	
