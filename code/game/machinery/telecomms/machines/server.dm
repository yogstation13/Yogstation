/*
	The server logs all traffic and signal data. Once it records the signal, it sends
	it to the subspace broadcaster.

	Store a maximum of some hundreds of logs and then deletes them.
*/

/obj/machinery/telecomms/server
	name = "telecommunication server"
	icon_state = "server"
	desc = "A machine used to store data and network statistics."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	circuit = /obj/item/circuitboard/machine/telecomms/server
	var/list/log_entries = list()
	var/totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)

/obj/machinery/telecomms/server/Initialize(mapload)
	. = ..()

/obj/machinery/telecomms/server/receive_information(datum/signal/subspace/vocal/signal, obj/machinery/telecomms/machine_from)
	// can't log non-vocal signals
	if(!istype(signal) || !signal.data["message"] || !is_freq_listening(signal))
		return

	if(traffic > 0)
		totaltraffic += traffic // add current traffic to total traffic

	// Delete particularly old logs
	if (log_entries.len >= SERVER_LOG_STORAGE_MAX)
		log_entries.Cut(1, 2)

	signal.data["server"] = src; //Yogs

	var/datum/comm_log_entry/log = new
	log.parameters["mobtype"] = signal.virt.source.type
	log.parameters["language"] = signal.language

	// If the signal is still compressed, make the log entry gibberish
	var/compression = signal.data["compression"]
	if(compression > 0 || (obj_flags & EMAGGED))
		log.input_type = "Corrupt File"
		log.parameters["name"] = Gibberish(signal.data["name"], compression + 50)
		log.parameters["job"] = Gibberish(signal.data["job"], compression + 50)
		log.parameters["message"] = Gibberish(signal.data["message"], compression + 50)
	else	// yogs start
		log.parameters["name"] = signal.data["name"]
		log.parameters["job"] = signal.data["job"]
		log.parameters["message"] = signal.data["message"]// yogs end

	// Give the log a name and store it
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "data packet ([md5(identifier)])"
	log_entries.Add(log)

	if(Compiler && autoruncode)//Yogs -- NTSL
		Compiler.Run(signal)// Yogs -- ditto

	if(!relay_information(signal, /obj/machinery/telecomms/hub)) //yogs
		relay_information(signal, /obj/machinery/telecomms/broadcaster)


// Simple log entry datum
/datum/comm_log_entry // Simple log entry datum
	var/input_type = "Speech File"
	var/name = "data packet (#)"
	var/parameters = list()  // copied from signal.data above


// Preset Servers
/obj/machinery/telecomms/server/presets
	network = "tcommsat"

/obj/machinery/telecomms/server/presets/Initialize(mapload)
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
/obj/machinery/telecomms/server/presets/common/Initialize(mapload)
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

/obj/machinery/telecomms/server/presets/common/birdstation/Initialize(mapload)
	. = ..()
	freq_listening = list()
