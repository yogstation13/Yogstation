/datum/antagonist/shadowling
	name = "Shadowling"
	job_rank = ROLE_SHADOWLING
	roundend_category = "shadowlings"
	antagpanel_category = "Shadowlings"
	antag_moodlet = /datum/mood_event/sling
	var/list/objectives_given = list()

/datum/antagonist/shadowling/on_gain()
	. = ..()
	SSticker.mode.update_shadow_icons_added(owner)
	SSticker.mode.shadows += owner
	owner.special_role = "Shadowling"
	log_game("[key_name(owner.current)] was made into a shadowling!")
	var/mob/living/carbon/human/S = owner.current
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hatch(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/shadowling_hivemind(null))
	if(owner.assigned_role == "Clown")
		to_chat(S, span_notice("Your alien nature has allowed you to overcome your clownishness."))
		S.dna.remove_mutation(CLOWNMUT)
	var/datum/objective/ascend/O = new
	O.update_explanation_text()
	objectives += O
	objectives_given += O
	owner.announce_objectives()

/datum/antagonist/shadowling/on_removal()
	for(var/O in objectives_given)
		objectives -= O
	SSticker.mode.update_shadow_icons_removed(owner)
	SSticker.mode.shadows -= owner
	message_admins("[key_name_admin(owner.current)] was de-shadowlinged!")
	log_game("[key_name(owner.current)] was de-shadowlinged!")
	owner.special_role = null
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		owner.RemoveSpell(S)
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a shadowling! Though you try, you cannot remember anything about your time as one..."))
	else
		M.visible_message(span_big("[M] screams and contorts!"))
		to_chat(M,span_userdanger("THE LIGHT-- YOUR MIND-- <i>BURNS--</i>"))
		spawn(30)
			if(QDELETED(M))
				return
			M.visible_message(span_warning("[M] suddenly bloats and explodes!"))
			to_chat(M,"<span class='warning bold'>AAAAAAAAA<font size=3>AAAAAAAAAAAAA</font><font size=4>AAAAAAAAAAAA----</font></span>")
			playsound(M, 'sound/magic/Disintegrate.ogg', 100, 1)
			M.gib()
	return ..()

/datum/antagonist/shadowling/greet()
	to_chat(owner, "<br> <span class='shadowling bold big'>You are a shadowling!</span>")
	to_chat(owner, "<b>Currently, you are disguised as an employee aboard [station_name()].</b>")
	to_chat(owner, "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>")
	to_chat(owner, "<b>Any other shadowlings are your allies. You must assist them as they shall assist you.</b>")
	to_chat(owner, "<b>You require [SSticker.mode.required_thralls || 15] thralls to ascend.</b><br>")
	SEND_SOUND(owner.current, sound('yogstation/sound/ambience/antag/sling.ogg'))

/datum/antagonist/shadowling/proc/check_shadow_()
	for(var/SM in get_antag_minds(/datum/antagonist/shadowling))
		var/datum/mind/shadow_mind = SM
		if(istype(shadow_mind))
			var/turf/T = get_turf(shadow_mind.current)
			if((shadow_mind) && (shadow_mind.current.stat != DEAD) && T && is_station_level(T.z) && ishuman(shadow_mind.current))
				return FALSE
	return TRUE

/datum/antagonist/shadowling/roundend_report()
	return "[owner ? printplayer(owner) : "Unnamed Shadowling"]"

/datum/antagonist/shadowling/roundend_report_header()
	if(SSticker.mode.shadowling_ascended) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
		return "<span class='greentext big'>The shadowlings have ascended and taken over the station!</span><br>"
	else if(!SSticker.mode.shadowling_ascended && check_shadow_()) //If the shadowlings have ascended, they can not lose the round
		return "<span class='redtext big'>The shadowlings have been killed by the crew!</span><br>"
	else if(!SSticker.mode.shadowling_ascended && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return "<span class='redtext big'>The crew escaped the station before the shadowlings could ascend!</span><br>"
	else
		return "<span class='redtext big'>The shadowlings have failed!</span><br>"

/datum/antagonist/shadowling/roundend_report_footer()
	if(!LAZYLEN(SSticker.mode.thralls))
		return "<span class='redtext big'>The shadowlings have not managed to convert anyone!</span></div>"

/datum/objective/ascend
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with 15 or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/datum/objective/ascend/check_completion()
	if(..())
		return TRUE
	return (SSticker && SSticker.mode && SSticker.mode.shadowling_ascended)

/datum/objective/ascend/update_explanation_text()
	explanation_text = "Ascend to your true form by use of the Ascendance ability. This may only be used with [SSticker.mode.required_thralls] or more collective thralls, while hatched, and is unlocked with the Collective Mind ability."

/mob/living/carbon/human/get_status_tab_items()
	. = ..()
	if((dna && dna.species) && istype(dna.species, /datum/species/shadow/ling))
		var/datum/species/shadow/ling/SL = dna.species
		. += "Shadowy Shield Charges: [SL.shadow_charges]"
