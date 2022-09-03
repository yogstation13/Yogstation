/datum/status_effect/toxic_buildup
	id = "toxic_buildup"
	duration = -1 // we handle this ourselves
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /obj/screen/alert/status_effect/toxic_buildup
	var/stack = 0
	var/max_stack = 4
	var/stack_decay_time = 1 MINUTES
	var/current_stack_decay = 0

/datum/status_effect/toxic_buildup/on_creation(mob/living/new_owner, ...)
	. = ..()
	update_stack(1)

/datum/status_effect/toxic_buildup/tick()
	current_stack_decay += initial(tick_interval)
	if(current_stack_decay >= stack_decay_time)
		current_stack_decay = 0
		on_stack_decay()
		update_stack(-1)
		if(stack <= 0)
			qdel(src)
			return

	if(!ishuman(owner))
		return 
	var/mob/living/carbon/human/human_owner = owner	

	if(prob(10))
		to_chat(human_owner,span_alert("The toxins run a course through your veins, you feel sick."))	
		human_owner.adjust_disgust(5)

	switch(stack)
		if(1)
			human_owner.adjustToxLoss(0.1)
		if(2)
			human_owner.adjustToxLoss(0.25)
			if(prob(1))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS
		if(3)
			human_owner.adjustToxLoss(0.5)
			if(prob(2))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS
		if(4)
			human_owner.adjustToxLoss(1)
			if(prob(5))
				human_owner.vomit()
				current_stack_decay += 5 SECONDS


/datum/status_effect/toxic_buildup/proc/on_stack_decay()
	if(!ishuman(owner))
		return 
	var/mob/living/carbon/human/human_owner = owner	

	switch(stack)
		if(1)
			human_owner.adjustStaminaLoss(75)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(2)
			human_owner.Jitter(1)
			human_owner.adjustStaminaLoss(150)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(3)
			human_owner.Jitter(1)
			human_owner.Dizzy(1)
			human_owner.adjustStaminaLoss(300)
			human_owner.Paralyze(3 SECONDS)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,10)
		if(4)
			human_owner.adjust_blurriness(0.5)
			human_owner.Dizzy(1)
			human_owner.Jitter(1)
			human_owner.adjustStaminaLoss(450)
			human_owner.Sleeping(5 SECONDS)
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER,20)

/datum/status_effect/toxic_buildup/proc/cure()
	to_chat(owner,span_alert("The toxins are washed away from your body, you feel better."))
	qdel(src)

/datum/status_effect/toxic_buildup/proc/update_stack(amt)
	stack = min(stack + amt,max_stack)
	linked_alert = owner.throw_alert(id,alert_type,stack)

/datum/status_effect/toxic_buildup/refresh()
	update_stack(1)
	current_stack_decay = 0

/obj/screen/alert/status_effect/toxic_buildup
	name = "Toxic buildup"
	desc = "Toxins have built up in your system, they cause sustained toxin damage, and once they leave your system cause additional harm as your bodies adjustments to the toxicity backfire."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "toxic_buildup"

/obj/screen/alert/status_effect/tar_curse
	name = "Curse of Tar"
	desc = "You've been cursed by the tar priest, next attack by any tar monster will cause more damage and may have additional effects."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "tar_curse"

/datum/status_effect/tar_curse
	id = "tar_curse"
	duration = 60 SECONDS// we handle this ourselves
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /obj/screen/alert/status_effect/tar_curse


/datum/status_effect/tar_curse/on_apply()
	. = ..()
	RegisterSignal(owner,COMSIG_JUNGLELAND_TAR_CURSE_PROC,.proc/curse_used)

/datum/status_effect/tar_curse/proc/curse_used()
	qdel(src)
