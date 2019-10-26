/obj/machinery/factory/mill
	name = "automated milling machine"
	desc = "A machine that takes raw materials, and forms them so they are ready for assembly."
	icon_state = "autolathe"
	var/cooldown = 60
	var/cooldownTimer

	var/ammo_boni = 0

	var/list/storedItems = list()

	upgradeBase = /datum/factory/mill



/obj/machinery/factory/mill/Initialize()
	START_PROCESSING(SSobj, src)
	..()

/obj/machinery/factory/mill/process()
	Mill()

	var/atom/input = get_step(src, input_dir)
	var/obj/item/factory/base/item = locate() in input
	if(!item)
		return
	if(item.stage != FACTORY_BASE)
		return

	storedItems += item
	item.forceMove(src)

/obj/machinery/factory/mill/proc/Mill()
	if(cooldownTimer > world.time)
		return

	if(storedItems.len == 0)
		return

	var/obj/item/factory/base/pItem = storedItems[1]
	if(!pItem)
		return
	pItem.setStage(FACTORY_MILLED)
	applyBonus(pItem)

	storedItems -= pItem

	var/turf = get_step(src, output_dir)
	pItem.forceMove(turf)

	cooldownTimer = world.time + cooldown

/obj/machinery/factory/mill/proc/applyBonus(obj/item/factory/base/item)
	//item.ammo_bonus += ammo_boni
	return

/obj/machinery/factory/mill/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Milling Machine</h2>"
	var/cooler = cooldownTimer - world.time

	if(cooler < 0)
		cooler = 0

	dat += "Base Cooldown: [cooldown / 10] second(s)<br>"
	dat += "Cooldown Timer: [cooler / 10] second(s)"

	dat += "<br><br>"

	dat += "<h2>Upgrade points: [crew.upgradePoints]</h2><br>"

	dat += "<br><h3>Available Upgrades</h3>"
	for(var/datum/factory/upgrade in availableUpgrades)
		dat += "<a href='?src=[REF(src)];upgrade=[upgrade.id]'>[upgrade.name]</a><br>"
		var/max = upgrade.maxBuy
		if(max == -1)
			max = "Infinite"
		dat += "Bought: [upgrade.bought]/[max]"


	var/datum/browser/popup = new(user, "computer", "Assembling Machine", 375, 375)
	popup.set_content(dat)
	popup.open()


/datum/factory/mill/cooldown
	name = "Cooldown Upgrade (-1.5 second cooldown)"
	cost = 1
	id = "dispenser_cooldown_mill"
	maxBuy = 4

/datum/factory/mill/cooldown/onUpgrade(obj/machinery/factory/dispenser/machine, user)
	if(..())
		machine.cooldown -= 15
