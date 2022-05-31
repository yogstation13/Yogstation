/obj/item/organ/lungs/ashwalker
	name = "grey lungs"
	desc = "The grey-ish lungs of an ashwalker."
	icon = 'yogstation/icons/obj/surgery.dmi'
	icon_state = "lungs-ash"

	safe_breath_min = 3
	safe_breath_max = 18
	
	gas_min = list(
		GAS_O2 = 0,
		GAS_N2 = 16,
	)
	gas_max = list(
		GAS_CO2 = 20,
		GAS_PLASMA = 0.05
	)

	SA_para_min = 1
	SA_sleep_min = 5
	BZ_trip_balls_min = 1
	gas_stimulation_min = 0.002
