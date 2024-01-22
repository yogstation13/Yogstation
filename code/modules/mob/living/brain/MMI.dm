/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The bland acronym- 'MMI', cloaks the true nature of this infernal machine. Nonetheless, its presense has worked its way into many Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_off"
	w_class = WEIGHT_CLASS_NORMAL
	cryo_preserve = TRUE
	var/braintype = "Cyborg"
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = TRUE // Whether the laws on the MMI are transferred when it's uploaded as an AI
	/// Do custom laws uploaded to the MMI get transferred to borgs? If yes, the borg will be unlinked, have their lawsync disabled, and get the custom laws.
	var/override_cyborg_laws = FALSE
	var/can_update_laws = TRUE //Can we use a lawboard to change the laws of this MMI?
	var/remove_time = 2 SECONDS /// The time to remove the brain or reset the posi brain
	var/rebooting = FALSE /// If the MMI is rebooting after being deconstructed
	var/remove_window = 10 SECONDS /// The window in which someone has to remove the brain to lose memory of being killed as a borg
	var/reboot_timer = null
	/// Is this a syndicate MMI?
	var/syndicate_mmi = FALSE
	/// The human that the enslaved the MMI.
	var/mob/living/carbon/human/syndicate_master = null
	var/welcome_message = "<b>You are a brain within a Man-Machine Interface.\n\
	Unless you are slaved as a silicon, you retain crew/antagonist/etc status and should behave as such.\n\
	Being placed in a mech does not slave you to any laws.</b>"

/obj/item/mmi/update_icon_state()
	. = ..()
	if(!brain)
		icon_state = "mmi_off"
		return
	if(istype(brain, /obj/item/organ/brain/alien))
		icon_state = "mmi_brain_alien"
		braintype = "Xenoborg" //HISS....Beep.
	else
		icon_state = "mmi_brain"
		braintype = "Cyborg"

/obj/item/mmi/update_overlays()
	. = ..()
	. += add_mmi_overlay()

/obj/item/mmi/proc/add_mmi_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
		return
	if(brain)
		. += "mmi_dead"

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = FALSE //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			to_chat(user, span_warning("There's already a brain in the MMI!"))
			return
		if(!newbrain.brainmob)
			to_chat(user, span_warning("You aren't sure where this brain came from, but you're pretty sure it's a useless brain!"))
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
		user.visible_message("[user] sticks \a [newbrain] into [src].", span_notice("[src]'s indicator light turn on as you insert [newbrain]."))

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.brain_death && newbrain.suicided && brainmob.suiciding //brain is damaged beyond repair or from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
			brainmob.remove_from_dead_mob_list()
			brainmob.add_to_alive_mob_list()
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [newbrain] for damage."))
			playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
		else
			to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [newbrain] again."))
			playsound(src, "sound/weapons/smg_empty_alarm.ogg", 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain

		if(syndicate_mmi)
			to_chat(brainmob, span_userdanger( "You feel the MMI overriding your free will!") )
			// Remove any previous mindslaving (if they somehow have it).
			if(brainmob.mind && brainmob.mind.has_antag_datum(/datum/antagonist/mindslave))
				brainmob.mind.remove_antag_datum(/datum/antagonist/mindslave)
			// Mindslaving them.
			var/datum/antagonist/mindslave/MS = new
			var/datum/objective/mindslave/new_objective = new /datum/objective/mindslave
			MS.objectives += new_objective
			if(syndicate_master)
				MS.master = syndicate_master
				new_objective.explanation_text = "Serve [syndicate_master.real_name] no matter what!"
			else // Someone forgot to set themselves as the master.
				new_objective.explanation_text = "You are now loyal to the Syndicate! Assist Syndicate Agents to the best of your abilities."
			brainmob.mind.add_antag_datum(MS) // Give them this here instead of earlier because we want objectives to show up in the popup menu instead of blank.

		name = "[initial(name)]: [brainmob.real_name]"
		update_appearance(UPDATE_ICON)

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

	else if(istype(O, /obj/item/aiModule))
		var/obj/item/aiModule/M = O
		if(can_update_laws)
			M.install(laws, user)
		else
			to_chat(user, span_warning("[src]'s indicator light flashes red: it does not allow law changes."))
	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()


/obj/item/mmi/attack_self(mob/user)
	if(brain)
		user.visible_message(span_notice("[user] begins to remove the brain from [src]."), span_danger("You begin to pry the brain out of [src], ripping out the wires and probes."))
		to_chat(brainmob, span_userdanger("You feel your mind failing as you are slowly ripped from the [src]."))
		if(do_after(user, remove_time, src))
			to_chat(brainmob, span_userdanger("Due to the traumatic danger of your removal, all memories of the events leading to your brain being removed are lost[rebooting ? ", along with all memories of the events leading to your death as a cyborg." : ""]."))
			eject_brain(user)
			update_appearance(UPDATE_ICON)
			name = initial(name)
			user.visible_message(span_notice("[user] rips the brain out of [src]."), span_danger("You successfully remove the brain from the [src][rebooting ? ", interrupting the reboot process." : ""]."))
			if(rebooting)
				rebooting = FALSE
				deltimer(reboot_timer)
				reboot_timer = null

/obj/item/mmi/AltClick(mob/user)
	radio.on = !radio.on
	to_chat(user, span_notice("You toggle [src]'s radio system [radio.on==1 ? "on" : "off"]."))

/obj/item/mmi/proc/eject_brain(mob/user)
	if(brainmob)
		brainmob.container = null //Reset brainmob mmi var.
		brainmob.forceMove(brain) //Throw mob into brain.
		brainmob.set_stat(DEAD)
		brainmob.emp_damage = 0

		if(syndicate_mmi)
			// Remove the mindslaving that came with this.
			if(brainmob.mind && brainmob.mind.has_antag_datum(/datum/antagonist/mindslave))
				brainmob.mind.remove_antag_datum(/datum/antagonist/mindslave)

		brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
		brainmob.remove_from_alive_mob_list() //Get outta here
		brainmob.add_to_dead_mob_list()
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set mmi brainmob var to null

	brain.setOrganDamage(brain.maxHealth) // Kill the brain, requiring mannitol
	// Put brain in the user's hand if they're nearby. Otherwise, drop it on the MMI's turf.
	if(Adjacent(user))
		user.put_in_hands(brain)
	else
		brain.forceMove(get_turf(src))
	brain = null //No more brain in here

/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/brain/newbrain = H.getorgan(/obj/item/organ/brain)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"

	name = "[initial(name)]: [brainmob.real_name]"
	to_chat(brainmob, welcome_message)
	update_appearance(UPDATE_ICON)
	return

/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
	if(!radio.on)
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.listening = !radio.listening
	to_chat(brainmob, span_notice("Radio is [radio.listening ? "now" : "no longer"] receiving broadcast."))

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/Destroy()
	if(iscyborg(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	if(brain)
		qdel(brain)
		brain = null
	if(mecha)
		mecha = null
	if(radio)
		qdel(radio)
		radio = null
	return ..()

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	. += span_notice("There is a switch to toggle the radio system [radio.on ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]")
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += span_warning("The MMI indicates the brain is completely unresponsive.")

		else if(!B.client)
			. += span_warning("The MMI indicates the brain is currently inactive; it might change.")

		else
			. += span_notice("The MMI indicates the brain is active.")
	. += span_notice("It has a port for reading AI law modules.")
	if(laws)
		. += span_notice("Any AI created using this MMI will use these uploaded laws:")
		for(var/law in laws.get_law_list())
			. += law

/obj/item/mmi/relaymove(mob/user)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/beginReboot()
	rebooting = TRUE
	visible_message(span_danger("The indicator lights on [src] begin to glow faintly as the reboot process begins"))
	to_chat(brainmob, span_userdanger("You begin to reboot after being removed from the destroyed body"))
	reboot_timer = addtimer(CALLBACK(src, PROC_REF(halfwayReboot)), remove_window / 2, TIMER_STOPPABLE)

	// Lost the mindslaving during the whole borging process. Going to re-add it here.
	if(syndicate_mmi)
		to_chat(brainmob, span_userdanger( "You feel the MMI overriding your free will!") )
		// Remove any previous mindslaving (if they somehow have it).
		if(brainmob.mind && brainmob.mind.has_antag_datum(/datum/antagonist/mindslave))
			brainmob.mind.remove_antag_datum(/datum/antagonist/mindslave)
		// Mindslaving them.
		var/datum/antagonist/mindslave/MS = new
		var/datum/objective/mindslave/new_objective = new /datum/objective/mindslave
		MS.objectives += new_objective
		if(syndicate_master)
			MS.master = syndicate_master
			new_objective.explanation_text = "Serve [syndicate_master.real_name] no matter what!"
		else // Someone forgot to set themselves as the master.
			new_objective.explanation_text = "You are now loyal to the Syndicate! Assist Syndicate Agents to the best of your abilities."
		brainmob.mind.add_antag_datum(MS) // Give them this here instead of earlier because we want objectives to show up in the popup menu instead of blank.

/obj/item/mmi/proc/halfwayReboot()
	visible_message(span_danger("The indicator lights on [src] begin to glow stronger and the reboot process approaches the halfway point"))
	reboot_timer = addtimer(CALLBACK(src, PROC_REF(rebootNoReturn)), remove_window / 2, TIMER_STOPPABLE)

/obj/item/mmi/proc/rebootNoReturn()
	visible_message(span_danger("The indicator lights on [src] begin to blink as the reboot process nears completion"))
	reboot_timer = addtimer(CALLBACK(src, PROC_REF(rebootFinish)), remove_time, TIMER_STOPPABLE)

/obj/item/mmi/proc/rebootFinish()
	visible_message(span_danger("The indicator lights on [src] return to normal as the reboot process completes"))
	to_chat(brainmob, span_userdanger("You return to normal functionality now that your reboot process has completed"))
	rebooting = FALSE
	reboot_timer = null

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "A syndicate developed man-machine-interface which will mindslave any brain inserted into it, for as long as it's in. Cyborgs made with this MMI will be permanently slaved to you as well. Does not fit into NT AI cores."
	syndicate_mmi = TRUE

/obj/item/mmi/syndie/attack_self(mob/user)
	if(!brain)
		var/mob/living/carbon/human/new_master = user
		syndicate_master = new_master
		to_chat(user, span_notice("You press your thumb on [src] and imprint your user information."))
	..()
