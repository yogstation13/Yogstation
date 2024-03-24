/// How often the sensor data is updated
#define SENSORS_UPDATE_PERIOD (10 SECONDS) //How often the sensor data updates.
/// The job sorting ID associated with otherwise unknown jobs
#define UNKNOWN_JOB_ID 81

/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
	circuit = /obj/item/circuitboard/computer/crew


	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/crew/syndie
	icon_keyboard = "syndie_key"

/obj/machinery/computer/crew/ui_interact(mob/user)
	GLOB.crewmonitor.show(user,src)

GLOBAL_DATUM_INIT(crewmonitor, /datum/crewmonitor, new)

/datum/crewmonitor
	var/list/ui_sources = list() //List of user -> ui source
	var/list/jobs
	var/list/data_by_z = list()
	var/list/last_update = list()
	var/list/death_list = list()

/datum/crewmonitor/New()
	. = ..()

	var/list/jobs = new/list()
	jobs["Captain"] = 00
	jobs["Head of Personnel"] = 50
	jobs["Head of Security"] = 10
	jobs["Warden"] = 11
	jobs["Security Officer"] = 12
	jobs["Detective"] = 13
	jobs["Chief Medical Officer"] = 20
	jobs["Chemist"] = 21
	jobs["Geneticist"] = 22
	jobs["Virologist"] = 23
	jobs["Medical Doctor"] = 24
	jobs["Paramedic"] = 25 //Yogs: Added IDs for this job
	jobs["Psychiatrist"] = 26 //Yogs: Added IDs for this job
	jobs["Mining Medic"] = 27 //Yogs: Added IDs for this job
	jobs["Brig Physician"] = 28 //Yogs: Added IDs for this job
	jobs["Research Director"] = 30
	jobs["Scientist"] = 31
	jobs["Roboticist"] = 32
	jobs["Chief Engineer"] = 40
	jobs["Station Engineer"] = 41
	jobs["Atmospheric Technician"] = 42
	jobs["Network Admin"] = 43 //Yogs: Added IDs for this job
	jobs["Quartermaster"] = 51
	jobs["Shaft Miner"] = 52
	jobs["Cargo Technician"] = 53
	jobs["Bartender"] = 61
	jobs["Cook"] = 62
	jobs["Botanist"] = 63
	jobs["Curator"] = 64
	jobs["Chaplain"] = 65
	jobs["Clown"] = 66
	jobs["Mime"] = 67
	jobs["Janitor"] = 68
	jobs["Lawyer"] = 69
	jobs["Clerk"] = 71 //Yogs: Added IDs for this job, also need to skip 70 or it clerk would be considered a head job
	jobs["Tourist"] = 72 //Yogs: Added IDs for this job
	jobs["Artist"] = 73 //Yogs: Added IDs for this job
	jobs["Assistant"] = 74 //Yogs: Assistants are with the other civilians
	jobs["Admiral"] = 200
	jobs["CentCom Commander"] = 210
	jobs["Custodian"] = 211
	jobs["Medical Officer"] = 212
	jobs["Research Officer"] = 213
	jobs["Emergency Response Team Commander"] = 220
	jobs["Security Response Officer"] = 221
	jobs["Engineer Response Officer"] = 222
	jobs["Medical Response Officer"] = 223

	src.jobs = jobs

/datum/crewmonitor/Destroy()
	return ..()

/datum/crewmonitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		for(var/datum/minimap/M in SSmapping.station_minimaps)
			M.send(user)
		ui = new(user, src, "CrewConsole")
		ui.open()

/datum/crewmonitor/proc/show(mob/M, source)
	ui_sources[M] = source
	ui_interact(M)

/datum/crewmonitor/ui_host(mob/user)
	return ui_sources[user]

/datum/crewmonitor/ui_data(mob/user)
	var/z = user.z
	if(!z)
		var/turf/T = get_turf(user)
		z = T.z
	var/list/zdata = update_data(z)
	. = list()
	.["sensors"] = zdata
	.["link_allowed"] = isAI(user)
	.["z"] = z
/datum/crewmonitor/proc/update_data(z)
	if(data_by_z["[z]"] && last_update["[z]"] && world.time <= last_update["[z]"] + SENSORS_UPDATE_PERIOD)
		return data_by_z["[z]"]

	var/list/results = list()
	var/list/new_death_list = list()
	var/obj/item/clothing/under/uniform
	var/obj/item/card/id/idcard
	var/turf/pos
	var/ijob
	var/name
	var/assignment_title
	var/assignment
	var/oxydam
	var/toxdam
	var/burndam
	var/brutedam
	var/area
	var/pos_x
	var/pos_y
	var/life_status

	for(var/mob/living/carbon/human/tracked_mob in GLOB.carbon_list)
		if(is_synth(tracked_mob)) //Synths are unsupported (they're not organic)
			continue
		var/forced_sensors = HAS_TRAIT(tracked_mob, TRAIT_SUITLESS_SENSORS)
		uniform = tracked_mob.w_uniform
		pos = get_turf(tracked_mob)

		// Check if the mob has sensors at all
		if(!(forced_sensors || (uniform && uniform.has_sensor > NO_SENSORS && uniform.sensor_mode > SENSOR_OFF)))
			continue

		if(!pos)
			stack_trace("[tracked_mob] cannot be tracked because it has no location.")
			continue // you don't exist in reality

		// Machinery and the target should be on the same level or different levels of the same station
		if(!(z in SSmapping.get_connected_levels(pos)) && !HAS_TRAIT(tracked_mob, TRAIT_MULTIZ_SUIT_SENSORS))
			continue
			
		var/jammed = FALSE
		for(var/obj/item/jammer/jammer in GLOB.active_jammers)
			var/turf/jammer_turf = get_turf(jammer)
			if(pos.z == jammer_turf.z && (get_dist(pos, jammer_turf) <= jammer.range))
				jammed = TRUE
				break
		if(jammed) // radio jammers prevent suit sensors 
			continue

		idcard = tracked_mob.wear_id ? tracked_mob.wear_id.GetID() : null

		var/species
		var/is_irradiated = FALSE
		var/is_wounded = FALSE
		var/is_husked = FALSE
		var/is_onfire = FALSE
		var/is_bonecrack = FALSE
		var/is_disabled = FALSE
		var/no_warnings = FALSE

		if (idcard)
			name = idcard.registered_name
			assignment_title = idcard.assignment
			assignment = idcard.originalassignment
			ijob = jobs[idcard.originalassignment]
		else
			name = "Unknown"
			assignment_title = ""
			assignment = ""
			ijob = 80
					
		if (forced_sensors || uniform.sensor_mode >= SENSOR_LIVING)
			life_status = tracked_mob.stat < DEAD
		else
			life_status = null

		if (forced_sensors || uniform.sensor_mode >= SENSOR_VITALS)
			oxydam = round(tracked_mob.getOxyLoss(),1)
			toxdam = round(tracked_mob.getToxLoss(),1)
			burndam = round(tracked_mob.getFireLoss(),1)
			brutedam = round(tracked_mob.getBruteLoss(),1)

			//species check
			if (ishumanbasic(tracked_mob))
				species = "Human"
			if (ispreternis(tracked_mob))
				species = "Robot"
			if (isipc(tracked_mob))
				species = "IPC"
			if (ispodperson(tracked_mob))
				species = "Podperson"
			if (islizard(tracked_mob))
				species = "Lizard"
			if (isplasmaman(tracked_mob))
				species = "Plasmaman"
			if (ispolysmorph(tracked_mob))
				species = "Polysmorph"
			if (ismoth(tracked_mob))
				species = "Moth"
			if (isflyperson(tracked_mob))
				species = "Fly"
			if (iscatperson(tracked_mob))
				species = "Felinid"
			if (isskeleton(tracked_mob))
				species = "Skeleton"
			if (isjellyperson(tracked_mob))
				species = "Slime"
			if (isethereal(tracked_mob))
				species = "Ethereal"
			if (iszombie(tracked_mob))
				species = "Zombie"
			if (issnail(tracked_mob))
				species = "Snail"
			if (isabductor(tracked_mob))
				species = "Alien"
			if (isandroid(tracked_mob))
				species = "Android"

			for(var/obj/item/bodypart/part in tracked_mob.bodyparts)
				if(part.bodypart_disabled == TRUE) //check if has disabled limbs
					is_disabled = TRUE
				if(locate(/obj/item) in part.embedded_objects) //check if has embed objects
					is_wounded = TRUE
			if(length(tracked_mob.get_missing_limbs())) //check if has missing limbs
				is_disabled = TRUE
					
			//check if has generic wounds except for bone one
			if(locate(/datum/wound/slash) in tracked_mob.all_wounds)
				is_wounded = TRUE
			if(locate(/datum/wound/pierce) in tracked_mob.all_wounds)
				is_wounded = TRUE
			if(locate(/datum/wound/slash) in tracked_mob.all_wounds)
				is_wounded = TRUE
			if(locate(/datum/wound/burn) in tracked_mob.all_wounds)
				is_wounded = TRUE

			if(locate(/datum/wound/blunt) in tracked_mob.all_wounds) //check if has bone wounds
				is_bonecrack = TRUE
								
			if(tracked_mob.radiation > RAD_MOB_SAFE) //safe level before sending alert
				is_irradiated = TRUE					

			if(HAS_TRAIT(tracked_mob, TRAIT_HUSK)) //check if husked
				is_husked = TRUE
				species = null //suit sensors won't recognize anymore

			if(tracked_mob.on_fire == TRUE) //check if on fire
				is_onfire = TRUE

			//warnings checks
			if(is_wounded || is_onfire || is_irradiated || is_husked || is_disabled || is_bonecrack)
				no_warnings = TRUE

		else
			oxydam = null
			toxdam = null
			burndam = null
			brutedam = null
			species = null

		if (forced_sensors || uniform.sensor_mode >= SENSOR_COORDS)
			if (!pos)
				pos = get_turf(tracked_mob)
			area = get_area_name(tracked_mob, TRUE, is_sensor = TRUE)
			pos_x = pos.x
			pos_y = pos.y
		else
			area = null
			pos_x = null
			pos_y = null

		if(life_status == FALSE)
			new_death_list.Add(tracked_mob)

		results[++results.len] = list(
			"name" = name,
			"assignment_title" = assignment_title,
			"assignment" = assignment,
			"ijob" = ijob,
			"is_wounded" = is_wounded,
			"no_warnings" = no_warnings,
			"is_onfire" = is_onfire,
			"is_husked" = is_husked,
			"is_bonecrack" = is_bonecrack,
			"is_disabled" = is_disabled,
			"is_irradiated" = is_irradiated,
			"species" = species,
			"life_status" = life_status,
			"oxydam" = oxydam,
			"toxdam" = toxdam,
			"burndam" = burndam,
			"brutedam" = brutedam,
			"area" = area,
			"pos_x" = pos_x,
			"pos_y" = pos_y,
			"can_track" = tracked_mob.can_track(null)
		)

	data_by_z["[z]"] = sortTim(results,/proc/sensor_compare)
	last_update["[z]"] = world.time
	death_list["[z]"] = new_death_list
	SEND_SIGNAL(src, COMSIG_MACHINERY_CREWMON_UPDATE)

	return results

/proc/sensor_compare(list/a,list/b)
	return a["ijob"] - b["ijob"]

/datum/crewmonitor/ui_act(action,params)
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI))
		return
	switch (action)
		if ("select_person")
			AI.ai_camera_track(params["name"])

#undef SENSORS_UPDATE_PERIOD
#undef UNKNOWN_JOB_ID
