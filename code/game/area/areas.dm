/**
  * # area
  *
  * A grouping of tiles into a logical space, mostly used by map editors
  */
/area
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = AREA_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	/// List of all turfs currently inside this area as nested lists indexed by zlevel.
	/// Acts as a filtered version of area.contents For faster lookup
	/// (area.contents is actually a filtered loop over world)
	/// Semi fragile, but it prevents stupid so I think it's worth it
	var/list/list/turf/turfs_by_zlevel = list()
	/// turfs_by_z_level can hold MASSIVE lists, so rather then adding/removing from it each time we have a problem turf
	/// We should instead store a list of turfs to REMOVE from it, then hook into a getter for it
	/// There is a risk of this and contained_turfs leaking, so a subsystem will run it down to 0 incrementally if it gets too large
	/// This uses the same nested list format as turfs_by_zlevel
	var/list/list/turf/turfs_to_uncontain_by_zlevel = list()

	var/area_flags = NONE

	var/map_name // Set in New(); preserves the name set by the map maker, even if renamed by the Blueprints.

	var/valid_territory = TRUE // If it's a valid territory for gangs to claim
	var/blob_allowed = TRUE // Does it count for blobs score? By default, all areas count.
	var/clockwork_warp_allowed = TRUE // Can servants warp into this area from Reebe?
	var/clockwork_warp_fail = "The structure there is too dense for warping to pierce. (This is normal in high-security areas.)"

	///If true, that means one of any fire alarms in the area is active
	var/fire = FALSE
	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE
	var/vacuum = null //yogs- yellow vacuum lights
	var/mining_speed = FALSE

	var/requires_power = TRUE
	var/always_unpowered = FALSE	// This gets overridden to 1 for space in area/Initialize(mapload).

	var/outdoors = FALSE //For space, the asteroid, lavaland, etc. Used with blueprints to determine if we are adding a new area (vs editing a station room)

	var/areasize = 0 //Size of the area in open turfs, only calculated for indoors areas.

	/// Bonus mood for being in this area
	var/mood_bonus = 0
	/// Mood message for being here, only shows up if mood_bonus != 0
	var/mood_message = span_nicegreen("This area is pretty nice!\n")

	/// The color of the light tubes' light in this area
	var/lighting_colour_tube = "#FFF6ED"
	/// The color of the light bulb's light in this area
	var/lighting_colour_bulb = "#FFE6CC"

	var/lighting_colour_night = "#FFDBB5"

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/has_gravity = 0
	///Hides area from player Teleport function.
	var/hidden = FALSE
	///Is the area teleport-safe: no space / radiation / aggresive mobs / other dangers
	var/safe = FALSE
	/// If false, loading multiple maps with this area type will create multiple instances.
	var/unique = TRUE
	/// If false, then this area will show up as gibberish on suit sensors.
	var/show_on_sensors = TRUE
	/// a simple check to determine whether the lights in an area should go red during delta alert
	var/delta_light = FALSE

	var/no_air = null

	var/parallax_movedir = 0

	var/global/global_uid = 0
	var/uid

	var/ambience_index = AMBIENCE_GENERIC
	var/list/ambientsounds

	///Ambient buzz of the station, plays repeatedly, also IC
	var/ambient_buzz = 'sound/ambience/shipambience.ogg'
	///The volume of the ambient buzz
	var/ambient_buzz_vol = 30
	///Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 30 SECONDS
	///Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 175 SECONDS
	///Used to decide what kind of reverb the area makes sound have
	var/sound_environment = SOUND_ENVIRONMENT_NONE

	var/ambient_music_index
	var/list/ambientmusic


	flags_1 = CAN_BE_DIRTY_1

	var/list/firedoors
	var/list/cameras
	var/list/firealarms
	var/list/airalarms

	///Typepath to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
	var/area/area_limited_icon_smoothing

	var/firedoors_last_closed_on = 0
	/// Can the Xenobio management console transverse this area by default?
	var/xenobiology_compatible = FALSE

	var/minimap_color = null // if null, chooses random one

	/// Wire assignment for airlocks in this area
	var/airlock_wires = /datum/wires/airlock

	///This datum, if set, allows terrain generation behavior to be ran on Initialize()
	var/datum/map_generator/map_generator
	
	var/turf/teleport_anchors = list()	//ist of tiles we prefer to teleport to. this is for areas that are partially hazardous like for instance atmos_distro


	/// Whether the lights in this area aren't turned off when it's empty at roundstart
	var/lights_always_start_on = FALSE

	/// Whether to cycle brightness based on time of day
	var/uses_daylight = FALSE
	/// Daylight brightness
	var/daylight_multiplier = 1
	
/**
  * A list of teleport locations
  *
  * Adding a wizard area teleport list because motherfucking lag -- Urist
  * I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game
  */
GLOBAL_LIST_EMPTY(teleportlocs)

/**
 * Generate a list of turfs you can teleport to from the areas list
 *
 * Includes areas if they're not a shuttle or not not teleport or have no contents
 *
 * The chosen turf is the first item in the areas contents that is a station level
 *
 * The returned list of turfs is sorted by name
 */
/proc/process_teleport_locs()
	for(var/area/AR as anything in get_sorted_areas())
		if(istype(AR, /area/shuttle) || (AR.area_flags & NOTELEPORT))
			continue
		if(GLOB.teleportlocs[AR.name])
			continue
		if (!AR.has_contained_turfs())
			continue
		if (is_station_level(AR.z))
			GLOB.teleportlocs[AR.name] = AR

/**
  * Called when an area loads
  *
  *  Adds the item to the GLOB.areas_by_type list based on area type
  */
/area/New()
	if(!minimap_color) // goes in New() because otherwise it doesn't fucking work
		// generate one using the icon_state
		if(icon_state && icon_state != "unknown")
			var/icon/I = new(icon, icon_state, dir)
			I.Scale(1,1)
			minimap_color = I.GetPixel(1,1)
		else // no icon state? use random.
			minimap_color = rgb(rand(50,70),rand(50,70),rand(50,70))

	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if (unique)
		GLOB.areas_by_type[type] = src
	GLOB.areas += src
	if(uses_daylight)
		SSdaylight.add_lit_area(src)
	return ..()

/**
  * Initalize this area
  *
  * intializes the dynamic area lighting and also registers the area with the z level via
  * reg_in_areas_in_z
  *
  * returns INITIALIZE_HINT_LATELOAD
  */
/area/Initialize(mapload)
	icon_state = ""
	map_name = name // Save the initial (the name set in the map) name of the area.

	add_delta_areas()

	if(!ambientsounds && ambience_index)
		ambientsounds = GLOB.ambience_assoc[ambience_index]

	if(!ambientmusic && ambient_music_index)
		ambientmusic = GLOB.ambient_music_assoc[ambient_music_index]

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

		if(static_lighting)
			luminosity = 0

	. = ..()

	if(!static_lighting)
		blend_mode = BLEND_MULTIPLY

	reg_in_areas_in_z()
	
	update_base_lighting()

	return INITIALIZE_HINT_LATELOAD

/**
  * Sets machine power levels in the area
  */
/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon

/area/proc/RunGeneration()
	if(map_generator)
		map_generator = new map_generator()
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs, src)

/area/proc/test_gen()
	if(map_generator)
		var/list/turfs = list()
		for(var/turf/T in contents)
			turfs += T
		map_generator.generate_terrain(turfs, src)

/// Returns the highest zlevel that this area contains turfs for
/area/proc/get_highest_zlevel()
	for (var/area_zlevel in length(turfs_by_zlevel) to 1 step -1)
		if (length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if (length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return area_zlevel
		else
			if (length(turfs_by_zlevel[area_zlevel]))
				return area_zlevel
	return 0

/// Returns a nested list of lists with all turfs split by zlevel.
/// only zlevels with turfs are returned. The order of the list is not guaranteed.
/area/proc/get_zlevel_turf_lists()
	if(length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs()

	var/list/zlevel_turf_lists = list()

	for (var/list/zlevel_turfs as anything in turfs_by_zlevel)
		if (length(zlevel_turfs))
			zlevel_turf_lists += list(zlevel_turfs)

	return zlevel_turf_lists

/// Returns a list with all turfs in this zlevel.
/area/proc/get_turfs_by_zlevel(zlevel)
	if (length(turfs_to_uncontain_by_zlevel) >= zlevel && length(turfs_to_uncontain_by_zlevel[zlevel]))
		cannonize_contained_turfs_by_zlevel(zlevel)

	if (length(turfs_by_zlevel) < zlevel)
		return list()

	return turfs_by_zlevel[zlevel]


/// Merges a list containing all of the turfs zlevel lists from get_zlevel_turf_lists inside one list. Use get_zlevel_turf_lists() or get_turfs_by_zlevel() unless you need all the turfs in one list to avoid generating large lists
/area/proc/get_turfs_from_all_zlevels()
	. = list()
	for (var/list/zlevel_turfs as anything in get_zlevel_turf_lists())
		. += zlevel_turfs

/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs_by_zlevel(zlevel_to_clean, _autoclean = TRUE)
	// This is massively suboptimal for LARGE removal lists
	// Try and keep the mass removal as low as you can. We'll do this by ensuring
	// We only actually add to contained turfs after large changes (Also the management subsystem)
	// Do your damndest to keep turfs out of /area/space as a stepping stone
	// That sucker gets HUGE and will make this take actual seconds
	if (zlevel_to_clean <= length(turfs_by_zlevel) && zlevel_to_clean <= length(turfs_to_uncontain_by_zlevel))
		turfs_by_zlevel[zlevel_to_clean] -= turfs_to_uncontain_by_zlevel[zlevel_to_clean]

	if (!_autoclean) // Removes empty lists from the end of this list
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()
		return

	var/new_length = length(turfs_to_uncontain_by_zlevel)
	// Walk backwards thru the list
	for (var/i in length(turfs_to_uncontain_by_zlevel) to 0 step -1)
		if (i && length(turfs_to_uncontain_by_zlevel[i]))
			break // Stop the moment we find a useful list
		new_length = i

	if (new_length < length(turfs_to_uncontain_by_zlevel))
		turfs_to_uncontain_by_zlevel.len = new_length

	if (new_length >= zlevel_to_clean)
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()


/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs()
	for (var/area_zlevel in 1 to length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs_by_zlevel(area_zlevel, _autoclean = FALSE)

	turfs_to_uncontain_by_zlevel = list()


/// Returns TRUE if we have contained turfs, FALSE otherwise
/area/proc/has_contained_turfs()
	for (var/area_zlevel in 1 to length(turfs_by_zlevel))
		if (length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if (length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return TRUE
		else
			if (length(turfs_by_zlevel[area_zlevel]))
				return TRUE
	return FALSE

/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!has_contained_turfs())
		return
	var/list/areas_in_z = SSmapping.areas_in_z
	update_areasize()
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src

/area/proc/add_delta_areas()
	if(is_station_level(z) && !istype(src, /area/shuttle) && !istype(src, /area/ruin) && !istype(src, /area/space))
		GLOB.delta_areas += src

/**
  * Destroy an area and clean it up
  *
  * Removes the area from GLOB.areas_by_type and also stops it processing on SSobj
  *
  * This is despite the fact that no code appears to put it on SSobj, but
  * who am I to argue with old coders
  */
/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	//this is not initialized until get_sorted_areas() is called so we have to do a null check
	if(!isnull(GLOB.sortedAreas))
		GLOB.sortedAreas -= src
	//just for sanity sake cause why not
	if(!isnull(GLOB.areas))
		GLOB.areas -= src
	
	//YOG
	if(!isnull(GLOB.delta_areas))
		GLOB.delta_areas -= src
	
	//daylight cleanup
	if(uses_daylight)
		SSdaylight.remove_lit_area(src)
	//machinery cleanup
	STOP_PROCESSING(SSobj, src)
	//turf cleanup
	turfs_by_zlevel = null
	turfs_to_uncontain_by_zlevel = null
	//parent cleanup
	return ..()

/**
  * Generate a power alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			for (var/item in GLOB.silicon_mobs)
				var/mob/living/silicon/aiPlayer = item
				if (state == 1)
					aiPlayer.cancelAlarm("Power", src, source)
				else
					aiPlayer.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.alert_consoles)
				var/obj/machinery/computer/station_alert/a = item
				if(state == 1)
					a.cancelAlarm("Power", src, source)
				else
					a.triggerAlarm("Power", src, cameras, source)

			for (var/item in GLOB.drones_list)
				var/mob/living/simple_animal/drone/D = item
				if(state == 1)
					D.cancelAlarm("Power", src, source)
				else
					D.triggerAlarm("Power", src, cameras, source)
			for(var/item in GLOB.alarmdisplay)
				var/datum/computer_file/program/alarm_monitor/p = item
				p.update_alarm_display()

/**
  * Generate an atmospheric alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  */
/area/proc/atmosalert(danger_level, obj/source)
	atmosalm = danger_level
	if (atmosalm==2)
		for (var/item in GLOB.silicon_mobs)
			var/mob/living/silicon/aiPlayer = item
			aiPlayer.triggerAlarm("Atmosphere", src, cameras, source)
		for (var/item in GLOB.alert_consoles)
			var/obj/machinery/computer/station_alert/a = item
			a.triggerAlarm("Atmosphere", src, cameras, source)
		for (var/item in GLOB.drones_list)
			var/mob/living/simple_animal/drone/D = item
			D.triggerAlarm("Atmosphere", src, cameras, source)
		for(var/item in GLOB.alarmdisplay)
			var/datum/computer_file/program/alarm_monitor/p = item
			p.update_alarm_display()

	else
		for (var/item in GLOB.silicon_mobs)
			var/mob/living/silicon/aiPlayer = item
			aiPlayer.cancelAlarm("Atmosphere", src, source)
		for (var/item in GLOB.alert_consoles)
			var/obj/machinery/computer/station_alert/a = item
			a.cancelAlarm("Atmosphere", src, source)
		for (var/item in GLOB.drones_list)
			var/mob/living/simple_animal/drone/D = item
			D.cancelAlarm("Atmosphere", src, source)
		for(var/item in GLOB.alarmdisplay)
			var/datum/computer_file/program/alarm_monitor/p = item
			p.update_alarm_display()
/**
  * Try to close all the firedoors in the area
  */
/area/proc/ModifyFiredoors(opening)
	if(firedoors)
		firedoors_last_closed_on = world.time
		for(var/FD in firedoors)
			var/obj/machinery/door/firedoor/D = FD
			var/cont = !D.welded
			if(cont && opening)	//don't open if adjacent area is on fire
				for(var/I in D.affecting_areas)
					var/area/A = I
					if(A.fire)
						cont = FALSE
						break
			if(cont && D.is_operational())
				if(D.operating)
					D.nextstate = opening ? FIREDOOR_OPEN : FIREDOOR_CLOSED
				else if(!(D.density ^ opening))
					INVOKE_ASYNC(D, (opening ? TYPE_PROC_REF(/obj/machinery/door/firedoor, open) : TYPE_PROC_REF(/obj/machinery/door/firedoor, close)))

/**
  * Generate an firealarm alert for this area
  *
  * Sends to all ai players, alert consoles, drones and alarm monitor programs in the world
  *
  * Also starts the area processing on SSobj
  */
/area/proc/firealert(obj/source)
	if(always_unpowered == 1) //no fire alarms in space/asteroid
		return

	if (!fire)
		set_fire_alarm_effect()
		ModifyFiredoors(FALSE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_appearance(UPDATE_ICON)

	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.triggerAlarm("Fire", src, cameras, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.triggerAlarm("Fire", src, cameras, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.update_alarm_display()

	START_PROCESSING(SSobj, src)

/**
  * Reset the firealarm alert for this area
  *
  * resets the alert sent to all ai players, alert consoles, drones and alarm monitor programs
  * in the world
  *
  * Also cycles the icons of all firealarms and deregisters the area from processing on SSOBJ
  */
/area/proc/firereset(obj/source, alert_only=FALSE)
	if (fire && !alert_only)
		unset_fire_alarm_effects()
		ModifyFiredoors(TRUE)
		for(var/item in firealarms)
			var/obj/machinery/firealarm/F = item
			F.update_appearance(UPDATE_ICON)

	for (var/item in GLOB.silicon_mobs)
		var/mob/living/silicon/aiPlayer = item
		aiPlayer.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/a = item
		a.cancelAlarm("Fire", src, source)
	for (var/item in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = item
		D.cancelAlarm("Fire", src, source)
	for(var/item in GLOB.alarmdisplay)
		var/datum/computer_file/program/alarm_monitor/p = item
		p.update_alarm_display()

	STOP_PROCESSING(SSobj, src)

/**
  * If 100 ticks has elapsed, toggle all the firedoors closed again
  */
/area/process()
	if(firedoors_last_closed_on + 100 < world.time)	//every 10 seconds
		ModifyFiredoors(FALSE)

/**
  * Close and lock a door passed into this proc
  *
  * Does this need to exist on area? probably not
  */
/area/proc/close_and_lock_door(obj/machinery/door/DOOR)
	set waitfor = FALSE
	DOOR.close()
	if(DOOR.density)
		DOOR.lock()

/**
  * Raise a burglar alert for this area
  *
  * Close and locks all doors in the area and alerts silicon mobs of a break in
  *
  * Alarm auto resets after 600 ticks
  */
/area/proc/burglaralert(obj/trigger)
	if(always_unpowered) //no burglar alarms in space/asteroid
		return

	//Trigger alarm effect
	set_fire_alarm_effect()
	//Lockdown airlocks
	for(var/obj/machinery/door/DOOR in src)
		close_and_lock_door(DOOR)

	for (var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/SILICON = i
		if(SILICON.triggerAlarm("Burglar", src, cameras, trigger))
			//Cancel silicon alert after 1 minute
			addtimer(CALLBACK(SILICON, TYPE_PROC_REF(/mob/living/silicon, cancelAlarm),"Burglar",src,trigger), 600)

	var/obj/item/radio/radio = new /obj/item/radio(trigger)
	radio.set_frequency(FREQ_SECURITY)
	radio.use_command = TRUE
	radio.independent = TRUE
	radio.name = "burglar alarm"
	radio.talk_into(radio, "Warning: Burglar alarm triggered in [src]!! Break in of [trigger]!!")
	qdel(radio)

/**
  * Trigger the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/set_fire_alarm_effect(delta_alert=FALSE)
	if(delta_alert)
		delta_light = TRUE
	else
		fire = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		F.update_fire_light(TRUE)
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/**
  * unset the fire alarm visual affects in an area
  *
  * Updates the fire light on fire alarms in the area and sets all lights to emergency mode
  */
/area/proc/unset_fire_alarm_effects(delta_alert=FALSE)
	if(delta_alert)
		delta_light = FALSE
	else
		fire = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/alarm in firealarms)
		var/obj/machinery/firealarm/F = alarm
		if(!delta_light)
			F.update_fire_light(FALSE)
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/area/proc/set_vacuum_alarm_effect() //Just like fire alarm but blue
	vacuum = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/area/proc/unset_vacuum_alarm_effect()
	vacuum = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	for(var/obj/machinery/light/L in src)
		L.update(TRUE, TRUE, TRUE)

/**
  * Update the icon state of the area
  *
  * Im not sure what the heck this does, somethign to do with weather being able to set icon
  * states on areas?? where the heck would that even display?
  */
/area/update_icon_state()
	var/weather_icon
	for(var/datum/weather/W as anything in SSweather.processing)
		if(W.stage != END_STAGE && (src in W.impacted_areas))
			W.update_areas()
			weather_icon = TRUE
	if(!weather_icon)
		icon_state = null
	return ..()

/**
  * Update the icon of the area (overridden to always be null for space
  */
/area/space/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	icon_state = null


/**
  * Returns int 1 or 0 if the area has power for the given channel
  *
  * evalutes a mixture of variables mappers can set, requires_power, always_unpowered and then
  * per channel power_equip, power_light, power_environ
  */
/area/proc/powered(chan)		// return true if the area has power to given channel

	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(AREA_USAGE_EQUIP)
			return power_equip
		if(AREA_USAGE_LIGHT)
			return power_light
		if(AREA_USAGE_ENVIRON)
			return power_environ

	return 0

/**
  * Space is not powered ever, so this returns 0
  */
/area/space/powered(chan) //Nope.avi
	return 0

/**
  * Called when the area power status changes
  *
  * Updates the area icon and calls power change on all machinees in the area
  */
/area/proc/power_change()
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)
	update_appearance()

/**
  * Return the usage of power per channel
  */
/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(AREA_USAGE_LIGHT)
			used += used_light
		if(AREA_USAGE_EQUIP)
			used += used_equip
		if(AREA_USAGE_ENVIRON)
			used += used_environ
		if(AREA_USAGE_TOTAL)
			used += used_light + used_equip + used_environ
		if(AREA_USAGE_STATIC_EQUIP)
			used += static_equip
		if(AREA_USAGE_STATIC_LIGHT)
			used += static_light
		if(AREA_USAGE_STATIC_ENVIRON)
			used += static_environ
	return used

/**
  * Add a static amount of power load to an area
  *
  * Possible channels
  * *AREA_USAGE_STATIC_EQUIP
  * *AREA_USAGE_STATIC_LIGHT
  * *AREA_USAGE_STATIC_ENVIRON
  */
/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(AREA_USAGE_STATIC_EQUIP)
			static_equip += value
		if(AREA_USAGE_STATIC_LIGHT)
			static_light += value
		if(AREA_USAGE_STATIC_ENVIRON)
			static_environ += value

/**
  * Clear all power usage in area
  *
  * Clears all power used for equipment, light and environment channels
  */
/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/**
  * Add a power value amount to the stored used_x variables
  */
/area/proc/use_power(amount, chan)
	amount *= POWER_MOD
	switch(chan)
		if(AREA_USAGE_EQUIP)
			used_equip += amount
		if(AREA_USAGE_LIGHT)
			used_light += amount
		if(AREA_USAGE_ENVIRON)
			used_environ += amount

/**
  * Call back when an atom enters an area
  *
  * Sends signals COMSIG_AREA_ENTERED and COMSIG_ENTER_AREA (to the atom)
  *
  * If the area has ambience, then it plays some ambience music to the ambience channel
  */
/area/Entered(atom/movable/arrived, area/old_area)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_area)

	if(!arrived.important_recursive_contents?[RECURSIVE_CONTENTS_AREA_SENSITIVE])
		return
	for(var/atom/movable/recipient as anything in arrived.important_recursive_contents[RECURSIVE_CONTENTS_AREA_SENSITIVE])
		SEND_SIGNAL(recipient, COMSIG_ENTER_AREA, src)

/**
  * Called when an atom exits an area
  *
  * Sends signals COMSIG_AREA_EXITED and COMSIG_EXIT_AREA (to the atom)
  */
/area/Exited(atom/movable/gone, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED,gone, direction)
	SEND_SIGNAL(gone, COMSIG_EXIT_AREA, src, direction) //The atom that exits the area

	if(!gone.important_recursive_contents?[RECURSIVE_CONTENTS_AREA_SENSITIVE])
		return
	for(var/atom/movable/recipient as anything in gone.important_recursive_contents[RECURSIVE_CONTENTS_AREA_SENSITIVE])
		SEND_SIGNAL(recipient, COMSIG_EXIT_AREA, src)


/**
  * Returns true if this atom has gravity for the passed in turf
  *
  * Sends signals COMSIG_ATOM_HAS_GRAVITY and COMSIG_TURF_HAS_GRAVITY, both can force gravity with
  * the forced gravity var
  *
  * Gravity situations:
  * * No gravity if you're not in a turf
  * * No gravity if this atom is in is a space turf
  * * Gravity if the area it's in always has gravity
  * * Gravity if there's a gravity generator on the z level
  * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
  * * otherwise no gravity
  */
/atom/proc/has_gravity(turf/target)
	SHOULD_BE_PURE(TRUE)

	//This is a bit weird but proc arguments are considered non local variables
	// so it gets mad if you try to reassign it see https://github.com/SpaceManiac/SpacemanDMM/issues/235
	var/turf/T
	if(!target || !isturf(target))
		T = get_turf(src)
	else
		T = target

	if(!T)
		return FALSE

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, T, forced_gravity)
	if(!forced_gravity.len)
		SEND_SIGNAL(T, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(forced_gravity.len)
		var/max_grav
		for(var/i in forced_gravity)
			max_grav = max(max_grav, i)
		return max_grav

	if(isspaceturf(T)) // Turf never has gravity
		return FALSE

	var/area/A = get_area(T)
	if(A.has_gravity) // Areas which always has gravity
		return A.has_gravity
	else
		// There's a gravity generator on our z level
		if(GLOB.gravity_generators["[T.z]"])
			var/max_grav = 0
			for(var/obj/machinery/gravity_generator/main/G in GLOB.gravity_generators["[T.z]"])
				max_grav = max(G.setting,max_grav)
			return max_grav
	return SSmapping.level_trait(T.z, ZTRAIT_GRAVITY)
/**
  * Setup an area (with the given name)
  *
  * Sets the area name, sets all status var's to false and adds the area to the sorted area list
  */
/area/proc/setup(a_name)
	name = a_name
	power_equip = FALSE
	power_light = FALSE
	power_environ = FALSE
	always_unpowered = FALSE
	valid_territory = FALSE
	blob_allowed = FALSE
	require_area_resort()
/**
  * Set the area size of the area
  *
  * This is the number of open turfs in the area contents, or FALSE if the outdoors var is set
  *
  */
/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/list/zlevel_turfs as anything in get_zlevel_turf_lists())
		for(var/turf/open/thisvarisunused in zlevel_turfs)
			areasize++

/**
  * Causes a runtime error
  */
/area/AllowDrop()
	CRASH("Bad op: area/AllowDrop() called")

/**
  * Causes a runtime error
  */
/area/drop_location()
	CRASH("Bad op: area/drop_location() called")

/// A hook so areas can modify the incoming args (of what??)
/area/proc/place_on_topReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags

/// Called when a living mob that spawned here, joining the round, receives the player client.
/area/proc/on_joining_game(mob/living/boarder)
	return

/**
 * Returns the name of an area, with the original name if the area name has been changed.
 *
 * If an area has not been renamed, returns the area name. If it has been modified (by blueprints or other means)
 * returns the current name, as well as the initial value, in the format of [Current Location Name (Original Name)]
 */

/area/proc/get_original_area_name()
	if(name == initial(name))
		return name
	return "[name] ([initial(name)])"

/**
 * A blank area subtype solely used by the golem area editor for the purpose of
 * allowing golems to create new areas without suffering from the hazard_area debuffs.
 */
/area/golem
	name = "Golem Territory"
