// **** Security gas mask ****

/datum/action/item_action/halt
	name = "HALT!"

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you tase them. Do not tamper with the device."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/dispatch)
	icon_state = "sechailer"
	item_state = "sechailer"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE
	flags_1 = HEAR_1
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR|HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	mutantrace_variation = MUTANTRACE_VARIATION
	modifies_speech = TRUE

	var/aggressiveness = 2
	var/cooldown_special
	var/recent_uses = 0
	var/broken_hailer = 0
	var/voicetoggled = TRUE

	///List of sounds that play on death, randomly selected.
	var/static/list/death_sounds = list(
		'sound/voice/cpdeath/die1.ogg',
		'sound/voice/cpdeath/die2.ogg',
		'sound/voice/cpdeath/die3.ogg',
		'sound/voice/cpdeath/die4.ogg',
	)
	///List of all lines that can be said by the sechailer, with their respective sound file.
	var/static/list/sechailer_voicelines = list(
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

/obj/item/clothing/mask/gas/sechailer/swat/spacepol
	name = "spacepol mask"
	desc = "A close-fitting tactical mask created in cooperation with a certain megacorporation, comes with an especially aggressive Compli-o-nator 3000."
	icon_state = "spacepol"
	item_state = "spacepol"

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	aggressiveness = 1 //Borgs are nicecurity!
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/dispatch)

/obj/item/clothing/mask/gas/sechailer/attack_self(mob/user)
	if(iscyborg(user))
		return
	adjustmask(user)

/obj/item/clothing/mask/gas/sechailer/AltClick(mob/user)
	. = ..()
	if (!can_use(usr))
		return
	voicetoggled = !voicetoggled
	to_chat(usr, span_notice("You [voicetoggled ? "enable" : "disable"] the security mask's voice modulator."))

/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	switch(aggressiveness)
		if(1)
			to_chat(user, span_notice("You set the restrictor to the middle position."))
			aggressiveness = 2
		if(2)
			to_chat(user, span_notice("You set the restrictor to the last position."))
			aggressiveness = 3
		if(3)
			to_chat(user, span_notice("You set the restrictor to the first position."))
			aggressiveness = 1
		if(4)
			to_chat(user, span_danger("You adjust the restrictor but nothing happens, probably because it's broken."))
	return TRUE

/obj/item/clothing/mask/gas/sechailer/wirecutter_act(mob/living/user, obj/item/I)
	if(aggressiveness != 4)
		to_chat(user, span_danger("You broke the restrictor!"))
		aggressiveness = 4
	return TRUE

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else if(istype(action, /datum/action/item_action/dispatch))
		dispatch(user)
	else
		adjustmask(user)

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_warning("You silently fry [src]'s vocal circuit with the cryptographic sequencer."))
	return TRUE
	
/obj/item/clothing/mask/gas/sechailer/handle_speech(datum/source, mob/speech_args)
	if(!voicetoggled)
		return
	var/full_message = speech_args[SPEECH_MESSAGE]
	for(var/lines in sechailer_voicelines)
		if(findtext(full_message, lines))
			playsound(source, sechailer_voicelines[lines], 50, FALSE)
			return // only play the first.

/obj/item/clothing/mask/gas/sechailer/on_mob_death()
	. = ..()
	playsound(loc, pick(death_sounds), 50, 0) //lost biosignal for protection team unit 4, remaining units contain.

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr

	if(!isliving(usr))
		return
	if(!can_use(usr))
		return
	if(broken_hailer)
		to_chat(usr, span_warning("\The [src]'s hailing system is broken."))
		return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 30) // A cooldown, to stop people being jerks
		recent_uses++
		if(cooldown_special < world.time - 180) //A better cooldown that burns jerks
			recent_uses = initial(recent_uses)

		switch(recent_uses)
			if(3)
				to_chat(usr, span_warning("\The [src] is starting to heat up."))
			if(4)
				to_chat(usr, span_userdanger("\The [src] is heating up dangerously from overuse!"))
			if(5) //overload
				broken_hailer = 1
				to_chat(usr, span_userdanger("\The [src]'s power modulator overloads and breaks."))
				return

		switch(aggressiveness)		// checks if the user has unlocked the restricted phrases
			if(1)
				phrase = rand(1,5)	// set the upper limit as the phrase above the first 'bad cop' phrase, the mask will only play 'nice' phrases
			if(2)
				phrase = rand(1,11)	// default setting, set upper limit to last 'bad cop' phrase. Mask will play good cop and bad cop phrases
			if(3)
				phrase = rand(1,18)	// user has unlocked all phrases, set upper limit to last phrase. The mask will play all phrases
			if(4)
				phrase = rand(12,18)	// user has broke the restrictor, it will now only play shitcurity phrases

		if(obj_flags & EMAGGED)
			phrase_text = "FUCK YOUR CUNT YOU SHIT EATING COCKSTORM AND EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND POO AND SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			phrase_sound = "emag"
		else

			switch(phrase)	//sets the properties of the chosen phrase
				if(1)				// good cop
					phrase_text = "HALT! HALT! HALT!"
					phrase_sound = "halt"
				if(2)
					phrase_text = "Stop in the name of the Law."
					phrase_sound = "bobby"
				if(3)
					phrase_text = "Compliance is in your best interest."
					phrase_sound = "compliance"
				if(4)
					phrase_text = "Prepare for justice!"
					phrase_sound = "justice"
				if(5)
					phrase_text = "Running will only increase your sentence."
					phrase_sound = "running"
				if(6)				// bad cop
					phrase_text = "Don't move, Creep!"
					phrase_sound = "dontmove"
				if(7)
					phrase_text = "Down on the floor, Creep!"
					phrase_sound = "floor"
				if(8)
					phrase_text = "Dead or alive you're coming with me."
					phrase_sound = "robocop"
				if(9)
					phrase_text = "God made today for the crooks we could not catch yesterday."
					phrase_sound = "god"
				if(10)
					phrase_text = "Freeze, Scum Bag!"
					phrase_sound = "freeze"
				if(11)
					phrase_text = "Stop right there, criminal scum!"
					phrase_sound = "imperial"
				if(12)				// LA-PD
					phrase_text = "Stop or I'll bash you."
					phrase_sound = "bash"
				if(13)
					phrase_text = "Go ahead, make my day."
					phrase_sound = "harry"
				if(14)
					phrase_text = "Stop breaking the law, ass hole."
					phrase_sound = "asshole"
				if(15)
					phrase_text = "You have the right to shut the fuck up."
					phrase_sound = "stfu"
				if(16)
					phrase_text = "Shut up crime!"
					phrase_sound = "shutup"
				if(17)
					phrase_text = "Face the wrath of the golden bolt."
					phrase_sound = "super"
				if(18)
					phrase_text = "I am, the LAW!"
					phrase_sound = "dredd"

		usr.audible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(loc, "sound/voice/complionator/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time
		cooldown_special = world.time
	
/obj/item/clothing/mask/gas/sechailer/verb/viewkeywords()
	set name = "View voice modulator keywords"
	set category = "Object"
	set src in usr

	if (!can_use(usr))
		return
	to_chat(usr, span_notice("The security mask quickly relays a list of recognized keywords"))
	for(var/line in sechailer_voicelines)
		to_chat(usr, span_notice("[line]"))
