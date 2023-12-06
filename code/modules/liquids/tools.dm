/client/proc/spawn_liquid()
	set category = "Admin.Fun"
	set name = "Spawn Liquid"
	set desc = "Spawns an amount of chosen liquid at your current location."

	var/choice
	var/valid_id
	while(!valid_id)
		choice = tgui_input_text(usr, "Enter the ID of the reagent you want to add.", "Search reagents")
		if(isnull(choice)) //Get me out of here!
			break
		if (!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if (ispath(choice))
				valid_id = TRUE
		else
			valid_id = TRUE
		if(!valid_id)
			to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
	if(!choice)
		return
	var/volume = tgui_input_number(usr, "Volume:", "Choose volume")
	if(!volume)
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.add_liquid(choice, volume)
	message_admins("[ADMIN_LOOKUPFLW(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")

/client/proc/remove_liquid(turf/epicenter in world)
	set name = "Remove Liquids"
	set category = "Admin.Game"
	set desc = "Fixes air in specified radius."

	var/range = tgui_input_number(usr, "Enter range:", "Range selection", 2)

	for(var/obj/effect/abstract/liquid_turf/liquid in range(range, epicenter))
		qdel(liquid, TRUE)

	message_admins("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
	log_game("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
