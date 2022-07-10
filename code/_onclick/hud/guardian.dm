/datum/hud/guardian
	ui_style = 'icons/mob/guardian.dmi'

/datum/hud/guardian/New(mob/living/simple_animal/hostile/guardian/owner)
	..()
	var/obj/screen/using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_living_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	healths = new /obj/screen/healths/guardian()
	infodisplay += healths

	using = new /obj/screen/guardian/Manifest()
	using.screen_loc = ui_hand_position(2)
	static_inventory += using

	using = new /obj/screen/guardian/Recall()
	using.screen_loc = ui_hand_position(1)
	static_inventory += using

	using = new owner.toggle_button_type()
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /obj/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/guardian/Communicate()
	using.screen_loc = ui_back
	static_inventory += using

/obj/screen/guardian
	icon = 'icons/mob/guardian.dmi'

/obj/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"


/obj/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Manifest()


/obj/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/obj/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/obj/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/obj/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/obj/screen/guardian/ToggleMode/Inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/obj/screen/guardian/ToggleMode/Assassin
	icon_state = "stealth"
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."

/obj/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/obj/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/obj/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/obj/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
