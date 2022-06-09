/datum/antagonist/hog
	name = "Generic HoG servant"   ///Because i plan to make guys have different datums, so... you know
	roundend_category = "HoG Cultists"
	antagpanel_category = "HoG Cult"
	var/hud_type = "dude"
	var/datum/team/hog_cult/cult
	var/list/god_actions = list() 
	var/farewell = "Blahblahblah"

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

/datum/antagonist/hog/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just returned a part of themselfes!")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("farewell"))


/datum/antagonist/hog/proc/update_hog_icons_added(mob/living/M)  ///Hope this shit will work, despite i brainlessly copied it from gang code
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(!culthud)
		culthud = new/datum/atom_hud/antag/hog()
		cult.hud_entry_num = GLOB.huds.len+1 
		GLOB.huds += culthud
	culthud.color = cult.cult_color
	culthud.join_hud(M)
	set_antag_hud(M,hud_type)

/datum/antagonist/gang/proc/update_hog_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(cult)
		ganghud.leave_hud(M)
		set_antag_hud(M, null)


