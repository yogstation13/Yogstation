GLOBAL_LIST_EMPTY(factory_dispensers)

/obj/machinery/factory/dispenser
	name = "material dispenser"
	desc = "A machine that accepts wireless orders from a factory controller, and dispenses base ingredients."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	var/cooldown = 50
	var/cooldownTimer

	var/list/queuedItems = list()

	upgradeBase = /datum/factory/dispenser



/obj/machinery/factory/dispenser/Initialize()
	GLOB.factory_dispensers += src
	START_PROCESSING(SSobj, src)
	..()

/obj/machinery/factory/dispenser/process()
	Dispense()

/obj/machinery/factory/dispenser/proc/AddItem(appliedItem, amount)
	var/obj/item/factory/base/ourItem = new(src)
	ourItem.item = appliedItem
	ourItem.createAmount = amount
	queuedItems += ourItem



/obj/machinery/factory/dispenser/proc/Dispense()
	if(cooldownTimer > world.time)
		return

	if(queuedItems.len == 0)
		return



	var/turf = get_step(src, output_dir)
	var/obj/item/ourItem = queuedItems[1]
	ourItem.forceMove(turf)
	queuedItems -= ourItem

	cooldownTimer = world.time + cooldown


/obj/machinery/factory/dispenser/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Dispenser</h2>"
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


	var/datum/browser/popup = new(user, "computer", "Resource Dispenser", 375, 375)
	popup.set_content(dat)
	popup.open()


/datum/factory/dispenser/dispenser_cooldown
	name = "Cooldown Upgrade (-1 second cooldown)"
	cost = 1
	id = "dispenser_cooldown"
	maxBuy = 3

/datum/factory/dispenser/dispenser_cooldown/onUpgrade(obj/machinery/factory/dispenser/machine, user, crew)
	if(..())
		machine.cooldown -= 10