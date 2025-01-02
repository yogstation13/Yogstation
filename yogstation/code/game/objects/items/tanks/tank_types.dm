/obj/item/tank/internals/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	icon_state = "oxygen_fr"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/nitrogen/populate_gas()
	air_contents.set_moles(GAS_N2, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/emergency_oxygen/nitrogen
	name = "emergency nitrogen tank"
	desc = "An emergency tank designed specifically for Vox."
	icon_state = "emergency_nitrogen"

/obj/item/tank/internals/emergency_oxygen/nitrogen/populate_gas()
	air_contents.set_moles(GAS_N2, (10*ONE_ATMOSPHERE)* volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/emergency_oxygen/vox
	name = "vox specialized nitrogen tank"
	desc = "A high-tech nitrogen tank designed specifically for Vox."
	icon_state = "emergency_vox"
	volume = 35

/obj/item/tank/internals/emergency_oxygen/vox/populate_gas()
	air_contents.set_moles(GAS_N2, (10*ONE_ATMOSPHERE)* volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/emergency_oxygen/vox/empty/populate_gas()
	return
