/datum/action/item_action/initialize_ninja_suit
	name = "Toggle ninja suit"

//Current ninja cell is 20000.

/datum/action/item_action/ninjasmoke
	name = "Smoke Bomb (100E)" //0.5%
	desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	button_icon_state = "smoke"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'

/datum/action/item_action/ninjaboost
	check_flags = NONE
	name = "Adrenaline Boost (250E)" //1.25%
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "repulse"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'

/datum/action/item_action/ninjapulse
	name = "EM Burst (5000E)" // 25%
	desc = "Disable any nearby technology with an electro-magnetic pulse."
	button_icon_state = "emp"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'

/datum/action/item_action/ninjastar
	name = "Create Throwing Stars (500E)" //2.5%
	desc = "Creates some throwing stars"
	button_icon_state = "throwingstar"
	icon_icon = 'icons/obj/weapons/misc.dmi'

/datum/action/item_action/ninjanet
	name = "Energy Net (1000E)" //5%
	desc = "Captures a fallen opponent in a net of energy."
	button_icon_state = "energynet"
	icon_icon = 'icons/effects/effects.dmi'

/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana (200E per tile)" //1% per tile.
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/weapons/swords.dmi'

/datum/action/item_action/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off. Only works in darkness."
	button_icon_state = "ninja_cloak"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'

/datum/action/item_action/toggle_glove
	name = "Toggle interaction"
	desc = "Switch between normal interaction and drain mode."
	button_icon_state = "s-ninjan"
	icon_icon = 'icons/obj/clothing/gloves.dmi'
