/obj/item/computer_hardware/paicard
	name = "personal AI device"
	desc = "A device capable of downloading and interfacing with personal AI units."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	cryo_preserve = TRUE
	var/mob/living/silicon/pai/pai
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	device_type = MC_PAI

/obj/item/computer_hardware/paicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is staring sadly at [src]! [user.p_they()] can't keep living without real human intimacy!"))
	return OXYLOSS

/obj/item/computer_hardware/paicard/Initialize(mapload)
	SSpai.paicard_list += src
	add_overlay("pai-off")
	return ..()

/obj/item/computer_hardware/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.paicard_list -= src
	if (!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/computer_hardware/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/obj/item/computer_hardware/paicard/card = src
	card.ui_interact(usr)

/obj/item/computer_hardware/paicard/var/candidates_ready
/obj/item/computer_hardware/paicard/var/list/candidates

/obj/item/computer_hardware/paicard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard", "Personal AI device")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/computer_hardware/paicard/ui_data(mob/user)
	var/list/data = list()
	data["pai"] = pai
	data["screen"] = candidates_ready
	data["candidates"] = candidates
	if(!isnull(pai))
		data["name"] = pai.name
		data["master"] = pai.master
		data["masterdna"] = pai.master_dna
		data["laws_zeroth"] = pai.laws.zeroth
		data["laws"] = pai.laws.supplied
		data["transmit"] = pai.can_transmit
		data["receive"] = pai.can_receive
		data["ismaster"] = FALSE
		if(ishuman(user))
			var/mob/living/carbon/H = user
			if(H.real_name == pai.master || H.dna.unique_enzymes == pai.master_dna)
				data["ismaster"] = TRUE
		data["holomatrix"] = pai.canholo
		data["modules"] = pai.software
		data["ram"] = pai.ram
	return data

/obj/item/computer_hardware/paicard/ui_act(action, params)
	switch(action)
		if("setdna")
			if(pai.master_dna)
				return
			if(!iscarbon(usr))
				to_chat(usr, span_warning("You don't have any DNA, or your DNA is incompatible with this device!"))
			else
				var/mob/living/carbon/M = usr
				pai.master = M.real_name
				pai.master_dna = M.dna.unique_enzymes
				to_chat(pai, span_notice("You have been bound to a new master."))
				pai.emittersemicd = FALSE
		if("request")
			candidates = SSpai.findPAI(src, usr)
			candidates_ready = TRUE
		if("wipe")
			var/confirm = tgui_alert(usr, "Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No"))
			if(confirm == "Yes")
				candidates_ready = null
				if(pai)
					to_chat(pai, span_warning("You feel yourself slipping away from reality."))
					to_chat(pai, span_danger("Byte by byte you lose your sense of self."))
					to_chat(pai, span_userdanger("Your mental faculties leave you."))
					to_chat(pai, span_rose("oblivion... "))
					qdel(pai)
		if("return")
			candidates_ready = null
		if("download")
			var/datum/paiCandidate/candidate
			for(var/datum/paiCandidate/c in SSpai.candidates)
				if(params["candidate_name"] == c.name)
					candidate = c
					break
			var/obj/item/computer_hardware/paicard/card = src
			if(card.pai)
				return
			if(istype(card, /obj/item/computer_hardware/paicard) && istype(candidate, /datum/paiCandidate))
				if(SSpai.check_ready(candidate) != candidate)
					return FALSE
				var/mob/living/silicon/pai/pai = new(card)
				if(!candidate.name)
					pai.name = pick(GLOB.ninja_names)
				else
					pai.name = candidate.name
				pai.real_name = pai.name
				pai.key = candidate.key

				card.setPersonality(pai)
				SSpai.candidates.Remove(candidate)
				candidate = list("name" = candidate.name, "description"=candidate.description, "prefrole"=candidate.role, "ooccomments"=candidate.comments)
				candidates.Remove(candidate)
		if("setlaws")
			var/newlaw = stripped_multiline_input(usr, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1], MAX_MESSAGE_LEN)
			if(newlaw && pai)
				pai.set_supplied_laws(list(newlaw))
		if("radio")
			var/transmitting = params["radio"] //it can't be both so if we know it's not transmitting it must be receiving.
			var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
			if(transmitting)
				pai.can_transmit = !pai.can_transmit
			else //receiving
				pai.can_receive = !pai.can_receive
			pai.radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
			transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
			to_chat(usr,span_warning("You [transmit_holder ? "enable" : "disable"] your pAI's [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
			to_chat(pai,span_warning("Your owner has [transmit_holder ? "enabled" : "disabled"] your [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
		if("holomatrix")
			if(pai.canholo)
				to_chat(pai, span_userdanger("Your owner has disabled your holomatrix projectors!"))
				pai.canholo = FALSE
				to_chat(usr, span_warning("You disable your pAI's holomatrix!"))
			else
				to_chat(pai, span_boldnotice("Your owner has enabled your holomatrix projectors!"))
				pai.canholo = TRUE
				to_chat(usr, span_notice("You enable your pAI's holomatrix!"))

/obj/item/computer_hardware/paicard/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/computer_hardware/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.add_overlay("pai-null")

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, TRUE, -1)
	audible_message("\The [src] plays a cheerful startup noise!")

/obj/item/computer_hardware/paicard/proc/setEmotion(emotion)
	if(pai)
		src.cut_overlays()
		switch(emotion)
			if("Happy")
				src.add_overlay("pai-happy")
			if("Cat")
				src.add_overlay("pai-cat")
			if("Extremely Happy")
				src.add_overlay("pai-extremely-happy")
			if("Face")
				src.add_overlay("pai-face")
			if("Laugh")
				src.add_overlay("pai-laugh")
			if("Off")
				src.add_overlay("pai-off")
			if("Sad")
				src.add_overlay("pai-sad")
			if("Angry")
				src.add_overlay("pai-angry")
			if("What")
				src.add_overlay("pai-what")
			if("Null")
				src.add_overlay("pai-null")
			if("Sunglasses")
				src.add_overlay("pai-sunglasses")

/obj/item/computer_hardware/paicard/proc/alertUpdate()
	audible_message(span_info("[src] flashes a message across its screen, \"Additional personalities available for download.\""), span_notice("[src] vibrates with an alert."))

/obj/item/computer_hardware/paicard/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)

/obj/item/computer_hardware/paicard/diagnostics(mob/living/user)
	..()
	if(!isnull(pai))
		to_chat(user, "Status: Active")
		to_chat(user, "pAI designation: [pai.name]")
		to_chat(user, "Remaining storage available: [pai.ram]GQ")
	else
		to_chat(user, "Status: Standby")
		to_chat(user, "Storage: Formatted")
