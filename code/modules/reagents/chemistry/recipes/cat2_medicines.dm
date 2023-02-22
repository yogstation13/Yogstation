
/*****BRUTE*****/

/datum/chemical_reaction/medicine/libital
	name = "libital"
	id = /datum/reagent/medicine/c2/libital
	results = list(/datum/reagent/medicine/c2/libital = 5)
	required_reagents = list(/datum/reagent/phenol = 3, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/medicine/probital
	name = "probital"
	id = /datum/reagent/medicine/c2/probital
	results = list(/datum/reagent/medicine/c2/probital = 4)
	required_reagents = list(/datum/reagent/copper = 1, /datum/reagent/acetone = 2,  /datum/reagent/phosphorus = 1)

/*****BURN*****/

/datum/chemical_reaction/medicine/lenturi
	name = "lenturi"
	id = /datum/reagent/medicine/c2/lenturi
	results = list(/datum/reagent/medicine/c2/lenturi = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulphur = 1, /datum/reagent/oxygen = 1, /datum/reagent/bromine = 1)

/datum/chemical_reaction/medicine/aiuri
	name = "aiuri"
	id = /datum/reagent/medicine/c2/aiuri
	results = list(/datum/reagent/medicine/c2/aiuri = 5)
	required_reagents = list(/datum/reagent/ammonia = 2, /datum/reagent/toxin/acid = 1, /datum/reagent/hydrogen = 2)

/datum/chemical_reaction/medicine/rhigoxane
	name = "rhigoxane"
	id = /datum/reagent/medicine/c2/rhigoxane
	results = list(/datum/reagent/medicine/c2/rhigoxane = 5)
	required_reagents = list(/datum/reagent/cryostylane = 3, /datum/reagent/bromine = 1, /datum/reagent/lye = 1)
	required_temp = 47
	is_cold_recipe = TRUE

/*****OXY*****/

/datum/chemical_reaction/medicine/tirimol
	name = "tirimol"
	id = /datum/reagent/medicine/c2/tirimol
	results = list(/datum/reagent/medicine/c2/tirimol = 5)
	required_reagents = list(/datum/reagent/nitrogen = 3, /datum/reagent/acetone = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)

/*****TOX*****/

/datum/chemical_reaction/medicine/seiver
	name = "seiver"
	id = /datum/reagent/medicine/c2/seiver
	results = list(/datum/reagent/medicine/c2/seiver = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/potassium = 1, /datum/reagent/aluminium = 1)

/datum/chemical_reaction/medicine/thializid
	name = "thializid"
	id = /datum/reagent/medicine/c2/thializid
	results = list(/datum/reagent/medicine/c2/thializid = 5)
	required_reagents = list(/datum/reagent/sulphur = 1, /datum/reagent/fluorine = 1, /datum/reagent/toxin = 1, /datum/reagent/nitrous_oxide = 2)
