/datum/action/cooldown/spell/conjure_item/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
	spell_requirements = NONE

	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	item_type = /obj/item/pitchfork/demonic

/datum/action/cooldown/spell/conjure_item/violin
	name = "Summon Golden Violin"
	desc = "Play some tunes."
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
	spell_requirements = NONE
	
	invocation = "I aint have this much fun since Georgia."
	invocation_type = INVOCATION_WHISPER

	item_type = /obj/item/instrument/violin/golden

/datum/action/cooldown/spell/conjure_item/summon_contract
	name = "Summon Devil Contract"
	desc = "Summon a contract that, when signed, will \
		add someone to the Agent's death loop."
	
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"
	spell_requirements = NONE

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES

	invocation = "Just sign on the dotted line."
	invocation_type = INVOCATION_WHISPER

	item_type = /obj/item/paper/devil_contract

/obj/item/paper/devil_contract
	name = "devil contract"
	desc = "Signing this would be the greatest mistake of your life... or the best."
	color = "#db7c00"
	item_flags = NOBLUDGEON
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	info = "<center><B>Contract for infernal power</B></center><BR><BR><BR>I, \[\"____________\"\] of sound mind, \
		do hereby willingly offer my soul to the infernal hells by way of the infernal agent, \
		in exchange for power and physical strength. I understand that upon my demise, my soul shall fall into the infernal hells, \
		and my body may not be resurrected, cloned, or otherwise brought back to life.  \
		I also understand that this will prevent my brain from being used in an MMI.\
		<BR><BR><BR>Signed, \n <i>\[\"____________\"\]</i>"

/obj/item/paper/devil_contract/attackby(obj/item/possible_pen, mob/user, params)
	if(IS_DEVIL(user))
		return
	var/datum/antagonist/infernal_affairs/affair_agent = IS_INFERNAL_AGENT(user)
	if(affair_agent)
		to_chat(user, span_notice("I know this paper, it serves no use for me anymore."))
		return
	if(HAS_TRAIT(user, TRAIT_DEVIL_CONTRACT_IMMUNE))
		to_chat(user, span_warning("I've read this before... I'm not signing this shit!"))
		return
	if(possible_pen.sharpness == SHARP_POINTY)
		var/tgui_response = tgui_alert(user, "You are about to give up your soul to the Infernal depths. Do you agree?", "Devil Agent", list("Yes", "NO!!"), timeout = 5 SECONDS)
		if(tgui_response != "Yes")
			user.visible_message(span_notice("[user] puts down \the [src]."))
			return
		affair_agent = user.mind.add_antag_datum(/datum/antagonist/infernal_affairs)
		to_chat(user, span_alert("You sign your life away. Now only He knows where you're going."))
		SSinfernal_affairs.update_objective_datums()
		qdel(src)
		return
	return ..()
