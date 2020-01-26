/obj/machinery/factory/packer
	name = "automated packing machine"
	desc = "A machine that takes assembled materials, and outputs their finished form."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "disposal"
	var/cooldown = 125
	var/cooldownTimer

	var/list/storedItems = list()

	upgradeBase = /datum/factory/assembler



/obj/machinery/factory/packer/Initialize()
	START_PROCESSING(SSobj, src)
	..()

/obj/machinery/factory/packer/process()
	Assemble()

	var/atom/input = get_step(src, input_dir)
	var/obj/item/factory/base/item = locate() in input
	if(!item)
		return
	if(item.stage != FACTORY_ASSEMBLED)
		return

	storedItems += item
	item.forceMove(src)

/obj/machinery/factory/packer/proc/Assemble()
	if(cooldownTimer > world.time)
		return

	if(storedItems.len == 0)
		return

	var/obj/item/factory/base/pItem = storedItems[1]
	if(!pItem)
		return
	pItem.setStage(FACTORY_FINALIZED)

	var/turf = get_step(src, output_dir)
	storedItems -= pItem

	pItem.forceMove(turf)

	pItem.finalize()

	cooldownTimer = world.time + cooldown


/obj/machinery/factory/packer/ui_interact(mob/user)
	. = ..()
	user.set_machine(src)
	var/dat
	dat += "<h2>Packing Machine</h2>"
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


	var/datum/browser/popup = new(user, "computer", "Packing Machine", 375, 375)
	popup.set_content(dat)
	popup.open()


/datum/factory/assembler/cooldown
	name = "Cooldown Upgrade (-2.5 second cooldown)"
	cost = 1
	id = "dispenser_cooldown_mill"
	maxBuy = 4

/datum/factory/assembler/cooldown/onUpgrade(obj/machinery/factory/dispenser/machine, user)
	if(..())
		machine.cooldown -= 25
