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
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/existing = owner.reagents.get_reagent_amount(/datum/reagent/toxin/bad_food)
	owner.reagents.add_reagent(/datum/reagent/toxin/bad_food, (poison_amount * (severity / EMP_HEAVY)) - existing)
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
	var/heal_amount = 1

/obj/item/organ/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat)
			addtimer(CALLBACK(src, PROC_REF(heal)), 2 SECONDS)
		else
			cooldown = revive_cost + world.time
			reviving = FALSE
			to_chat(owner, span_notice("Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)]."))
		return

	if(cooldown > world.time)
		return
	if(!owner.stat)
		return
	if(owner.suiciding)
		return

	revive_cost = 0
	reviving = TRUE
	to_chat(owner, span_notice("You feel a faint buzzing as your reviver implant starts patching your wounds..."))

/obj/item/organ/cyberimp/chest/reviver/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-heal_amount * 5)
		revive_cost += 0.5 SECONDS
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-heal_amount * 2, required_status = BODYPART_ANY)
		revive_cost += 4 SECONDS
	if(owner.getFireLoss())
		owner.adjustFireLoss(-heal_amount * 2, required_status = BODYPART_ANY)
		revive_cost += 4 SECONDS
	if(owner.getToxLoss())
		owner.adjustToxLoss(-heal_amount)
		revive_cost += 4 SECONDS

/obj/item/organ/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(reviving)
		revive_cost += 20 SECONDS
	else
		cooldown += 20 SECONDS

	if(ishuman(owner) && !syndicate_implant)
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(5 * severity) && H.can_heartattack())
			H.set_heartattack(TRUE)
			to_chat(H, span_userdanger("You feel a horrible agony in your chest!"))
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), severity SECONDS)

/obj/item/organ/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	H.set_heartattack(FALSE)
	if(H.stat == CONSCIOUS)
		to_chat(H, span_notice("You feel your heart beating again!"))

/obj/item/organ/cyberimp/chest/reviver/syndicate
	name = "syndicate reviver implant"
	desc = "A more powerful and experimental version of the one utilized by Nanotrasen, this implant will attempt to revive and heal you if you are critically injured. For the faint of heart!"
	implant_color = "#600000"
	syndicate_implant = TRUE
	heal_amount = 2

/obj/item/organ/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_TORSO_IMPLANT
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
			RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
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
	update_appearance(UPDATE_ICON)

/obj/item/organ/cyberimp/chest/thrusters/update_icon_state()
	. = ..()
	if(on)
		icon_state = "imp_jetpack-on"
	else
		icon_state = "imp_jetpack"
	for(var/datum/action/A as anything in actions)
		A.build_all_button_icons()

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
	owner.adjustFireLoss(3 * severity)
	to_chat(owner, span_warning("Your thruster implant malfunctions and severely burns you!"))

/obj/item/organ/cyberimp/chest/spinalspeed
	name = "neural overclocker implant"
	desc = "Stimulates your central nervous system in order to enable you to perform muscle movements faster. Careful not to overuse it."
	slot = ORGAN_SLOT_TORSO_IMPLANT
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
		if(syndicate_implant)//the toy doesn't do anything aside from the trail and the sound
			if(ishuman(owner))
				var/mob/living/carbon/human/human = owner
				human.physiology.do_after_speed *= 0.7
				human.physiology.crawl_speed -= 1
			owner.next_move_modifier *= 0.7
			owner.add_movespeed_modifier("spinalimplant", priority=100, multiplicative_slowdown=-1)
		owner.AddComponent(/datum/component/after_image, 2 SECONDS, 0.5, TRUE)
	else
		if(COOLDOWN_FINISHED(src, endsoundcooldown))
			playsound(owner, 'sound/effects/spinal_implant_off.ogg', 70)
			COOLDOWN_START(src, endsoundcooldown, 1 SECONDS)
		if(syndicate_implant)
			if(ishuman(owner))
				var/mob/living/carbon/human/human = owner
				human.physiology.do_after_speed /= 0.7
				human.physiology.crawl_speed += 1
			owner.next_move_modifier /= 0.7
			owner.remove_movespeed_modifier("spinalimplant")
		var/datum/component/after_image = owner.GetComponent(/datum/component/after_image)
		qdel(after_image)
	on = !on
	if(!silent)
		to_chat(owner, span_notice("You turn your spinal implant [on? "on" : "off"]."))
	update_appearance(UPDATE_ICON)

/obj/item/organ/cyberimp/chest/spinalspeed/update_icon_state()
	. = ..()
	if(on)
		icon_state = "imp_spinal-on"
	else
		icon_state = "imp_spinal"
	for(var/datum/action/A as anything in actions)
		A.build_all_button_icons()

/obj/item/organ/cyberimp/chest/spinalspeed/on_life()
	if(!syndicate_implant)//the toy doesn't have a drawback
		return

	if(on)
		if(owner.stat == UNCONSCIOUS || owner.stat == DEAD)
			toggle(silent = TRUE)
		time_on += 1
		switch(time_on)
			if(20 to 50)
				if(COOLDOWN_FINISHED(src, alertcooldown))
					to_chat(owner, span_alert("You feel your spine tingle."))
					COOLDOWN_START(src, alertcooldown, 10 SECONDS)
				owner.adjust_hallucinations(20 SECONDS)
				owner.adjustFireLoss(1)
			if(50 to 100)
				if(COOLDOWN_FINISHED(src, alertcooldown) || !hasexerted)
					to_chat(owner, span_userdanger("Your spine and brain feel like they're burning!"))
					COOLDOWN_START(src, alertcooldown, 5 SECONDS)
				hasexerted = TRUE
				owner.set_drugginess(2 SECONDS)
				owner.adjust_hallucinations(20 SECONDS)
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
	if(!syndicate_implant)//the toy has a different emp act
		owner.adjust_dizzy(severity SECONDS)
		to_chat(owner, span_warning("Your spinal implant makes you feel queasy!"))
		return

	owner.set_drugginess(4 * severity)
	owner.adjust_hallucinations((50 * severity) SECONDS)
	owner.adjust_eye_blur(2 * severity)
	owner.adjust_dizzy(severity SECONDS)
	time_on += severity
	owner.adjustFireLoss(severity)
	to_chat(owner, span_warning("Your spinal implant malfunctions and you feel it scramble your brain!"))

/obj/item/organ/cyberimp/chest/spinalspeed/toy
	name = "glowy after-image trail implant"
	desc = "Donk Co's first forray into the world of entertainment implants. Projects a series of after-images as you move, perfect for starting a dance party all on your own."
	syndicate_implant = FALSE

/obj/item/organ/cyberimp/chest/cooling_intake
	name = "cooling intake"
	desc = "An external port that can intake air from the environment or coolant from a tank."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
