/obj/structure/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	max_integrity = 400
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 75, ACID = 90)
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	resistance_flags = LAVA_PROOF

/obj/structure/blob/core/Initialize(mapload, client/new_overmind = null, placed = 0)
	AddComponent(/datum/component/stationloving, FALSE, TRUE)
	GLOB.blob_cores += src
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	update_appearance(UPDATE_ICON) //so it atleast appears
	if(!placed && !overmind)
		return INITIALIZE_HINT_QDEL
	if(overmind)
		update_appearance(UPDATE_ICON)
	return ..()

/obj/structure/blob/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/core/update_overlays()
	. = ..()
	color = null
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	. += blob_overlay
	. += mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay")

/obj/structure/blob/core/Destroy()
	GLOB.blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	var/obj/item/assembly/signaler/anomaly/drop = new /obj/item/assembly/signaler/anomaly(src.loc)
	drop.name = "Blob Anomaly Core"
	return ..()

/obj/structure/blob/core/ex_act(severity, target)
	var/damage = 50 - 10 * severity //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, BOMB, 0)

/obj/structure/blob/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0, overmind_reagent_trigger = 1)
	. = ..()
	if(atom_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/core/process(delta_time)
	if(QDELETED(src))
		return
	if(!overmind)
		qdel(src)
	if(check_containment(src, 5))
		SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_GENERIC, 3000)
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			D.adjust_money(5000)
	if(overmind)
		overmind.blobstrain.core_process()
		overmind.update_health_hud()
	Pulse_Area(overmind, 12, 4, 3)
	for(var/obj/structure/blob/normal/B in range(1, src))
		if(DT_PROB(2.5, delta_time))
			B.change_to(/obj/structure/blob/shield/core, overmind)
	..()

/proc/check_containment(atom/source, range)
	var/safe = locate(/obj/machinery/field/containment) in urange(range, source, 1)
	if(safe)
		return TRUE
	else
		return FALSE

/obj/structure/blob/core/attack_ghost(mob/user)
	. = ..()
	become_blob(user)

/obj/structure/blob/core/proc/become_blob(mob/user)
	if(is_banned_from(user.key, ROLE_BLOB))
		to_chat(user, span_warning("You are banned from being a blob!"))
		return
	if(overmind.key)
		to_chat(user, span_warning("Someone else already took this [overmind.name]!"))
		return
	var/blob_ask = tgui_alert(user,"Become [overmind.name]?", "BLOBBER", list("Yes", "No"))
	if(blob_ask == "No" || QDELETED(overmind))
		return
	overmind.key = user.key
	log_game("[key_name(user)] took control of [overmind.name].")
	message_admins("[key_name(user)] took control of [overmind.name]. [ADMIN_JMP(overmind)].")

/obj/structure/blob/core/on_changed_z_level(turf/old_turf, turf/new_turf)
	if(overmind && is_station_level(new_turf.z))
		overmind.forceMove(get_turf(src))
	return ..()
