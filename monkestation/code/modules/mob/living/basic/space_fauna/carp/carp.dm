/mob/living/basic/carp/on_tamed(mob/tamer, feedback = TRUE)
	. = ..()
	ai_controller?.change_ai_movement_type(/datum/ai_movement/jps)
