/obj/item/melee/baton/abductor
	var/charges = 3
	var/max_charges = 3
	var/charge_rate = 5 SECONDS
	var/charging = FALSE
	COOLDOWN_DECLARE(next_charge)

/obj/item/melee/baton/abductor/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/baton/abductor/examine(mob/user)
	. = ..()
	if(isobserver(user) || AbductorCheck(user))
		. += span_notice("It has <b>[charges]</b> charge\s remaining.")
		. += span_notice("It takes [DisplayTimeText(charge_rate)] to regenerate 1 charge.")

/obj/item/melee/baton/abductor/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, next_charge))
		charges = min(charges + 1, max_charges)
		playsound(src, 'sound/machines/twobeep.ogg', vol = 10, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		COOLDOWN_START(src, next_charge, charge_rate)
	if(charges >= max_charges)
		charging = FALSE
		return PROCESS_KILL

/obj/item/melee/baton/abductor/proc/use_charge(mob/living/user)
	if(!charging)
		charging = TRUE
		START_PROCESSING(SSobj, src)
		COOLDOWN_START(src, next_charge, charge_rate)
	if(charges >= 1)
		charges--
		to_chat(user, span_notice("[icon2html(src, user)] <b>[charges]</b> charge\s remaining."))
		return TRUE
	else
		to_chat(user, span_warning("[icon2html(src, user)] Out of charges! Wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, next_charge))] for the next charge!"))
		return FALSE
