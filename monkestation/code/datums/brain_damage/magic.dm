/datum/brain_trauma/magic/stalker
	name = "Stalking Phantom"
	desc = "Patient is stalked by a phantom only they can see."
	scan_desc = "extra-sensory paranoia"
	gain_text = span_warning("You feel like something wants to kill you...")
	lose_text = span_notice("You no longer feel eyes on your back.")
	var/max_stalkers = 1
	var/list/obj/effect/client_image_holder/stalker_phantom/stalkers = list()
	var/close_stalker = FALSE //For heartbeat

/datum/brain_trauma/magic/stalker/Destroy()
	QDEL_LIST(stalkers)
	return ..()

/datum/brain_trauma/magic/stalker/on_gain()
	create_stalkers()
	return ..()

/datum/brain_trauma/magic/stalker/on_lose()
	QDEL_LIST(stalkers)
	return ..()

/datum/brain_trauma/magic/stalker/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.stat != CONSCIOUS || !isturf(owner.loc))
		QDEL_LIST(stalkers)
		return

	var/any_stalkers_close = FALSE
	for(var/obj/effect/client_image_holder/stalker_phantom/stalker as anything in stalkers)
		if(QDELETED(stalker))
			continue
		if(stalk_tick(stalker, seconds_per_tick))
			any_stalkers_close ||= (get_dist(owner, stalker) <= 8)
		CHECK_TICK
	if(any_stalkers_close)
		if(!close_stalker)
			var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
			owner.playsound_local(owner, slowbeat, vol = 40, vary = FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			close_stalker = TRUE
	else if(close_stalker)
		owner.stop_sound_channel(CHANNEL_HEARTBEAT)
		close_stalker = FALSE

	create_stalkers()

/datum/brain_trauma/magic/stalker/proc/create_single_stalker(turf/stalker_source)
	if(!stalker_source)
		stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z) //random corner
	var/obj/effect/client_image_holder/stalker_phantom/stalker = new(stalker_source, owner)
	RegisterSignal(stalker, COMSIG_QDELETING, PROC_REF(on_phantom_destroyed))
	stalkers += stalker

/datum/brain_trauma/magic/stalker/proc/create_stalkers()
	if(!isturf(owner?.loc))
		return
	var/amount_to_create = max_stalkers - length(stalkers)
	if(amount_to_create <= 0)
		return
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	for(var/i = 1 to amount_to_create)
		create_single_stalker(stalker_source)

/datum/brain_trauma/magic/stalker/proc/on_phantom_destroyed(obj/effect/client_image_holder/stalker_phantom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	stalkers -= source

/datum/brain_trauma/magic/stalker/proc/stalk_tick(obj/effect/client_image_holder/stalker_phantom/stalker, seconds_per_tick)
	if(QDELETED(owner) || !isturf(owner.loc) || !isturf(stalker.loc) || owner.z != stalker.z)
		qdel(stalker)
		return FALSE
	if(get_dist(owner, stalker) <= 1)
		playsound(owner, 'sound/magic/demon_attack1.ogg', vol = 50)
		owner.visible_message(span_warning("[owner] is torn apart by invisible claws!"), span_userdanger("Ghostly claws tear your body apart!"))
		owner.take_bodypart_damage(rand(20, 45), wound_bonus = CANT_WOUND)
	else if(SPT_PROB(30, seconds_per_tick))
		var/turf/next_step = get_step_towards(stalker, owner)
		if(!isturf(next_step) || QDELING(next_step))
			qdel(stalker)
			return FALSE
		stalker.forceMove(next_step)
	return TRUE

/datum/brain_trauma/magic/stalker/multiple
	name = "Stalking Phantoms"
	desc = "Patient is stalked by multiple phantoms only they can see."
	scan_desc = "extra-EXTRA-sensory paranoia"
	gain_text = span_warning("You feel like the gods have released the hounds...")
	lose_text = span_notice("You no longer feel the wrath of the gods watching you.")
	max_stalkers = 10
