/datum/disease/acute/premade/fungal_tb
	name = "Tubercle Bacillus Cosmosis Microbes"
	form = "Fungal Spores"
	origin = "Active fungal spores"
	category = DISEASE_FUNGUS

	symptoms = list(
		new /datum/symptom/fungal_tb
	)
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_AIRBORNE
	robustness = 100
	strength = 100

	infectionchance = 75
	infectionchance_base = 75
	severity = DISEASE_SEVERITY_BIOHAZARD
	required_organs = list(/obj/item/organ/internal/lungs)
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.
	viable_mobtypes = list(/mob/living/carbon/human)

/datum/disease/acute/premade/fungal_tb/after_add()
	. = ..()
	antigen = null
	stage = 4

/datum/disease/acute/premade/fungal_tb/activate(mob/living/mob, starved, seconds_per_tick)
	. = ..()
	if(mob.has_reagent(/datum/reagent/medicine/antipathogenic/spaceacillin, 1))
		if(mob.has_reagent(/datum/reagent/medicine/c2/convermol, 1))
			if(prob(5))
				cure()
