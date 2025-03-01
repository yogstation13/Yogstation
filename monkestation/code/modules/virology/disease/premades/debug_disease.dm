/datum/disease/acute/premade/disease_debug
	name = "Debug Virus"
	form = "Infective code"
	category = DISEASE_DEBUG

	symptoms = list(
		new /datum/symptom/sensory_restoration
	)
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_AIRBORNE
	strength = 100
	robustness = 100

	infectionchance = 100
	infectionchance_base = 100

/datum/disease/acute/premade/fungal_tb/after_add()
	. = ..()
	antigen = null
	stage = 4

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure/debug
	name = "Debug Vaccine autoinjector"
	desc = "An autoinjector to cure Debug disease, which is otherwise incurable. Has a two use system for yourself, and someone else. Inject when infected."
	volume = 20
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/vaccine/debug = 20)

/datum/reagent/vaccine/debug
	name = "Vaccine (Debug)"

/datum/reagent/vaccine/debug/New(data)
	. = ..()
	var/list/cached_data
	if(!data)
		cached_data = list()
	else
		cached_data = data
	cached_data |= "[/datum/disease/acute/premade/disease_debug]"
	src.data = cached_data

/obj/item/storage/box/disease_debug/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/tuberculosiscure/debug(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/cup/bottle/disease_debug(src)

/obj/item/reagent_containers/cup/bottle/disease_debug
	name = "Disease Debug culture bottle"
	desc = "A small bottle, contains a uncurable disease with whatever symtomp the debuggers are feelings at the time."
	spawned_disease = /datum/disease/acute/premade/disease_debug
