/datum/hud/guardian
	ui_style = 'icons/mob/guardian.dmi'

/datum/hud/guardian/New(mob/living/simple_animal/hostile/guardian/owner)
	..()
	var/atom/movable/screen/using

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healths = new /atom/movable/screen/healths/guardian()
	infodisplay += healths

	using = new /atom/movable/screen/guardian/Manifest()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /atom/movable/screen/guardian/Recall()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /atom/movable/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /atom/movable/screen/guardian/Communicate()
	using.screen_loc = ui_back
	static_inventory += using

/atom/movable/screen/guardian
	icon = 'icons/mob/guardian.dmi'

/atom/movable/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"


/atom/movable/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Manifest()


/atom/movable/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/atom/movable/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/atom/movable/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/atom/movable/screen/guardian/ToggleMode/Inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/atom/movable/screen/guardian/ToggleMode/Assassin
	icon_state = "stealth"
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."

/atom/movable/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/atom/movable/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/atom/movable/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/atom/movable/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
