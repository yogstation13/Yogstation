/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/simple_animal/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/simple_animal/pet/dog/corgi/Ian) || istype(dog, /mob/living/simple_animal/pet/dog/corgi/puppy/ian)))
			continue

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)


/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 0.2
	show_in_report = TRUE
	report_message = "Please be nice to him."
	blacklist = list(/datum/station_trait/announcement_medbot)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 0.2
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintenance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/cargorilla
	name = "Cargo Gorilla"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = FALSE // Selective attention test. Did you spot the gorilla?

	/// The gorilla we created, we only hold this ref until the round starts.
	var/mob/living/simple_animal/hostile/gorilla/cargo_domestic/cargorilla

/datum/station_trait/cargorilla/New()
	. = ..()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, .proc/replace_cargo)

/// Replace some cargo equipment and 'personnel' with a gorilla.
/datum/station_trait/cargorilla/proc/replace_cargo(datum/source)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/sloth/cargo_sloth = GLOB.cargo_sloth
	if(!cargo_sloth)
		return

	cargorilla = new(cargo_sloth.loc)
	cargorilla.name = cargo_sloth.name
	// We do a poll on roundstart, don't let ghosts in early
	cargorilla.being_polled_for = TRUE
	INVOKE_ASYNC(src, .proc/make_id_for_gorilla)

	// hm our sloth looks funny today
	qdel(cargo_sloth)



/// Makes an ID card for the gorilla
/datum/station_trait/cargorilla/proc/make_id_for_gorilla()
	var/obj/item/card/id/advanced/cargo_gorilla/gorilla_id = new(cargorilla.loc)
	gorilla_id.registered_name = cargorilla.name
	gorilla_id.update_label()

	cargorilla.put_in_hands(gorilla_id, del_on_fail = TRUE)

/datum/station_trait/cargorilla/on_round_start()
	if(!cargorilla)
		return

	addtimer(CALLBACK(src, .proc/get_ghost_for_gorilla, cargorilla), 12 SECONDS) // give ghosts a bit of time to funnel in
	cargorilla = null

/// Get us a ghost for the gorilla.
/datum/station_trait/cargorilla/proc/get_ghost_for_gorilla(mob/living/simple_animal/hostile/gorilla/cargo_domestic/gorilla)
	if(QDELETED(gorilla))
		return

	gorilla.poll_for_gorilla()