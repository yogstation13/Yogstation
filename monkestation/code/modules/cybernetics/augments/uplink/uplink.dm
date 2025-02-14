/datum/uplink_item/bundles_tc/sandy
	name = "Sandevistan Bundle"
	desc = "A box containing autosurgeons for a cyberlink and a sandevistan, allowing you to outspeed targets."
	item = /obj/item/storage/box/syndie_kit/sandy
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/sandy/PopulateContents()
	new /obj/item/autosurgeon/syndicate/cyberlink_syndicate(src)
	new /obj/item/autosurgeon/organ/syndicate/sandy(src)


/datum/uplink_item/bundles_tc/mantis
	name = "Mantis Blade Bundle"
	desc = "A box containing autosurgeons for a cyberlink and two mantis blade implants, one for each arm."
	item = /obj/item/storage/box/syndie_kit/mantis
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/mantis/PopulateContents()
	new /obj/item/autosurgeon/syndicate/cyberlink_syndicate(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis/l(src)

/datum/uplink_item/bundles_tc/dualwield
	name = "C.C.M.S Bundle"
	desc = "A box containing autosurgeons for a cyberlink and a C.C.M.S implant that lets you dual wield melee weapons."
	item = /obj/item/storage/box/syndie_kit/dualwield
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/dualwield/PopulateContents()
	new /obj/item/autosurgeon/syndicate/cyberlink_syndicate(src)
	new /obj/item/autosurgeon/organ/syndicate/dualwield(src)
