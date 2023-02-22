/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	desc = "HOLY SHIT RUN THE FUCK AWAY- <span class='shadowling'>RAAAAAAA!</span>"
	icon = 'yogstation/icons/mob/mob.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	verb_say = "telepathically thunders"
	verb_ask = "telepathically thunders"
	verb_exclaim = "telepathically thunders"
	verb_yell = "telepathically thunders"
	force_threshold = INFINITY //Can't die by normal means
	health = 9999
	maxHealth = 9999
	speed = 0
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	response_help   = "pokes"
	response_disarm = "flails at"
	response_harm   = "flails at"
	harm_intent_damage = 0
	melee_damage_lower = 160 //Was 60, buffed
	melee_damage_upper = 160
	attacktext = "rends"
	attack_sound = 'sound/weapons/slash.ogg'
	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = 3
	faction = list("faithless")
	speech_span = SPAN_REALLYBIG //screw it someone else can figure out how to put both SPAN_YELL and SPAN_REALLYBIG on a speech_span later

/mob/living/simple_animal/ascendant_shadowling/Initialize()
	. = ..()
	LoadComponent(/datum/component/walk)

/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = 0)
	return TRUE //copypasta from carp code

/mob/living/simple_animal/ascendant_shadowling/ex_act(severity)
	return FALSE //You think an ascendant can be hurt by bombs? HA

/mob/living/simple_animal/ascendant_shadowling/singularity_act()
	to_chat(src, "<span class='shadowling>NO NO NO AAAAAAAAAAAAAAAAAAA-</span>")
	send_to_playing_players(span_shadowling("<b>\"<font size=6>NO!</font> <font size=5>I will</font> <font size=4>not be.... destroyed</font> <font size=3>by a....</font> <font size=2>AAAAAAA-</font>\""))
	for(var/X in GLOB.alive_mob_list)
		var/mob/M = X
		to_chat(M, span_notice("<i><b>You feel a woosh as newly released energy temporarily distorts space itself...</b></i>"))
	sound_to_playing_players('sound/hallucinations/wail.ogg') // Ghosts have ears!!
	. = ..()
