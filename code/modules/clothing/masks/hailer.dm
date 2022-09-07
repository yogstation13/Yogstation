
// **** Security gas mask ****

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
	var/aggressiveness = 2
	var/cooldown_special
	var/recent_uses = 0
	var/broken_hailer = 0
	var/safety = TRUE
	var/voicetoggled = TRUE

/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/dispatch)
	icon_state = "swat"
	item_state = "swat"
	aggressiveness = 3
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR
	visor_flags_inv = 0

/obj/item/clothing/mask/gas/sechailer/swat/encrypted
	name = "\improper MK.II SWAT mask"
	desc = "A top-grade mask that encrypts your voice, allowing only other users of the same mask to understand you. \
			There are some buttons with basic commands to control the locals."

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/equipped(mob/living/user)
	user.add_blocked_language(subtypesof(/datum/language/) - /datum/language/encrypted, LANGUAGE_HAT)
	user.grant_language(/datum/language/encrypted, TRUE, TRUE, LANGUAGE_HAT)
	..()

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/dropped(mob/living/user)
	user.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_HAT)
	user.remove_language(/datum/language/encrypted, TRUE, TRUE, LANGUAGE_HAT)
	..()

/obj/item/clothing/mask/gas/sechailer/swat/encrypted/on_mob_say(mob/living/carbon/L, message, message_range)
	if(L.wear_mask == src)
		var/chosen_sound = file("sound/voice/cpvoice/ds ([rand(1,27)]).ogg")
		playsound(L, chosen_sound, 50, FALSE)

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

/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
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

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()
/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user as mob)
	if(safety)
		safety = FALSE
		to_chat(user, span_warning("You silently fry [src]'s vocal circuit with the cryptographic sequencer."))
	else
		return

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

		if(!safety)
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
		playsound(src.loc, "sound/voice/complionator/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time
		cooldown_special = world.time

/obj/item/clothing/mask/gas/sechailer/on_mob_()
	. = ..()
	playsound(loc, pick('sound/voice/cp/die1.ogg', 'sound/voice/cp/die2.ogg', 'sound/voice/cp/die3.ogg', 'sound/voice/cp/die4.ogg'), 50, 0) //lost biosignal for protection team unit 4, remaining units contain 

/obj/item/clothing/mask/gas/sechailer/verb/toggle()
	set name = "Toggle voice modulator"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(voicetoggled == TRUE)
		to_chat(usr, span_notice("You disable the security mask's voice modulator."))
		voicetoggled = FALSE
	else
		to_chat(usr, span_notice("You enable the security mask's voice modulator."))
		voicetoggled = TRUE
	
/obj/item/clothing/mask/gas/sechailer/verb/viewkeywords()
	set name = "View voice modulator keywords"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	to_chat(usr, span_notice("The security mask quickly relays a list of recognized keywords"))
	to_chat(usr, span_notice("Affirmative; Copy; Alright, you can go; Backup; Citizen; Get down; Get out of here; Grenade; Help; Hold it; In position; I said move along; Keep moving; Lookout; Move along; Move back right now; Move it; Now get out of here; Pick up that can; I said pick up the can; Suspect prepare to receive civil judgement; Now put it in the trash can; Responding; Roger that; Shit; Take cover; You knocked it over, pick it up; Searching for suspect; First warning, move away; Sentence delivered; Issuing malcompliant citation; Anticitizen; Apply; Hehe"))

/obj/item/clothing/mask/gas/sechailer/on_mob_say(mob/living/carbon/L, message, message_range)
	if(voicetoggled == FALSE)
		return 1
	if(findtext(message, "Affirmative", 1, 12))
		playsound(L, 'sound/voice/cpvoicelines/affirmative.ogg', 50, FALSE)
	else if(findtext(message, "Copy", 1, 5))
		playsound(L, 'sound/voice/cpvoicelines/copy.ogg', 50, FALSE)
	else if(findtext(message, "Alright, you can go", 1, 20))
		playsound(L, 'sound/voice/cpvoicelines/allrightyoucango.ogg', 50, FALSE)
	else if(findtext(message, "Backup", 1, 7))
		playsound(L, 'sound/voice/cpvoicelines/backup.ogg', 50, FALSE)
	else if(findtext(message, "Citizen", 1, 8))
		playsound(L, 'sound/voice/cpvoicelines/citizen.ogg', 50, FALSE)
	else if(findtext(message, "Get down", 1, 9))
		playsound(L, 'sound/voice/cpvoicelines/getdown.ogg', 50, FALSE)
	else if(findtext(message, "Get out of here", 1, 16))
		playsound(L, 'sound/voice/cpvoicelines/getoutofhere.ogg', 50, FALSE)
	else if(findtext(message, "Grenade", 1, 8))
		playsound(L, 'sound/voice/cpvoicelines/grenade.ogg', 50, FALSE)
	else if(findtext(message, "Help", 1, 5))
		playsound(L, 'sound/voice/cpvoicelines/help.ogg', 50, FALSE)
	else if(findtext(message, "Hold it", 1, 8))
		playsound(L, 'sound/voice/cpvoicelines/holdit.ogg', 50, FALSE)
	else if(findtext(message, "In position", 1, 12))
		playsound(L, 'sound/voice/cpvoicelines/inposition.ogg', 50, FALSE)
	else if(findtext(message, "I said move along", 1, 18))
		playsound(L, 'sound/voice/cpvoicelines/isaidmovealong.ogg', 50, FALSE)
	else if(findtext(message, "Keep moving", 1, 12))
		playsound(L, 'sound/voice/cpvoicelines/keepmoving.ogg', 50, FALSE)
	else if(findtext(message, "Lookout", 1, 8))
		playsound(L, 'sound/voice/cpvoicelines/Lookout.ogg', 50, FALSE)
	else if(findtext(message, "Move along", 1, 11))
		playsound(L, 'sound/voice/cpvoicelines/movealong.ogg', 50, FALSE)
	else if(findtext(message, "Move back right now", 1, 20))
		playsound(L, 'sound/voice/cpvoicelines/movebackrightnow.ogg', 50, FALSE)
	else if(findtext(message, "Move it", 1, 8))
		playsound(L, 'sound/voice/cpvoicelines/moveit2.ogg', 50, FALSE)
	else if(findtext(message, "Now get out of here", 1, 20))
		playsound(L, 'sound/voice/cpvoicelines/nowgetoutofhere.ogg', 50, FALSE)
	else if(findtext(message, "Pick up that can", 1, 17))
		playsound(L, 'sound/voice/cpvoicelines/pickupthecan1.ogg', 50, FALSE)
	else if(findtext(message, "I said pick up the can", 1, 24))
		playsound(L, 'sound/voice/cpvoicelines/pickupthecan3.ogg', 50, FALSE)
	else if(findtext(message, "Suspect prepare to receive civil judgement", 1, 43))
		playsound(L, 'sound/voice/cpvoicelines/prepareforjudgement.ogg', 50, FALSE)
	else if(findtext(message, "Now put it in the trash can", 1, 29))
		playsound(L, 'sound/voice/cpvoicelines/putitinthetrash1.ogg', 50, FALSE)
	else if(findtext(message, "Responding", 1, 11))
		playsound(L, 'sound/voice/cpvoicelines/responding2.ogg', 50, FALSE)
	else if(findtext(message, "Roger that", 1, 11))
		playsound(L, 'sound/voice/cpvoicelines/rodgerthat.ogg', 50, FALSE)
	else if(findtext(message, "Shit", 1, 5))
		playsound(L, 'sound/voice/cpvoicelines/shit.ogg', 50, FALSE)
	else if(findtext(message, "Take cover", 1, 11))
		playsound(L, 'sound/voice/cpvoicelines/takecover.ogg', 50, FALSE)
	else if(findtext(message, "You knocked it over, pick it up", 1, 32))
		playsound(L, 'sound/voice/cpvoicelines/youknockeditover.ogg', 50, FALSE)
	else if(findtext(message, "Searching for suspect", 1, 22))
		playsound(L, 'sound/voice/cpvoicelines/searchingforsuspect.ogg', 50, FALSE)
	else if(findtext(message, "First warning, move away", 1, 25))
		playsound(L, 'sound/voice/cpvoicelines/firstwarningmove.ogg', 50, FALSE)
	else if(findtext(message, "Sentence delivered", 1, 19))
		playsound(L, 'sound/voice/cpvoicelines/sentencedelivered.ogg', 50, FALSE)
	else if(findtext(message, "Issuing malcompliant citation", 1, 30))
		playsound(L, 'sound/voice/cpvoicelines/issuingmalcompliantcitation.ogg', 50, FALSE)
	else if(findtext(message, "Anticitizen", 1, 12))
		playsound(L, 'sound/voice/cpvoicelines/anticitizen.ogg', 50, FALSE)
	else if(findtext(message, "Apply", 1, 6))
		playsound(L, 'sound/voice/cpvoicelines/apply.ogg', 50, FALSE)
	else if(findtext(message, "Hehe", 1, 5))
		playsound(L, 'sound/voice/cpvoicelines/chuckle.ogg', 50, FALSE)
	

