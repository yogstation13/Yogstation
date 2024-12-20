/datum/physiology
	///our temp stamina mod
	var/temp_stamina_mod = 1

/datum/status_effect/stacking/debilitated
	id = "debilitated"
	stacks = 0
	max_stacks = 20
	tick_interval = 5 SECONDS
	delay_before_decay = 30 SECONDS
	consumed_on_threshold = FALSE
	alert_type = /atom/movable/screen/alert/status_effect/debilitated
	status_type = STATUS_EFFECT_REFRESH

	///our base stamina loss multiplier
	var/loss_multiplier = 1
	///our per stack increase to stamina loss
	var/per_stack_multiplier_increase = 0.05

/datum/status_effect/stacking/debilitated/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.physiology.temp_stamina_mod = loss_multiplier + (stacks * per_stack_multiplier_increase)

/datum/status_effect/stacking/debilitated/add_stacks(stacks_added)
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human = owner
	human.physiology.temp_stamina_mod = loss_multiplier + (stacks * per_stack_multiplier_increase)

/atom/movable/screen/alert/status_effect/debilitated
	icon_state = "debilitated"
	name = "Debilitated"
	desc = "You are taking extra stamina damage from incoming projectiles, and lose stamina faster."
