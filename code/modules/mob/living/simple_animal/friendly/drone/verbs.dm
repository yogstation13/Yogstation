
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons

/**
  * Echoes drone laws to the user
  *
  * See [/mob/living/simple_animal/drone/var/laws]
  */
/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	to_chat(src, "<b>Drone Laws</b>")
	to_chat (src, "[laws]")

/**
  * Creates an alert to drones in the same network
  *
  * Prompts user for alert level of:
  * * Low
  * * Medium
  * * High
  * * Critical
  *
  * Attaches area name to message
  */
/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>DRONE PING: [name]: [alert_s] priority alert in [A.name]!</span>"
		alert_drones(msg)

/mob/living/simple_animal/drone/verb/cmd_robot_alerts()
	set category = "Drone"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, "<span class='userdanger'>Alert: You are dead.</span>")
		return //won't work if dead
	robot_alerts()

/mob/living/simple_animal/drone/proc/robot_alerts()
	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				dat += "<span style=\"white-space: nowrap;\">"
				dat += "-- [A.name]"
				dat += "</span><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	alerts.set_content(dat)
	alerts.open()