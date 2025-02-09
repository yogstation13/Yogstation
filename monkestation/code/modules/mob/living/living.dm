// This adds extra overhead to getting `lying_angle` directly but doing so upsets SpacemanDMM as it's set to protected
/mob/living/proc/get_lying_angle()
	return lying_angle

/// Comprehensively resets every single hunger thing the mob could possibly have from alerts to obesity. At least ideally it does.
/mob/living/proc/reset_hunger()
	// Reset all the funny variables.
	set_nutrition(NUTRITION_LEVEL_FED)
	metabolism_efficiency = 1
	overeatduration = 0
	satiety = 0

	// And then undo a couple effects.
	remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
	REMOVE_TRAIT(src, TRAIT_FAT, OBESITY)
	clear_alert(ALERT_NUTRITION)
