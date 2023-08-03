/datum/component/shadow_step
	var/speedboost = -1

/datum/component/shadow_step/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	
/datum/component/shadow_step/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(apply_darkness_speed))

/datum/component/shadow_step/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	C.remove_movespeed_modifier(type)

/datum/component/shadow_step/proc/apply_darkness_speed()
	var/turf/T = get_turf(parent)
	var/light_amount = T.get_lumcount()
	if(light_amount > DARKSPAWN_BRIGHT_LIGHT)
		parent.remove_movespeed_modifier(type)
	else
		parent.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=speedboost, blacklisted_movetypes=(FLYING|FLOATING))
