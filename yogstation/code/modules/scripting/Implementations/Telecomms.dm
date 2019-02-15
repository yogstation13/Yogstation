//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl, ported to Yogs by Altoids

#define HUMAN 1
#define MONKEY 2
#define ALIEN 4
#define ROBOT 8
#define SLIME 16
#define DRONE 32
GLOBAL_LIST_INIT(allowed_custom_spans,list(SPAN_ROBOT,SPAN_YELL,SPAN_ITALICS,SPAN_SANS,SPAN_COMMAND,SPAN_CLOWN))//Span classes that players are allowed to set in a radio transmission.

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

	GC()
		..()
		Compiler = null


/datum/TCS_Compiler
	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/telecomms/server/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Set ourselves to Garbage Collect -- */

/datum/TCS_Compiler/proc/GC()
	Holder = null
	if(interpreter)
		interpreter.GC()


	/* -- Compile a raw block of text -- */

/datum/TCS_Compiler/proc/Compile(code as message)
	var/n_scriptOptions/nS_Options/options = new()
	var/n_Scanner/nS_Scanner/scanner       = new(code, options)
	var/list/tokens                        = scanner.Scan()
	var/n_Parser/nS_Parser/parser          = new(tokens, options)
	var/node/BlockDefinition/GlobalBlock/program   	 = parser.Parse()

	var/list/returnerrors = list()

	returnerrors += scanner.errors
	returnerrors += parser.errors

	if(returnerrors.len)
		return returnerrors

	interpreter 		= new(program)
	interpreter.persist	= 1
	interpreter.Compiler= src
	interpreter.container = src

	interpreter.SetVar("PI"		, 	3.141592653)	// value of pi
	interpreter.SetVar("E" 		, 	2.718281828)	// value of e
	interpreter.SetVar("SQURT2" , 	1.414213562)	// value of the square root of 2
	interpreter.SetVar("FALSE"  , 	0)				// boolean shortcut to 0
	interpreter.SetVar("false"  , 	0)				// boolean shortcut to 0
	interpreter.SetVar("TRUE"	,	1)				// boolean shortcut to 1
	interpreter.SetVar("true"	,	1)				// boolean shortcut to 1

	interpreter.SetVar("NORTH" 	, 	NORTH)			// NORTH (1)
	interpreter.SetVar("SOUTH" 	, 	SOUTH)			// SOUTH (2)
	interpreter.SetVar("EAST" 	, 	EAST)			// EAST  (4)
	interpreter.SetVar("WEST" 	, 	WEST)			// WEST  (8)

	// Channel macros
	interpreter.SetVar("channels", new /datum/n_enum(list(
		"common" = 1459,
		"science" = 1351,
		"command" = 1353,
		"medical" = 1355,
		"engineering" = 1357,
		"security" = 1359,
		"supply" = 1347,
		"service" = 1349,
		"centcom" = 1337,// Yes, that is the real Centcom freq.
		//This whole game is a big fuckin' meme.
		"aiprivate" = 1447 // The Common Server is the one...
		// ...that handles the AI Private Channel, btw.
	)))


	interpreter.SetVar("filter_types", new /datum/n_enum(list(
		"robot" = SPAN_ROBOT,
		"loud" = SPAN_YELL,
		"emphasis" = SPAN_ITALICS,
		"wacky" = SPAN_SANS,
		"commanding" = SPAN_COMMAND
	)))
	//Current allowed span classes

	//Language bitflags
	/* (Following comment written 26 Jan 2019)
	So, language doesn't work with bitflags anymore
	But having them be bitflags inside of NTSL makes more sense in its context
	So, when we get the signal back from NTSL, if the language has been altered, we'll set it to a new language datum,
	based on the bitflag the guy used.

	However, I think the signal can only have one language
	So, the lowest bit set within $language overrides any higher ones that are set.
	*/
	interpreter.SetVar("languages", new /datum/n_enum(list(
		"human" = HUMAN,
		"monkey" = MONKEY,
		"alien" = ALIEN,
		"robot" = ROBOT,
		"slime" = SLIME,
		"drone" = DRONE
	)))

	interpreter.Run() // run the thing

	return returnerrors

	/* -- Execute the compiled code -- */

/datum/TCS_Compiler/proc/Run(datum/signal/subspace/vocal/signal) // Runs the already-compiled code on an incoming signal.

	if(!ready)
		return

	if(!interpreter)
		return

	if(!interpreter.ProcExists("process_signal"))
		return

	var/datum/language/oldlang = signal.language
	if(oldlang == /datum/language/common)
		oldlang = HUMAN
	else if(oldlang == /datum/language/monkey)
		oldlang = MONKEY
	else if(oldlang == /datum/language/xenocommon)
		oldlang = ALIEN
	else if(oldlang == /datum/language/machine)
		oldlang = ROBOT
	else if(oldlang == /datum/language/slime)
		oldlang = SLIME
	else if(oldlang == /datum/language/drone)
		oldlang = DRONE

	// Signal data

	var/datum/n_struct/signal/script_signal = new(list(
		"content" = html_decode(signal.data["message"]),
		"freq" = signal.frequency,
		"source" = signal.data["name"],
		"uuid" = signal.data["name"],
		"sector" = signal.levels,
		"job" = signal.data["job"],
		"pass" = !(signal.data["reject"]),
		"filters" = signal.data["spans"],
		"language" = oldlang,
		"say" = signal.virt.verb_say,
		"ask" = signal.virt.verb_ask,
		"yell" = signal.virt.verb_yell,
		"exclaim" = signal.virt.verb_exclaim
	))


	/*
	Telecomms procs
	*/

	/*
		-> Send another signal to a server
				@format: broadcast(content, frequency, source, job, lang)

				@param content:		Message to broadcast
				@param frequency:	Frequency to broadcast to
				@param source:		The name of the source you wish to imitate. Must be stored in stored_names list.
				@param job:			The name of the job.
				@param spans		What span classes you want to apply to your message. Must be in the "allowed_custom_spans" list.
				@param say			Say verb used in messages ending in ".".
				@param ask			Say verb used in messages ending in "?".
				@param yell			Say verb used in messages ending in "!!" (or more).
				@param exclaim		Say verb used in messages ending in "!".

	*/
	interpreter.SetProc("broadcast", "tcombroadcast", signal, list("message", "freq", "source", "job","spans","say","ask","yell","exclaim","language"))

	/*
		-> Send a code signal.
				@format: signal(frequency, code)

				@param frequency:		Frequency to send the signal to
				@param code:			Encryption code to send the signal with
	*/
	interpreter.SetProc("signal", "signaler", signal, list("freq", "code"))

	/*
		-> Store a value permanently to the server machine (not the actual game hosting machine, the ingame machine)
				@format: mem(address, value)

				@param address:		The memory address (string index) to store a value to
				@param value:		The value to store to the memory address
	*/
	interpreter.SetProc("mem", "mem", signal, list("address", "value"))

	/*
		-> Wipe all the mem() variables on this server (for garbage collection purposes)
	*/
	interpreter.SetProc("clearmem","clearmem",signal, list())

	// Run the compiled code
	script_signal = interpreter.CallProc("process_signal", list(script_signal))
	if(!istype(script_signal))
		signal.data["reject"] = 1
		return

	// Backwards-apply variables onto signal data
	/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

	var/msg = script_signal.get_clean_property("content", signal.data["message"])
	if(isnum(msg))
		msg = "[msg]"
	else if(!msg)
		msg = "*beep*"
	signal.data["message"] = msg


	signal.frequency 		= script_signal.get_clean_property("freq", signal.frequency)

	var/setname = script_signal.get_clean_property("source", signal.data["name"])

	if(signal.data["name"] != setname)
		signal.data["realname"] = signal.data["name"]
		signal.virt.name = setname
	signal.data["name"]			= setname
	//signal.data["uuid"]			= script_signal.get_clean_property("$uuid", signal.data["uuid"])
	signal.levels 				= script_signal.get_clean_property("sector", signal.levels)
	signal.data["job"]			= script_signal.get_clean_property("job", signal.data["job"])
	signal.data["reject"]		= !(script_signal.get_clean_property("pass")) // set reject to the opposite of $pass
	signal.virt.verb_say		= script_signal.get_clean_property("say")
	signal.virt.verb_ask		= script_signal.get_clean_property("ask")
	signal.virt.verb_yell		= script_signal.get_clean_property("yell")
	signal.virt.verb_exclaim	= script_signal.get_clean_property("exclaim")
	var/newlang = script_signal.get_clean_property("language")
	signal.language = signal.LangBit2Datum(newlang) || oldlang
	var/list/setspans 			= script_signal.get_clean_property("filters") //Save the span vector/list to a holder list
	if(islist(setspans)) //Players cannot be trusted with ANYTHING. At all. Ever.
		setspans &= GLOB.allowed_custom_spans //Prune out any illegal ones. Go ahead, comment this line out. See the horror you can unleash!
		signal.data["spans"]	= setspans //Apply new span to the signal only if it is a valid list, made using $filters & vector() in the script.
	else
		signal.data["spans"] = list()

	// If the message is invalid, just don't broadcast it!
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/datum/n_struct/signal/New(list/P)
	properties = P | list(
		"content" = "",
		"freq" = 1459,
		"source" = "",
		"uuid" = "",
		"sector" = list(),
		"job" = "",
		"pass" = TRUE,
		"filters" = list(),
		"language" = HUMAN,
		"say" = "says",
		"ask" = "asks",
		"yell" = "yells",
		"exclaim" = "exclaims"
	)

/*  -- Actual language proc code --  */

#define SIGNAL_COOLDOWN 20 // 2 seconds
#define MAX_MEM_VARS 500 // The maximum number of variables that can be stored by NTSL via mem()

/datum/signal

/datum/signal/proc/LangBit2Datum(langbits) // Takes in the set language bits, returns the datum to use
	switch(langbits)
		if(HUMAN)
			return /datum/language/common
		if(MONKEY)
			return /datum/language/monkey
		if(ALIEN)
			return /datum/language/xenocommon
		if(ROBOT)
			return /datum/language/machine
		if(SLIME)
			return /datum/language/slime
		if(DRONE)
			return /datum/language/drone

/datum/signal/proc/mem(address, value)

	if(istext(address))
		var/obj/machinery/telecomms/server/S = data["server"]

		if(!value && value != 0) // Getting the value
			return S.memory[address]

		else // Setting the value
			if(S.memory.len >= MAX_MEM_VARS)
				if(!(address in S.memory))
					return FALSE
			S.memory[address] = value
			return TRUE

/datum/signal/proc/clearmem()
	var/obj/machinery/telecomms/server/S = data["server"]
	S.memory = list()
	return TRUE

/datum/signal/proc/signaler(freq = 1459, code = 30)

	if(isnum(freq) && isnum(code))

		var/obj/machinery/telecomms/server/S = data["server"]

		if(S.last_signal + SIGNAL_COOLDOWN > world.timeofday && S.last_signal < MIDNIGHT_ROLLOVER)
			return
		S.last_signal = world.timeofday

		var/datum/radio_frequency/connection = SSradio.return_frequency(freq)

		if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
			freq *= 10 // shift the decimal one place
			// "But wait, wouldn't floating point mess this up?" You ask.
			// Nah. That actually can't happen when you multiply by a whole number.
			// Think about it.

		freq = sanitize_frequency(freq)

		code = round(code)
		code = CLAMP(code, 0, 100)

		var/datum/signal/signal = new
		signal.source = S
		signal.data["message"] = "ACTIVATE"

		connection.post_signal(S, signal)

		message_admins("Telecomms server \"[S.id]\" sent a signal command, which was triggered by NTSL<B>: </B> [format_frequency(freq)]/[code]")

/datum/signal/proc/tcombroadcast(message, freq, source, job, spans, say = "says", ask = "asks", yell = "yells", exclaim = "exclaims", language = /datum/language/common)
	//languages &= allowed_translateable_langs //we can only translate to certain languages

	var/obj/machinery/telecomms/server/S = data["server"]
	var/obj/item/radio/server/hradio = S.server_radio

	if(!hradio)
		throw EXCEPTION("tcombroadcast(): signal has no radio")
		return
	//First lets do some checks for bad input
	if(isnum(message)) // Allows for setting $content to a number value
		message = "[message]"
	if((!message) && message != 0)
		message = "*beep*"
	if(!source)
		source = "[html_encode(uppertext(S.id))]"
		//hradio = new // sets the hradio as a radio intercom
	if(!job)
		job = "Unknown"
	if(!freq || (!isnum(freq) && text2num(freq) == null))
		freq = 1459
	if(!isnum(freq))
		freq = text2num(freq)
	if(findtext(num2text(freq), ".")) // if the frequency has been set as a decimal
		freq *= 10 // shift the decimal one place
		// "But wait, wouldn't floating point mess this up?" You ask.
		// Nah. That actually can't happen when you multiply by a whole number.
		// Think about it.
	if(isnum(language)) // If the language was a lang bit instead of a datum
		language = LangBit2Datum(language)
	if(!islist(spans))
		spans = list()
	else
		spans &= GLOB.allowed_custom_spans //Removes any spans not on the allowed list. Comment this out if want to let players use ANY span in stylesheet.dm!

	//SAY REWRITE RELATED CODE.
	//This code is a little hacky, but it *should* work. Even though it'll result in a virtual speaker referencing another virtual speaker. vOv
	var/atom/movable/virtualspeaker/virt = new
	virt.name = source
	virt.job = job
	virt.verb_say = say
	virt.verb_ask = ask
	virt.verb_exclaim = exclaim
	virt.verb_yell = yell

	var/datum/signal/subspace/vocal/newsign = new(hradio,freq,virt,language,message,spans,list(S.z))
	/*
	virt.languages_spoken = language
	virt.languages_understood = virt.languages_spoken //do not remove this or everything turns to jibberish
	*/
	//END SAY REWRITE RELATED CODE.

	//Now we set up the signal
	newsign.data["mob"] = virt
	newsign.data["mobtype"] = /mob/living/carbon/human
	newsign.data["name"] = source
	newsign.data["realname"] = newsign.data["name"]
	newsign.data["uuid"] = source
	newsign.data["job"] = "[job]"
	newsign.data["compression"] = 0
	newsign.data["message"] = message
	//newsign.data["type"] = BROADCAST_ARTIFICIAL // artificial broadcast
	newsign.data["spans"] = spans
	newsign.data["language"] = language
	newsign.frequency = freq
	newsign.data["radio"] = hradio
	newsign.data["vmessage"] = message
	newsign.data["vname"] = source
	newsign.data["vmask"] = 0
	newsign.data["broadcast_levels"] = data["broadcast_levels"]
	newsign.sanitize_data()

	var/pass = S.relay_information(newsign, /obj/machinery/telecomms/hub)
	if(!pass) // If we're not sending this to the hub (i.e. we're running a basic tcomms or something)
		pass = S.relay_information(newsign, /obj/machinery/telecomms/broadcaster) // send this message to broadcasters directly
	return pass // Returns, as of Jan 23 2019, the number of machines that received this broadcast's message.
#undef SIGNAL_COOLDOWN
#undef MAX_MEM_VARS
#undef HUMAN
#undef MONKEY
#undef ALIEN
#undef ROBOT
#undef SLIME
#undef DRONE
