GLOBAL_LIST_EMPTY(fabs)

/obj/machinery/crewFab
	name = "fabricator"
	desc = "It produces items using magical points"
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER

	var/datum/infection_crew/crew

	var/points = 0

	var/pointGain = 250

	var/pointInterval = 600
	var/pointTimer

	var/designs = list()

/obj/machinery/crewFab/Initialize()
	..()
	GLOB.fabs += src
	START_PROCESSING(SSobj, src)
	pointTimer = world.time + pointInterval
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

	for(var/D in subtypesof(/datum/fab_design))
		designs += new D()

/obj/machinery/crewFab/process()
	if(pointTimer <= world.time)
		points += pointGain
		pointTimer = world.time + pointInterval


/obj/machinery/crewFab/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat

	dat += "<h2>Fabricator</h2>"
	dat += "<br><br>"
	dat += "<h2>Points: [points]</h2>"
	var/pass = TRUE

	for(var/D in designs)
		pass = TRUE
		var/datum/fab_design/design = D
		for(var/req in design.requiredResearch)
			for(var/research in crew.available_researches)
				var/datum/crew_researches/R = research
				if(R.id == req && !R.researched)
					pass = FALSE
		if(design.construction_limit)
			if(design.constructed)
				dat += "<a>[design.name] ([design.cost]) ALREADY CONSTRUCTED - TRY OTHER FABRICATOR</a><br>"
				pass = FALSE
		if(pass)
			dat += "<a href='?src=[REF(src)];make=[design.id]'>[design.name] ([design.cost])</a><br>"

	var/datum/browser/popup = new(user, "computer", "Fabricator", 400, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/crewFab/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["make"])
		for(var/R in designs)
			var/datum/fab_design/design = R
			if(design.id == href_list["make"])
				if(design.Make(usr, src))
					to_chat(usr, "<span class='notice'>Item constructed</span>")
				else
					to_chat(usr, "<span class='notice'>Not enough points!</span>")

	ui_interact(usr)
	updateUsrDialog()
