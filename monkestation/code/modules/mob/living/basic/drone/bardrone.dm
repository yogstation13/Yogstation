/obj/effect/mob_spawn/ghost_role/drone/bar
	name = "bardrone shell"
	desc = "A modified shell of a maintenance drone, an nonexpendable robot built to serve drinks and chat."
	icon = 'icons/mob/silicon/drone.dmi'
	icon_state = "drone_maint_hat"
	mob_name = "Bardrone"
	mob_type = /mob/living/basic/drone/snowflake/bardrone
	anchored = TRUE
	prompt_name = "bardrone"
	you_are_text = "You are a Bardrone."
	flavour_text = "Born out of drunk science, your purpose is to keep the drinks flowing on the station and comfort the patrons with their issues, not solve them."
	important_text = "You MUST read and follow your laws carefully."
	spawner_job_path = /datum/job/bar_drone

/obj/effect/mob_spawn/ghost_role/drone/bar/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	if(area)
		notify_ghosts(
			"A bardrone shell has been created in \the [area.name].",
			source = src,
			action = NOTIFY_PLAY,
			notify_flags = (GHOST_NOTIFY_IGNORE_MAPLOAD),
			ignore_key = POLL_IGNORE_DRONE,
		)

/obj/effect/mob_spawn/ghost_role/drone/bar/allow_spawn(mob/user, silent = FALSE)
	var/client/user_client = user.client
	var/mob/living/basic/drone/drone_type = mob_type
	if(!initial(drone_type.shy) || isnull(user_client) || !CONFIG_GET(flag/use_exp_restrictions_other))
		return ..()
	var/required_role = CONFIG_GET(string/drone_required_role)
	var/required_playtime = CONFIG_GET(number/drone_role_playtime) * 60
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights_for(user.client, R_ADMIN))
		return ..()
	if(user?.client?.prefs.db_flags & DB_FLAG_EXEMPT)
		return ..()
	if(required_playtime <= 0)
		return ..()
	var/current_playtime = user_client?.calc_exp_type(required_role)
	if (current_playtime < required_playtime)
		var/minutes_left = required_playtime - current_playtime
		var/playtime_left = DisplayTimeText(minutes_left * (1 MINUTES))
		if(!silent)
			to_chat(user, span_danger("You need to play [playtime_left] more as [required_role] to spawn as a Bardrone!"))
		return FALSE
	return ..()

/datum/action/drone/bar/information //sets up action button datum for the button itself
	name = "Bar Drone Information"
	desc = "Shows information and laws for the Bar Drone."
	button_icon = 'monkestation/code/modules/veth_misc_items/bardrone/sillybardrone.dmi'
	button_icon_state = "silly_bardrone"

/datum/action/drone/bar/information/Trigger(trigger_flags) //what happens when the button is pressed
	var/datum/drone/bar/information/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/drone/bar/information //datum required for the tgui component

/datum/drone/bar/information/ui_close()
	qdel(src)

/datum/drone/bar/information/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BarDrone")
		ui.open()

/datum/drone/bar/information/ui_state(mob/user) //should always be accessible, only inherited by bardrone anyway
	return GLOB.always_state

/mob/living/basic/drone/snowflake/bardrone/Initialize(mapload) //initialization of the action button onto the linked mob (only bardrones)
	. = ..()
	for (var/action_type in actions_to_add)
		var/datum/action/new_action = new action_type(src)
		new_action.Grant(src)

/mob/living/basic/drone/snowflake/bardrone/Login() //force open the tgui window with laws on login to the bardrone mob.
	..()
	var/datum/drone/bar/information/tgui = new(usr)
	tgui.ui_interact(usr)
