/datum/antagonist/hog
	name = "Generic HoG servant"   ///Because i plan to make guys have different datums, so... you know
	roundend_category = "HoG Cultists"
	antagpanel_category = "HoG Cult"
	var/hud_type = "dude"
	var/datum/team/hog_cult/cult
	var/list/god_actions = list() 
	var/farewell = "You are no longer a cultist!"
	var/greet = "You are now a HoG cultist!"

/datum/antagonist/hog/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/hog/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_hog_icons_added(M)

/datum/antagonist/hog/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_hog_icons_removed(M)

/datum/antagonist/hog/get_team()
	return cult

/datum/antagonist/hog/greet()
	to_chat(owner, span_userdanger("greet"))

/datum/antagonist/hog/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just returned a part of themselfes!")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("farewell"))

/datum/antagonist/hog/on_gain()
	if(!gang)
		create_team()
	..()
	add_to_cult()
	equip_cultist()

/datum/antagonist/hog/on_removal()
	remove_from_cult()
	..()

/datum/antagonist/hog/proc/update_hog_icons_added(mob/living/M)  ///Hope this shit will work, despite i brainlessly copied it from gang code
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(!culthud)
		culthud = new/datum/atom_hud/antag/hog()
		cult.hud_entry_num = GLOB.huds.len+1 
		GLOB.huds += culthud
	culthud.color = cult.cult_color
	culthud.join_hud(M)
	set_antag_hud(M,hud_type)

/datum/antagonist/hog/proc/update_hog_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(cult)
		culthud.leave_hud(M)
		set_antag_hud(M, null)

/datum/antagonist/hog/create_team(team)
	if(!cult) 
		if(team)
			cult = team
			return
		var/datum/team/gang/cultteam = pick_n_take(GLOB.possible_hog_cults)
		if(cultteam)
			cult = new cultteam

/datum/antagonist/hog/proc/add_to_cult()
	cult.add_member(owner)
	owner.current.log_message("<font color='red'>Has been converted to the [cult.name] cult!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/hog/proc/remove_from_cult()
	cult.remove_member(owner)
	owner.current.log_message("<font color='red'>Has been deconverted from the [cult.name] cult!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/hog/proc/equip_cultist()
	return ///No items coded yet, so for now it does nothing. 
