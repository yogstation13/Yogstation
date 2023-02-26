/obj/machinery/airalarm/tcomms
	name = "telecomms air alarm"
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_TCOM_ADMIN)
	TLV = list( // This is the list provided by obj machinery airalarm server. No checks, apparently.
		"pressure"					= new/datum/tlv/no_checks,
		"temperature"				= new/datum/tlv/no_checks,
		GAS_O2			= new/datum/tlv/no_checks,
		GAS_N2			= new/datum/tlv/no_checks,
		GAS_CO2	= new/datum/tlv/no_checks,
		GAS_MIASMA			= new/datum/tlv/no_checks,
		GAS_PLASMA			= new/datum/tlv/no_checks,
		GAS_NITROUS	= new/datum/tlv/no_checks,
		GAS_BZ				= new/datum/tlv/no_checks,
		GAS_HYPERNOB		= new/datum/tlv/no_checks,
		GAS_H2O		= new/datum/tlv/no_checks,
		GAS_TRITIUM			= new/datum/tlv/no_checks,
		GAS_STIMULUM			= new/datum/tlv/no_checks,
		GAS_NITRYL			= new/datum/tlv/no_checks,
		GAS_PLUOXIUM			= new/datum/tlv/no_checks
	)
