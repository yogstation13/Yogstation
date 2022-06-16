/obj/structure/hog_structure
	name = "generic HoG structure"
	desc = "Cry at SuperSlayer if you see this."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	var/icon_originalname = "sex"
	anchored = TRUE
	density = TRUE
	var/datum/team/hog_cult/cult
	var/list/god_actions = list()
	var/list/god_actions_add = list(/datum/hog_god_interaction/structure/overcharge)
	var/obj/item/hog_item/prismatic_lance/weapon = null
	var/shield_integrity = 0
	var/cost = 10
	var/time_builded = 10

/obj/structure/hog_structure/Initialize()	
	GLOB.hog_structures += src
	. = ..()
	for(var/datum/hog_god_interaction/structure/spell in god_actions_add)
		spell = new
		spell.owner = src
		god_actions += spell
	
/obj/structure/hog_structure/Destroy()
	GLOB.hog_structures -= src
	for(var/qdel_candidate in god_actions)
		qdel(qdel_candidate)
	. = ..()

/obj/structure/hog_structure/proc/update_hog_icons()
	cut_overlays()
	icon_state = "[icon_originalname]_[cult.cult_color]"
	if(weapon && !istype(weapon, /obj/item/hog_item/prismatic_lance/guardian))
		add_overlay("overchange_[cult.cult_color]")
	if(shield_integrity > 0)
		add_overlay("shield_[cult.cult_color]")
	
/obj/structure/hog_structure/proc/handle_team_change(var/datum/team/hog_cult/new_cult)
	shield_integrity = 0 
	if(weapon && !istype(weapon, /obj/item/hog_item/prismatic_lance/guardian))
		qdel(weapon)
	cult = new_cult
	update_hog_icons()

/obj/structure/hog_structure/proc/special_interaction(var/mob/user)
	return
	
/obj/structure/hog_structure/attack_hand(mob/user)
	if(iscyborg(user))
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == src.cult && cultie.banned_by_god != TRUE)
		special_interaction(user)
		return
	. = ..()

/obj/structure/hog_structure/attack_alien(mob/user) ///Cult aliens, hooray!!!
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == src.cult && cultie.banned_by_god != TRUE)
		special_interaction(user)
		return
	. = ..()

/obj/structure/hog_structure/attack_paw(mob/user)
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == src.cult && cultie.banned_by_god != TRUE)
		special_interaction(user)
		return
	. = ..()

/obj/structure/hog_structure/attack_god(mob/camera/hog_god/god, modifier)
	if(cult != god.cult)
		return
	if(!modifier)
		var/list/susass = list()
		var/list/names = list() ///A bit weird, but if you have any other idea... propose it

		for(var/datum/hog_god_interaction/spell in god_actions)
			susass[spell.name] = spell
			names += spell.name

		var/datum/hog_god_interaction/spelli = susass[input(god,"What do you want to cast?","Action") in names]
		if(!spelli)
			return
		if(!spelli.on_called(god))
			return
		spelli.on_use(god)
		return  
	return 
