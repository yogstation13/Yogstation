/atom/movable/screen/alert/status_effect/food/food_poisoning
	name = "Food Poisoning"
	desc = "Suffering from food Poisoning"
	icon_state = "gross2"

/datum/status_effect/food/food_poisoning
	duration = 1.5 MINUTES
	id = "food_poisoning"
	alert_type = /atom/movable/screen/alert/status_effect/food/food_poisoning
	var/min_vomit_processes = 5

/datum/status_effect/food/food_poisoning/tick(seconds_per_tick, times_fired)
	. = ..()
	owner.adjust_hallucinations(0.5 SECONDS)
	owner.adjust_drugginess(0.75 SECONDS)
	if(prob(20) && min_vomit_processes <= 0)
		owner.vomit(4, FALSE, FALSE)
		min_vomit_processes = 5
	min_vomit_processes--
