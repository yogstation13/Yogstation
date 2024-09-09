/datum/export/fermented_kegs
	cost = 0
	unit_name = "place holder"
	export_types = list(/obj/structure/fermentation_keg)

/datum/export/fermented_kegs/get_cost(obj/O)
	var/obj/structure/fermentation_keg/keg = O
	var/credit_value = keg.price_tag
	unit_name = keg.selected_recipe?.display_name
	if(!unit_name)
		unit_name = "Unnamed Keg"

	return credit_value
