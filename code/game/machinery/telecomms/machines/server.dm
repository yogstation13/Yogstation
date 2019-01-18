/*
	The server logs all traffic and signal data. Once it records the signal, it sends
	it to the subspace broadcaster.

	Store a maximum of 100 logs and then deletes them.
*/

/obj/machinery/telecomms/server
	name = "telecommunication server"
	icon_state = "comm_server"
	desc = "A machine used to store data and network statistics."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	circuit = /obj/item/circuitboard/machine/telecomms/server
	var/list/log_entries = list()
	var/totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)
	
//NTSL-related stuffs
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = FALSE		// 1 if the code is set to run every time a signal is picked up
	var/list/memory = list()	// stored memory, for mem() in NTSL
	var/rawcode = ""	// the code to compile (raw-ass text)
	var/obj/item/radio/headset/server_radio // Allows the server to talk on the radio, via broadcast() in NTSL
	var/last_signal = 0 // Marks the last time an NTSL script called signal() from this server, to stop spam.
//End-NTSL

/obj/machinery/telecomms/server/Initialize()
	Compiler = new()
	Compiler.Holder = src
	server_radio = new()
	. = ..()

/obj/machinery/telecomms/server/receive_information(datum/signal/subspace/vocal/signal, obj/machinery/telecomms/machine_from)
	// can't log non-vocal signals
	if(!istype(signal) || !signal.data["message"] || !is_freq_listening(signal))
		return

	if(traffic > 0)
		totaltraffic += traffic // add current traffic to total traffic

	// Delete particularly old logs
	if (log_entries.len >= 400)
		log_entries.Cut(1, 2)

	var/datum/comm_log_entry/log = new
	log.parameters["mobtype"] = signal.virt.source.type
	log.parameters["name"] = signal.data["name"]
	log.parameters["job"] = signal.data["job"]
	log.parameters["message"] = signal.data["message"]
	log.parameters["language"] = signal.language

	// If the signal is still compressed, make the log entry gibberish
	var/compression = signal.data["compression"]
	if(compression > 0)
		log.input_type = "Corrupt File"
		log.parameters["name"] = Gibberish(signal.data["name"], compression + 50)
		log.parameters["job"] = Gibberish(signal.data["job"], compression + 50)
		log.parameters["message"] = Gibberish(signal.data["message"], compression + 50)

	// Give the log a name and store it
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "data packet ([md5(identifier)])"
	log_entries.Add(log)

	if(Compiler && autoruncode)
		Compiler.Run(signal)
	var/can_send = relay_information(signal, /obj/machinery/telecomms/hub)
	if(!can_send)
		relay_information(signal, /obj/machinery/telecomms/broadcaster)



//NTSL procs
/datum/comm_log_entry // Simple log entry datum
	var/input_type = "Speech File"
	var/name = "data packet (#)"
	var/parameters = list()  // copied from signal.data above
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



// Preset Servers
/obj/machinery/telecomms/server/presets
	network = "tcommsat"

/obj/machinery/telecomms/server/presets/Initialize()
	. = ..()
	name = id


/obj/machinery/telecomms/server/presets/science
	id = "Science Server"
	freq_listening = list(FREQ_SCIENCE)
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	freq_listening = list(FREQ_MEDICAL)
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/supply
	id = "Supply Server"
	freq_listening = list(FREQ_SUPPLY)
	autolinkers = list("supply")

/obj/machinery/telecomms/server/presets/service
	id = "Service Server"
	freq_listening = list(FREQ_SERVICE)
	autolinkers = list("service")

/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	freq_listening = list()
	autolinkers = list("common")

//Common and other radio frequencies for people to freely use
/obj/machinery/telecomms/server/presets/common/Initialize()
	. = ..()
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(FREQ_COMMAND)
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(FREQ_ENGINEERING)
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/security
	id = "Security Server"
	freq_listening = list(FREQ_SECURITY)
	autolinkers = list("security")

/obj/machinery/telecomms/server/presets/common/birdstation/Initialize()
	. = ..()
	freq_listening = list()
