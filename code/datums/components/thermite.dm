#define IGNITION_TEMP 1922

/datum/component/thermite
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/amount
	var/overlay
	var/melting_point = 50

	var/static/list/blacklist = typecacheof(list(
		/turf/open/lava,
		/turf/open/space,
		/turf/open/water,
		/turf/open/chasm,
		/turf/open/openspace,
	))

	var/static/list/immunelist = typecacheof(list(
		/turf/closed/wall/mineral/diamond,
		/turf/closed/indestructible,
		/turf/open/indestructible,
		/turf/closed/wall/r_wall,
	))
	
	var/static/list/resistlist = typecacheof(
		/turf/closed/wall/mineral,
	)

/datum/component/thermite/Initialize(_amount)
	if(!istype(parent, /turf) || is_type_in_typecache(parent, blacklist))
		return COMPONENT_INCOMPATIBLE
	if(immunelist[parent.type])
		melting_point = INFINITY //Yeah the overlay can still go on it and be cleaned but you arent burning down a diamond wall
	if(resistlist[parent.type])
		melting_point = 200

	amount = _amount*10

	var/turf/master = parent
	overlay = mutable_appearance('icons/effects/effects.dmi', "thermite")
	master.add_overlay(overlay)

/datum/component/thermite/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_react))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlay_update))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(welder_act))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby_react))
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, PROC_REF(flame_react))

/datum/component/thermite/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_TOOL_ACT(TOOL_WELDER),
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_FIRE_ACT,
	))

/datum/component/thermite/proc/on_overlay_update(datum/source, list/overlays)
	overlays += overlay

/datum/component/thermite/Destroy()
	var/turf/master = parent
	. = ..()
	master.update_overlays()

/datum/component/thermite/InheritComponent(datum/component/thermite/newC, i_am_original, _amount)
	if(!i_am_original)
		return
	if(newC)
		amount += newC.amount
	else
		amount += _amount

/datum/component/thermite/proc/thermite_melt(mob/user)
	var/turf/master = parent
	master.cut_overlay(overlay)
	var/obj/effect/overlay/thermite/fakefire = new(master)

	playsound(master, 'sound/items/welder.ogg', 100, 1)

	if(amount >= melting_point)
		var/burning_time = max(100, 100-amount)
		master = master.Melt()
		master.burn_tile()
		if(user)
			master.add_hiddenprint(user)
		QDEL_IN(fakefire, burning_time)
	else
		QDEL_IN(fakefire, 50)

/datum/component/thermite/proc/clean_react(datum/source, strength)
	//Thermite is just some loose powder, you could probably clean it with your hands. << todo?
	qdel(src)
	return TRUE

/datum/component/thermite/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	if(exposed_temperature > IGNITION_TEMP) // This is roughly the real life requirement to ignite thermite
		thermite_melt()

/datum/component/thermite/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	if(thing.is_hot() > IGNITION_TEMP)
		thermite_melt(user)
		return COMPONENT_BLOCK_TOOL_ATTACK
	else if(thing.is_hot())
		to_chat(user, span_warning("[thing] isn't hot enough!"))

/datum/component/thermite/proc/welder_act(datum/source, mob/user, obj/item/tool, params)
	if(tool.is_hot() > IGNITION_TEMP)
		thermite_melt(user)
		return COMPONENT_BLOCK_TOOL_ATTACK
	else if(tool.is_hot())
		to_chat(user, span_warning("[tool] isn't hot enough!"))

#undef IGNITION_TEMP
