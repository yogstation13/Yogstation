GLOBAL_LIST_EMPTY(crewDatum)

/datum/infection_crew
	var/defcon = 5
	var/available_researches = list()
	var/tier = 0
	var/points = 0
	var/tunnelClosed
	var/tunnelTimer = 1200
	var/innerClosed
	var/outerClosed
	var/innerTunnel
	var/outerTunnel
	var/closing

	var/tier4Timer
	var/tier4Interval = 9000
	var/tier4

/datum/infection_crew/New()
	message_admins("CREW INIT COMPLETE")
	for(var/R in subtypesof(/datum/crew_researches))
		available_researches += new R()
	START_PROCESSING(SSobj, src)

/datum/infection_crew/proc/changeDefcon(level)
	defcon = level
	processDefcon()

/datum/infection_crew/process()
	if(closing)
		if(outerTunnel <= world.time)
			if(!outerClosed)
				openDoors("outer")
				priority_announce("The outer tunnel doors have been closed. Clear the middle, or you will become trapped!", "Door Control System")
				outerClosed = TRUE
		if(innerTunnel <= world.time)
			if(!innerClosed)
				openDoors("inner")
				priority_announce("The inner tunnel doors have been closed. The tunnel is now closed, and cannot be opened", "Door Control System")
				innerClosed  = TRUE

	if(tier4)
		if(tier < 4)
			if(tier4Timer <= world.time)
				tier = 4
				priority_announce("Tier 4 has been unlocked. The Self Destruct device is now ready. It will need both detonation keys, the nuclear authentication disk & a willing human to offer their life, by entering the device", "Nanotrasen Biological Research Department")



/datum/infection_crew/proc/processDefcon()
	switch(defcon)
		if(4)
			openDoors("basic_armory")
			message_admins("DEFCON 4 triggered")
			priority_announce("The DEFCON level has been raised to 4. There is a possible threat to the facility, and the Armory has been unlocked.", "Nanotrasen Defence Department")
			return
		if(3)
			openDoors("advanced_armory")
			message_admins("DEFCON 3 triggered")
			priority_announce("The DEFCON level has been raised to 3. There is a confirmed threat to the facility, and the Heavy Duty Armory has been unlocked.", "Nanotrasen Defence Department")
			return
		if(2)
			message_admins("DEFCON 2 triggered")
			priority_announce("The DEFCON level has been raised to 2. There is a serious threat to the facility, and Central Command is now authorized to send in ERTs if requested.", "Nanotrasen Defence Department")
			return
		if(1)
			message_admins("DEFCON 1 triggered")
			priority_announce("The DEFCON level has been raised to 1. There is a serious & uncontainable threat to the facility, and the Self Destruct has been activated. Make your way to the escape shuttle in an orderly fashion.", "Nanotrasen Defence Department")
			SSshuttle.emergency.request()
			message_admins("Shuttle called by DEFCON")
			return

/datum/infection_crew/proc/openDoors(id)
	var/doors_need_closing = FALSE
	var/list/obj/machinery/door/airlock/open_or_close = list()

	for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
		if(D.id_tag == id)
			open_or_close += D
			if(!D.density)
				doors_need_closing = TRUE

	for(var/D in open_or_close)
		INVOKE_ASYNC(D, doors_need_closing ? /obj/machinery/door/airlock.proc/close : /obj/machinery/door/airlock.proc/open)

/datum/infection_crew/proc/addPoints(amount)
	points += amount

//I was too lazy to message anyone on how to do this better
/obj/infection_kickstarter
	name = "I AM A BUG"

/obj/infection_kickstarter/Initialize(mapload)
	GLOB.crewDatum += new /datum/infection_crew()
	message_admins("CREW INIT")
	qdel(src)

/datum/infection_crew/proc/closeTunnel()
	if(tunnelClosed)
		return
	closing = TRUE
	outerTunnel = world.time + tunnelTimer
	innerTunnel = world.time + (tunnelTimer * 2)
	priority_announce("Tunnel lockdown procedure initiated, outer doors will close in 2 minutes, inner doors will close in 4 minutes.", "Door Control System")
	tunnelClosed = TRUE

/datum/infection_crew/proc/tier3()
	tier4Timer = world.time + tier4Interval
	tier4 = TRUE