/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = tgui_input_list(usr, "Do you want to add or remove traits?", "Modify Traits", items = list("Add", "Remove"))
	if(!add_or_remove)
		return
	var/list/available_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					available_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.global_trait_name_map)
				GLOB.global_trait_name_map = generate_global_trait_name_map()
			for(var/trait in D._status_traits)
				var/name = GLOB.global_trait_name_map[trait] || trait
				available_traits[name] = trait

	var/list/chosen_trait_names = tgui_input_checkboxes(usr, "Select which traits you want to [lowertext(add_or_remove)]", "Modify Traits", items = sort_list(assoc_to_keys(available_traits)))
	if(!chosen_trait_names)
		return
	var/list/chosen_traits = list()
	for(var/name in chosen_trait_names)
		chosen_traits += available_traits[name]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			if(length(chosen_traits & assoc_to_keys(GLOB.movement_type_trait_to_flag)))
				D.AddElement(/datum/element/movetype_handler)
			D.add_traits(chosen_traits, source)
		if("Remove")
			var/specific = tgui_input_list(usr, "All or specific source?", "Modify Traits", items = list("All", "Specific"))
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					var/list/shared_sources = list()
					for(var/trait in chosen_traits)
						if(!length(shared_sources))
							shared_sources = GET_TRAIT_SOURCES(D, trait)
						else
							shared_sources &= GET_TRAIT_SOURCES(D, trait)
					source = tgui_input_list(usr, "Source to be removed", "Modify Traits", items = sort_list(shared_sources))
					if(!source)
						return
			D.remove_traits(chosen_traits, source)
