/datum/bounty/item/atmos
	wanted_types = list(/obj/item/tank)
	var/moles_required = 20 // A full tank is 28 moles, but CentCom ignores that fact.
	var/gas_type

/datum/bounty/item/atmos/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/tank/T = O
	return T.air_contents.get_moles(gas_type) >= moles_required

/datum/bounty/item/atmos/simple/pluoxium
	name = "Full Tank of Pluoxium"
	description = "CentCom RnD is researching extra compact internals. Ship us a tank full of Pluoxium and you'll be compensated."
	reward = 2500
	gas_type = GAS_PLUOXIUM

/datum/bounty/item/atmos/simple/nitryl_tank
	name = "Full Tank of Nitryl"
	description = "The non-human staff of Station 88 has been volunteered to test performance enhancing drugs. Ship them a tank full of Nitryl so they can get started."
	reward = 6000
	gas_type = GAS_NITRYL

/datum/bounty/item/atmos/simple/tritium_tank
	name = "Full Tank of Tritium"
	description = "Station 49 is looking to kickstart their research program. Ship them a tank full of Tritium."
	reward = 3500
	gas_type = GAS_TRITIUM

/datum/bounty/item/atmos/simple/freon_tank
	name = "Full Tank of Freon"
	description = "The Supermatter of station 33 has started the delamination process. Deliver a tank of Freon gas to help them stop it! (20 Moles)"
	reward = 4500
	gas_type = GAS_FREON

/datum/bounty/item/atmos/simple/healium_tank
	name = "Full Tank of Healium"
	description = "Station 42's medical staff are working on an experimental cryogenics setup. They need a tank of Healium. (20 Moles)"
	reward = 8000
	gas_type = GAS_HEALIUM

/datum/bounty/item/atmos/complex/zauker_tank
	name = "Full Tank of Zauker"
	description = "The main planet of \[REDACTED] has been chosen as testing grounds for the new weapon that uses Zauker gas. Ship us a tank full of it. (20 Moles)"
	reward = 25000
	gas_type = GAS_ZAUKER

/datum/bounty/item/atmos/complex/hypernob_tank
	name = "Full Tank of Hypernoblium"
	description = "Station 26's atmospheric division has had a mishap with an experimental fusion mix. Some Hyper-Noblium would be appreciated. (20 Moles)"
	reward = 15000
	gas_type = GAS_HYPERNOB

/datum/bounty/item/atmos/complex/stimulum_tank
	name = "Full Tank of Stimulum"
	description = "Station 14's staff are behind schedule on important research. Ship them some Stimulum to get them back up to speed. (20 Moles)"
	reward = 12000
	gas_type = GAS_STIMULUM

/datum/bounty/item/h2metal/metallic_hydrogen_armor
	name = "Metallic Hydrogen Armors"
	description = "Nanotrasen is requiring new armor to be made. Ship them some metallic hydrogen armors."
	reward = 8000
	required_count = 1
	wanted_types = list(/obj/item/clothing/suit/armor/elder_atmosian)

/datum/bounty/item/h2metal/metallic_hydrogen_helmet
	name = "Metallic Hydrogen Armors"
	description = "Nanotrasen is requiring new helmet to be made. Ship them some metallic hydrogen helmets."
	reward = 7000
	required_count = 1
	wanted_types = list(/obj/item/clothing/head/helmet/elder_atmosian)

/datum/bounty/item/h2metal/metallic_hydrogen_axe
	name = "Metallic Hydrogen axes"
	description = "Nanotrasen is requiring new axes to be made. Ship them some metallic hydrogen helmets."
	reward = 7500
	required_count = 3
	wanted_types = list(/obj/item/twohanded/fireaxe/metal_h2_axe)
