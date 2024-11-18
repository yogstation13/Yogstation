/datum/supply_pack/security/armory/eva
	name = "Security Hardsuit Crate"
	desc = "Contains two security hardsuits and two security jetpacks."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/sec = 2,
		/obj/item/tank/jetpack/oxygen/security = 2,
	)
	crate_name = "security hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/engineering/eva
	name = "Engineering Hardsuit Crate"
	desc = "Contains two engineering hardsuits."
	cost = CARGO_CRATE_VALUE * 10
	access = ACCESS_CE
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/engine = 2,
	)
	crate_name = "hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/engineering/eva/atmos
	name = "Atmos Hardsuit Crate"
	desc = "Contains two atmospheric hardsuits."
	cost = CARGO_CRATE_VALUE * 10
	access = ACCESS_CE
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/atmos = 2,
	)
	crate_name = "hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/plasma


