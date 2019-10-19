

/obj/machinery/neural_hijacker
	name = "Neural Hijacker"
	desc = "A strange machine, some say it can read minds.."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	var/datum/infection_crew/crew
	var/begun
	var/baseTime = 9000
	var/endTimer
	var/boosts = 1
	var/finished
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100

/obj/machinery/neural_hijacker/Initialize(mapload)
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew


/obj/machinery/neural_hijacker/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	var/goOn = FALSE

	for(var/R in crew.available_researches)
		var/datum/crew_researches/research = R
		if(research.id == "neural_hijacker")
			if(research.researched)
				goOn = TRUE

	if(!goOn)
		dat += "<h1>Neural Hijacker needs to be unlocked to access this machine</h1>"
	else
		if(!begun)
			dat += "<a href='?src=[REF(src)];begin=1'>Begin Hijacking</a><br><br>"
		else if(finished)
			dat += "<h1>Neural Hijacking Finished!</h1>"
		else
			dat += "<h1>Time remaining: [(endTimer - world.time) / 10] seconds</h1><br>"
			dat += "<span>Pay 20 points to quicken hijacking</span><br>"
			dat += "<a href='?src=[REF(src)];quicken=1'>Pay 20 points</a>"

	var/datum/browser/popup = new(user, "computer", "Neural Hijacker", 375, 700)
	popup.set_content(dat)
	popup.open()

/obj/machinery/neural_hijacker/process()
	if(endTimer <= world.time && begun && !finished)
		crew.tier = 3
		priority_announce("Neural Hijacking completed. Research Tier upped to 3.", "Nanotrasen Biological Research Department")
		crew.tier3()
		finished = TRUE
		STOP_PROCESSING(SSobj, src)

/obj/machinery/neural_hijacker/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["begin"])
		for(var/R in crew.available_researches)
			var/datum/crew_researches/research = R
			if(research.id == "neural_hijacker" && research.researched)
				if(!begun)
					endTimer = world.time + baseTime
					begun = TRUE
					for(var/O in GLOB.overminds)
						var/mob/camera/blob/infection/overmind = O
						to_chat(overmind, "<span class='big'>Something is forcing its way inside our hivemind... We must destroy the humans quicker.</span>")
					START_PROCESSING(SSobj, src)
	if(href_list["quicken"])
		if(crew.points >= 20)
			if(begun)
				crew.points -= 20
				var/timeReduction = (2 ** (-boosts)) * 4
				boosts++
				endTimer -= (timeReduction * 60) * 10
				to_chat(usr, "<span class='notice'>Time reduced by [timeReduction * 60] seconds</span>")
	ui_interact(usr)
	updateUsrDialog()
