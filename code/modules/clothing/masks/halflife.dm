/obj/item/clothing/mask/gas/civilprotection
	name = "civil protection mask"
	desc = "Heavy duty white mask for civil protection units. Provides some protection to the face."
	icon_state = "civilprotection"
	item_state = "swat"
	armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 80, RAD = 80, FIRE = 80, ACID = 80, WOUND = 5)
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE
	flags_1 = HEAR_1
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	modifies_speech = TRUE

	///List of sounds that play on death, randomly selected.
	var/static/list/death_sounds = list(
		'sound/voice/cpdeath/die1.ogg',
		'sound/voice/cpdeath/die2.ogg',
		'sound/voice/cpdeath/die3.ogg',
		'sound/voice/cpdeath/die4.ogg',
	)
	///List of all lines that can be said by the mask, with their respective sound file.
	var/static/list/cp_voicelines = list(
		"Affirmative" = 'sound/voice/cpvoicelines/affirmative.ogg',
		"Copy" = 'sound/voice/cpvoicelines/copy.ogg',
		"Alright, you can go" = 'sound/voice/cpvoicelines/allrightyoucango.ogg',
		"Backup" = 'sound/voice/cpvoicelines/backup.ogg',
		"Anticitizen" = 'sound/voice/cpvoicelines/anticitizen.ogg',
		"Citizen" = 'sound/voice/cpvoicelines/citizen.ogg',
		"Get down" = 'sound/voice/cpvoicelines/getdown.ogg',
		"Get out of here" = 'sound/voice/cpvoicelines/getoutofhere.ogg',
		"Grenade" = 'sound/voice/cpvoicelines/grenade.ogg',
		"Help" = 'sound/voice/cpvoicelines/help.ogg',
		"Hold it" = 'sound/voice/cpvoicelines/holdit.ogg',
		"In position" = 'sound/voice/cpvoicelines/inposition.ogg',
		"I said move along" = 'sound/voice/cpvoicelines/isaidmovealong.ogg',
		"Keep moving" = 'sound/voice/cpvoicelines/keepmoving.ogg',
		"Lookout" = 'sound/voice/cpvoicelines/Lookout.ogg',
		"Move along" = 'sound/voice/cpvoicelines/movealong.ogg',
		"Move back right now" = 'sound/voice/cpvoicelines/movebackrightnow.ogg',
		"Move it" = 'sound/voice/cpvoicelines/moveit2.ogg',
		"Now get out of here" = 'sound/voice/cpvoicelines/nowgetoutofhere.ogg',
		"Pick up that can" = 'sound/voice/cpvoicelines/pickupthecan1.ogg',
		"I said pick up the can" = 'sound/voice/cpvoicelines/pickupthecan3.ogg',
		"Suspect prepare to receive civil judgement" = 'sound/voice/cpvoicelines/prepareforjudgement.ogg',
		"Now put it in the trash can" = 'sound/voice/cpvoicelines/putitinthetrash1.ogg',
		"Responding" = 'sound/voice/cpvoicelines/responding2.ogg',
		"Roger that" = 'sound/voice/cpvoicelines/rodgerthat.ogg',
		"Shit" = 'sound/voice/cpvoicelines/shit.ogg',
		"Take cover" = 'sound/voice/cpvoicelines/takecover.ogg',
		"You knocked it over, pick it up" = 'sound/voice/cpvoicelines/youknockeditover.ogg',
		"Searching for suspect" = 'sound/voice/cpvoicelines/searchingforsuspect.ogg',
		"First warning, move away" = 'sound/voice/cpvoicelines/firstwarningmove.ogg',
		"Sentence delivered" = 'sound/voice/cpvoicelines/sentencedelivered.ogg',
		"Issuing malcompliant citation" = 'sound/voice/cpvoicelines/issuingmalcompliantcitation.ogg',
		"Apply" = 'sound/voice/cpvoicelines/apply.ogg',
		"Hehe" = 'sound/voice/cpvoicelines/chuckle.ogg',
	)
	
/obj/item/clothing/mask/gas/civilprotection/handle_speech(mob/living/carbon/source, mob/speech_args)
	if(source.wear_mask == src)
		var/chosen_sound = file("sound/voice/cpradio/off[rand(1,4)].ogg")
		playsound(source, chosen_sound, 50, FALSE)

	var/full_message = speech_args[SPEECH_MESSAGE]
	for(var/lines in cp_voicelines)
		if(findtext(full_message, lines))
			playsound(source, cp_voicelines[lines], 50, FALSE)
			return // only play the first.

/obj/item/clothing/mask/gas/civilprotection/on_mob_death()
	. = ..()
	playsound(loc, pick(death_sounds), 50, 0) //lost biosignal for protection team unit 4, remaining units contain.

/obj/item/clothing/mask/gas/civilprotection/overwatch
	name = "overwatch soldier mask"
	desc = "Heavy duty armored mask for the overwatch transhuman team."
	icon_state = "overwatch"
	item_state = "swat"
	armor = list(MELEE = 20, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 80, RAD = 80, FIRE = 80, ACID = 80, WOUND = 5)
