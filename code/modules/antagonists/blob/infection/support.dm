/obj/machinery/computer/orbital_support
	name = "orbital support console"
	desc = "Used to order supplies directly from Nanotrasen Supply Depots"
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1
	var/datum/infection_crew/crew
	var/supports = list()

/obj/machinery/computer/orbital_support/Initialize(mapload)
	..()
	for(var/S in subtypesof(/datum/support_callin))
		supports += new S()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

/obj/machinery/computer/orbital_support/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Nanotrasen Orbital Support System v1.6</h2>"
	if(crew.defcon > 4)
		dat += "<h3>DEFCON too high for Orbital Support</h3>"
	else
		dat += "Available Points: [crew.orbital_points]<br><br>"
		for(var/S in supports)
			var/datum/support_callin/support = S
			dat += "<b>[support.name]</b><br>"
			dat += "[support.desc]<br>"
			dat += "<a href='?src=[REF(src)];order=[support.id]'>Order ([support.cost] points)</a><br><br>"

	var/datum/browser/popup = new(user, "computer", "Orbital Support", 375, 375)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/orbital_support/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["order"])
		for(var/R in supports)
			var/datum/support_callin/support = R
			if(support.id == href_list["order"])
				if(support.Purchase(crew, usr))
					to_chat(usr, "<span class='notice'>Package ordered</span>")
				else
					to_chat(usr, "<span class='notice'>Not enough points!</span>")

	updateUsrDialog()