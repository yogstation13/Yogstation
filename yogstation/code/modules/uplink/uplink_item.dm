/datum/uplink_item
	var/list/include_objectives = list() //objectives to allow the buyer to buy this item
	var/list/exclude_objectives = list() //objectives to disallow the buyer from buying this item

/datum/uplink_item/dangerous/smokebeacon
	name = "Syndicate Smoke Beacon"
	desc = "The smoke beacon is a grenade with a five-second fuse. Upon detonation, it will create a small amount of smoke, \
			to mark the location for a Blue Space Artillery attack. Looks just like a regular smoke grenade."
	item = /obj/item/grenade/smokebeacon
	cost = 7

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
	item = /obj/item/flashlight //doesn't actually spawn a flashlight, but it needs an object to show up in the menu :^)
	cost = 5
	surplus = 0

/datum/uplink_item/device_tools/arm/spawn_item(spawn_item, mob/user)
	var/limbs = user.held_items.len
	user.change_number_of_hands(limbs+1)
	to_chat(user, "You feel more dexterous")


/datum/uplink_item/device_tools/emag
	cost = 8


/datum/uplink_item/role_restricted/his_grace
	include_objectives = list(/datum/objective/hijack)


/datum/uplink_item/role_restricted/gondola_meat
	name = "Gondola meat"
	desc = "A slice of gondola meat will turn any hard-working, brainwashed NT employee into a goody-two-shoes gondola in a matter of minutes."
	item = /obj/item/reagent_containers/food/snacks/meat/slab/gondola
	cost = 6
	restricted_roles = list("Cook")
	
/datum/uplink_item/role_restricted/cluwneburger
	name = "Cluwne Burger"
	desc = "A burger infused with the tears of thousands of cluwnes infects anyone who takes a bite with a cluwnification virus which will turn them into a cluwne"
	item = /obj/item/reagent_containers/food/snacks/burger/cluwneburger
	cost = 25
	restricted_roles = list("Clown", "Cook")
