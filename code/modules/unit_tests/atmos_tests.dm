/datum/unit_test/fusion_reaction/Run()
	var/datum/gas_mixture/fusion_test_mix = new

	fusion_test_mix.set_moles(GAS_TRITIUM, 1000)
	fusion_test_mix.set_moles(GAS_PLASMA, 4500)
	fusion_test_mix.set_moles(GAS_CO2, 1500)
	fusion_test_mix.set_moles(GAS_DILITHIUM, 2000)
	fusion_test_mix.set_temperature(FUSION_TEMPERATURE_THRESHOLD - 1)

	if(fusion_test_mix.react() != REACTING)
		TEST_FAIL("Fusion reaction was unable to start!")
	qdel(fusion_test_mix)
