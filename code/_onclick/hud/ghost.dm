/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered()
	. = ..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/jump_to_mob
	name = "Jump to mob"
	icon_state = "jump_to_mob"

/atom/movable/screen/ghost/jump_to_mob/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/spawners
	name = "Ghost role spawners"
	icon_state = "spawners"

/atom/movable/screen/ghost/spawners/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/jump_to_mob(src)
	using.screen_loc = ui_ghost_jump_to_mob
	static_inventory += using

	using = new /atom/movable/screen/ghost/orbit(src)
	using.screen_loc = ui_ghost_orbit
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse(src)
	using.screen_loc = ui_ghost_reenter_corpse
	static_inventory += using

	using = new /atom/movable/screen/ghost/teleport(src)
	using.screen_loc = ui_ghost_teleport
	static_inventory += using

	using = new /atom/movable/screen/ghost/spawners(src)
	using.screen_loc = ui_ghost_spawners
	static_inventory += using

	using = new /atom/movable/screen/ghost/med_scan(src)
	using.screen_loc = ui_ghost_med
	static_inventory += using

	using = new /atom/movable/screen/ghost/chem_scan(src)
	using.screen_loc = ui_ghost_chem
	static_inventory += using

	using = new /atom/movable/screen/ghost/nanite_scan(src)
	using.screen_loc = ui_ghost_nanite
	static_inventory += using

	using = new /atom/movable/screen/ghost/wound_scan(src)
	using.screen_loc = ui_ghost_wound
	static_inventory += using

	using = new /atom/movable/screen/ghost/pai(src)
	using.screen_loc = ui_ghost_pai
	static_inventory += using

	using = new /atom/movable/screen/language_menu/ghost(src)
	using.icon = ui_style
	static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(screenmob.client.prefs.read_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen += static_inventory
	else
		screenmob.client.screen -= static_inventory

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		return
	. = ..()
