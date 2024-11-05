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
