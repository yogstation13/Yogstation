/client/proc/change_fab_rate()
	set name = "Change Fabricator Point Rate"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.change_fab()

/datum/admins/proc/change_fab()
	if(!usr.client.holder)
		return

	var/rate = input(usr, "Change rate to X points per minute") as num
	for(var/D in GLOB.fabs)
		if(istype(D, /obj/machinery/crewFab))
			var/obj/machinery/crewFab/fab = D
			fab.pointGain = rate

	priority_announce("The rate of point generation in fabricators has been changed to [rate] per minute.", "Nanotrasen Cargo Department")


/client/proc/begin_infect()
	set name = "Begin Infection"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.begin_infect()


/datum/admins/proc/begin_infect()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			if(crew.defcon < 5)
				return

	message_admins("INFECTION BEGUN")
	for(var/W in GLOB.blob_walls)
		var/turf/closed/indestructible/riveted/infection/wall = W
		wall.ScrapeAway()

	for(var/O in GLOB.overminds)
		if(istype(O, /mob/camera/blob/infection))
			var/mob/camera/blob/infection/infection = O
			infection.timers_enabled = TRUE

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			crew.changeDefcon(4)

/client/proc/raiseDefcon()
	set name = "Change Defcon"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.defcon()

/datum/admins/proc/defcon()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			var/defconLevel = input(usr, "Change DEFCON to what?") as num
			if(defconLevel < 1 || defconLevel > 5)
				message_admins("DEFCON is limited to between 5 and 1")
				return
			crew.changeDefcon(defconLevel)

/client/proc/stopSelfDestruct()
	set name = "Stop Self Destruct"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.stopself()

/datum/admins/proc/stopself()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D

			crew.changeDefcon(2)

/client/proc/start_blob()
	set name = "Start Blob Victory Timer"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.start_blobber()


/datum/admins/proc/start_blobber()
	if(!usr.client.holder)
		return

	for(var/O in GLOB.overminds)
		if(istype(O, /mob/camera/blob/infection))
			var/mob/camera/blob/infection/infection = O
			infection.startVictory()

/client/proc/stop_blob()
	set name = "Stop Blob Victory Timer"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.stop_blobber()


/datum/admins/proc/stop_blobber()
	if(!usr.client.holder)
		return

	for(var/O in GLOB.overminds)
		if(istype(O, /mob/camera/blob/infection))
			var/mob/camera/blob/infection/infection = O
			infection.stopVictory()

/client/proc/giveOrbitalPoints()
	set name = "Give Orbital Points"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.gib_points()

/datum/admins/proc/gib_points()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			var/points = input(usr, "Award how many points?") as num
			crew.addOrbPoints(points)

/client/proc/giveOrbitalMunitions()
	set name = "Give Orbital Munitions"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.gib_boom()

/datum/admins/proc/gib_boom()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			var/which = input(usr, "Which missile?", "Missile") as null|anything in list("AGM", "Fatty", "Sidewinder", "Cancel")
			if(which == "Cancel")
				return
			var/amount = input(usr, "Award how many?") as num
			crew.addBoom(which, amount)

/client/proc/giveFactoryUpgrade()
	set name = "Give Factory Upgrade Points"
	set category = "Infection"

	if(!check_rights(R_ADMIN))
		return

	holder.gib_factory()

/datum/admins/proc/gib_factory()
	if(!usr.client.holder)
		return

	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			var/datum/infection_crew/crew = D
			var/amount = input(usr, "Award how many?") as num
			crew.upgradePoints += amount
			priority_announce("You have been awarded [amount] point(s) for Factory Upgrades!", "Nanotrasen Cargo Department")