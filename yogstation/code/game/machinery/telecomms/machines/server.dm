/obj/item/radio/server

/obj/item/radio/server/can_receive(frequency,levels)
	return FALSE // The server's radio isn't for receiving, it's for outputting. For now.

/obj/machinery/telecomms/server
	//Joao-related stuffs
	var/autoruncode = FALSE		// 1 if the code is set to run every time a signal is picked up
	var/list/memory = list()	// stored memory, for mem() in NTSL
	var/codestr = ""	// the code to compile (raw-ass text)
	var/obj/item/radio/server/server_radio // Allows the server to talk on the radio, via broadcast() in NTSL
	var/last_signal = 0 // Marks the last time an NTSL script called signal() from this server, to stop spam.
	var/list/compile_warnings = list()
	//End-Joao

//Joao-related procs
/obj/machinery/telecomms/server/Initialize()
	server_radio = new()
	. = ..()

/obj/machinery/telecomms/server/proc/update_logs()
	if(log_entries.len >= 400) // If so, start deleting at least, hopefully, one log entry
		log_entries.Cut(1, 2)

/obj/machinery/telecomms/server/proc/add_entry(content, input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "[input] ([md5(identifier)])"
	log.input_type = input
	log.parameters["message"] = content
	log_entries.Add(log)
	update_logs()


/obj/machinery/telecomms/server/proc/setcode(t)
	if(t && istext(t))
		codestr = t
//end-Joao
