

/obj/machinery/blob_cultivator
	name = "Biological Cultivator"
	desc = "Some sort of pod filled with blood and viscera. You swear you can see it moving..."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g"
	var/datum/infection_crew/crew
	var/begun
	var/baseTime = 6000
	var/endTimer
	var/boosts = 1
	var/finished
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

/obj/machinery/blob_cultivator/Initialize(mapload)
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew


/obj/machinery/blob_cultivator/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	var/goOn = FALSE

	for(var/R in crew.available_researches)
		var/datum/crew_researches/research = R
		if(research.id == "blob_cultivation")
			if(research.researched)
				goOn = TRUE

	if(!goOn)
		dat += "<h1>Blob Cultivation needs to be researched to access this machine</h1>"
	else
		if(!begun)
			dat += "<a href='?src=[REF(src)];begin=1'>Begin Cultivation</a><br><br>"
		else if(finished)
			dat += "<h1>Cultivation Complete</h1>"
		else
			dat += "<h1>Time remaining: [(endTimer - world.time) / 10] seconds</h1><br>"
			dat += "<span>Using additional sample extractors on this machine will shorten the time taken!</span>"

	var/datum/browser/popup = new(user, "computer", "Blob Cultivator", 375, 700)
	popup.set_content(dat)
	popup.open()

/obj/machinery/blob_cultivator/process()
	if(endTimer <= world.time && begun && !finished)
		crew.tier = 2
		finished = TRUE
		priority_announce("Blob Cultivation Successful. Research Tier upped to 2.", "Nanotrasen Biological Research Department")
		STOP_PROCESSING(SSobj, src)

/obj/machinery/blob_cultivator/attackby(obj/item/I, mob/user, params)
	if(!begun)
		return
	if (istype(I, /obj/item/implanter/blob))
		var/obj/item/implanter/blob/sample = I
		if(sample.sample)
			var/timeReduction = (2 ** (-boosts)) * 2
			endTimer -= (timeReduction * 60) * 10
			boosts++
			to_chat(user, "<span class='notice'>Time reduced by [timeReduction * 60] seconds!")
			qdel(sample)
		return

/obj/machinery/blob_cultivator/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["begin"])
		for(var/R in crew.available_researches)
			var/datum/crew_researches/research = R
			if(research.id == "blob_cultivation")
				if(research.researched)
					if(!begun)
						endTimer = world.time + baseTime
						begun = TRUE
						START_PROCESSING(SSobj, src)
	ui_interact(usr)
	updateUsrDialog()
