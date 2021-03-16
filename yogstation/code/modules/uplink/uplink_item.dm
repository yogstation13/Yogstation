/datum/uplink_item
	var/list/include_objectives = list() //objectives to allow the buyer to buy this item
	var/list/exclude_objectives = list() //objectives to disallow the buyer from buying this item
	var/surplus_nullcrates

/datum/uplink_item/New()	
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus

/////////////////////////////////
////////Item re-balancing////////
/////////////////////////////////

/datum/uplink_item/dangerous
	category = "Conspicuous Weapons"

/datum/uplink_item/stealthy_weapons/throwingweapons
	category = "Conspicuous Weapons"

/datum/uplink_item/stealthy_weapons/martialarts
	category = "Conspicuous Weapons"

/datum/uplink_item/stealthy_weapons/cqc
	category = "Conspicuous Weapons"

/datum/uplink_item/stealthy_weapons/romerol_kit
	category = "Conspicuous Weapons"
	include_objectives = list(/datum/objective/hijack, /datum/objective/martyr)

/datum/uplink_item/stealthy_weapons/soap_clusterbang
	category = "Conspicuous Weapons"

/datum/uplink_item/device_tools/hypnotic_flash
	restricted_roles = list("Psychiatrist")
	category = "Role-Restricted"


/datum/uplink_item/dangerous/syndicate_minibomb
	cost = 4

/datum/uplink_item/role_restricted/his_grace
	include_objectives = list(/datum/objective/hijack)

/datum/uplink_item/stealthy_tools/mulligan
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops, /datum/game_mode/traitor/internal_affairs)

/datum/uplink_item/device_tools/fakenucleardisk
	surplus_nullcrates = 0

//////////////////////////
/////////New Items////////
//////////////////////////

/datum/uplink_item/stealthy_weapons/door_charge
	name = "Explosive Airlock Charge"
	desc = "A small, easily concealable device. It can be applied to an open airlock panel, booby-trapping it. \
			The next person to use that airlock will trigger an explosion, knocking them down and destroying \
			the airlock maintenance panel."
	item = /obj/item/doorCharge
	cost = 2
	surplus = 10
	exclude_modes = list(/datum/game_mode/nuclear)


/datum/uplink_item/device_tools/arm
	name = "Additional Arm"
	desc = "An additional arm, automatically added to your body upon purchase, allows you to use more items at once"
	item = /obj/item/melee/supermatter_sword //doesn't actually spawn a supermatter sword, but it needs an object to show up in the menu :^)
	cost = 5
	surplus = 0
	exclude_modes = list(/datum/game_mode/nuclear)
	
/datum/uplink_item/device_tools/arm/nuke
	cost = 15
	exclude_modes = list()
	include_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/arm/spawn_item(spawn_item, mob/user)
	var/limbs = user.held_items.len
	user.change_number_of_hands(limbs+1)
	to_chat(user, "You feel more dexterous")

/datum/uplink_item/role_restricted/gondola_meat
	name = "Gondola meat"
	desc = "A slice of gondola meat will turn any hard-working, brainwashed NT employee into a goody-two-shoes gondola in a matter of minutes."
	item = /obj/item/reagent_containers/food/snacks/meat/slab/gondola
	cost = 6
	restricted_roles = list("Cook")

/datum/uplink_item/role_restricted/cluwneburger
	name = "Cluwne Burger"
	desc = "A burger infused with the tears of thousands of cluwnes. Infects anyone who takes a bite and pretty much everyone else on the station with a cluwnification virus which will quickly turn them into a cluwne. Can only be cured with Mimanas."
	item = /obj/item/storage/box/syndie_kit/cluwnification
	cost = 25
	restricted_roles = list("Clown", "Cook")

/datum/uplink_item/role_restricted/syndicate_basket
	name = "Syndicate Frying Basket"
	desc = "A syndicate basket which allows the deep frying of dead corpses, ejects anything which the corpse is wearing."
	item = /obj/item/syndicate_basket
	cost = 7
	restricted_roles = list("Cook")

/datum/uplink_item/implants/mindslave
	name = "Mindslave Implant"
	desc = "An implant injected into another body, forcing the victim to obey any command by the user."
	item = /obj/item/storage/box/syndie_kit/imp_mindslave
	cost = 7
	manufacturer = /datum/corporation/traitor/cybersun
	surplus = 20

/datum/uplink_item/implants/greytide
	name = "Greytide Implant"
	desc = "An implant injected into another body, forcing the victim to greytide."
	item = /obj/item/storage/box/syndie_kit/imp_greytide
	cost = 5
	surplus = 20
	restricted_roles = list("Assistant")

/datum/uplink_item/badass/frying_pan
	name = "Bananium Plated Frying Pan"
	desc = "A frying pan imbued with ancient powers."
	item = /obj/item/melee/fryingpan/bananium
	cost = 40
	cant_discount = TRUE
