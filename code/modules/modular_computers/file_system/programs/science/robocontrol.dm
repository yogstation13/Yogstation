
/datum/computer_file/program/robocontrol
	filename = "robocontrol"
	filedesc = "Bot Remote Controller"
	category = PROGRAM_CATEGORY_SCI
	program_icon_state = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	requires_ntnet = TRUE
	network_destination = "robotics control network"
	size = 12
	tgui_id = "NtosRoboControl"
	program_icon = "robot"

	///Number of simple robots on-station.
	var/botcount = 0
	///Used to find the location of the user for the purposes of summoning robots.
	var/mob/current_user
	///Access granted by the used to summon robots.
	var/list/current_access = list()

/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/current_turf = get_turf(ui_host())
	var/zlevel = current_turf.z
	var/list/botlist = list()
	var/list/mulelist = list()

	if(computer)
		data["id_owner"] = computer.computer_id_slot || ""

	botcount = 0
	current_user = user

	for(var/B in GLOB.bots_list)
		var/mob/living/simple_animal/bot/Bot = B
		if(Bot.z != zlevel || Bot.remote_disabled || !Bot.bot_core.check_access(computer))
			continue //Only non-emagged bots on the same Z-level are detected! Also, the PDA must have access to the bot type.
		var/list/newbot = list("name" = Bot.name, "mode" = Bot.get_mode_ui(), "model" = Bot.model, "locat" = get_area(Bot), "bot_ref" = REF(Bot), "mule_check" = FALSE, "enabled" = Bot.on)
		if(Bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/MULE = Bot
			mulelist += list(list("name" = MULE.name, "dest" = MULE.destination, "power" = MULE.cell ? MULE.cell.percent() : 0, "home" = MULE.home_destination, "autoReturn" = MULE.auto_return, "autoPickup" = MULE.auto_pickup, "reportDelivery" = MULE.report_delivery, "mule_ref" = REF(MULE)))
			if(MULE.load)
				data["load"] = MULE.load.name
			newbot["mule_check"] = TRUE
		botlist += list(newbot)

	data["bots"] = botlist
	data["mules"] = mulelist
	data["botcount"] = botlist.len

	return data

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	if(..())
		return TRUE
	var/obj/item/card/id/inserted_id = computer?.computer_id_slot

	var/list/standard_actions = list("patroloff", "patrolon", "ejectpai")
	var/list/MULE_actions = list("stop", "go", "home", "destination", "setid", "sethome", "unload", "autoret", "autopick", "report", "ejectpai")
	var/mob/living/simple_animal/bot/Bot = locate(params["robot"]) in GLOB.bots_list
	if (action in standard_actions)
		Bot.bot_control(action, current_user, current_access)
	if (action in MULE_actions)
		Bot.bot_control(action, current_user, current_access, TRUE)
	switch(action)
		if("toggle")
			if(Bot.on)
				Bot.turn_off()
			else
				Bot.turn_on()
		if("summon")
			Bot.bot_control(action, current_user, inserted_id ? inserted_id.access : current_access)
		if("ejectcard")
			if(!computer || !computer.computer_id_slot)
				return
			if(inserted_id)
				GLOB.data_core.manifest_modify(inserted_id.registered_name, inserted_id.assignment)
				computer.RemoveID(usr)
			else
				playsound(get_turf(ui_host()) , 'sound/machines/buzz-sigh.ogg', 25, FALSE)
	return
