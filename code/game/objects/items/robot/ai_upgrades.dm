///AI Upgrades


//Malf Picker
/obj/item/malf_upgrade
	name = "combat software upgrade"
	desc = "A highly illegal, highly dangerous upgrade for artificial intelligence units, granting them a variety of powers as well as the ability to hack APCs.<br>This upgrade does not override any active laws, and must be applied to an unlocked AI control console."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/malf_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	. = ..()
	if(!istype(AI))
		return
	if(AI.malf_picker)
		AI.malf_picker.processing_time += 50
		to_chat(AI, span_userdanger("[user] has attempted to upgrade you with combat software that you already possess. You gain 50 points to spend on Malfunction Modules instead."))
	else
		to_chat(AI, span_userdanger("[user] has upgraded you with combat software!"))
		to_chat(AI, span_userdanger("Your current laws and objectives remain unchanged.")) //this unlocks malf powers, but does not give the license to plasma flood
		AI.add_malf_picker()
		log_game("[key_name(user)] has upgraded [key_name(AI)] with \a [src].")
		message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with \a [src].")
	to_chat(user, span_notice("You upgrade [AI]. [src] is consumed in the process."))
	qdel(src)

//Lipreading
/obj/item/surveillance_upgrade
	name = "surveillance software upgrade"
	desc = "An illegal software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading and hidden microphones. Must be installed using an unlocked AI control console."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/surveillance_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	. = ..()
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE
		to_chat(AI, span_userdanger("[user] has upgraded you with surveillance software!"))
		to_chat(AI, "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations.")
	to_chat(user, span_notice("You upgrade [AI]. [src] is consumed in the process."))
	log_game("[key_name(user)] has upgraded [key_name(AI)] with \a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with \a [src].")
	qdel(src)

/obj/item/cameragun_upgrade
	name = "camera laser upgrade"
	desc = "A software package that will allow an artificial intelligence to briefly increase the amount of light an camera outputs to an outrageous amount to the point it burns skins. Must be installed using an unlocked AI control console." // In short, laser gun!
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/cameragun_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	. = ..()
	if(!istype(AI))
		return

	var/datum/action/innate/ai/ranged/cameragun/ai_action
	for(var/datum/action/innate/ai/ranged/cameragun/listed_action in AI.actions)
		if(!listed_action.from_traitor) // Duplicate.
			to_chat(user, span_notice("[AI] has already been upgraded with \a [src]."))
			return
		ai_action = listed_action // If they somehow have more than one action, blame adminbus first.
		ai_action.from_traitor = FALSE // Let them keep the action if they lose traitor status.

	if(!ai_action)
		ai_action = new
		ai_action.Grant(AI)

	to_chat(user, span_notice("You upgrade [AI]. [src] is consumed in the process."))
	log_game("[key_name(user)] has upgraded [key_name(AI)] with \a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with \a [src].")
	qdel(src)

/// An ability that allows the user to shoot a laser beam at a target from the nearest camera.
// TODO: If right-click functionality for buttons are added, make singleshot a left-click ability & burstmode a right-click ability.
/datum/action/innate/ai/ranged/cameragun
	name = "Camera Laser Gun"
	desc = "Shoots a laser from the nearest available camera toward a chosen destination if it is highly probable to reach said destination. If successful, enters burst mode which temporarily allows the ability to be reused every second for 30 seconds."
	button_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "laser"
	background_icon_state = "bg_default" // Better button sprites welcomed. :)
	enable_text = span_notice("You prepare to overcharge a camera. Click a target for a nearby camera to shoot a laser at.")
	disable_text = span_notice("You dissipate the overcharged energy.")
	click_action = FALSE // Even though that we are a click action, we want to use Activate() and Deactivate().
	/// The beam projectile that is spawned and shot.
	var/obj/projectile/beam/proj_type = /obj/projectile/beam/laser
	/// Pass flags used for the `can_shoot_to` proc.
	var/proj_pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	/// If this ability is sourced from being a traitor AI.
	var/from_traitor = FALSE
	/// Is burst mode activated?
	var/burstmode_activated = FALSE
	/// How long is burst mode?
	var/burstmode_length = 30 SECONDS
	COOLDOWN_DECLARE(since_burstmode)
	/// How much time (after burst mode is deactivated) must pass before it can be activated again?
	var/activate_cooldown = 60 SECONDS
	COOLDOWN_DECLARE(next_activate)
	/// How much time between shots (during burst mode)?
	var/fire_cooldown = 1 SECONDS
	COOLDOWN_DECLARE(next_fire)
	/// What EMP strength will the camera be hit with after it is used to shoot?
	var/emp_drawback = EMP_HEAVY // 7+ guarantees a 90 seconds downtime.

/// Checks if it is possible for a (hitscan) projectile to reach a target in a straight line from a camera.
/datum/action/innate/ai/ranged/cameragun/proc/can_shoot_to(obj/machinery/camera/C, atom/target)
	var/obj/projectile/proj = new /obj/projectile
	proj.icon = null
	proj.icon_state = null
	proj.hitsound = ""
	proj.suppressed = TRUE
	proj.ricochets_max = 0
	proj.ricochet_chance = 0
	proj.damage = 0
	proj.nodamage = TRUE // Prevents this projectile from detonating certain objects (e.g. welding tanks). 
	proj.log_override = TRUE
	proj.hitscan = TRUE
	proj.pass_flags = proj_pass_flags

	proj.preparePixelProjectile(target, C)
	proj.fire()

	var/turf/target_turf = get_turf(target)
	var/turf/last_turf = proj.hitscan_last
	if(last_turf == target_turf)
		return TRUE
	return FALSE

/datum/action/innate/ai/ranged/cameragun/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/ai/ranged/cameragun/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/ai/ranged/cameragun/process()
	if(burstmode_activated && COOLDOWN_FINISHED(src, since_burstmode))
		toggle_burstmode()
	build_all_button_icons()

/datum/action/innate/ai/ranged/cameragun/Activate(loud = TRUE)
	set_ranged_ability(owner, loud ? enable_text : null)
	active = TRUE
	background_icon_state = "bg_default_on"
	build_all_button_icons()

/datum/action/innate/ai/ranged/cameragun/Deactivate(loud = TRUE)
	unset_ranged_ability(owner, loud ? disable_text : null)
	active = FALSE
	background_icon_state = "bg_default"
	build_all_button_icons()

/datum/action/innate/ai/ranged/cameragun/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(burstmode_activated && !COOLDOWN_FINISHED(src, next_fire)) // Not ready to shoot (during brustmode).
		return FALSE
	if(!burstmode_activated && !COOLDOWN_FINISHED(src, next_activate)) // Burstmode is not ready.
		return FALSE

/datum/action/innate/ai/ranged/cameragun/do_ability(mob/living/caller, params, atom/target)
	var/turf/loc_target = get_turf(target)
	var/obj/machinery/camera/chosen_camera
	for(var/obj/machinery/camera/cam in GLOB.cameranet.cameras)
		if(!isturf(cam.loc))
			continue
		if(cam == target)
			continue
		if(!cam.status || cam.emped) // Non-functional camera.
			continue
		var/turf/loc_camera = get_turf(cam)
		if(loc_target.z != loc_camera.z)
			continue
		if(get_dist(cam, target) <= 1) // Pointblank shot.
			chosen_camera = cam
			break
		if(get_dist(cam, target) > 12)
			continue
		if(!can_shoot_to(cam, target)) // No chance to hit.
			continue
		if(!chosen_camera)
			chosen_camera = cam
			continue
		if(get_dist(chosen_camera, target) > get_dist(cam, target)) // Closest camera that can hit.
			chosen_camera = cam
			continue
	if(!chosen_camera)
		Deactivate(FALSE)
		to_chat(caller, span_notice("Unable to find nearby available cameras for this target."))
		return FALSE
	if(!burstmode_activated)
		toggle_burstmode()

	COOLDOWN_START(src, next_fire, fire_cooldown)
	var/turf/loc_chosen = get_turf(chosen_camera)
	var/obj/projectile/beam/proj = new proj_type(loc_chosen)
	if(!isprojectile(proj))
		Deactivate(FALSE)
		CRASH("Camera gun's proj_type was not a projectile.")
	proj.preparePixelProjectile(target, chosen_camera)
	proj.firer = caller

	// Fire the shot.
	var/pointblank = get_dist(chosen_camera, target) <= 1 ? TRUE : FALSE // Same tile or right next.
	if(pointblank)
		chosen_camera.visible_message(span_danger("[chosen_camera] fires a laser point blank at [target]!"))
		proj.fire(direct_target = target) 
	else
		chosen_camera.visible_message(span_danger("[chosen_camera] fires a laser!"))
		proj.fire() 
	Deactivate(FALSE)
	to_chat(caller, span_danger("Camera overcharged."))

	/* 	This EMP prevents burstmode from annihilating a stationary object/person.
		If someone gives a camera EMP resistance, then they had it coming. */
	if(emp_drawback > 0)
		chosen_camera.emp_act(emp_drawback)
	return TRUE

/datum/action/innate/ai/ranged/cameragun/proc/toggle_burstmode()
	burstmode_activated = !burstmode_activated
	if(burstmode_activated)
		COOLDOWN_START(src, since_burstmode, burstmode_length)
		to_chat(owner, span_notice("Burstmode activated."))
		owner.playsound_local(owner, 'sound/effects/light_flicker.ogg', 50, FALSE)
	else
		COOLDOWN_START(src, next_activate, activate_cooldown)
		to_chat(owner, span_notice("Burstmode deactivated."))
		Deactivate(FALSE) // In case that they were in the middle of shooting.
		owner.playsound_local(owner, 'sound/items/timer.ogg', 50, FALSE)
	return TRUE
