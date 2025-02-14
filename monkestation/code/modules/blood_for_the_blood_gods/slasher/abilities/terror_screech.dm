/datum/action/cooldown/slasher/terror
	name = "Screech of Terror"
	desc = "Inflict near paralyzing fear to those already scared of you."
	button_icon_state = "stagger_group"

	cooldown_time = 45 SECONDS


/datum/action/cooldown/slasher/terror/Activate(atom/target)
	. = ..()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	playsound(owner, 'monkestation/sound/voice/terror.ogg', 100, falloff_exponent = 0, use_reverb = FALSE)
	var/datum/antagonist/slasher/slasher = owner.mind.has_antag_datum(/datum/antagonist/slasher)

	for(var/mob/living/carbon/human/human_resolved in view(7, owner))
		if(human_resolved == owner)
			continue
		human_resolved.overlay_fullscreen("terror", /atom/movable/screen/fullscreen/curse, 1)
		human_resolved.emote("scream")
		var/stage = slasher.fear_stages[human_resolved]
		var/fear_amount = (15 - get_dist(owner, human_resolved))
		slasherdatum.increase_fear(human_resolved, fear_amount)

		if(stage >= 1)
			human_resolved.Shake(duration = 7.5 SECONDS)
			human_resolved.stamina.adjust(-80)
			human_resolved.SetParalyzed(2 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(remove_overlay), human_resolved), 7.5 SECONDS)

		if(stage >= 2)
			human_resolved.Shake(duration = 10 SECONDS)
			human_resolved.stamina.adjust(-100)
			human_resolved.SetParalyzed(2.5 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(remove_overlay), human_resolved), 5 SECONDS)

		if(stage >= 3)
			human_resolved.Shake(duration = 12.5 SECONDS)
			human_resolved.stamina.adjust(-120)
			human_resolved.SetParalyzed(3 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(remove_overlay), human_resolved), 5 SECONDS)

		if(stage >= 4)
			human_resolved.Shake(duration = 15 SECONDS)
			human_resolved.stamina.adjust(-140)
			human_resolved.SetParalyzed(4 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(remove_overlay), human_resolved), 5 SECONDS)

		else
			human_resolved.Shake(duration = 5 SECONDS)
			human_resolved.stamina.adjust(-60)
			human_resolved.SetParalyzed(1.5 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(remove_overlay), human_resolved), 5 SECONDS)


	for(var/obj/machinery/light/light in view(7, owner))
		light.break_light_tube()


/datum/action/cooldown/slasher/terror/proc/remove_overlay(mob/living/carbon/human/remover)
	remover.clear_fullscreen("terror", 10)
