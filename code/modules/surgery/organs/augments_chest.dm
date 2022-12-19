/obj/item/organ/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "Implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = BODY_ZONE_CHEST

/obj/item/organ/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = ORGAN_SLOT_STOMACH_AID

/obj/item/organ/cyberimp/chest/nutriment/on_life()
	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_notice("You feel less hungry..."))
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, .proc/synth_cool), 50)

/obj/item/organ/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.reagents.add_reagent(/datum/reagent/toxin/bad_food, poison_amount / severity)
	to_chat(owner, span_warning("You feel like your insides are burning."))


/obj/item/organ/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10

/obj/item/organ/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	slot = ORGAN_SLOT_HEART_AID
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/organ/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat == UNCONSCIOUS || owner.stat == SOFT_CRIT)
			addtimer(CALLBACK(src, .proc/heal), 2 SECONDS)
		else
			cooldown = revive_cost + world.time
			reviving = FALSE
			to_chat(owner, span_notice("Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)]."))
		return

	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		return

	revive_cost = 0
	reviving = TRUE
	to_chat(owner, span_notice("You feel a faint buzzing as your reviver implant starts patching your wounds..."))

/obj/item/organ/cyberimp/chest/reviver/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-5)
		revive_cost += 0.5 SECONDS
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-2)
		revive_cost += 4 SECONDS
	if(owner.getFireLoss())
		owner.adjustFireLoss(-2)
		revive_cost += 4 SECONDS
	if(owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 4 SECONDS

/obj/item/organ/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(reviving)
		revive_cost += 20 SECONDS
	else
		cooldown += 20 SECONDS

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity) && H.can_heartattack())
			H.set_heartattack(TRUE)
			to_chat(H, span_userdanger("You feel a horrible agony in your chest!"))
			addtimer(CALLBACK(src, .proc/undo_heart_attack), 10 SECONDS / severity)

/obj/item/organ/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, span_notice("You feel your heart beating again!"))


/obj/item/organ/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_jetpack"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/organ/cyberimp/chest/thrusters/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(!ion_trail)
		ion_trail = new
	ion_trail.set_up(M)

/obj/item/organ/cyberimp/chest/thrusters/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent = TRUE)
	..()

/obj/item/organ/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/thrusters/proc/toggle(silent = FALSE)
	if(!on)
		if((organ_flags & ORGAN_FAILING))
			if(!silent)
				to_chat(owner, span_warning("Your thrusters set seems to be broken!"))
			return 0
		on = TRUE
		if(allow_thrust(0.01))
			ion_trail.start()
			RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/move_react)
			owner.add_movespeed_modifier(MOVESPEED_ID_CYBER_THRUSTER, priority=100, multiplicative_slowdown=-0.3, movetypes=FLOATING, conflict=MOVE_CONFLICT_JETPACK)
			if(!silent)
				to_chat(owner, span_notice("You turn your thrusters set on."))
	else
		ion_trail.stop()
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		owner.remove_movespeed_modifier(MOVESPEED_ID_CYBER_THRUSTER)
		if(!silent)
			to_chat(owner, span_notice("You turn your thrusters set off."))
		on = FALSE
	update_icon()

/obj/item/organ/cyberimp/chest/thrusters/update_icon()
	if(on)
		icon_state = "imp_jetpack-on"
	else
		icon_state = "imp_jetpack"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/cyberimp/chest/thrusters/proc/move_react()
	allow_thrust(0.01)

/obj/item/organ/cyberimp/chest/thrusters/proc/allow_thrust(num)
	if(!on || !owner)
		return 0

	var/turf/T = get_turf(owner)
	if(!T) // No more runtimes from being stuck in nullspace.
		return 0

	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.return_pressure() > 30)
		return 1

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num*100)
		owner.adjustPlasma(-num*100)
		return 1

	// Priority 3: use internals tank.
	var/obj/item/tank/I = owner.internal
	if(I && I.air_contents && I.air_contents.total_moles() >= num)
		T.assume_air_moles(I.air_contents, num)

	toggle(silent = TRUE)
	return 0

/obj/item/organ/cyberimp/chest/thrusters/emp_act(severity)
	. = ..()
	switch(severity)
		if(EMP_HEAVY)
			owner.adjustFireLoss(35)
			to_chat(owner, span_warning("Your thruster implant malfunctions and severely burns you!"))
		if(EMP_LIGHT)
			owner.adjustFireLoss(10)
			to_chat(owner, span_danger("Your thruster implant malfunctions and mildly burns you!"))

/obj/item/organ/cyberimp/chest/spinalspeed
	name = "neural overclocker implant"
	desc = "Overloads your central nervous system in order to do everything faster. Careful not to overuse it."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_spinal"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	syndicate_implant = TRUE
	var/on = FALSE
	var/time_on = 0
	var/hasexerted = FALSE
	COOLDOWN_DECLARE(alertcooldown)
	COOLDOWN_DECLARE(startsoundcooldown)
	COOLDOWN_DECLARE(endsoundcooldown)

/obj/item/organ/cyberimp/chest/spinalspeed/Insert(mob/living/carbon/M, special = 0)
	. = ..()

/obj/item/organ/cyberimp/chest/spinalspeed/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent = TRUE)
	..()

/obj/item/organ/cyberimp/chest/spinalspeed/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/spinalspeed/proc/toggle(silent = FALSE)
	if(!on)
		if(COOLDOWN_FINISHED(src, startsoundcooldown))
			playsound(owner, 'sound/effects/spinal_implant_on.ogg', 60)
			COOLDOWN_START(src, startsoundcooldown, 1 SECONDS)
		owner.add_movespeed_modifier("spinalimplant", priority=100, multiplicative_slowdown=-1)
		owner.next_move_modifier *= 0.7
		owner?.dna?.species?.action_speed_coefficient *= 0.7
		RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/move_react)
	else
		if(COOLDOWN_FINISHED(src, endsoundcooldown))
			playsound(owner, 'sound/effects/spinal_implant_off.ogg', 70)
			COOLDOWN_START(src, endsoundcooldown, 1 SECONDS)
		owner.next_move_modifier /= 0.7
		owner?.dna?.species?.action_speed_coefficient /= 0.7
		owner.remove_movespeed_modifier("spinalimplant")
		UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	on = !on
	if(!silent)
		to_chat(owner, span_notice("You turn your spinal implant [on? "on" : "off"]."))
	update_icon()

/obj/item/organ/cyberimp/chest/spinalspeed/update_icon()
	if(on)
		icon_state = "imp_spinal-on"
	else
		icon_state = "imp_spinal"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/cyberimp/chest/spinalspeed/proc/move_react()//afterimage
	var/turf/currentloc = get_turf(owner)
	var/obj/effect/temp_visual/decoy/fading/F = new(currentloc, owner)
	var/rvalue = 0
	var/gvalue = 0
	var/bvalue = 0
	var/numcolors = (world.time * 32) % 1280
	var/segment = numcolors / 256
	var/specific_color = numcolors % 256 //works like any non-sine wave rainbow generator thing, google it
	switch(segment)//transition isn't as precise as if i used sin() but this is far more efficient for runtime
		if(0 to 1)
			rvalue = 255
			gvalue = specific_color
		if(1 to 2)
			rvalue = 255 - specific_color
			gvalue = 255
		if(2 to 3)
			gvalue = 255
			bvalue = specific_color
		if(3 to 4)
			gvalue = 255 - specific_color
			bvalue = 255
		if(4 to 5)
			rvalue = specific_color
			bvalue = 255 - specific_color
	var/usedcolor = rgb(rvalue, gvalue, bvalue)
	F.color = usedcolor	//gotta add the flair

/obj/item/organ/cyberimp/chest/spinalspeed/on_life()
	if(on)
		if(owner.stat == UNCONSCIOUS || owner.stat == DEAD)
			toggle(silent = TRUE)
		time_on += 1
		switch(time_on)
			if(20 to 50)
				if(COOLDOWN_FINISHED(src, alertcooldown))
					to_chat(owner, span_alert("You feel your spine tingle."))
					COOLDOWN_START(src, alertcooldown, 10 SECONDS)
				owner.hallucination += 5
				owner.adjustFireLoss(1)
			if(50 to 100)
				if(COOLDOWN_FINISHED(src, alertcooldown) || !hasexerted)
					to_chat(owner, span_userdanger("Your spine and brain feel like they're burning!"))
					COOLDOWN_START(src, alertcooldown, 5 SECONDS)
				hasexerted = TRUE
				owner.set_drugginess(10)
				owner.hallucination += 100
				owner.adjustFireLoss(5)
			if(100 to INFINITY)//no infinite abuse
				to_chat(owner, span_userdanger("You feel a slight sense of shame as your brain and spine rip themselves apart from overexertion."))
				owner.gib()
	else
		time_on -= 2

	time_on = max(time_on, 0)
	if(hasexerted && time_on == 0)
		to_chat(owner, "Your brains feels normal again.")
		hasexerted = FALSE

/obj/item/organ/cyberimp/chest/spinalspeed/emp_act(severity)
	. = ..()
	switch(severity)//i don't want emps to just be damage again, that's boring
		if(EMP_HEAVY)
			owner.set_drugginess(40)
			owner.hallucination += 500
			owner.blur_eyes(20)
			owner.dizziness += 10
			time_on += 10
			owner.adjustFireLoss(10)
			to_chat(owner, span_warning("Your spinal implant malfunctions and you feel it scramble your brain!"))
		if(EMP_LIGHT)
			owner.set_drugginess(20)
			owner.hallucination += 200
			owner.blur_eyes(10)
			owner.dizziness += 5
			time_on += 5
			owner.adjustFireLoss(5)
			to_chat(owner, span_danger("Your spinal implant malfunctions and you suddenly feel... wrong."))

/obj/item/organ/cyberimp/chest/cooling_intake
	name = "cooling intake"
	desc = "An external port that can intake air from the environment or coolant from a tank."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
