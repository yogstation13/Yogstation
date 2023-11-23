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
		log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
		message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
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
	log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
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

	var/datum/action/innate/ai/ranged/cameragun/ability = new
	ability.Grant(AI)

	to_chat(user, span_notice("You upgrade [AI]. [src] is consumed in the process."))
	log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
	qdel(src)

/// An ability that allows the user to shoot a laser beam at a target from the nearest camera.
/datum/action/innate/ai/ranged/cameragun
	name = "Camera Laser Gun"
	desc = "Shoots a laser from the nearest available camera toward a chosen destination. Accuracy not guaranteed." // Disclaimer is to warn people to treat this like a turret's aiming -- it might be a bit dumb at times.
	button_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "laser"
	enable_text = span_notice("You prepare to overcharge a camera. Click a target for a nearby camera to shoot a laser at.")
	disable_text = span_notice("You dissipate the overcharged energy.")
	click_action = FALSE // Even though that we are an click action, we want to use Activate() and Deactivate().
	COOLDOWN_DECLARE(next_shot)
	var/cooldown = 10 SECONDS

/// Checks if it is possible for an projectile to reach a target in a straight line from a camera.
/datum/action/innate/ai/ranged/cameragun/proc/can_shoot_to(obj/machinery/camera/C, turf/target, atom/A, confidence = 0)
	var/turf/turf_camera = get_turf(C.loc)
	var/obj/dummy = new(turf_camera)
	switch(confidence) // How confident do we want to be about the projectile reaching their destination? Lower is more restrictive/confident.
		if(0)
			dummy.pass_flags |= PASSTABLE // Might hit their attached wall if the camera is on a corner -- should hit otherwise.
		if(1)
			dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE // Same concerns above.
		if(2)
			dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE|PASSMACHINES|PASSCOMPUTER|PASSMOB|PASSSTRUCTURE // May hit a dense object on the way, but intentional.
	for(var/turf/turf in getline(turf_camera, target))
		if(turf.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy, turf, 1))
				qdel(dummy)
				return FALSE
	qdel(dummy)
	return TRUE

/datum/action/innate/ai/ranged/cameragun/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/ai/ranged/cameragun/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/ai/ranged/cameragun/process()
	build_all_button_icons() // To update the button to display if active/available.

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
	if(!. || !COOLDOWN_FINISHED(src, next_shot))
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
		if(get_dist(cam, target) > 12)
			continue
		if(get_dist(cam, target) == 0) // Pointblank shot.
			chosen_camera = cam
			break
		if(can_shoot_to(cam, loc_target, null, confidence = 0)) // Camera with the best accuracy.
			chosen_camera = cam
			break
		if(!can_shoot_to(cam, loc_target, null, confidence = 2)) // Never had the possibility to hit.
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
	
	COOLDOWN_START(src, next_shot, cooldown)
	var/turf/loc_chosen = get_turf(chosen_camera)
	var/obj/projectile/beam/laser/proj = null
	proj = new /obj/projectile/beam/laser(loc_chosen)
	proj.preparePixelProjectile(target, loc_chosen)
	proj.firer = caller

	// Fire the shot.
	var/pointblank = get_dist(chosen_camera, target) == 0 ? TRUE : FALSE // Same tile.
	if(pointblank)
		chosen_camera.visible_message(span_danger("[chosen_camera] fires a laser point blank at [target]!"))
		proj.fire(direct_target = target) 
	else
		chosen_camera.visible_message(span_danger("[chosen_camera] fires a laser!"))
		proj.fire() 
	Deactivate(FALSE)
	to_chat(caller, span_danger("Camera overcharged."))

	chosen_camera.emp_act(EMP_LIGHT) // 90 seconds downtime -- definitely enough time to toolbox this camera (unless it is emp-proof).
	return TRUE
