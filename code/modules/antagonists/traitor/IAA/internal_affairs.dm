#define PINPOINTER_MINIMUM_RANGE 15
#define PINPOINTER_EXTRA_RANDOM_RANGE 10
#define PINPOINTER_PING_TIME 40



/datum/status_effect/agent_pinpointer
	id = "agent_pinpointer"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	var/range_fuzz_factor = PINPOINTER_EXTRA_RANDOM_RANGE
	var/mob/scan_target = null
	var/range_mid = 8
	var/range_far = 16

/atom/movable/screen/alert/status_effect/agent_pinpointer
	name = "Internal Affairs Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here?.z != there?.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range + rand(0, range_fuzz_factor))
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.icon_state = "pinonclose"
		else if(dist > range_mid && dist <= range_far)
			linked_alert.icon_state = "pinonmedium"
		else if(dist > range_far)
			linked_alert.icon_state = "pinonfar"

/datum/status_effect/agent_pinpointer/proc/scan_for_target()
	scan_target = null
	if(owner)
		if(owner.mind)
			for(var/datum/objective/objective_ in owner.mind.get_all_objectives())
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				var/mob/current = objective.target.current
				if(current&&current.stat!=DEAD)
					scan_target = current
					break

/datum/status_effect/agent_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()


/proc/is_internal_objective(datum/objective/O)
	return (istype(O, /datum/objective/assassinate/internal)||istype(O, /datum/objective/destroy/internal))

#undef PINPOINTER_EXTRA_RANDOM_RANGE
#undef PINPOINTER_MINIMUM_RANGE
#undef PINPOINTER_PING_TIME
