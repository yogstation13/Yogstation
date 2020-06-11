/obj/machinery/nuclearbomb/selfdestruct/infection
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	var/datum/infection_crew/crew

	var/obj/item/detonation_key/captain/capKey
	var/obj/item/detonation_key/hos/hosKey
	var/activated = FALSE
	safety = FALSE
	timer_set = 900

/obj/machinery/nuclearbomb/selfdestruct/infection/Initialize(mapload)
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew
	..()

/obj/machinery/nuclearbomb/selfdestruct/infection/attackby(obj/item/I, mob/user, params)
	if(crew.defcon != 1)
		..()
		return
	if (istype(I, /obj/item/detonation_key/captain))
		if(!user.transferItemToLoc(I, src))
			return
		capKey = I
		add_fingerprint(user)
		return
	if (istype(I, /obj/item/detonation_key/hos))
		if(!user.transferItemToLoc(I, src))
			return
		hosKey = I
		add_fingerprint(user)
		return
	..()

/obj/machinery/nuclearbomb/selfdestruct/infection/ui_interact(mob/user, ui_key="main", datum/tgui/ui=null, force_open=0, datum/tgui/master_ui=null, datum/ui_state/state=GLOB.default_state)
	user.set_machine(src)
	var/dat

	dat += "<h2>Self Destruct</h2>"
	if(detonation_timer)
		dat += "<h1>Time to Detonation: [(detonation_timer - world.time) / 10]</h1>"


	if(crew.defcon == 5)
		dat += "<br><h3>There are currently no detected threats, Self-destruct has been locked</h3>"
	else if(crew.tier < 4 && crew.defcon != 5)
		dat += "<br><h3>We do not have enough info to detonate. Please advance in your research first</h3>"
	else
		if(auth)
			dat += "<h3>Nuclear Authentication Disk: <font color='green'>Confirmed</font></h3><br>"
			dat += "<a href='?src=[REF(src)];disk_eject=1'>Eject Disk</a><br>"
		else
			dat += "<h3>Nuclear Authentication Disk: <font color='red'>MISSING</font></h5><br>"

		if(capKey)
			dat += "<h3>Detonation Key #1: <font color='green'>Confirmed</font></h3><br>"
			dat += "<a href='?src=[REF(src)];key_1=1'>Eject Key #1</a><br>"
		else
			dat += "<h3>Detonation Key #1: <font color='red'>MISSING</font></h5><br>"

		if(hosKey)
			dat += "<h3>Detonation Key #2: <font color='green'>Confirmed</font></h3><br>"
			dat += "<a href='?src=[REF(src)];key_2=1'>Eject Key #2</a><br>"
		else
			dat += "<h3>Detonation Key #2: <font color='red'>MISSING</font></h5><br>"

		if(hosKey && capKey && auth)
			dat += "<br>"
			dat += "<a href='?src=[REF(src)];go=1'>Initiate Self-Destruct</a><br>"


	var/datum/browser/popup = new(user, "computer", "Self Destruct", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/nuclearbomb/selfdestruct/infection/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["disk_eject"])
		if(auth && auth.loc == src)
			auth.forceMove(get_turf(src))
			auth = null

	if(href_list["key_1"])
		if(capKey && capKey.loc == src)
			capKey.forceMove(get_turf(src))
			capKey = null

	if(href_list["key_2"])
		if(hosKey && hosKey.loc == src)
			hosKey.forceMove(get_turf(src))
			hosKey = null

	if(href_list["go"])
		if(capKey && hosKey && auth && !exploded && !activated)
			set_active()
			activated = TRUE
			crew.changeDefcon(1)

	ui_interact(usr)
	updateUsrDialog()

/obj/item/detonation_key
	name = "detonation key"
	desc = "Keep this handy, you might need it today..."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 250000
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/detonation_key/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, TRUE)

/obj/item/detonation_key/captain
	name = "Captain's detonation key"
	desc = "Pray you won't need this Captain"

/obj/item/detonation_key/hos
	name = "HoS's detonation key"
	desc = "You know what needs to be done, HoS"