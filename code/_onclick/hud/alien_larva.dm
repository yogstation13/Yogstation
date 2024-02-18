/datum/hud/larva
	ui_style = 'icons/mob/screen_alien.dmi'

/datum/hud/larva/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/act_intent/alien(src)
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	healths = new /atom/movable/screen/healths/alien(src)
	infodisplay += healths

	alien_queen_finder = new /atom/movable/screen/alien/alien_queen_finder(src)
	infodisplay += alien_queen_finder
	pull_icon = new /atom/movable/screen/pull(src)
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_appearance(UPDATE_ICON)
	pull_icon.screen_loc = ui_above_movement
	hotkeybuttons += pull_icon

	using = new/atom/movable/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel/alien(src)
	zone_select.update_appearance(UPDATE_ICON)
	static_inventory += zone_select
