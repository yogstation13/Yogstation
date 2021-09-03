//Credit to oraclestation for the idea! This just a recode...

#define MAX_TIMER 25 MINUTES //Maximum you can give without a permabrigging (Yogstation)
#define PRESET_SHORT 3 MINUTES
#define PRESET_MEDIUM 5 MINUTES
#define PRESET_LONG 10 MINUTES

/obj/structure/closet/secure_closet/genpop
	name = "genpop locker"
	desc = "A locker to store a prisoner's valuables, that they can collect at a later date."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/registered_name = null

/obj/structure/closet/secure_closet/genpop/Initialize(mapload)
	. = ..()
	//Show that it's available.
	set_light(1,1,COLOR_GREEN)

/obj/structure/closet/secure_closet/genpop/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = null
	if(istype(W, /obj/item/card/id))
		I = W
	else
		I = W.GetID()
	if(istype(I))
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(!I || !I.registered_name)
			return
		//Sec officers can always open the lockers. Bypass the ID setting behaviour.
		//Buuut, if they're holding a prisoner ID, that takes priority.
		if(allowed(user) && !istype(I, /obj/item/card/id/genpop))
			locked = !locked
			update_icon()
			return TRUE
		//Handle setting a new ID.
		if(!registered_name)
			if(istype(I, /obj/item/card/id/genpop)) //Don't claim the locker for a sec officer mind you...
				var/obj/item/card/id/genpop/P = I
				if(P.assigned_locker)
					to_chat(user, "<span class='notice'>This ID card is already registered to a locker.</span>")
					return FALSE
				P.assigned_locker = src
				registered_name = I.registered_name
				desc = "Assigned to: [I.registered_name]."
				say("Locker sealed. Assignee: [I.registered_name]")

				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				set_light(1,1,COLOR_RED)
				locked = TRUE
				update_icon()
			else
				to_chat(user, "<span class='danger'>Invalid ID. Only prisoners / officers may use these lockers.</span>")
			return FALSE
		//It's an ID, and is the correct registered name.
		if(istype(I) && (registered_name == I.registered_name))
			var/obj/item/card/id/genpop/ID = I
			//Not a prisoner ID.
			if(!istype(ID))
				return FALSE
			if(ID.served_time < ID.sentence)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 80)
				say("DANGER: PRISONER HAS NOT COMPLETED SENTENCE. AWAIT SENTENCE COMPLETION. COMPLIANCE IS IN YOUR BEST INTEREST.")
				return FALSE
			visible_message("<span class='warning'>[user] slots [I] into [src]'s ID slot, freeing its contents!</span>")
			registered_name = null
			desc = initial(desc)
			locked = FALSE
			update_icon()
			set_light(1,1,COLOR_GREEN)
			qdel(I)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()

//Officer interface.
/obj/machinery/genpop_interface
	name = "Prisoner Management Interface"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "An all-in-one interface for officers to manage prisoners!"
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	circuit = /obj/item/circuitboard/machine/genpop_interface
	var/next_print = 0
	var/desired_sentence = 0 //What sentence do you want to give them?
	var/desired_crime = null //What is their crime?
	var/desired_name = null
	var/obj/item/radio/Radio //needed to send messages to sec radio
	//Preset crimes that you can set, without having to remember times
	var/static/list/crimespetty = list(
		list(name="Petty Theft", tooltip="To take items from areas one does not have access to or to take items belonging to others or the station as a whole.", colour="good",icon="hand-holding",sentence="1"),
		list(name="Vandalism (Cosmetic)", tooltip="To deliberately vandalize the station.", colour="good",icon="spray-can",sentence="1"),
		list(name="Resisting Arrest", tooltip="To not cooperate with an officer who attempts a proper arrest.", colour="good",icon="running",sentence="1"),
		list(name="Drug Possession", tooltip="To possess space drugs or other narcotics by unauthorized personnel.", colour="good",icon="joint",sentence="1"),
		list(name="Indecent Exposure", tooltip="To be intentionally and publicly unclothed.", colour="good",icon="flushed",sentence="1"),
		list(name="Trespass", tooltip="To be in an area which a person does not have access to. This counts for general areas of the ship, and trespass in restricted areas is a more serious crime.", colour="good",icon="door-open",sentence="1")
	)
	var/static/list/crimesminor = list(
		list(name="Vandalism (Destructive)", tooltip="To deliberately damage the station without malicious intent.", colour="average",icon="car-crash",sentence="3"),
		list(name="Narcotics Distribution", tooltip="To distribute narcotics and other controlled substances.", colour="average",icon="tablets",sentence="3"),
		list(name="Possession of a Weapon", tooltip="To be in possession of a dangerous item that is not part of their job role.", colour="average",icon="bolt",sentence="3"),
		list(name="Possession, Contraband", tooltip="To be in possession of illegal or prohibited goods.", colour="average",icon="syringe",sentence="3"),
		list(name="Assault", tooltip="To use physical force against someone without the apparent intent to kill them.", colour="average",icon="fist-raised",sentence="3")
	)
	var/static/list/crimesmoderate = list(
		list(name="Theft", tooltip="To steal restricted or dangerous items",colour="average",icon="people-carry",sentence="5"),
		list(name="Rioting", tooltip="To partake in an unauthorized and disruptive assembly of crewmen that refuse to disperse.",colour="average",icon="users",sentence="5"),
		list(name="Creating a workplace hazard", tooltip="To endanger the crew or station through negligent or irresponsible, but not deliberately malicious, actions.",colour="average",icon="bomb",sentence="5"),
		list(name="Breaking and Entry", tooltip="Forced entry to areas where the subject does not have access to. This counts for general areas, and breaking into restricted areas is a more serious crime.",colour="average",icon="door-closed",sentence="5"),
		list(name="Insubordination", tooltip="To disobey a lawful direct order from one's superior officer.",colour="average",icon="user-minus",sentence="5")
	)
	var/static/list/crimesmajor = list(
		list(name="Assault, Officer", tooltip="To use physical force against a Department Head or member of Security without the apparent intent to kill them.",colour="bad",icon="gavel",sentence="7"),
		list(name="Possession, restricted weapon", tooltip="To be in possession of a restricted weapon without prior authorization, such as guns, batons, flashes, grenades, etc.",colour="bad",icon="exclamation",sentence="7"),
		list(name="Possession, Explosives", tooltip="To be in possession of an explosive device.",colour="bad",icon="bomb",sentence="7"),
		list(name="Inciting a Riot", tooltip="To attempt to stir the crew into a riot",colour="bad",icon="bullhorn",sentence="7"),
		list(name="Sabotage", tooltip="To hinder the work of the crew or station through malicious actions.",colour="bad",icon="fire",sentence="7"),
		list(name="Major Trespass", tooltip="Being in a restricted area without prior authorization. This includes any Security Area, Command area (including EVA), The Engine Room, Atmos, or Toxins Research.",colour="bad",icon="key",sentence="7")
	)
	var/static/list/crimessevere = list(
		list(name="Assault With a Deadly Weapon", tooltip="	To use physical force, through a deadly weapon, against someone without the apparent intent to kill them.",colour="bad",icon="user-injured",sentence="10"),
		list(name="Manslaughter", tooltip="To unintentionally kill someone through negligent, but not malicious, actions.",colour="bad",icon="skull-crossbones",sentence="10"),
		list(name="Possession, Syndicate Contraband", tooltip="To be in unauthorized possession of syndicate or other PTE technology.",colour="bad",icon="bomb",sentence="10"),
		list(name="Embezzlement", tooltip="To misuse a security or command position to steal money from the crew.",colour="bad",icon="dollar-sign",sentence="10"),
		list(name="B&E of a Restricted Area", tooltip="This is breaking into any Security area, Command area (Bridge, EVA, Captains Quarters, Teleporter, etc.), the Engine Room, Atmos, or Toxins research.",colour="bad",icon="id-card",sentence="10"),
		list(name="Dereliction of Duty", tooltip="To willfully abandon an obligation that is critical to the station's continued operation.",colour="bad",icon="walking",sentence="10")
	)

/obj/item/circuitboard/machine/genpop_interface
	name = "Prisoner Management Interface (circuit)"
	build_path = /obj/machinery/genpop_interface

/obj/machinery/genpop_interface/Initialize()
	. = ..()
	update_icon()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0
	Radio.set_frequency(FREQ_SECURITY)

/obj/machinery/genpop_interface/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return

	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	set_picture("default")


/obj/machinery/genpop_interface/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(mutable_appearance(icon, state))

/obj/machinery/genpop_interface/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/genpop_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GenPop")
		ui.open()

/obj/machinery/genpop_interface/ui_data(mob/user)
	var/list/data = list()
	data["allPrisoners"] = list()
	data["desired_name"] = desired_name
	data["desired_crime"] = desired_crime
	data["sentence"] = desired_sentence
	data["canPrint"] = world.time >= next_print
	data["pettyCrimes"] = crimespetty
	data["minorCrimes"] = crimesminor
	data["moderateCrimes"] = crimesmoderate
	data["majorCrimes"] = crimesmajor
	data["severeCrimes"] = crimessevere
	var/list/L = data["allPrisoners"]
	for(var/obj/item/card/id/genpop/ID in GLOB.prisoner_ids)
		var/list/id_info = list()
		id_info["name"] = ID.registered_name
		id_info["id"] = "\ref[ID]"
		id_info["served_time"] = ID.served_time
		id_info["sentence"] = ID.sentence
		id_info["crime"] = ID.crime
		data["allPrisoners"][++L.len] = id_info
	return data

/obj/machinery/genpop_interface/proc/print_id(mob/user)

	if(world.time < next_print)
		to_chat(user, "<span class='warning'>[src]'s ID printer is on cooldown.</span>")
		return FALSE
	investigate_log("[key_name(user)] created a prisoner ID with sentence: [desired_sentence] for [desired_sentence] min", INVESTIGATE_RECORDS)
	user.log_message("[key_name(user)] created a prisoner ID with sentence: [desired_sentence] for [desired_sentence] min", LOG_ATTACK)

	if(desired_crime)
		var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.security)
		if(R)
			R.fields["criminal"] = "Incarcerated"
			var/crime = GLOB.data_core.createCrimeEntry(desired_crime, null, user.real_name, station_time_timestamp())
			GLOB.data_core.addCrime(R.fields["id"], crime)
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [R.fields["name"]] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [R.fields["name"]] successfully updated with inputted crime.")
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)

	var/obj/item/card/id/id = new /obj/item/card/id/genpop(get_turf(src), desired_sentence, desired_crime, desired_name)
	Radio.talk_into(src, "Prisoner [id.registered_name] has been incarcerated for [desired_sentence / 60] minute(s).", FREQ_SECURITY)
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.info = "<h1 id='record-of-incarceration'>Record Of Incarceration:</h1> <hr> <h2 id='name'>Name: </h2> <p>[desired_name]</p> <h2 id='crime'>Crime: </h2> <p>[desired_crime]</p> <h2 id='sentence-min'>Sentence (Min)</h2> <p>[desired_sentence/60]</p> <p>Nanotrasen Security Forces</p>"
	desired_sentence = 0
	desired_crime = null
	desired_name = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	next_print = world.time + 20 SECONDS

/obj/machinery/genpop_interface/ui_act(action, params)
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value && isnum(value))
				desired_sentence += value
				desired_sentence = clamp(desired_sentence,0,MAX_TIMER)
		if("crime")
			var/crimes = stripped_input(usr, "Input prisoner's crimes...", "Crimes", desired_crime)
			if(crimes == null | !Adjacent(usr))
				return FALSE
			desired_crime = crimes
		if("prisoner_name")
			var/prisoner_name = stripped_input(usr, "Input prisoner's name...", "Crimes", desired_name)
			if(prisoner_name == null | !Adjacent(usr))
				return FALSE
			desired_name = prisoner_name
		if("print")
			print_id(usr)

		if("preset")
			var/preset = params["preset"]
			var/preset_time = 0
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
				if("medium")
					preset_time = PRESET_MEDIUM
				if("long")
					preset_time = PRESET_LONG

			desired_sentence = preset_time
			desired_sentence /= 10
		if("presetCrime")
			var/preset_time = text2num(params["preset"])
			var/preset_crime = params["crime"]
			desired_sentence += preset_time*60
			desired_crime += preset_crime + ", "
			desired_sentence = clamp(desired_sentence,0,MAX_TIMER)

		if("release")
			var/obj/item/card/id/genpop/id = locate(params["id"])
			if(!istype(id))
				return
			if(alert("Are you sure you want to release [id.registered_name]", "Prisoner Release", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has been discharged.", FREQ_SECURITY)
			investigate_log("[key_name(usr)] has early-released [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has early-released [id] ([id.loc])", LOG_ATTACK)
			id.served_time = id.sentence

GLOBAL_LIST_EMPTY(prisoner_ids)

/obj/item/card/id/genpop
	var/served_time = 0 //Seconds.
	var/sentence = 0 //'ard time innit.
	var/crime = null //What you in for mate?
	var/atom/assigned_locker = null //Where's our stuff then guv?

/obj/item/card/id/genpop/Initialize(mapload, _sentence, _crime, _name)
	. = ..()
	LAZYADD(GLOB.prisoner_ids, src)
	if(_crime)
		crime = _crime
	if(_sentence)
		sentence = _sentence
		if(!_name)
			registered_name = "Prisoner WR-DELPHIC#[rand(0, 10000)]"
		else
			registered_name = _name
		update_label(registered_name, "Convict")
		START_PROCESSING(SSobj, src)

/obj/item/card/id/genpop/Destroy()
	GLOB.prisoner_ids -= src
	. = ..()

/obj/item/card/id/genpop/examine(mob/user)
	. = ..()
	if(sentence)
		. += "<span class='notice'>The card indicates the holder has served [served_time] out of [sentence] seconds.</span>"
	if(crime)
		. += "<span class='warning'>It appears its holder was convicted of: <b>[crime]</b></span>"

/obj/item/card/id/genpop/process()
	served_time ++ //Maybe 2?

	if (served_time >= sentence) //FREEDOM!
		assignment = "Ex-Convict"
		access = list(ACCESS_PRISONER)
		update_label(registered_name, assignment)
		playsound(loc, 'sound/machines/ping.ogg', 50, 1)

		var/datum/data/record/R = find_record("name", registered_name, GLOB.data_core.security)
		if(R)
			R.fields["criminal"] = "Discharged"

		if(isliving(loc))
			to_chat(loc, "<span class='boldnotice'>You have served your sentence! You may now exit prison through the turnstiles and collect your belongings.</span>")
		return PROCESS_KILL



#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
