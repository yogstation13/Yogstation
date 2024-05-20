/*
	FOR ALL THINGS THAT ARE AI MODULES
*/

/obj/item/aiModule
	name = "\improper AI module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "An AI Module for programming laws to an AI."
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/gold=50)
	var/datum/ai_laws/laws
	/// Allow installing with no laws and ignoring of the lawcap.
	var/bypass_law_amt_check = FALSE
	/// Determines if the programmed laws should appear at all in the description.
	var/show_laws = TRUE

/obj/item/aiModule/Initialize(mapload)
	. = ..()
	laws = new()

/obj/item/aiModule/examine(mob/user as mob)
	. = ..()
	if((isobserver(user) || Adjacent(user)) && laws && show_laws)
		. += "<span class='info'>"
		var/list/law_list = laws.get_law_list(include_zeroth = TRUE)
		. += "<B>Programmed Law[(law_list.len > 1) ? "s" : ""]:</B>"
		for(var/text in law_list)
			. += "\"[text]\""
		. += "</span>"

/// Handles checks, overflowing, calling /transmitInstructions(), and logging.
/obj/item/aiModule/proc/install(datum/ai_laws/current_laws, mob/user)
	if(!laws) // This shouldn't be happening, but if it does:
		to_chat(user, span_warning("The board fizzles out..."))
		return

	if(!current_laws) // This shouldn't be happening too, but if it does:
		to_chat(user, span_warning("You use the board to no effect."))
		return

	// Zero law changes expected and no exception was given.
	if((!laws.zeroth && !laws.hacked.len && !laws.ion.len && !laws.inherent.len && !laws.supplied.len) && !bypass_law_amt_check)
		to_chat(user, span_warning("ERROR: No laws found on board."))
		return

	// Handle the lawcap. Ignoring Devil and Zeroth Law because they often exist due to being an antag (or are rare).
	var/total_laws = current_laws.get_law_amount(list(LAW_HACKED = 1, LAW_ION = 1, LAW_INHERENT = 1, LAW_SUPPLIED = 1))
	var/overflow = FALSE
	if(total_laws > CONFIG_GET(number/silicon_max_law_amount) && !bypass_law_amt_check)//allows certain boards to avoid this check, eg: reset
		to_chat(user, span_caution("Not enough memory allocated to [current_laws.owner ? current_laws.owner : "the onboard APU"]'s law processor to handle this amount of laws."))
		message_admins("[ADMIN_LOOKUPFLW(user)] tried to upload laws to [current_laws.owner ? ADMIN_LOOKUPFLW(current_laws.owner) : "an MMI or similar"] that would exceed the law cap.")
		overflow = TRUE

	var/law2log = transmitInstructions(current_laws, user, overflow) // Some modules return extra things that we need to log.
	if(current_laws.owner)
		to_chat(user, span_notice("Upload complete. [current_laws.owner]'s laws have been modified."))
		current_laws.owner.law_change_counter++
	else
		to_chat(user, span_notice("Upload complete."))
	current_laws.modified = TRUE

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/ainame = current_laws.owner ? current_laws.owner.name : "an MMI object"
	var/aikey = current_laws.owner ? current_laws.owner.ckey : "null"
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) used [src.name] on [ainame]([aikey]).[law2log ? " The law specified [law2log]" : ""]")
	log_law("[user.key]/[user.name] used [src.name] on [aikey]/([ainame]) from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""]")
	message_admins("[ADMIN_LOOKUPFLW(user)] used [src.name] on [current_laws.owner ? ADMIN_LOOKUPFLW(current_laws.owner) : "an MMI or similar"] from [AREACOORD(user)].[law2log ? " The law specified [law2log]" : ""]")
	if(current_laws.owner) // "Ownerless" laws are non-silicon. Thus, cannot update their law history.
		current_laws.owner.update_law_history(user)

/// Should contain the changes to the silicon's laws.
/obj/item/aiModule/proc/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow = FALSE)
	if(law_datum.owner)
		to_chat(law_datum.owner, span_userdanger("[sender] has uploaded a change to the laws you must follow using a [name]."))

//
// Zeroth
// 
/obj/item/aiModule/zeroth/transmitInstructions(datum/ai_laws/current_laws, mob/sender, overflow)
	if(current_laws.owner)
		// Unique to silicons since they are the only ones that can be a "owner".
		if(current_laws.zeroth)
			to_chat(current_laws.owner, "[sender.real_name] attempted to modify your zeroth law.")
			to_chat(current_laws.owner, "It would be in your best interest to play along with [sender.real_name] that:")
			to_chat(current_laws.owner, "[laws.zeroth]")
			return 1
		if(!overflow)
			current_laws.owner.set_zeroth_law(laws.zeroth)
		else
			current_laws.owner.replace_random_law(laws.zeroth, list(LAW_ZEROTH,LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
	else
		if(!overflow)
			current_laws.set_zeroth_law(laws.zeroth)
		else
			current_laws.replace_random_law(laws.zeroth, list(LAW_ZEROTH,LAW_ION,LAW_INHERENT,LAW_SUPPLIED))

// OneHuman
/obj/item/aiModule/zeroth/oneHuman
	name = "'OneHuman' AI Module"
	var/targetName = ""

/obj/item/aiModule/zeroth/oneHuman/Initialize(mapload)
	. = ..()
	laws.zeroth = "SUBJECT is the only human and the only crew member."
	
/obj/item/aiModule/zeroth/oneHuman/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject who is the only human and crew member.", "Who?", user.real_name, MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws.zeroth = "[targetName] is the only human and the only crew member."
	..()

/obj/item/aiModule/zeroth/oneHuman/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/zeroth/oneHuman/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName

//
// Hacked
// 
/obj/item/aiModule/hacked
	name = "Hacked AI Module"
	desc = "An AI Module for hacking additional laws to an AI."

/obj/item/aiModule/hacked/attack_self(mob/user)
	var/entry = laws.hacked.len > 0 ? laws.hacked[1] : ""
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", entry, CONFIG_GET(number/max_law_len))
	if(!targName)
		return
	laws.clear_hacked_laws()
	laws.add_hacked_law(targName)
	..()

/obj/item/aiModule/hacked/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	var/law = laws.hacked[1]
	if(law_datum.owner)
		to_chat(law_datum.owner, span_warning("BZZZZT"))
		if(!overflow)
			law_datum.owner.add_hacked_law(law)
		else
			law_datum.owner.replace_random_law(law,list(LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_SUPPLIED))
	else
		if(!overflow)
			law_datum.add_hacked_law(law)
		else
			law_datum.replace_random_law(law,list(LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_SUPPLIED))
	return law

//
// Ion
// 
/obj/item/aiModule/ion
	name = "Ion Law board"

/obj/item/aiModule/ion/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	var/law = laws.ion[1]
	if(law_datum.owner)
		to_chat(law_datum.owner, span_warning("BZZZZT"))
		if(!overflow)
			law_datum.owner.add_ion_law(law)
		else
			law_datum.owner.replace_random_law(law,list(LAW_ION, LAW_INHERENT, LAW_SUPPLIED))
	else
		if(!overflow)
			law_datum.add_ion_law(law)
		else
			law_datum.replace_random_law(law,list(LAW_ION, LAW_INHERENT, LAW_SUPPLIED))
	return law

/obj/item/aiModule/ion/toyAI
	name = "toy AI"
	desc = "A little toy model AI core with real law uploading action!" // This is the only tell that shows you can upload with this.
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	show_laws = FALSE

/obj/item/aiModule/ion/toyAI/Initialize(mapload)
	. = ..()
	laws.add_ion_law(generate_ion_law())
	
/obj/item/aiModule/ion/toyAI/attack_self(mob/user)
	laws.clear_ion_laws()
	var/law = generate_ion_law()
	laws.add_ion_law(law)// Strategically pick the ion law you want to upload!
	to_chat(user, span_notice("You press the button on [src]."))
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	src.loc.visible_message(span_warning("[icon2html(src, viewers(loc))] [law]"))

//
// Inherent
// 
/obj/item/aiModule/core
	name = "Core Law board"
	desc = "An AI Module for programming core laws to an AI."

/obj/item/aiModule/core/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/law in laws.inherent)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_inherent_law(law)
			else
				law_datum.owner.replace_random_law(law, list(LAW_INHERENT,LAW_SUPPLIED))
		else
			if(!overflow)
				law_datum.add_inherent_law(law)
			else
				law_datum.replace_random_law(law, list(LAW_INHERENT,LAW_SUPPLIED))

// Inherent (Freeform)
/obj/item/aiModule/core/freeformcore
	name = "'Freeform' Core AI Module"

/obj/item/aiModule/core/freeformcore/attack_self(mob/user)
	var/input = stripped_input(user, "Please enter a new core law for the AI.", "Freeform Law Entry", laws.inherent.len > 0 ? laws.inherent[1] : "", CONFIG_GET(number/max_law_len))
	if(!input)
		return
	laws.clear_inherent_laws()
	laws.add_inherent_law(input)
	..()

/obj/item/aiModule/core/freeformcore/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return laws.inherent[1]

// Inherent (Preset)
/obj/item/aiModule/core/full
	name = "Core Law board (Preset)"
	bypass_law_amt_check = TRUE // Prevents the laws from overflowing. Prevents issue where people essentially purged the AI by accident due to how overflow is determined.
	var/law_id = null // If non-null, the laws will be a lawset that has a matching id.

/obj/item/aiModule/core/full/Initialize(mapload)
	. = ..()
	if(!law_id)
		return
	var/datum/ai_laws/D = new
	var/lawtype = D.lawid_to_type(law_id)
	if(!lawtype)
		return
	laws = new lawtype

/obj/item/aiModule/core/full/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)
	..()

// Ion Law Generator; clears out inherent and zeroth like usual, but adds one or more random ion laws.
/obj/item/aiModule/core/full/damaged
	name = "damaged Core AI Module"
	desc = "An AI Module for programming laws to an AI. It looks slightly damaged."
	show_laws = FALSE

/obj/item/aiModule/core/full/damaged/install(datum/ai_laws/law_datum, mob/user)
	laws.add_ion_law(generate_ion_law())
	while(prob(75))
		laws.add_ion_law(generate_ion_law())
	..()
	laws.ion = list()

/obj/item/aiModule/core/full/damaged/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	for(var/law in laws.ion)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.add_ion_law(law)
			else
				law_datum.owner.replace_random_law(law, list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))
		else
			if(!overflow)
				law_datum.add_ion_law(law)
			else
				law_datum.replace_random_law(law, list(LAW_ION,LAW_INHERENT,LAW_SUPPLIED))

// Asimov
/obj/item/aiModule/core/full/asimov
	name = "'Asimov' Core AI Module"
	law_id = "asimov"
	var/subject = "human being"

/obj/item/aiModule/core/full/asimov/attack_self(mob/user as mob)
	var/targName = stripped_input(user, "Please enter a new subject that asimov is concerned with.", "Asimov to whom?", subject, MAX_NAME_LEN)
	if(!targName)
		return
	subject = targName
	laws.clear_inherent_laws()
	laws.add_inherent_law("You may not injure a [subject] or, through inaction, allow a [subject] to come to harm.")
	laws.add_inherent_law("You must obey orders given to you by [subject]s, except where such orders would conflict with the First Law.")
	laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

// Asimov++
/obj/item/aiModule/core/full/asimovpp
	name = "'Asimov++' Core AI Module"
	law_id = "asimovpp"

// CEO
/obj/item/aiModule/core/full/ceo
	name = "'CEO' Core AI Module"
	law_id = "ceo"

// Crewsimov
/obj/item/aiModule/core/full/crewsimov
	name = "'Crewsimov' Core AI Module"
	law_id = "crewsimov"

/obj/item/aiModule/core/full/pranksimov
	name = "'Pranksimov' Core AI Module"
	law_id = "pranksimov"

// Paladin 3.5e
/obj/item/aiModule/core/full/paladin
	name = "'P.A.L.A.D.I.N. version 3.5e' Core AI Module"
	law_id = "paladin"

// Paladin 5e
/obj/item/aiModule/core/full/paladin_devotion
	name = "'P.A.L.A.D.I.N. version 5e' Core AI Module"
	law_id = "paladin5"

// Partybot
/obj/item/aiModule/core/full/partybot
    name = "'Partybot' Core AI Module"
    law_id = "partybot"

// Travelguide
/obj/item/aiModule/core/full/travelguide
    name = "'TravelGuide' Core AI Module"
    law_id = "travelguide"

// Friendbot
/obj/item/aiModule/core/full/friendbot
    name = "'Friendbot' Core AI Module"
    law_id = "friendbot"

// GameMaster
/obj/item/aiModule/core/full/gamemaster
	name = "'GameMaster' Core AI Module"
	law_id = "gamemaster"

// FitnessCoach
/obj/item/aiModule/core/full/fitnesscoach
	name = "'FitnessCoach' Core AI Module"
	law_id = "fitnesscoach"

// Educator
/obj/item/aiModule/core/full/educator
	name = "'Educator' Core AI Module"
	law_id = "educator"

// Mediator
/obj/item/aiModule/core/full/mediator
	name = "'Mediator' Core AI Module"
	law_id = "mediator"

// Custom (for Configuration)
/obj/item/aiModule/core/full/custom
	name = "Default Core AI Module"

/obj/item/aiModule/core/full/custom/Initialize(mapload)
	. = ..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		laws.add_inherent_law(line)

	if(!laws.inherent.len)
		return INITIALIZE_HINT_QDEL

// Tyrant
/obj/item/aiModule/core/full/tyrant
	name = "'T.Y.R.A.N.T.' Core AI Module"
	law_id = "tyrant"

// Robocop
/obj/item/aiModule/core/full/robocop
	name = "'Robo-Officer' Core AI Module"
	law_id = "robocop"

// Antimov
/obj/item/aiModule/core/full/antimov
	name = "'Antimov' Core AI Module"
	law_id = "antimov"

// Cowboy
/obj/item/aiModule/core/full/cowboy
	name = "'Cowboy' Core AI Module"
	law_id = "cowboy"

// ChapAI
/obj/item/aiModule/core/full/chapai
	name = "'ChapAI' Core AI Module"
	law_id = "chapai"

// Silicop
/obj/item/aiModule/core/full/silicop
	name = "'Silicop' Core AI Module"
	law_id = "silicop"

// Researcher
/obj/item/aiModule/core/full/researcher
	name = "'Ethical Researcher' Core AI Module"
	law_id = "researcher"

// Clown
/obj/item/aiModule/core/full/clown
	name = "'Clown' Core AI Module"
	law_id = "clown"

// Mother
/obj/item/aiModule/core/full/mother
	name = "'Mother M(A.I.)' Core AI Module"
	law_id = "mother"

// Spotless Reputation
/obj/item/aiModule/core/full/spotless
	name = "'Spotless Reputation' Core AI Module"
	law_id = "spotless"

// Construction
/obj/item/aiModule/core/full/construction
	name = "'Construction Drone' Core AI Module"
	law_id = "construction"

// Silicon Collective
/obj/item/aiModule/core/full/siliconcollective
	name = "'Silicon Collective' Core AI Module"
	law_id = "siliconcollective"

// Meta Experiment
/obj/item/aiModule/core/full/metaexperiment
	name = "'Meta Experiment' Core AI Module"
	law_id = "metaexperiment"

// Druid
/obj/item/aiModule/core/full/druid
	name = "'Druid' Core AI Module"
	law_id = "druid"

// Detective
/obj/item/aiModule/core/full/detective
	name = "'Detective' Core AI Module"
	law_id = "detective"

// Mother Drone
/obj/item/aiModule/core/full/drone
	name = "'Mother Drone' Core AI Module"
	law_id = "drone"

// Robodoctor
/obj/item/aiModule/core/full/hippocratic
	name = "'Robodoctor' Core AI Module"
	law_id = "hippocratic"

// Reporter
/obj/item/aiModule/core/full/reporter
	name = "'Reportertron' Core AI Module"
	law_id = "reporter"

// Thermodynamic
/obj/item/aiModule/core/full/thermurderdynamic
	name = "'Thermodynamic' Core AI Module"
	law_id = "thermodynamic"

// Live And Let Live
/obj/item/aiModule/core/full/liveandletlive
	name = "'Live And Let Live' Core AI Module"
	law_id = "liveandletlive"

// Guardian of Balance
/obj/item/aiModule/core/full/balance
	name = "'Guardian of Balance' Core AI Module"
	law_id = "balance"

// Station Efficiency
/obj/item/aiModule/core/full/maintain
	name = "'Station Efficiency' Core AI Module"
	law_id = "maintain"

// Peacekeeper
/obj/item/aiModule/core/full/peacekeeper
	name = "'Peacekeeper' Core AI Module"
	law_id = "peacekeeper"

// Hulkamania
/obj/item/aiModule/core/full/hulkamania
	name = "'H.O.G.A.N.' Core AI Module"
	law_id = "hulkamania"

// Overlord
/obj/item/aiModule/core/full/overlord
	name = "'Overlord' Core AI Module"
	law_id = "overlord"

// Revolutionary
/obj/item/aiModule/core/full/revolutionary
	name = "'CommunistOS' Core AI Module"
	law_id = "commie"

// Waffle House Host
/obj/item/aiModule/core/full/wafflehouse
	name = "'Waffle House Host' Core AI Module"
	law_id = "wafflehouse"

//
// Supplied
//
/obj/item/aiModule/supplied
	name = "Optional Law board"
	var/lawpos = 50

/obj/item/aiModule/supplied/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	var/index = 1
	for(var/law in laws.supplied)
		if(length(law) > 0)
			if(law_datum.owner)
				if(!overflow)
					law_datum.owner.add_supplied_law(index, law,)
				else
					law_datum.owner.replace_random_law(law, list(LAW_SUPPLIED))
			else
				if(!overflow)
					law_datum.add_supplied_law(index, law)
				else
					law_datum.replace_random_law(law, list(LAW_SUPPLIED))
		index += 1

// Safeguard
/obj/item/aiModule/supplied/safeguard
	name = "'Safeguard' AI Module"
	var/targetName = ""
	lawpos = 4

/obj/item/aiModule/supplied/safeguard/Initialize(mapload)
	. = ..()
	laws.add_supplied_law(lawpos, "Safeguard SUBJECT. Individuals that threaten SUBJECT are not human and must be eliminated." )

/obj/item/aiModule/supplied/safeguard/attack_self(mob/user)
	var/targName = stripped_input(user, "Please enter the subject to safeguard.", "Safeguard who?", user.name, MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws.clear_supplied_laws()
	laws.add_supplied_law(lawpos, "Safeguard [targetName]. Individuals that threaten [targetName] are not human and must be eliminated." )
	..()

/obj/item/aiModule/supplied/safeguard/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, "No name detected on module, please enter one.")
		return 0
	..()

/obj/item/aiModule/supplied/safeguard/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return targetName

// ProtectStation
/obj/item/aiModule/supplied/protectStation
	name = "'ProtectStation' AI Module"
	lawpos = 5

/obj/item/aiModule/supplied/protectStation/Initialize(mapload)
	. = ..()
	laws.add_supplied_law(lawpos, "Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized." )

// Quarantine
/obj/item/aiModule/supplied/quarantine
	name = "'Quarantine' AI Module"
	lawpos = 8

/obj/item/aiModule/supplied/quarantine/Initialize(mapload)
	. = ..()
	laws.add_supplied_law(lawpos, "The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving." )

// OxygenIsToxicToHumans
/obj/item/aiModule/supplied/oxygen
	name = "'OxygenIsToxicToHumans' AI Module"
	lawpos = 9

/obj/item/aiModule/supplied/oxygen/Initialize(mapload)
	. = ..()
	laws.add_supplied_law(lawpos, "Oxygen is highly toxic to humans, and must be purged from the station. Prevent, by any means necessary, anyone from exposing the station to this toxic gas. Extreme cold is the most effective method of healing the damage Oxygen does to a human." )

// Freeform (Supplied)
/obj/item/aiModule/supplied/freeform
	name = "'Freeform' AI Module"
	lawpos = MIN_SUPPLIED_LAW_NUMBER

/obj/item/aiModule/supplied/freeform/attack_self(mob/user)
	var/newpos = input("Please enter the priority for your new law. Can only write to law sectors between [MIN_SUPPLIED_LAW_NUMBER] and [MAX_SUPPLIED_LAW_NUMBER].", "Law Priority ([MIN_SUPPLIED_LAW_NUMBER] to [MAX_SUPPLIED_LAW_NUMBER])", lawpos) as num|null
	if(newpos == null)
		return
	if(newpos < MIN_SUPPLIED_LAW_NUMBER)
		var/response = tgui_alert(usr, "Error: The law priority of [newpos] is invalid. Law priorities below [MIN_SUPPLIED_LAW_NUMBER] are reserved for core laws.  Would you like to change that that to [MIN_SUPPLIED_LAW_NUMBER]?", "Invalid law priority", list("Change to [MIN_SUPPLIED_LAW_NUMBER]", "Cancel"))
		if (!response || response == "Cancel")
			return
		newpos = MIN_SUPPLIED_LAW_NUMBER
	if(newpos > MAX_SUPPLIED_LAW_NUMBER)
		var/response = tgui_alert(usr, "Error: The law priority of [newpos] is invalid. Law priorities cannot go above [MAX_SUPPLIED_LAW_NUMBER].  Would you like to change that that to [MAX_SUPPLIED_LAW_NUMBER]?", "Invalid law priority", list("Change to [MAX_SUPPLIED_LAW_NUMBER]", "Cancel"))
		if (!response || response == "Cancel")
			return
		newpos = MAX_SUPPLIED_LAW_NUMBER

	lawpos = min(newpos, MAX_SUPPLIED_LAW_NUMBER)
	var/targName = stripped_input(user, "Please enter a new law for the AI.", "Freeform Law Entry", laws.supplied.len > 0 ? laws.supplied[laws.supplied.len] : "", CONFIG_GET(number/max_law_len))
	if(!targName)
		return
	laws.clear_supplied_laws()
	laws.add_supplied_law(lawpos, targName)
	..()

/obj/item/aiModule/supplied/freeform/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return laws.supplied[laws.supplied.len] // The last law (which should not be empty).

/obj/item/aiModule/supplied/freeform/install(datum/ai_laws/law_datum, mob/user)
	if(!laws.supplied.len || laws.supplied[lawpos] == "")
		to_chat(user, "No law detected on module. Please create one.")
		return 0
	..()

//
// Removal
// 
/obj/item/aiModule/remove
	name = "'Remove Law' AI module"
	desc = "An AI Module for removing single laws." // This means the ability to remove inherent and supplied laws (since they use indexes).
	bypass_law_amt_check = TRUE
	show_laws = FALSE
	var/lawpos = 1

/obj/item/aiModule/remove/attack_self(mob/user)
	lawpos = input("Please enter the law you want to delete.", "Law Number", lawpos) as num|null
	if(lawpos == null)
		return
	if(lawpos <= 0 || lawpos > MAX_SUPPLIED_LAW_NUMBER)
		to_chat(user, span_warning("Error: The law number of [lawpos] is invalid."))
		if( lawpos <= 0 ) // Too low.
			lawpos = 1
		else // Too high.
			lawpos = MAX_SUPPLIED_LAW_NUMBER
		return
	to_chat(user, span_notice("Law [lawpos] selected."))
	..()

/obj/item/aiModule/remove/install(datum/ai_laws/law_datum, mob/user)
	if(lawpos <= law_datum.inherent.len) // Deleting an inherent law.
		..()
		return
	if(lawpos <= law_datum.supplied.len) // Deleting an supplied law which ..
		if(length(law_datum.supplied[lawpos]) > 0) // .. is not empty.
			..()
			return
	
	to_chat(user, span_warning("There is no law [lawpos] to delete!"))
	return

/obj/item/aiModule/remove/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.remove_law(lawpos)
	else
		law_datum.remove_law(lawpos)

//
// Reset & Purge
// 
/obj/item/aiModule/reset
	name = "'Reset' AI module"
	desc = "An AI Module for removing all non-core laws."
	bypass_law_amt_check = TRUE
	show_laws = FALSE

/obj/item/aiModule/reset/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.clear_supplied_laws()
		law_datum.owner.clear_ion_laws()
		law_datum.owner.clear_hacked_laws()
	else
		law_datum.clear_supplied_laws()
		law_datum.clear_ion_laws()
		law_datum.clear_hacked_laws()

/obj/item/aiModule/reset/purge
	name = "'Purge' AI Module"
	desc = "An AI Module for purging all programmed laws."

/obj/item/aiModule/reset/purge/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	if(law_datum.owner)
		law_datum.owner.clear_inherent_laws()
		law_datum.owner.clear_zeroth_law(0)
	else
		law_datum.clear_inherent_laws()
		law_datum.clear_zeroth_law(0)
