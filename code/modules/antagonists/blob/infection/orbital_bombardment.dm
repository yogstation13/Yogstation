GLOBAL_LIST_EMPTY(orbital_beacons)
GLOBAL_VAR_INIT(orbital_beacon_count, 0)

/obj/machinery/computer/orbital_bomb
	name = "orbital bombardment control"
	desc = "Used to call down bombardment support."
	icon_screen = "robot"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/robotics
	light_color = LIGHT_COLOR_PINK
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1
	var/datum/infection_crew/crew
	var/warned = FALSE
	var/closing
	var/obj/item/flashlight/glowstick/cyan/orb/selectedTarget = null
	var/datum/orb_munition/selectedMuniton = null
	var/fired = FALSE

/obj/machinery/computer/orbital_bomb/Initialize(mapload)
	..()
	for(var/D in GLOB.crewDatum)
		if(istype(D, /datum/infection_crew))
			crew = D
			return
	if(!crew)
		var/datum/infection_crew/newCrew = new /datum/infection_crew()
		GLOB.crewDatum += newCrew
		crew = newCrew

/obj/machinery/computer/orbital_bomb/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Orbital Bombardment Control System</h2>"
	if(crew.defcon > 3)
		dat += "<h3>DEFCON is not high enough to order orbital bombardment!</h3>"
	else
		dat += "<br><br><h3>Select Bombardment Target:</h3><br>"

		if(fired)
			dat += "<h2>Munition fired, please await detonation.</h2>"

		var/DisplayTarget
		if(selectedTarget)
			if(!selectedTarget.loc.x || !selectedTarget.loc.y)
				DisplayTarget = "None"
				selectedTarget = null
			else
				DisplayTarget = "[selectedTarget.name] (X: [selectedTarget.loc.x], Y: [selectedTarget.loc.y])"
		else
			DisplayTarget = "None"

		dat += "<br><h4>Selected Target: [DisplayTarget]</h4><br>"
		for(var/R in GLOB.orbital_beacons)
			var/obj/item/flashlight/glowstick/cyan/orb/beacon = R
			if(!beacon.loc)
				continue
			dat += "<a href='?src=[REF(src)];select=[beacon.glowID]'>Beacon (X: [beacon.loc.x], Y: [beacon.loc.y])</a><br>"

		dat += "<br><br>"
		dat += "<h3>Select Munitions</h3>"
		var/selectedMunition2
		if(selectedMuniton)
			selectedMunition2 = selectedMuniton.name
		else
			selectedMunition2 = "None"
		dat += "<h4>Selected Munition: [selectedMunition2]</h4><br>"

		for(var/M in crew.orbital_missiles)
			var/datum/orb_munition/selected = M
			dat += "[selected.name] ([selected.amountLeft] left)<br>"
			dat += "[selected.desc]<br>"
			dat += "<a href='?src=[REF(src)];missile=[selected.id]'>Select</a><br><br>"

		dat += "<br><br>"
		dat += "<a href='?src=[REF(src)];fire=1'>Fire!</a>"

	var/datum/browser/popup = new(user, "computer", "Bombardment Control", 375, 700)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/orbital_bomb/Topic(href, href_list)
	. = ..()
	if(.)
		return

	fired = FALSE

	if(href_list["select"])
		for(var/U in GLOB.orbital_beacons)
			var/obj/item/flashlight/glowstick/cyan/orb/beacon = U
			if("[beacon.glowID]" == href_list["select"])
				selectedTarget = beacon

	if(href_list["missile"])
		for(var/U in crew.orbital_missiles)
			var/datum/orb_munition/selected = U
			if("[selected.id]" == href_list["missile"])
				selectedMuniton = selected

	if(href_list["fire"])
		if(crew.defcon > 3)
			return
		if(!selectedMuniton)
			to_chat(usr, "<span>No munition selected!</span>")
			return
		if(!selectedTarget)
			to_chat(usr, "<span>No target selected!</span>")
			return
		if(selectedMuniton.amountLeft < 1)
			to_chat(usr, "<span>Not enough munitions left! Please reselect your choice of munition.</span>")
			return
		if(!selectedTarget.loc)
			selectedTarget = null
			to_chat(usr, "<span>No target selected!</span>")
			return
		if(selectedTarget.firedOn)
			to_chat(usr, "<span>There's already a missile inbound to this target!</span>")
			return
		if(!selectedTarget.loc.x || !selectedTarget.loc.y)
			selectedTarget = null
			to_chat(usr, "<span>Failed. Unknown error.</span>")
			return
		var/dev = selectedMuniton.dev
		var/heavy = selectedMuniton.heavy
		var/light = selectedMuniton.light
		var/flash = selectedMuniton.flash
		var/flame = selectedMuniton.flame
		selectedMuniton.amountLeft--
		selectedTarget.help = new /obj/effect/missileTarget(selectedTarget.loc)
		selectedTarget.firedOn = TRUE
		selectedTarget.prime()
		addtimer(CALLBACK(selectedTarget, .proc/bombard, loc, dev, heavy, light, flash, flame), selectedMuniton.landTime)
		to_chat(usr, "<span>Order recieved, firing.</span>")
		GLOB.orbital_beacons -= selectedTarget
		qdel(selectedTarget)
		selectedTarget = null
		fired = TRUE
	updateUsrDialog()

/obj/machinery/computer/orbital_bomb/proc/bombard(loc, dev, heavy, light, flash, flame)
	explosion(loc, dev, heavy, light, flash_range = flash, flame_range = flame)

/obj/item/flashlight/glowstick/cyan/orb
	name = "orbital bombardment beacon"
	desc = "Throw this at the target, and tell the Big Boss to fire"
	var/listAdded = FALSE
	var/glowID = 0
	var/obj/effect/missileTarget/help = null
	var/firedOn = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/flashlight/glowstick/cyan/orb/Destroy()
	if(listAdded)
		GLOB.orbital_beacons -= src
	..()
/obj/item/flashlight/glowstick/cyan/orb/blob_act()
	return FALSE


/obj/item/flashlight/glowstick/cyan/orb/Initialize(mapload)
	glowID = GLOB.orbital_beacon_count
	GLOB.orbital_beacon_count++
	..()

/obj/item/flashlight/glowstick/cyan/orb/proc/prime()
	interaction_flags_item = FALSE

/obj/item/flashlight/glowstick/cyan/orb/attack_self(mob/user)
	..()

	if(on && !listAdded)
		listAdded = TRUE
		GLOB.orbital_beacons += src

/obj/item/flashlight/glowstick/cyan/orb/proc/bombard(dev = 0, heavy = 0, light = 0, flash = 0, flame = 0)
	GLOB.orbital_beacons -= src
	if(!src.loc)
		return

	explosion(src.loc, dev, heavy, light, flash_range = flash, flame_range = flame)
	if(src)
		if(help)
			qdel(help)
		qdel(src)

/datum/orb_munition
	var/name = "TEST"
	var/desc = "TEST"
	var/amountLeft = 0
	var/landTime = 0
	var/dev = 0
	var/heavy = 0
	var/light = 0
	var/flash = 0
	var/flame = 0
	var/id

/datum/orb_munition/regular
	name = "AGM-472 'Saviour'"
	desc = "A regular missile, with a medium explosion radius. Landing time: Medium"
	landTime = 300
	dev = 2
	heavy = 3
	light = 6
	flash = 9
	flame = 5
	id = "regular"

/datum/orb_munition/fatty
	name = "AS-212 'Fat Man'"
	desc = "An ancient heavy missile, makes a big boom. Landing time: Long"
	landTime = 750
	dev = 4
	heavy = 5
	light = 9
	flash = 15
	flame = 9
	id = "fatty"

/datum/orb_munition/sidewinder
	name = "AGO-2 'Side Winder'"
	desc = "A modern missile, the explosion is smaller than that of the regular AGM-472. Landing time: Short"
	landTime = 125
	dev = 1
	heavy = 3
	light = 5
	flash = 8
	flame = 4
	id = "sidewinder"

/obj/effect/missileTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2