/obj/item/implant/psi_control
	name = "psi dampener implant"
	desc = "A safety implant for registered psi-operants."
	implant_color = "n"
	activated = FALSE

	var/overload = 0
	var/max_overload = 100
	var/cooldown_rate = 10
	var/psi_mode = PSI_IMPLANT_AUTOMATIC
	var/list/logs

/obj/item/implant/psi_control/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Psionic Mitigation Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Psionic personel injected with this device can have their psionic potental di.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small shard of nullglass that prevents those implanted from being able to use psionic powers.<BR>
				<b>Special Features:</b> Will prevent and log the use of psionics.<BR>
				<b>Integrity:</b> Implant will last so long as the device is inside the bloodstream."}
	return dat

/obj/item/implant/psi_control/Initialize()
	. = ..()
	SSpsi.psi_dampeners += src
	SSpsi.processing += src

/obj/item/implant/psi_control/Destroy()
	SSpsi.psi_dampeners -= src
	SSpsi.processing -= src
	. = ..()

/obj/item/implant/psi_control/process()
	..()
	overload = max(overload - cooldown_rate, 0)

/obj/item/implant/psi_control/disrupts_psionics()
	if(!imp_in)
		return FALSE
	var/use_psi_mode = get_psi_mode()
	return (use_psi_mode == PSI_IMPLANT_SHOCK || use_psi_mode == PSI_IMPLANT_WARN) ? src : FALSE

/obj/item/implant/psi_control/removed()
	var/mob/living/M = imp_in
	if(disrupts_psionics() && istype(M) && M.psi)
		to_chat(M, span_notice("You feel the chilly shackles around your psionic faculties fade away."))
	. = ..()

/obj/item/implant/psi_control/proc/update_functionality(silent)
	var/mob/living/M = imp_in
	if(silent || !M || !M.psi)
		return
	if(get_psi_mode() == PSI_IMPLANT_DISABLED)
		to_chat(M, span_notice("You feel the chilly shackles around your psionic faculties fade away."))
	else
		to_chat(M, span_notice("Bands of hollow ice close themselves around your psionic faculties."))

/obj/item/implant/psi_control/proc/meltdown()
	overload = 100
	if(imp_in)
		report_failure()
	psi_mode = PSI_IMPLANT_DISABLED
	update_functionality()

/obj/item/implant/psi_control/proc/get_psi_mode()
	if(psi_mode == PSI_IMPLANT_AUTOMATIC)
		switch(get_security_level())
			if("green")
				return PSI_IMPLANT_SHOCK
			if("blue")
				return PSI_IMPLANT_WARN
			else
				return PSI_IMPLANT_LOG

	return psi_mode

/obj/item/implant/psi_control/withstand_psi_stress(stress, atom/source)
	if(source != imp_in)
		return

	var/use_psi_mode = get_psi_mode()

	if(use_psi_mode == PSI_IMPLANT_DISABLED)
		return stress

	. = 0

	if(stress)

		// If we're disrupting psionic attempts at the moment, we might overload.
		if(disrupts_psionics())
			var/overload_amount = FLOOR(stress, 10)
			if(overload_amount)
				overload += overload_amount
				if(overload >= 100)
					if(imp_in)
						to_chat(imp_in, span_danger("Your psi dampener overloads violently!"))
					meltdown()
					update_functionality()
					return
				if(imp_in)
					if(overload >= 75 && overload < 100)
						to_chat(imp_in, span_danger("Your psi dampener is searing hot!"))
					else if(overload >= 50 && overload < 75)
						to_chat(imp_in, span_warning("Your psi dampener is uncomfortably hot..."))
					else if(overload >= 25 && overload < 50)
						to_chat(imp_in, span_warning("You feel your psi dampener heating up..."))

		// If all we're doing is logging the incident then just pass back stress without changing it.
		if(source && source == imp_in)
			report_violation(stress)
			switch(use_psi_mode)
				if(PSI_IMPLANT_LOG)
					return stress
				if(PSI_IMPLANT_SHOCK)
					to_chat(imp_in, span_danger("Your psi dampener punishes you with a violent neural shock!"))
					imp_in.electrocute_act(5, src)
					if(isliving(imp_in))
						var/mob/living/M = imp_in
						if(M.psi) M.psi.stunned(5)
				if(PSI_IMPLANT_WARN)
					to_chat(imp_in, span_warning("Your psi dampener primly informs you it has reported this violation."))

/obj/item/implant/psi_control/proc/report_failure()
	LAZYADD(logs, "Critical system failure - [imp_in.name].")

/obj/item/implant/psi_control/proc/report_violation(stress)
	LAZYADD(logs, "Sigma [round(stress/10)] event - [imp_in.name].")

/obj/item/implant/psi_control/psych
	psi_mode = PSI_IMPLANT_LOG

/obj/item/implanter/psi_control
	name = "implanter (psi dampener)"
	imp_type = /obj/item/implant/psi_control

/obj/item/implantcase/psi_control
	name = "implant case - 'Psi Dampener'"
	desc = "A glass case containing a psi dampener implant."
	imp_type = /obj/item/implant/psi_control

/obj/item/implant/nullglass
	name = "nullglass shard"
	desc = "A shard of psionic inhibiting glass."
	implant_color = "n"
	var/stress_left = 100
	var/lifespan = 1 MINUTES

/obj/item/implant/nullglass/Initialize()
	. = ..()
	QDEL_IN(src, lifespan)

/obj/item/implant/nullglass/disrupts_psionics()
	if(imp_in)
		return src

/obj/item/implant/nullglass/withstand_psi_stress(stress, atom/source)
	if(source != imp_in)
		return stress

	. = max(stress - stress_left, 0)
	stress_left -= stress
	if(imp_in)
		if(stress_left > 0 && stress_left < 25)
			to_chat(imp_in, span_danger("You feel a searing hot piece of glass in your body!"))
		else if(stress_left >= 25 && stress_left < 50)
			to_chat(imp_in, span_warning("You feel a piece of glass in your body getting uncomfortably hot..."))
		else if(stress_left >= 50)
			to_chat(imp_in, span_warning("You feel a piece of glass in your body heating up..."))
	if(stress_left <= 0)
		to_chat(imp_in, span_danger("You hear a piece of glass shatter in your body!"))
		qdel(src)
