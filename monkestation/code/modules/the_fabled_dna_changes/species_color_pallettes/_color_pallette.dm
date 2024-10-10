/datum/color_palette
	var/default_color = "#FFFFFF"

///override this if you need to check if the color can be applied
/datum/color_palette/proc/is_viable_color(color)
	return TRUE

///this is where we apply colors to our palette from our prefs
/datum/color_palette/proc/apply_prefs(datum/preferences/incoming)
	CRASH("Please Override apply_prefs on your color palette")

///this takes 2 inputs varname and mainvar. mainvar is optional but if varname is null trys to return maincolor
/datum/color_palette/proc/return_color(varname, mainvar)
	if(!varname && !mainvar)
		return default_color

	var/retrieved_var = vars[varname]
	if(!retrieved_var)
		if(mainvar)
			retrieved_var = vars[mainvar]
			if(retrieved_var)
				return retrieved_var
		return default_color

	return retrieved_var
