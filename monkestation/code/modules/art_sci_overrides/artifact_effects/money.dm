/datum/artifact_effect/lodedsamoney
	examine_hint = "Might sell well."
	examine_discovered = "Generates an aura of value."
	discovered_credits = CARGO_CRATE_VALUE * 25 //LODESA
	weight = ARTIFACT_UNCOMMON

	type_name = "Economical Aura Effect"
	research_value = 250

/datum/artifact_effect/lodedsamoney/setup()
	discovered_credits *= ((potency+50)/75)
	discovered_credits = round(discovered_credits)
