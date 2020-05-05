//Converts people within three tiles of the caster into veils. Also confuses noneligible targets and stuns silicons.
/datum/action/innate/darkspawn/veil_mind
	name = "Veil Mind"
	id = "veil_mind"
	desc = "Converts nearby eligible targets into veils. To be eligible, they must be alive and recently drained by Devour Will."
	button_icon_state = "veil_mind"
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	psi_cost = 60 //since this is only useful when cast directly after a succ it should be pretty expensive
	lucidity_price = 1 //Yep, thralling is optional! It's just one of many possible playstyles.

/datum/action/innate/darkspawn/veil_mind/Activate()
	var/mob/living/carbon/human/H = owner
	if(!H.can_speak_vocal())
		to_chat(H, "<span class='warning'>You can't speak!</span>")
		return
	owner.visible_message("<span class='warning'>[owner]'s sigils flare as they inhale...</span>", "<span class='velvet bold'>dawn kqn okjc...</span><br>\
	<span class='notice'>You take a deep breath...</span>")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg', 25)
	if(!do_after(owner, 10, target = owner))
		return
	owner.visible_message("<span class='boldwarning'>[owner] lets out a chilling cry!</span>", "<span class='velvet bold'>...wjz oanra</span><br>\
	<span class='notice'>You veil the minds of everyone nearby.</span>")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			to_chat(L, "<span class='ownerdanger'>$@!) ERR: RECEPTOR OVERLOAD ^!</</span>")
			SEND_SOUND(L, sound('sound/misc/interference.ogg', volume = 50))
			L.emote("alarm")
			L.Stun(20)
			L.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
		else
			if(HAS_TRAIT(L, TRAIT_DEAF))
				to_chat(L, "<span class='warning'>...but you can't hear it!</span>")
			else
				if(L.has_status_effect(STATUS_EFFECT_BROKEN_WILL))
					if(L.add_veil())
						to_chat(owner, "<span class='velvet'><b>[L.real_name]</b> has become a veil!</span>")
				else
					to_chat(L, "<span class='boldwarning'>...and it scrambles your thoughts!</span>")
					L.dir = pick(GLOB.cardinals)
					L.confused += 2
	return TRUE