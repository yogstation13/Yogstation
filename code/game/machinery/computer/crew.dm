#define SENSORS_UPDATE_PERIOD 100 //How often the sensor data updates.

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
	var/obj/item/clothing/under/U
	var/obj/item/card/id/I
	var/turf/pos
	var/ijob
	var/name
	var/is_robot
	var/is_human
	var/is_catperson
	var/is_lizard
	var/is_moth
	var/is_polysmorph
	var/is_slime
	var/is_fly
	var/is_skeleton
	var/is_husked
	var/is_onfire
	var/is_podperson
	var/is_plasmaman
	var/is_ethereal
	var/is_irradiated
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

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		var/nanite_sensors = FALSE
		if(H in SSnanites.nanite_monitored_mobs)
			nanite_sensors = TRUE
		// Check if their z-level is correct and if they are wearing a uniform.
		// Accept H.z==0 as well in case the mob is inside an object.
		if ((H.z == 0 || H.z == z) && (istype(H.w_uniform, /obj/item/clothing/under) || nanite_sensors))
			U = H.w_uniform

			// Are the suit sensors on?
			if (nanite_sensors || ((U.has_sensor > 0) && U.sensor_mode))
				pos = H.z == 0 || (nanite_sensors || U.sensor_mode == SENSOR_COORDS) ? get_turf(H) : null

				// Special case: If the mob is inside an object confirm the z-level on turf level.
				if (H.z == 0 && (!pos || (pos.z != z) && !(is_station_level(pos.z) && is_station_level(z))))
					continue

				I = H.wear_id ? H.wear_id.GetID() : null

				if (I)
					name = I.registered_name
					assignment_title = I.assignment
					assignment = I.originalassignment
					ijob = jobs[I.originalassignment]
				else
					name = "Unknown"
					assignment_title = ""
					assignment = ""
					ijob = 80

				if (ispreternis(H) || isipc(H))
					is_robot = TRUE
				else
					is_robot = FALSE

				if (ishumanbasic(H))
					is_human = TRUE
				else
					is_human = FALSE

				if (iscatperson(H))
					is_catperson = TRUE
				else
					is_catperson = FALSE

				if (islizard(H))
					is_lizard = TRUE
				else
					is_lizard = FALSE

				if (ismoth(H))
					is_moth = TRUE
				else
					is_moth = FALSE

				if (ispolysmorph(H))
					is_polysmorph = TRUE
				else
					is_polysmorph = FALSE

				if (ispodperson(H))
					is_podperson= TRUE
				else
					is_podperson = FALSE

				if (isplasmaman(H))
					is_plasmaman = TRUE
				else
					is_plasmaman = FALSE

				if (isethereal(H))
					is_ethereal= TRUE
				else
					is_ethereal = FALSE

				if (isslimeperson(H) || isjellyperson(H) || isluminescent(H))
					is_slime = TRUE
				else
					is_slime = FALSE

				if (isskeleton(H))
					is_skeleton = TRUE
				else
					is_skeleton = FALSE

				if (isflyperson(H))
					is_fly = TRUE
				else
					is_fly = FALSE

				if (H.radiation > 500) //safe level before sending alert
					is_irradiated = TRUE
				else
					is_irradiated = FALSE

				if (HAS_TRAIT(H, TRAIT_HUSK))
					is_husked = TRUE
				else
					is_husked = FALSE

				if (H.on_fire == TRUE)
					is_onfire = TRUE
				else
					is_onfire = FALSE
					
				if (nanite_sensors || U.sensor_mode >= SENSOR_LIVING)
					life_status = H.stat < DEAD
				else
					life_status = null

				if (nanite_sensors || U.sensor_mode >= SENSOR_VITALS)
					oxydam = round(H.getOxyLoss(),1)
					toxdam = round(H.getToxLoss(),1)
					burndam = round(H.getFireLoss(),1)
					brutedam = round(H.getBruteLoss(),1)
				else
					oxydam = null
					toxdam = null
					burndam = null
					brutedam = null

				if (nanite_sensors || U.sensor_mode >= SENSOR_COORDS)
					if (!pos)
						pos = get_turf(H)
					area = get_area_name(H, TRUE, is_sensor = TRUE)
					pos_x = pos.x
					pos_y = pos.y
				else
					area = null
					pos_x = null
					pos_y = null

				if(life_status == FALSE)
					new_death_list.Add(H)

				results[++results.len] = list("name" = name, "assignment_title" = assignment_title, "assignment" = assignment, "ijob" = ijob, "is_onfire" = is_onfire, "is_husked" = is_husked, "is_irradiated" = is_irradiated, "is_robot" = is_robot, "is_human" = is_human, "is_slime" = is_slime, "is_skeleton" = is_skeleton, "is_fly" = is_fly, "is_catperson" = is_catperson, "is_lizard" = is_lizard, "is_moth" = is_moth, "is_polysmorph" = is_polysmorph, "is_podperson" = is_podperson, "is_plasmaman" = is_plasmaman, "is_ethereal" = is_ethereal, "life_status" = life_status, "oxydam" = oxydam, "toxdam" = toxdam, "burndam" = burndam, "brutedam" = brutedam, "area" = area, "pos_x" = pos_x, "pos_y" = pos_y, "can_track" = H.can_track(null))

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
