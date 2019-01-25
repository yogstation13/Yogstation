//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33


/* --- Traffic Control Scripting Language --- */
	// Nanotrasen TCS Language - Made by Doohl
GLOBAL_LIST_INIT(allowed_custom_spans,list(SPAN_ROBOT,SPAN_YELL,SPAN_ITALICS,SPAN_SANS,SPAN_COMMAND))//Span classes that players are allowed to set in a radio transmission.

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

	return returnerrors

	/* -- Execute the compiled code -- */

/datum/TCS_Compiler/proc/Run(datum/signal/subspace/vocal/signal) // Runs the already-compiled code on an incoming signal.

	if(!ready)
		return

	if(!interpreter)
		return

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
	interpreter.SetVar("$common",	1459)
	interpreter.SetVar("$science",	1351)
	interpreter.SetVar("$command",	1353)
	interpreter.SetVar("$medical",	1355)
	interpreter.SetVar("$engineering",1357)
	interpreter.SetVar("$security",	1359)
	interpreter.SetVar("$supply",	1347)
	interpreter.SetVar("$service",	1349)
	interpreter.SetVar("$centcom",	1337) // Yes, that is the real Centcom freq.
	//This whole game is a big fuckin' meme.
	interpreter.SetVar("$aiprivate", 1447) // The Common Server is the one...
	// ...that handles the AI Private Channel, btw.

	// Signal data

	interpreter.SetVar("$content", 	html_decode(signal.data["message"]))
	interpreter.SetVar("$freq"   , 	signal.frequency)
	interpreter.SetVar("$source" , 	signal.data["name"])
	interpreter.SetVar("$uuid"   , 	signal.data["uuid"])
	interpreter.SetVar("$sector" , 	signal.levels)
	interpreter.SetVar("$job"    , 	signal.data["job"])
	interpreter.SetVar("$sign"   ,	signal)
	interpreter.SetVar("$pass"	 ,  !(signal.data["reject"])) // Being passed is the opposite of being rejected, so they're logical not of each other.
	interpreter.SetVar("$filters"  ,	signal.data["spans"]) //Important, this is given as a vector! (a list)
	interpreter.SetVar("$say"    , 	signal.virt.verb_say)
	interpreter.SetVar("$ask"    , 	signal.virt.verb_ask)
	interpreter.SetVar("$yell"    , 	signal.virt.verb_yell)
	interpreter.SetVar("$exclaim"    , 	signal.virt.verb_exclaim)

	//Current allowed span classes
	interpreter.SetVar("$robot",	SPAN_ROBOT) //The font used by silicons!
	interpreter.SetVar("$loud",		SPAN_YELL)	//Bolding, applied when ending a message with several exclamation marks.
	interpreter.SetVar("$emphasis",	SPAN_ITALICS) //Italics
	interpreter.SetVar("$wacky",	SPAN_SANS) //Comic sans font, normally seen from the genetics power.
	interpreter.SetVar("$commanding",	SPAN_COMMAND) //Bolding from high-volume mode on command headsets

	//Language bitflags
	interpreter.SetVar("HUMAN"   ,	1)
	interpreter.SetVar("MONKEY"   ,	2)
	interpreter.SetVar("ALIEN"   ,	4)
	interpreter.SetVar("ROBOT"   ,	8)
	interpreter.SetVar("SLIME"   ,	16)
	interpreter.SetVar("DRONE"   ,	32)

	var/datum/language/curlang = /datum/language/common
	if(istype(signal.data["mob"], /atom/movable))
		var/atom/movable/M = signal.data["mob"]
		curlang = M.get_default_language()

	interpreter.SetVar("$language", curlang)


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
	
	
	/*
	General NTSL procs
	Should probably be moved to its own place
	*/
	// Vector
	interpreter.SetProc("vector", /proc/n_list)
	interpreter.SetProc("at", /proc/n_listpos)
	interpreter.SetProc("copy", /proc/n_listcopy)
	interpreter.SetProc("push_back", /proc/n_listadd)
	interpreter.SetProc("remove", /proc/n_listremove)
	interpreter.SetProc("cut", /proc/n_listcut)
	interpreter.SetProc("swap", /proc/n_listswap)
	interpreter.SetProc("insert", /proc/n_listinsert)
	interpreter.SetProc("pick", /proc/n_pick)
	interpreter.SetProc("prob", /proc/n_prob)
	interpreter.SetProc("substr", /proc/n_substr)
	interpreter.SetProc("find", /proc/n_smartfind)
	interpreter.SetProc("length", /proc/n_smartlength)

	// Strings
	interpreter.SetProc("lower", /proc/n_lower)
	interpreter.SetProc("upper", /proc/n_upper)
	interpreter.SetProc("explode", /proc/n_explode)
	interpreter.SetProc("implode", /proc/n_implode)
	interpreter.SetProc("repeat", /proc/n_repeat)
	interpreter.SetProc("reverse", /proc/n_reverse)
	interpreter.SetProc("tonum", /proc/n_str2num)
	interpreter.SetProc("replace", /proc/n_replace)
	interpreter.SetProc("proper", /proc/n_proper)

	// Numbers
	interpreter.SetProc("tostring", /proc/n_num2str)
	interpreter.SetProc("sqrt", /proc/n_sqrt)
	interpreter.SetProc("abs", /proc/n_abs)
	interpreter.SetProc("floor", /proc/n_floor)
	interpreter.SetProc("ceil", /proc/n_ceil)
	interpreter.SetProc("round", /proc/n_round)
	interpreter.SetProc("clamp", /proc/n_clamp)
	interpreter.SetProc("inrange", /proc/n_inrange)
	interpreter.SetProc("rand", /proc/n_rand)
	interpreter.SetProc("randseed", /proc/n_randseed)
	interpreter.SetProc("min", /proc/n_min)
	interpreter.SetProc("max", /proc/n_max)
	interpreter.SetProc("sin", /proc/n_sin)
	interpreter.SetProc("cos", /proc/n_cos)
	interpreter.SetProc("asin", /proc/n_asin)
	interpreter.SetProc("acos", /proc/n_acos)
	interpreter.SetProc("log", /proc/n_log)

	// Time
	interpreter.SetProc("time", /proc/n_time)
	interpreter.SetProc("sleep", /proc/n_delay)
	interpreter.SetProc("timestamp", /proc/gameTimestamp)

	// Run the compiled code
	interpreter.Run()

	// Backwards-apply variables onto signal data
	/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */

	var/msg = interpreter.GetCleanVar("$content", signal.data["message"])
	if(isnum(msg))
		msg = "[msg]"
	else if(!msg)
		msg = "*beep*"
	signal.data["message"] = msg
	
	
	signal.frequency 		= interpreter.GetCleanVar("$freq", signal.frequency)

	var/setname = interpreter.GetCleanVar("$source", signal.data["name"])

	if(signal.data["name"] != setname)
		signal.data["realname"] = signal.data["name"]
		signal.virt.name = setname
	signal.data["name"]			= setname
	signal.data["uuid"]			= interpreter.GetCleanVar("$uuid", signal.data["uuid"])
	signal.levels 				= interpreter.GetCleanVar("$sector", signal.levels)
	signal.data["job"]			= interpreter.GetCleanVar("$job", signal.data["job"])
	signal.data["reject"]		= !(interpreter.GetCleanVar("$pass")) // set reject to the opposite of $pass
	signal.virt.verb_say		= interpreter.GetCleanVar("$say")
	signal.virt.verb_ask		= interpreter.GetCleanVar("$ask")
	signal.virt.verb_yell		= interpreter.GetCleanVar("$yell")
	signal.virt.verb_exclaim	= interpreter.GetCleanVar("$exclaim")
	ASSERT(signal.virt.verb_say == interpreter.GetCleanVar("$say"))
	var/list/setspans 			= interpreter.GetCleanVar("$filters") //Save the span vector/list to a holder list
	if(islist(setspans)) //Players cannot be trusted with ANYTHING. At all. Ever.
		setspans &= GLOB.allowed_custom_spans //Prune out any illegal ones. Go ahead, comment this line out. See the horror you can unleash!
		signal.data["spans"]	= setspans //Apply new span to the signal only if it is a valid list, made using $filters & vector() in the script.

	// If the message is invalid, just don't broadcast it!
	if(signal.data["message"] == "" || !signal.data["message"])
		signal.data["reject"] = 1

/*  -- Actual language proc code --  */

#define SIGNAL_COOLDOWN 20 // 2 seconds
#define MAX_MEM_VARS 500 // The maximum number of variables that can be stored by NTSL via mem()

/datum/signal

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

	if(!islist(spans))
		spans = list()
	else
		spans &= GLOB.allowed_custom_spans //Removes any spans not on the allowed list. Comment this out if want to let players use ANY span in stylesheet.dm!

	//SAY REWRITE RELATED CODE.
	//This code is a little hacky, but it *should* work. Even though it'll result in a virtual speaker referencing another virtual speaker. vOv
	var/atom/movable/virtualspeaker/virt = new
	virt.name = source
	virt.job = job
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
	newsign.data["verb_say"] = say
	newsign.data["verb_ask"] = ask
	newsign.data["verb_yell"]= yell
	newsign.data["verb_exclaim"] = exclaim
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