/datum/brewing_recipe
	///the type path of the reagent
	var/reagent_to_brew = /datum/reagent/consumable/ethanol
	///our display name
	var/display_name = "Pure Coder Tears"
	///pre-reqs: Essentially do we need past recipes made of this, uses the reagent_to_brew var to know if this has been done
	var/pre_reqs
	///the crops typepath we need goes typepath = amount. Amount is not just how many based on potency value up to a cap it adds values.
	var/list/needed_crops = list()
	///the type paths of needed reagents in typepath = amount
	var/list/needed_reagents = list()
	///list of items that aren't crops we need
	var/list/needed_items = list()
	///our brewing time in deci seconds should use the SECONDS MINUTES HOURS helpers
	var/brew_time = 1 SECONDS
	///the price this gets at cargo
	var/cargo_valuation = 0
	///amount of brewed creations used when either canning or bottling
	var/brewed_amount = 1
	///each bottle or canning gives how this much reagents
	var/per_brew_amount = 50
	///helpful hints
	var/helpful_hints
	///if we have a secondary name some do if you want to hide the ugly info
	var/secondary_name
	///typepath of our output if set we also make this item
	var/brewed_item
	///amount of brewed items
	var/brewed_item_count = 1
