/datum/uplink_item
	var/list/include_objectives = list() //objectives to allow the buyer to buy this item
	var/list/exclude_objectives = list() //objectives to disallow the buyer from buying this item

/datum/uplink_item/stealthy_weapons/door_charge
	name = "Explosive Airlock Charge"
	desc = "A small, easily concealable device. It can be applied to an open airlock panel, booby-trapping it. \
			The next person to use that airlock will trigger an explosion, knocking them down and destroying \
			the airlock maintenance panel."
	item = /obj/item/doorCharge
	cost = 2
	surplus = 10
	exclude_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/role_restricted/his_grace
	include_objectives = list(/datum/objective/hijack)