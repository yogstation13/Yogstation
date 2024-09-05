/datum/ai_behavior/perform_speech/parrot/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	controller.behavior_cooldowns[src] = world.time + rand(45 SECONDS, 3 MINUTES) // Prevents Poly from being too yappy
	. = ..()
