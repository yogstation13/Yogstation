/datum/chemical_infuser_recipe/sulfur
	name = "Sulfur"
	required_reagents = list(/datum/reagent/gunpowder = 5)
	required_gases = list(/datum/gas/oxygen = 5)
	outputs = list(/datum/reagent/sulfur = 50)

/datum/chemical_infuser_recipe/sulfur_trioxide
	name = "Sulfur Trioxide"

	required_reagents = list(/datum/reagent/sulfur/dioxide = 5)
	required_gases = list(/datum/gas/oxygen = 5)
	outputs = list(/datum/reagent/sulfur/trioxide = 10)

/datum/chemical_infuser_recipe/sulfuric_acid
	name = "Sulfuric Acid"

	required_gases = list(/datum/gas/oxygen = 5)
	required_reagents = list(/datum/reagent/sulfur/trioxide = 5)
	outputs = list(/datum/reagent/toxin/acid = 10)


/datum/reagent/sulfur/dioxide
	name = "Sulfur Dioxide"

/datum/reagent/sulfur/trioxide
	name = "sulfur Trioxide"
