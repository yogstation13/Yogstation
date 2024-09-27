/mob/living/simple_animal/hl2bot
	var/radio_key = null //which channels can the bot listen to
	var/radio_channel = RADIO_CHANNEL_COMMON //The bot's default radio channel
	var/obj/item/radio/Radio //The bot's radio, for speaking to people.
	var/data_hud_type
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_PATH_HUD = HUD_LIST_LIST) //Diagnostic HUD views

/mob/living/simple_animal/hl2bot/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id(src)
	access_card.access += ACCESS_SEC_BASIC
	Radio = new/obj/item/radio(src)
	if(radio_key)
		Radio.keyslot = new radio_key
	Radio.subspace_transmission = TRUE
	Radio.canhear_range = 0 // anything greater will have the bot broadcast the channel as if it were saying it out loud.
	Radio.recalculateChannels()

	//If a bot has its own HUD (for player bots), provide it.
	if(data_hud_type)
		var/datum/atom_hud/datahud = GLOB.huds[data_hud_type]
		datahud.show_to(src)

/mob/living/simple_animal/hl2bot/Destroy()
	qdel(Radio)
	qdel(access_card)
	return ..()

/mob/living/simple_animal/hl2bot/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(. != 0)
		return

	if(message_mods[MODE_HEADSET])
		Radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT)
		Radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		Radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE

/mob/living/simple_animal/hl2bot/cityscanner
	name = "City Scanner"
	desc = "A flying machine built to scan the city for malcompliants."
	icon = 'icons/mob/halflife.dmi'
	icon_state = "cityscanner"
	icon_living = "cityscanner"
	del_on_death = 1
	health = 50
	maxHealth = 50
	unsuitable_atmos_damage = 0
	wander = 0
	speed = -0.25
	healable = 0
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	speak_emote = list("beeps")
	speech_span = SPAN_ROBOT
	bubble_icon = BUBBLE_MACHINE
	movement_type = FLYING
	radio_key = /obj/item/encryptionkey/secbot //AI Priv + Security
	radio_channel = RADIO_CHANNEL_SECURITY //Security channel
	has_unlimited_silicon_privilege = 1
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	faction = list("neutral","silicon","combine")
	deathsound = 'sound/creatures/cityscanner/cbot_energyexplosion1.ogg'
	var/idle_sound_chance = 100
	var/idle_sounds = list('sound/creatures/cityscanner/cbot_fly_loop.ogg', 'sound/creatures/cityscanner/scanner_scan_loop1.ogg')

/mob/living/simple_animal/hl2bot/cityscanner/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stat)
		return
	if(prob(idle_sound_chance))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, FALSE)
