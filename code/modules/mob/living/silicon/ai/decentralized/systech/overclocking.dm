#define OVERCLOCKING_DURATION (5 SECONDS)

/obj/machinery/computer/ai_overclocking
	name = "overclocking workstation"
	desc = "Used for overclocking neural processing units."

	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	circuit = /obj/item/circuitboard/computer/ai_server_overview

	var/obj/item/ai_cpu/inserted_cpu = null
	var/overclocking = FALSE

	COOLDOWN_DECLARE(overclocking_timer)

/obj/machinery/computer/ai_overclocking/process()
	if(!..())
		if(inserted_cpu)
			inserted_cpu.forceMove(drop_location(src))
			overclocking = FALSE
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			inserted_cpu.last_overclocking_values += list(list("speed" = inserted_cpu.speed, "power" = inserted_cpu.power_multiplier, "valid" = FALSE))
			inserted_cpu = null
		return

	if(overclocking && COOLDOWN_FINISHED(src, overclocking_timer))
		overclocking = FALSE
		if(!inserted_cpu)
			return
		var/overclock_result = inserted_cpu.valid_overclock()
		if(overclock_result == SUCCESSFUL_OVERCLOCK)
			say("Overclock stable.")
			if(inserted_cpu.last_overclocking_values.len + 1 >= 6)
				pop(inserted_cpu.last_overclocking_values)
			inserted_cpu.last_overclocking_values += list(list("speed" = inserted_cpu.speed, "power" = inserted_cpu.power_multiplier, "valid" = TRUE))
			inserted_cpu.forceMove(drop_location(src))
			inserted_cpu = null
		else
			if(inserted_cpu.last_overclocking_values.len + 1 >= 6)
				pop(inserted_cpu.last_overclocking_values)
			say("Unstable overclock.")
			say("Possible reason: [overclock_result]")
			inserted_cpu.last_overclocking_values += list(list("speed" = inserted_cpu.speed, "power" = inserted_cpu.power_multiplier, "valid" = FALSE))
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)

/obj/machinery/computer/ai_overclocking/Destroy()
	if(inserted_cpu)
		inserted_cpu.speed = initial(inserted_cpu.speed)
		inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
	. = ..()

/obj/machinery/computer/ai_overclocking/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ai_cpu))
		if(inserted_cpu)
			to_chat(user, span_warning("There's already a CPU inserted!"))
			return ..()
		var/obj/item/ai_cpu/CPU = I
		inserted_cpu = CPU
		CPU.forceMove(src)
		return FALSE
	
	return ..()


/obj/machinery/computer/ai_overclocking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiOverclocking", name)
		ui.open()

/obj/machinery/computer/ai_overclocking/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["has_cpu"] = inserted_cpu
	data["overclocking"] = overclocking

	if(inserted_cpu)
		data["speed"] = inserted_cpu.speed
		data["power_multiplier"] = inserted_cpu.power_multiplier
		data["power_usage"] = inserted_cpu.get_power_usage()
		var/time_left_percent = COOLDOWN_TIMELEFT(src, overclocking_timer)/OVERCLOCKING_DURATION
		data["overclock_progress"] = overclocking ? time_left_percent : FALSE
		data["last_values"] = inserted_cpu.last_overclocking_values
		

	return data


/obj/machinery/computer/ai_overclocking/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("eject_cpu")
			if(!inserted_cpu)
				return
			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			inserted_cpu.forceMove(drop_location(src))
			inserted_cpu = null
			. = TRUE
		if("set_speed")
			if(!inserted_cpu)
				return
			var/new_speed = params["new_speed"]
			if(!isnum(new_speed))
				return
			inserted_cpu.speed = new_speed
			. = TRUE
		if("set_power")
			if(!inserted_cpu)
				return
			var/new_power = params["new_power"]
			if(!isnum(new_power))
				return
			inserted_cpu.power_multiplier = new_power
			. = TRUE 

		if("test_overclock")
			if(!inserted_cpu)
				return
			overclocking = TRUE
			COOLDOWN_START(src, overclocking_timer, OVERCLOCKING_DURATION)
			. = TRUE

		if("stop_overclock")
			if(!inserted_cpu || !overclocking)
				return
			overclocking = FALSE

			inserted_cpu.speed = initial(inserted_cpu.speed)
			inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)
			. = TRUE
			