/obj/machinery/psionic_awakener
	name = "psionic awakener"
	desc = "An enclosed machine used trigger psionic latencies."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "oldpod"
	base_icon_state = "oldpod"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/psionic_awakener
	clicksound = 'sound/machines/pda_button1.ogg'

	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
	var/open_sound = 'sound/machines/podopen.ogg'
	var/close_sound = 'sound/machines/podclose.ogg'

	var/trigger_power = 50

	COOLDOWN_DECLARE(next_trigger)
	var/cooldown_duration = 10 SECONDS

/obj/machinery/psionic_awakener/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_appearance(UPDATE_ICON)

/obj/machinery/psionic_awakener/update_icon_state()
	icon_state = "[base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/psionic_awakener/container_resist(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"), span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/psionic_awakener/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist(user)

/obj/machinery/psionic_awakener/relaymove(mob/user)
	if (!state_open)
		container_resist(user)

/obj/machinery/psionic_awakener/open_machine()
	if(!state_open && !panel_open)
		flick("[base_icon_state]-anim", src)
		if(open_sound)
			playsound(src, open_sound, 40)
		..()

/obj/machinery/psionic_awakener/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[base_icon_state]-anim", src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "[enter_message]")
		if(close_sound)
			playsound(src, close_sound, 40)

/obj/machinery/psionic_awakener/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational() && occupant)
		open_machine()

/obj/machinery/psionic_awakener/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	to_chat(user, span_danger("You disable the safeties of [src]..."))
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/psionic_awakener/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	close_machine(target)

/obj/machinery/psionic_awakener/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
		return
	if(default_deconstruction_screwdriver(user, "[base_icon_state]-o", base_icon_state, I))
		return
	return FALSE

/obj/machinery/psionic_awakener/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_change_direction_wrench(user, I))
		return TRUE

/obj/machinery/psionic_awakener/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/psionic_awakener/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/psionic_awakener/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/psionic_awakener/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PsionicAwakener", name)
		ui.open()

/obj/machinery/psionic_awakener/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/psionic_awakener/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to [state_open ? "close" : "open"] it.")

/obj/machinery/psionic_awakener/ui_data(mob/user)
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open
	data["ready"] = COOLDOWN_FINISHED(src, next_trigger)
	data["timeleft"] = (COOLDOWN_TIMELEFT(src, next_trigger))/10

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["brainLoss"] = mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN)
	return data

/obj/machinery/psionic_awakener/ui_act(action, params)
	if(..())
		return
	var/mob/living/mob_occupant = occupant
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("activate")
			if(!is_operational() || !mob_occupant)
				return
			
			trigger_psionics(mob_occupant)
			. = TRUE

/obj/machinery/psionic_awakener/proc/trigger_psionics(mob/living/mob_occupant)
	if(!mob_occupant || !COOLDOWN_FINISHED(src, next_trigger))
		return
	COOLDOWN_START(src, next_trigger, cooldown_duration)

	if(!mob_occupant.psi)
		visible_message(span_notice("[src] whirrs quietly as it fails to detect any psionic potential."))
		playsound(src, 'sound/effects/psi/power_fail.ogg', 50, TRUE, 2)
		return

	if(obj_flags & EMAGGED)
		trigger_power = 100

	if(obj_flags & EMAGGED)
		playsound(src, 'sound/effects/gravhit.ogg', 30, TRUE, 5)
		visible_message(span_notice("[src] makes some unusual noises."))
		mob_occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(trigger_power, trigger_power * 2))

	if(mob_occupant?.psi?.check_latency_trigger(trigger_power, name))
		visible_message(span_notice("[src] whirrs loudly as it successfully triggers latent psionic abilities in [mob_occupant]."))
		playsound(src, 'sound/effects/psi/power_evoke.ogg', 50, TRUE, 2)
		playsound(src, 'sound/effects/psi/power_fabrication.ogg', 50, TRUE, 2)
		log_admin("[name] triggered psi latencies for [key_name(mob_occupant)].")
		message_admins(span_adminnotice("[ADMIN_FLW(name)] triggered psi latencies for [key_name(mob_occupant)]."))
		trigger_power = initial(trigger_power)
	else
		visible_message(span_notice("[src] whirrs quietly as it fails to unlock any psionic potential."))
		playsound(src, 'sound/effects/psi/power_fail.ogg', 50, TRUE, 2)
		trigger_power += 10 //little bit of pity, so it's not just rng
