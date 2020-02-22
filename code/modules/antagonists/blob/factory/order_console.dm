/obj/machinery/computer/factory_order
	name = "ordering console"
	desc = "Used to order supplies from factory machines"
	icon_screen = "supply"

	light_color = "#E2853D"//orange
	var/datum/infection_crew/crew
	var/designs = list()

/obj/machinery/computer/factory_order/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat

	dat += "<h2>Ordering Console</h2>"
	dat += "<br><br>"
	var/pass = TRUE

	for(var/D in designs)
		pass = TRUE
		var/datum/factory_design/design = D
		for(var/req in design.requiredResearch)
			for(var/research in crew.available_researches)
				var/datum/crew_researches/R = research
				if(R.id == req && !R.researched)
					pass = FALSE
		if(design.construction_limit)
			if(design.constructed)
				dat += "<a>[design.name] ALREADY CONSTRUCTED - TRY OTHER FABRICATOR</a><br>"
				pass = FALSE
		if(pass)
			dat += "<a href='?src=[REF(src)];make=[design.id]'>[design.name]</a><br>"

	dat += "<br><a href='?src=[REF(src)];clear=1'>Clear Queue</a>"
	var/datum/browser/popup = new(user, "computer", "Ordering Console", 400, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/factory_order/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["make"])
		for(var/R in designs)
			var/datum/factory_design/design = R
			if(design.id == href_list["make"])
				if(design.Make(usr, src))
					to_chat(usr, "<span>Order sent to factory machinery.</span>")
				else
					to_chat(usr, "<span>Order <b>NOT</b> sent to factory machinery.</span>")
	if(href_list["clear"])
		for(var/obj/machinery/factory/dispenser/thing in GLOB.factory_dispensers)
			thing.queuedItems = list()

	ui_interact(usr)
	updateUsrDialog()


/obj/machinery/computer/factory_order/Initialize()
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

	for(var/D in subtypesof(/datum/factory_design))
		designs += new D()
