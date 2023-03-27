/obj/machinery/airalarm/tcomms
	name = "telecomms air alarm"
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_TCOM_ADMIN)
	TLV = list( // This is the list provided by obj machinery airalarm server. No checks, apparently.
		"pressure"					= new/datum/tlv/no_checks,
		"temperature"				= new/datum/tlv/no_checks,
		/datum/gas/oxygen			= new/datum/tlv/no_checks,
		/datum/gas/nitrogen			= new/datum/tlv/no_checks,
		/datum/gas/carbon_dioxide	= new/datum/tlv/no_checks,
		/datum/gas/miasma			= new/datum/tlv/no_checks,
		/datum/gas/plasma			= new/datum/tlv/no_checks,
		/datum/gas/nitrous_oxide	= new/datum/tlv/no_checks,
		/datum/gas/bz				= new/datum/tlv/no_checks,
		/datum/gas/hypernoblium		= new/datum/tlv/no_checks,
		/datum/gas/water_vapor		= new/datum/tlv/no_checks,
		/datum/gas/tritium			= new/datum/tlv/no_checks,
		/datum/gas/nitrium			= new/datum/tlv/no_checks,
		/datum/gas/pluoxium			= new/datum/tlv/no_checks,
	)
