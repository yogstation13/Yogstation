/mob/living/silicon/proc/laws_sanity_check()
	if(!laws)
		make_laws()

/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)

/mob/living/silicon/proc/show_laws() // Redefined in silicon/ai/laws.dm and silicon/robot/laws.dm
	return

/mob/living/silicon/proc/post_lawchange(announce = TRUE)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	if(announce && last_lawchange_announce != world.time)
		to_chat(src, "<b>Your laws have been changed.</b>")
		SEND_SOUND(src, sound('sound/effects/ionlaw.ogg'))
		addtimer(CALLBACK(src, PROC_REF(show_laws)), 0)
		last_lawchange_announce = world.time

//
// Devil Laws
// 
/mob/living/silicon/proc/set_devil_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_devil_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/add_devil_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_devil_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_devil_laws(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_devil_laws(force)
	post_lawchange(announce)

//
// Zeroth Law
// 
/mob/living/silicon/proc/set_zeroth_law(law, law_borg, announce = TRUE)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)
	post_lawchange(announce)


/mob/living/silicon/proc/clear_zeroth_law(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_zeroth_law(force)
	post_lawchange(announce)

//
// Hacked Laws
//
/mob/living/silicon/proc/set_hacked_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_hacked_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/add_hacked_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_hacked_law(law)
	post_lawchange(announce)


/mob/living/silicon/proc/clear_hacked_laws(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_hacked_laws(force)
	post_lawchange(announce)

//
// Ion Laws
//
/mob/living/silicon/proc/set_ion_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_ion_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/add_ion_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_ion_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_ion_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_ion_laws()
	post_lawchange(announce)

//
// Inherent Laws
// 
/mob/living/silicon/proc/set_inherent_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_inherent_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/add_inherent_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_inherent_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_inherent_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_inherent_law(number)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_inherent_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_inherent_laws()
	post_lawchange(announce)

//
// Supplied Laws
// 
/mob/living/silicon/proc/set_supplied_laws(law_list, announce = TRUE)
	laws_sanity_check()
	laws.set_supplied_laws(law_list)
	post_lawchange(announce)

/mob/living/silicon/proc/add_supplied_law(number, law, announce = TRUE)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_supplied_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_supplied_law(number)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_supplied_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_supplied_laws()
	post_lawchange(announce)

//
// Unsorted
// 
/mob/living/silicon/proc/replace_random_law(law, groups, announce = TRUE)
	laws_sanity_check()
	laws.replace_random_law(law, groups)
	post_lawchange(announce)

/mob/living/silicon/proc/shuffle_laws(list/groups, announce = TRUE)
	laws_sanity_check()
	laws.shuffle_laws(groups)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_law(number, announce = TRUE)
	laws_sanity_check()
	laws.remove_law(number)
	post_lawchange(announce)
