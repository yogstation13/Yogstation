/obj/item/implant/infiltrator
	name = "infiltration implant"
	desc = "A sneaky implant for sneaky infiltrators"
	activated = FALSE
	var/obj/item/radio/alert_radio
	var/datum/team/infiltrator/team
	var/upgraded = FALSE

/obj/item/implant/infiltrator/Initialize(mapload, _owner, _team)
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	var/datum/component/uplink/uplink = AddComponent(/datum/component/uplink, _owner, TRUE, FALSE, null, 20)
	uplink.set_gamemode(/datum/game_mode/infiltration)
	alert_radio = new(src)
	alert_radio.make_syndie()
	alert_radio.listening = FALSE
	alert_radio.canhear_range = 0
	alert_radio.set_frequency(FREQ_SYNDICATE)
	alert_radio.name = "infiltration cruiser autopilot"
	team = _team

/obj/item/implant/infiltrator/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		target.apply_status_effect(/datum/status_effect/infiltrator_pinpointer)

/obj/item/implant/infiltrator/removed(mob/living/target, silent = FALSE, special = 0)
	var/turf/T = get_turf(src)
	. = ..()
	if (.)
		target.remove_status_effect(/datum/status_effect/infiltrator_pinpointer)
		visible_message(T, span_notice("[src] explodes into a bunch of sparks!"))
		do_sparks(8, FALSE, T)
		qdel(src)

/obj/item/implant/infiltrator/activate()
	var/obj/item/stack/telecrystal/TC = imp_in.is_holding_item_of_type(/obj/item/stack/telecrystal)
	if (TC)
		to_chat(imp_in, span_notice("You put [TC.amount] TC into your hidden uplink."))
		var/datum/component/uplink/uplink = GetComponent(/datum/component/uplink)
		uplink.telecrystals += TC.amount
		TC.use(TC.amount)
		return
	var/list/radial_menu = list()
	radial_menu["Syndicate Uplink"] = image(icon = 'icons/obj/radio.dmi', icon_state = "radio")
	radial_menu["Change Pinpointer Target"] = image(icon = icon = 'icons/obj/device.dmi', icon_state = "pinpointer_syndicate")
	var/obj/docking_port/mobile/cutter = SSshuttle.getShuttle("syndicatecutter")
	var/obj/docking_port/stationary/homePort = SSshuttle.getDock("syndicatecutter_home")
	var/obj/docking_port/stationary/targetPort = SSshuttle.getDock("syndicatecutter_custom")
	if (cutter)
		if (is_centcom_level(cutter.z))
			if (targetPort)
				radial_menu["Call Ship"] = image(icon = 'icons/obj/decals.dmi', icon_state = "drop")
		else
			radial_menu["Send Ship Away"] = image(icon = 'icons/obj/decals.dmi', icon_state = "evac")
	var/chosen = show_radial_menu(imp_in, imp_in, radial_menu, "infiltrator_implant")
	if (!chosen)
		return
	switch (chosen)
		if ("Syndicate Uplink")
			var/datum/component/uplink/uplink = GetComponent(/datum/component/uplink)
			uplink.implant_activation()
		if ("Change Pinpointer Target")
			var/datum/status_effect/infiltrator_pinpointer/pinpointer = imp_in.has_status_effect(/datum/status_effect/infiltrator_pinpointer)
			if (!pinpointer)
				return
			var/list/pinpointer_menu = list()
			var/list/targets = get_targets()
			for(var/A in targets)
				if(istype(targets[A], /mob))
					pinpointer_menu[A] = getFlatIcon(targets[A])
				else if(istype(targets[A], /atom))
					var/atom/AT = targets[A]
					pinpointer_menu[A] = image(AT.icon, AT.icon_state)
			pinpointer_menu["Infiltration Cruiser"] = image(icon = 'icons/turf/shuttle.dmi', icon_state = "burst_s")
			var/pinpointer_chosen = show_radial_menu(imp_in, imp_in, pinpointer_menu, "infiltrator_implant_pinpointer")
			if (pinpointer_chosen)
				if (pinpointer_chosen == "Infiltration Cruiser")
					pinpointer.scan_target = SSshuttle.getShuttle("syndicatecutter")
					to_chat(imp_in, span_notice("Pinpointer target set to the infiltration cruiser."))
				else
					pinpointer.scan_target = targets[pinpointer_chosen]
					to_chat(imp_in, span_notice("Pinpointer target set to [pinpointer.scan_target]"))
				pinpointer.point_to_target()
		if ("Send Ship Away")
			alert_radio.talk_into(alert_radio, "The infiltration cruiser has been remotely sent to the base by [imp_in.real_name]")
			cutter.request(homePort)
		if ("Call Ship")
			alert_radio.talk_into(alert_radio, "The infiltration cruiser has been remotely sent to [station_name()] by [imp_in.real_name]")
			cutter.request(targetPort)

/obj/item/implant/infiltrator/proc/get_targets()
	var/list/targets = list()
	if(team && LAZYLEN(team.objectives))
		for(var/A in team.objectives)
			var/datum/objective/O = A
			if(istype(O) && !O.check_completion())
				if(istype(O.target, /datum/mind))
					var/datum/mind/M = O.target
					targets[M.current.real_name] = M.current
				else if(istype(O, /datum/objective/steal))
					var/datum/objective/steal/S = O
					targets[S.targetinfo.name] = locate(S.targetinfo.targetitem)
	return targets

/atom/movable/screen/alert/status_effect/infiltrator_pinpointer
	name = "Infilitrator Integrated Pinpointer"
	desc = "The stealthiest pinpointer."
	icon = 'yogstation/icons/misc/infiltrator_pinpointer.dmi'
	icon_state = "overlay"

/atom/movable/screen/alert/status_effect/infiltrator_pinpointer/examine(mob/user)
	. = ..()
	var/datum/status_effect/infiltrator_pinpointer/effect = attached_effect
	if (effect?.scan_target)
		. += span_notice("Currently tracking [effect.scan_target]")

/atom/movable/screen/alert/status_effect/infiltrator_pinpointer/Click()
	if (isliving(usr))
		var/obj/item/implant/infiltrator/implant = locate() in usr
		implant.activate()

/datum/status_effect/infiltrator_pinpointer
	id = "infiltrator_pinpointer"
	duration = -1
	tick_interval = 40
	alert_type = /atom/movable/screen/alert/status_effect/infiltrator_pinpointer
	var/atom/movable/scan_target
	var/minimum_range = 4
	var/range_mid = 8
	var/range_far = 16

/datum/status_effect/infiltrator_pinpointer/New()
	. = ..()
	scan_target = SSshuttle.getShuttle("syndicatecutter")

/datum/status_effect/infiltrator_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	linked_alert.cut_overlays()
	if(!scan_target)
		linked_alert.add_overlay("unknown")
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.add_overlay("unknown")
		return
	if(get_dist_euclidian(here,there)<=minimum_range)
		linked_alert.add_overlay("direct")
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.add_overlay("close")
		else if(dist > range_mid && dist <= range_far)
			linked_alert.add_overlay("medium")
		else if(dist > range_far)
			linked_alert.add_overlay("far")

/datum/status_effect/infiltrator_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	point_to_target()
