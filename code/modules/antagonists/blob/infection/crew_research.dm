/obj/machinery/computer/crewResearch
	name = "research console"
	desc = "Used to research just about everything"
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1
	var/temp = null
	var/datum/infection_crew/crew

/obj/machinery/computer/crewResearch/Initialize(mapload)
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

/obj/machinery/computer/crewResearch/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Research Points: [crew.points]</h2>"
	dat += "<h3>Tier: [crew.tier]</h3><br>"
	dat += "<br><h3>Available Researches</h3>"
	if(crew.tier == 0)
		dat += "<h2>Grab a sample using the sample extractor to begin researching</h2>"


	for(var/R in crew.available_researches)
		var/datum/crew_researches/research = R
		if(research.researched)
			continue
		if(research.tier > crew.tier)
			continue
		dat += "<span>[research.name]<br>[research.desc]<br>Cost: [research.cost] points</span><br>"
		dat += "<a href='?src=[REF(src)];research=[research.id]'>Research</a><br><br>"

	dat += "<br><br><br>"
	dat += "<h3>Already Researched:</h3>"
	for(var/R in crew.available_researches)
		var/datum/crew_researches/research = R
		if(!research.researched)
			continue
		dat += "<span>[research.name]<br>[research.desc]<br><br></span>"

	var/datum/browser/popup = new(user, "computer", "Research Console", 375, 700)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/crewResearch/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["research"])
		for(var/U in crew.available_researches)
			var/datum/crew_researches/research = U
			if("[research.id]" == href_list["research"])
				var/returnVal = research.onPurchase(crew)
				if(!returnVal)
					to_chat(usr, "<span class='big'>Not enough points to research this!</span>")
				else
					to_chat(usr, "<span class='big'>Researched!</span>")

	updateUsrDialog()

/obj/machinery/computer/crewResearch/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/implanter/blob))
		var/obj/item/implanter/blob/sample = I
		if(sample.sample && crew.tier == 0)
			crew.tier = 1
			priority_announce("A sample of the blob has been procured, your research tier has been increased to 1!", "Nanotrasen Biological Research Department")
			qdel(sample)
		return

/obj/item/implanter/blob
	name = "sample extractor"
	desc = "A sterile automatic sample extractor."
	var/sample = FALSE

/obj/item/implanter/blob/update_icon()
	if(sample)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"

/obj/machinery/computer/door_control
	name = "tunnel door control"
	desc = "Used to control the tunnel doors."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1
	var/datum/infection_crew/crew
	var/warned = FALSE
	var/closing

/obj/machinery/computer/door_control/Initialize(mapload)
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

/obj/machinery/computer/door_control/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Tunnel Control System</h2>"
	if(crew.defcon > 2)
		dat += "<h3>DEFCON is not high enough to seal the tunnel!</h3>"
	else
		if(!closing)
			if(!warned)
				dat += "<a href='?src=[REF(src)];close=1'>Close Tunnel</a><br><br>"
			else
				dat += "<a href='?src=[REF(src)];final=1'>Are you sure?</a><br><br>"
		else
			dat += "<h2>Tunnel is closing.</h2>"

	var/datum/browser/popup = new(user, "computer", "Tunnel Control", 375, 375)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/door_control/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["close"])
		warned = TRUE

	if(href_list["final"])
		if(!closing)
			crew.closeTunnel()
			closing = TRUE
	updateUsrDialog()