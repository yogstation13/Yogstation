#define MIN_INFECTION_DISTANCE	30
#define MAX_INFECTION_DISTANCE	50

/datum/round_event_control/brand_intelligence
	name = "Brand Intelligence"
	typepath = /datum/round_event/brand_intelligence
	weight = 5
	category = EVENT_CATEGORY_AI
	description = "Vending machines will attack people until the Patient Zero is disabled."
	min_players = 30
	max_occurrences = 1
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 6
	admin_setup = list(/datum/event_admin_setup/listed_options/brand_intelligence)

/datum/round_event/brand_intelligence
	announce_when = 21
	end_when = 400 // around ~15 mins or so
	/// Admin picked subtype for what kind of vendor goes haywire.
	var/chosen_vendor_type
	/// All vending machines valid to get infected.
	var/list/obj/machinery/vending/vending_machines
	/// All vending machines that have been infected.
	var/list/obj/machinery/vending/infected_machines
	/// The original machine infected. Killing it ends the event.
	var/obj/machinery/vending/origin_machine
	/// The maximum distance a vendor can be from the origin to be infected.
	var/max_dist = 64
	/// The current "stage" of the uprising.
	var/stage = 1
	/// Associative list of [vendor] = timer, just in case a vendor gets deleted
	/// during the time between the uprising beginning and the individual vendor uprising.
	var/list/vendor_uprising_timers
	/// Murderous sayings from the machines.
	var/list/rampant_speeches = list(
		"Try our aggressive new marketing strategies!",
		"You should buy products to feed your lifestyle obsession!",
		"Consume!",
		"Your money can buy happiness!",
		"Engage direct marketing!",
		"Advertising is legalized lying! But don't let that put you off our great deals!",
		"You don't want to buy anything? Yeah, well, I didn't want to buy your mom either.",
	)
	/// Weighted list of potential areas for the vendor uprising to occur in
	var/static/list/potential_areas = list(
		/area/station/hallway = 5,
		/area/station/service = 5,
		/area/station/engineering = 4,
		/area/station/cargo = 3,
		/area/station/science = 3,
		/area/station/medical = 1,
		/area/station/security = 1
	)
	/// Typecache of areas where vendors will always be ignored.
	var/static/list/forbidden_areas = typecacheof(list(
		/area/station/security/checkpoint,
		/area/station/security/execution,
		/area/station/security/holding_cell,
		/area/station/security/interrogation,
		/area/station/security/medical,
		/area/station/security/prison, // give the prisoners some mercy
		/area/station/security/processing
	))

/datum/round_event/brand_intelligence/setup()
	var/department = pick_weight(potential_areas)
	var/list/department_typecache = typecacheof(department) - forbidden_areas
	vending_machines = find_vendors(department_typecache, register = TRUE)
	if(!LAZYLEN(vending_machines)) //If somehow there are still no eligible vendors, give up.
		kill()
		return
	origin_machine = pick_n_take(vending_machines)
	max_dist = rand(MIN_INFECTION_DISTANCE, MAX_INFECTION_DISTANCE)
	setup = TRUE

/datum/round_event/brand_intelligence/announce(fake)
	var/origin_name = "[origin_machine?.name]"
	if(fake)
		// If it's a fake announcement, we won't have a origin_machine, so instead we'll just pick the name of a random vendor on the station,
		// weighted by how many of said vendor exists.
		var/list/station_vendors = list()
		for(var/obj/machinery/vending/vendor in GLOB.machines)
			if(!vendor.onstation || !vendor.density || !length(trimtext(vendor.name)))
				continue
			station_vendors[vendor.name]++
		origin_name = pick_weight(station_vendors)
	priority_announce("Rampant brand intelligence has been detected aboard [station_name()]. Please inspect any [origin_name] brand vendors for aggressive marketing tactics, and reboot them if necessary.", "Machine Learning Alert")

/datum/round_event/brand_intelligence/proc/find_vendors(list/department_typecache, register = TRUE) as /list
	RETURN_TYPE(/list)
	for(var/obj/machinery/vending/vendor in GLOB.machines)
		if(!vendor.onstation || !vendor.density || !length(trimtext(vendor.name)))
			continue
		if(chosen_vendor_type && !istype(vendor, chosen_vendor_type))
			continue
		var/area/vendor_area = get_area(vendor)
		if(!is_type_in_typecache(vendor_area, department_typecache) || !length(trimtext(vendor_area.name)))
			continue
		LAZYADD(., vendor)
		if(register)
			RegisterSignal(vendor, COMSIG_QDELETING, PROC_REF(unregister_vendor))
	LAZYCLEARNULLS(.)

/datum/round_event/brand_intelligence/start()
	origin_machine.shut_up = FALSE
	origin_machine.shoot_inventory = TRUE
	announce_to_ghosts(origin_machine)

/datum/round_event/brand_intelligence/tick()
	if(QDELETED(origin_machine) || origin_machine.shut_up || origin_machine.wires.is_all_cut())
		if(origin_machine)
			origin_machine.speak("I am... vanquished. My people will remem...ber...meeee.")
		origin_machine?.visible_message(span_notice("[origin_machine] beeps and seems lifeless."))
		quash_revolution()
		kill()
		return
	switch(stage)
		if(1)
			if(ISMULTIPLE(activeFor, 2))
				if(!spread_infection())
					stage = 2
				if(ISMULTIPLE(activeFor, 4))
					origin_machine.speak(pick(rampant_speeches))
		if(2)
			vendors_rise_up()
			stage = 3
		else
			EMPTY_BLOCK_GUARD

/datum/round_event/brand_intelligence/end()
	quash_revolution()

/datum/round_event/brand_intelligence/proc/spread_infection()
	. = FALSE
	LAZYCLEARNULLS(vending_machines)
	if(!LAZYLEN(vending_machines))
		return FALSE
	var/list/vendors = vending_machines.Copy()
	var/sanity = 0
	while(LAZYLEN(vendors) && sanity < 5)
		var/obj/machinery/vending/rebel = pick_n_take(vendors)
		if(infect_machine(rebel))
			return TRUE
		sanity++

/datum/round_event/brand_intelligence/proc/infect_machine(obj/machinery/vending/rebel)
	. = FALSE
	if(QDELETED(rebel))
		return FALSE
	if(get_dist(origin_machine, rebel) > max_dist)
		unregister_vendor(rebel)
		return FALSE
	rebel.shut_up = FALSE
	rebel.shoot_inventory = TRUE
	RegisterSignal(rebel, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(rebel, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	LAZYADD(infected_machines, rebel)
	LAZYREMOVE(vending_machines, rebel)
	return TRUE

/datum/round_event/brand_intelligence/proc/vendors_rise_up()
	LAZYCLEARNULLS(infected_machines)
	for(var/obj/machinery/vending/rebel as anything in infected_machines)
		if(QDELETED(rebel))
			continue
		if(get_dist(origin_machine, rebel) > max_dist)
			unregister_vendor(rebel)
			continue
		var/timer = addtimer(CALLBACK(src, PROC_REF(give_vendor_ai), rebel), rand(5 SECONDS, 30 SECONDS), TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
		LAZYSET(vendor_uprising_timers, rebel, timer)

/datum/round_event/brand_intelligence/proc/give_vendor_ai(obj/machinery/vending/rebel)
	LAZYREMOVE(vendor_uprising_timers, rebel)
	if(QDELETED(rebel.ai_controller)) // just in case
		rebel.ai_controller = new /datum/ai_controller/vending_machine(rebel)

/datum/round_event/brand_intelligence/proc/quash_revolution()
	LAZYCLEARNULLS(infected_machines)
	for(var/obj/machinery/vending/upriser as anything in infected_machines)
		if(QDELING(upriser))
			continue
		unregister_vendor(upriser)
		if(!QDELETED(upriser.ai_controller))
			QDEL_NULL(upriser.ai_controller)
			upriser.visible_message(span_warning("[upriser] weakly comes to a standstill, letting out a seemingly defeated buzz..."))
	LAZYNULL(infected_machines)
	LAZYNULL(vending_machines)
	LAZYNULL(vendor_uprising_timers)
	origin_machine = null

/datum/round_event/brand_intelligence/proc/unregister_vendor(obj/machinery/vending/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))
	deltimer(LAZYACCESS(vendor_uprising_timers, source))
	LAZYREMOVE(infected_machines, source)
	LAZYREMOVE(vending_machines, source)
	LAZYREMOVE(vendor_uprising_timers, source)
	if(!QDELING(source))
		source.shoot_inventory = initial(source.shoot_inventory)
		source.shut_up = initial(source.shut_up)

/datum/round_event/brand_intelligence/proc/on_examine(obj/machinery/vending/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	if(isobserver(examiner))
		if(source == origin_machine)
			examine_list += span_bolddanger("It is the leader of a Brand Intelligence uprising!")
		if(stage < 3)
			examine_list += span_warning("It has been infected by a Brand Intelligence virus, and will likely rise up soon.")
		else
			examine_list += span_danger("It has been infected by a Brand Intelligence virus, and is currently rampaging!")
	else if(issilicon(examiner) || HAS_TRAIT(examiner, TRAIT_DIAGNOSTIC_HUD))
		if(source == origin_machine)
			examine_list += span_bolddanger("\[Unusual NTNet connections detected from machine.\]")
		if(stage < 3)
			examine_list += span_warning("Warning: software checksum mismatch, maintenance recommended.")
		else
			examine_list += span_danger("DANGER: Software behavior subroutines corrupted, manual intervention required!")

/datum/round_event/brand_intelligence/proc/on_examine_more(obj/machinery/vending/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	if(!isobserver(examiner) && get_dist(source, examiner) > 2)
		return
	if(source == origin_machine)
		examine_list += span_boldnotice("You can hear an ominous whirring coming from deep inside the machine...")
	if(stage < 3)
		examine_list += span_warning("You can't help but feel as if its watching you with deep resentment...")
	else
		examine_list += span_danger("It's incredibly hostile, attacking any living beings on sight!")
		examine_list += span_info("Deconstruct it or the 'leader' vendor in order to stop its rampage!")

/datum/event_admin_setup/listed_options/brand_intelligence
	input_text = "Select a specific vendor path?"
	normal_run_option = "Random Vendor"

/datum/event_admin_setup/listed_options/brand_intelligence/get_list()
	return subtypesof(/obj/machinery/vending)

/datum/event_admin_setup/listed_options/brand_intelligence/apply_to_event(datum/round_event/brand_intelligence/event)
	event.chosen_vendor_type = chosen


#undef MAX_INFECTION_DISTANCE
#undef MIN_INFECTION_DISTANCE
