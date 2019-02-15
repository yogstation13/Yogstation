/obj/item/radio/server

/obj/item/radio/server/can_receive(frequency,levels)
	return FALSE // The server's radio isn't for receiving, it's for outputting. For now.
	
/obj/machinery/telecomms/server
	//NTSL-related stuffs
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = FALSE		// 1 if the code is set to run every time a signal is picked up
	var/list/memory = list()	// stored memory, for mem() in NTSL
	var/rawcode = ""	// the code to compile (raw-ass text)
	var/obj/item/radio/server/server_radio // Allows the server to talk on the radio, via broadcast() in NTSL
	var/last_signal = 0 // Marks the last time an NTSL script called signal() from this server, to stop spam.
	//End-NTSL
	
//NTSL-related procs
/obj/machinery/telecomms/server/Initialize()
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()
	. = ..()

/obj/machinery/telecomms/server/proc/update_logs()
	if(log_entries.len >= 400) // If so, start deleting at least, hopefully, one log entry
		log_entries.Cut(1, 2)
	/*
		for(var/i = 1, i <= log_entries.len, i++) // locate the first garbage collectable log entry and remove it
			var/datum/comm_log_entry/L = log_entries[i]
			if(L.garbage_collector)
				log_entries.Remove(L)
				break
	*/

/obj/machinery/telecomms/server/proc/add_entry(content, input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "[input] ([md5(identifier)])"
	log.input_type = input
	log.parameters["message"] = content
	log_entries.Add(log)
	update_logs()


/obj/machinery/telecomms/server/proc/setcode(t)
	if(t)
		if(istext(t))
			rawcode = t
/obj/machinery/telecomms/server/proc/compile(mob/user = usr)
	if(is_banned_from(user.ckey, "Signal Technician"))
		to_chat(user, "<span class='warning'>You are banned from using NTSL.</span>")
		return
	if(Compiler)
		return Compiler.Compile(rawcode)
//end-NTSL
