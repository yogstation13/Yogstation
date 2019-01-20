/datum/atom_hud/data/human/rev
	hud_icons = list(REV_APPEARANCE_HUD)

/mob/living/carbon/human/proc/update_face_dependant_huds()
	sec_hud_set_ID()
	update_rev_hud()

/mob/living/carbon/human/proc/update_rev_hud()
	var/image/holder = hud_list[REV_APPEARANCE_HUD]
	var/hudstate
	if(get_face_name("Unknown") == "Unknown")
		hudstate = "rev_maybe"
	else if(mind)
		if(mind in SSjob.get_all_heads())
			hudstate = "rev_enemyhead"
		else if(/datum/antagonist/rev/head)
			hudstate = "rev_head"
		else if(/datum/antagonist/rev)
			hudstate = "rev"
	if(!hudstate)
		hudstate = "rev_convertable"
	holder.icon_state = hudstate