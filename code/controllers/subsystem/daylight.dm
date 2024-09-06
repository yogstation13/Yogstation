#define NIGHT_TURF_BRIGHTNESS 0.1

SUBSYSTEM_DEF(daylight)
	name = "Daylight"
	wait = 2 SECONDS
	flags = SS_NO_INIT
	/// Time required to complete a full day-night cycle
	var/daylight_time = 24 MINUTES
	/// All areas that should update their lighting based on time of day
	var/list/area/daylight_areas = list()

/datum/controller/subsystem/daylight/proc/add_lit_area(area/new_area)
	daylight_areas.Add(new_area)

/datum/controller/subsystem/daylight/proc/remove_lit_area(area/old_area)
	daylight_areas.Remove(old_area)

/datum/controller/subsystem/daylight/fire(resumed = FALSE)
	var/light_coefficient = max((sin(world.time * 360 / daylight_time) + 0.5) * 2 / 3, 0)
	var/light_alpha = round(255 * light_coefficient)
	var/light_color = rgb(255, 130 + 125 * light_coefficient, 130 + 125 * light_coefficient)
	for(var/area/lit_area as anything in daylight_areas)
		lit_area.set_base_lighting(light_color, light_alpha * lit_area.daylight_multiplier)
