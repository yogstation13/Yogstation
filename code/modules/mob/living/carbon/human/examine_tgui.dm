/datum/examine_panel
	/// Mob that the examine panel belongs to.
	var/mob/living/holder
	/// The screen containing the appearance of the mob
	var/atom/movable/screen/map_view/examine_panel_screen/examine_panel_screen


/datum/examine_panel/ui_state(mob/user)
	return GLOB.always_state


/datum/examine_panel/ui_close(mob/user)
	user.client.clear_map(examine_panel_screen.assigned_map)


/atom/movable/screen/map_view/examine_panel_screen
	name = "examine panel screen"


/datum/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!examine_panel_screen)
		examine_panel_screen = new
		examine_panel_screen.name = "screen"
		examine_panel_screen.assigned_map = "examine_panel_[REF(holder)]_map"
		examine_panel_screen.del_on_map_removal = FALSE
		examine_panel_screen.screen_loc = "[examine_panel_screen.assigned_map]:1,1"

	var/mutable_appearance/current_mob_appearance = new(holder)
	current_mob_appearance.setDir(SOUTH)
	current_mob_appearance.transform = matrix() // We reset their rotation, in case they're lying down.

	// In case they're pixel-shifted, we bring 'em back!
	current_mob_appearance.pixel_x = 0
	current_mob_appearance.pixel_y = 0

	examine_panel_screen.cut_overlays()
	examine_panel_screen.add_overlay(current_mob_appearance)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		examine_panel_screen.display_to(user)
		user.client.register_map_obj(examine_panel_screen)
		ui = new(user, src, "ExaminePanel")
		ui.open()


/datum/examine_panel/ui_data(mob/user)
	var/list/data = list()

	var/flavor_text
	var/obscured
	var/ideal_antag_optin_status
	var/current_antag_optin_status
	var/headshot = ""

	if(ishuman(holder))
		var/mob/living/carbon/human/holder_human = holder
		obscured = (holder_human.wear_mask && (holder_human.wear_mask.flags_inv & HIDEFACE)) || (holder_human.head && (holder_human.head.flags_inv & HIDEFACE))
		flavor_text = obscured ? "Obscured" :  holder_human.dna.features["flavor_text"]
		if(!obscured)
			headshot += holder_human.dna.features["headshot"]

	var/name = obscured ? "Unknown" : holder.name

	data["obscured"] = obscured ? TRUE : FALSE
	data["character_name"] = name
	data["assigned_map"] = examine_panel_screen.assigned_map
	data["flavor_text"] = flavor_text
	data["headshot"] = headshot

	data["ideal_antag_optin_status"] = ideal_antag_optin_status
	data["current_antag_optin_status"] = current_antag_optin_status
	return data

/datum/examine_panel/ui_static_data(mob/user)
	var/list/data = list()

	return data
