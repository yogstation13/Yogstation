/obj/machinery/nanite_programmer
	name = "nanite programmer"
	desc = "A device that can edit nanite program disks to adjust their functionality."
	var/obj/item/disk/nanite_program/disk
	var/datum/nanite_program/program
	circuit = /obj/item/circuitboard/machine/nanite_programmer
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_programmer"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE

/obj/machinery/nanite_programmer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(disk)
			eject(user)
		if(user.transferItemToLoc(N, src))
			to_chat(user, "<span class='notice'>You insert [N] into [src]</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			disk = N
			program = N.program
	else
		..()

/obj/machinery/nanite_programmer/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null
	program = null

/obj/machinery/nanite_programmer/AltClick(mob/user)
	if(disk && user.canUseTopic(src, !issilicon(user)))
		to_chat(user, "<span class='notice'>You take out [disk] from [src].</span>")
		eject(user)
	return

/obj/machinery/nanite_programmer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteProgrammer", name)
		ui.open()

/obj/machinery/nanite_programmer/ui_data()
	var/list/data = list()
	data["has_disk"] = istype(disk)
	data["has_program"] = istype(program)
	if(program)
		data["name"] = program.name
		data["desc"] = program.desc
		data["use_rate"] = program.use_rate
		data["can_trigger"] = program.can_trigger
		data["trigger_cost"] = program.trigger_cost
		data["trigger_cooldown"] = program.trigger_cooldown / 10

		data["activated"] = program.activated
		data["activation_delay"] = program.activation_delay
		data["timer"] = program.timer
		data["activation_code"] = program.activation_code
		data["deactivation_code"] = program.deactivation_code
		data["kill_code"] = program.kill_code
		data["trigger_code"] = program.trigger_code
		data["timer_type"] = program.get_timer_type_text()

		var/list/extra_settings = list()
		for(var/X in program.extra_settings)
			var/list/setting = list()
			setting["name"] = X
			setting["value"] = program.get_extra_setting(X)
			extra_settings += list(setting)
		data["extra_settings"] = extra_settings
		if(LAZYLEN(extra_settings))
			data["has_extra_settings"] = TRUE

	return data

/obj/machinery/nanite_programmer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			eject(usr)
			. = TRUE
		if("toggle_active")
			playsound(src, "terminal_type", 25, 0)
			program.activated = !program.activated //we don't use the activation procs since we aren't in a mob
			if(program.activated)
				program.activation_delay = 0
			. = TRUE
		if("set_code")
			var/new_code = text2num(params["code"])

			if(!isnull(new_code))
				playsound(src, "terminal_type", 25, 0)
				new_code = clamp(round(new_code, 1),0,9999)
			else
				return

			playsound(src, "terminal_type", 25, 0)
			var/target_code = params["target_code"]
			switch(target_code)
				if("activation")
					program.activation_code = clamp(round(new_code, 1),0,9999)
				if("deactivation")
					program.deactivation_code = clamp(round(new_code, 1),0,9999)
				if("kill")
					program.kill_code = clamp(round(new_code, 1),0,9999)
				if("trigger")
					program.trigger_code = clamp(round(new_code, 1),0,9999)
			. = TRUE
		if("set_extra_setting")
			program.set_extra_setting(usr, params["target_setting"])
			playsound(src, "terminal_type", 25, 0)
			. = TRUE
		if("set_activation_delay")
			var/delay = params["delay"]

			if(!isnull(delay))
				playsound(src, "terminal_type", 25, 0)
				delay = clamp(round(delay, 1),0,1800)
				program.activation_delay = delay
				if(delay)
					program.activated = FALSE
			. = TRUE
		if("set_timer")
			var/timer = text2num(params["timer"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, 0)
				if(!timer == 0)
					timer = clamp(round(timer, 1),10,3600)
				program.timer = timer
			. = TRUE
		if("set_timer_type")
			var/new_type = input("Choose the timer effect","Timer Effect") as null|anything in list("Deactivate","Self-Delete","Trigger","Reset Activation Timer")
			if(new_type)
				playsound(src, "terminal_type", 25, 0)
				switch(new_type)
					if("Deactivate")
						program.timer_type = NANITE_TIMER_DEACTIVATE
					if("Self-Delete")
						program.timer_type = NANITE_TIMER_SELFDELETE
					if("Trigger")
						program.timer_type = NANITE_TIMER_TRIGGER
					if("Reset Activation Timer")
						program.timer_type = NANITE_TIMER_RESET
			. = TRUE
