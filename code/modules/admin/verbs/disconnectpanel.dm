GLOBAL_LIST_EMPTY(connection_logs)

/datum/connection_log
	var/datum/connection_entry/last_data_point
	var/first_login
	var/list/datum/connection_log/data_points = list()

/datum/connection_log/New()
	first_login = world.time

/datum/connection_log/proc/logout(mob/C)
	var/datum/connection_entry/CE = new()
	CE.disconnected = world.time
	CE.disconnect_type = C.type
	last_data_point = CE
	data_points |= CE

/datum/connection_log/proc/login()
	if(last_data_point)
		last_data_point.connected = world.time

/datum/connection_entry
	var/disconnected
	var/connected
	var/disconnect_type
