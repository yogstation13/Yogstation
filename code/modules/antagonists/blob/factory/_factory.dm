/obj/machinery/factory
	name = "BUG"
	density = TRUE
	layer = BELOW_OBJ_LAYER

	var/input_dir = NORTH
	var/output_dir = SOUTH

	var/upgradePoints = 0

	var/availableUpgrades = list()
	var/datum/infection_crew/crew

	var/datum/factory/upgradeBase = /datum/factory/dummy

/obj/machinery/factory/Initialize(mapload)
	..()
	for(var/U in subtypesof(upgradeBase))
		availableUpgrades += new U()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

/obj/machinery/factory/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["upgrade"])
		for(var/U in availableUpgrades)
			var/datum/factory/upgrade = U
			if("[upgrade.id]" == href_list["upgrade"])
				upgrade.onUpgrade(src, usr, crew)

	updateUsrDialog()


//UPGRADE BASE
/datum/factory
	var/name = "Hey"
	var/id = "1"
	var/cost = 1
	var/bought = 0
	var/maxBuy = -1

/datum/factory/proc/onUpgrade(obj/machinery/factory/machine, user, datum/infection_crew/crew)

	if(crew.upgradePoints >= cost)
		if(maxBuy != -1)
			if(bought >= maxBuy)
				to_chat(user, "<span class='warning'>That upgrade has already been maxed out!</span>")
				return FALSE
		bought++
		crew.upgradePoints -= cost
		return TRUE
	to_chat(user, "<span class='warning'>Not enough upgrade points to buy that upgrade!</span>")
	return FALSE

/datum/factory/dummy