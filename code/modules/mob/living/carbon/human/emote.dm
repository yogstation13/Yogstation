/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses."
	emote_type = EMOTE_AUDIBLE
	var/list/viable_tongues = list(/obj/item/organ/tongue/lizard, /obj/item/organ/tongue/polysmorph)

/datum/emote/living/carbon/hiss/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	if(istype(T, /obj/item/organ/tongue/lizard))
		return 'sound/voice/lizard/hiss.ogg'
	if(istype(T, /obj/item/organ/tongue/polysmorph))
		return pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')

/datum/emote/living/carbon/hiss/can_run_emote(mob/living/user, status_check = TRUE, intentional)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	return is_type_in_list(T, viable_tongues)

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	emote_type = EMOTE_AUDIBLE
	cooldown = 10 SECONDS
	vary = TRUE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.mind?.miming)
		return
	if(H.dna?.species) //yogs start: grabs scream from screamsound located in the appropriate species file.
		return H.dna.species.get_scream_sound(H) //yogs end - current added screams: basic human, moth, lizard, preternis, felinid.

/datum/emote/living/carbon/meow
	key = "meow"
	key_third_person = "meows"
	message = "meows."
	emote_type = EMOTE_AUDIBLE
	cooldown = 10 SECONDS

/datum/emote/living/carbon/meow/can_run_emote(mob/living/user, status_check = TRUE, intentional)
	return iscatperson(user)

/datum/emote/living/carbon/meow/get_sound(mob/living/user)
	return pick('sound/voice/feline/meow1.ogg', 'sound/voice/feline/meow2.ogg', 'sound/voice/feline/meow3.ogg', 'sound/voice/feline/meow4.ogg', 'sound/effects/meow1.ogg')

/datum/emote/living/carbon/human/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "rattles their bones!"
	message_param = "rattles %t bones!"
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/voice/rattled.ogg'

/datum/emote/living/carbon/rattle/can_run_emote(mob/living/user, status_check = TRUE, intentional)
	return isskeleton(user)
	
/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	restraint_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags their tail."

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.dna || !H.dna.species || !H.dna.species.can_wag_tail(H))
		return
	if(!H.dna.species.is_wagging_tail())
		H.dna.species.start_wagging_tail(H)
	else
		H.dna.species.stop_wagging_tail(H)

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.dna && H.dna.species && H.dna.species.can_wag_tail(user)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!H.dna || !H.dna.species)
		return
	if(H.dna.species.is_wagging_tail())
		. = null

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		if(findtext(select_message_type(user,intentional), "open"))
			H.OpenWings()
		else
			H.CloseWings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if("wings" in H.dna.species.mutant_bodyparts)
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species && (H.dna.features["wings"] != "None"))
		return TRUE
		
/mob/living/carbon/human/proc/OpenWings()
	if(!dna || !dna.species)
		return
	if("wings" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "wings"
		dna.species.mutant_bodyparts |= "wingsopen"
	if("moth_wings" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts |= "moth_wingsopen"
		dna.features["moth_wingsopen"] = "moth_wings"
		dna.species.mutant_bodyparts -= "moth_wings"
	update_body()

/mob/living/carbon/human/proc/CloseWings()
	if(!dna || !dna.species)
		return
	if("wingsopen" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "wingsopen"
		dna.species.mutant_bodyparts |= "wings"
	if("moth_wingsopen" in dna.species.mutant_bodyparts)
		dna.species.mutant_bodyparts -= "moth_wingsopen"
		dna.species.mutant_bodyparts |= "moth_wings"
	update_body()
	if(isturf(loc))
		var/turf/T = loc
		T.Entered(src)

/datum/emote/living/carbon/human/robot_tongue/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/obj/item/organ/tongue/T = user.getorganslot("tongue")
	if(T.status == ORGAN_ROBOTIC)
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps."
	message_param = "beeps at %t."

/datum/emote/living/carbon/human/robot_tongue/beep/get_sound(mob/living/user)
	return 'sound/machines/twobeep.ogg'

/datum/emote/living/carbon/human/robot_tongue/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."

/datum/emote/living/carbon/human/robot_tongue/buzz/get_sound(mob/living/user)
	return 'sound/machines/buzz-sigh.ogg'

/datum/emote/living/carbon/human/robot_tongue/buzz2
	key = "buzz2"
	message = "buzzes twice."

/datum/emote/living/carbon/human/robot_tongue/buzz2/get_sound(mob/living/user)
	return 'sound/machines/buzz-two.ogg'

/datum/emote/living/carbon/human/robot_tongue/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."

/datum/emote/living/carbon/human/robot_tongue/chime/get_sound(mob/living/user)
	return 'sound/machines/chime.ogg'

/datum/emote/living/carbon/human/robot_tongue/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."

/datum/emote/living/carbon/human/robot_tongue/ping/get_sound(mob/living/user)
	return 'sound/machines/ping.ogg'

 // Clown Robotic Tongue ONLY. Henk.

/datum/emote/living/carbon/human/robot_tongue/clown/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	if(user.mind.assigned_role == "Clown")
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/clown/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks."

/datum/emote/living/carbon/human/robot_tongue/clown/honk/get_sound(mob/living/user)
	return 'sound/items/bikehorn.ogg'

/datum/emote/living/carbon/human/robot_tongue/clown/sad
	key = "sad"
	key_third_person = "plays a sad trombone..."
	message = "plays a sad trombone..."

/datum/emote/living/carbon/human/robot_tongue/clown/sad/run_emote(mob/living/user)
	return 'sound/misc/sadtrombone.ogg'
