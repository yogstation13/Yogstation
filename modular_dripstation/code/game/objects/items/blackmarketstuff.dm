/obj/item/reagent_containers/glass/beaker/thermite
	name = "thermite beaker"
	desc = "Beaker with thermite. Danger, flammable."
	list_reagents = list(/datum/reagent/thermite = 30)

/obj/item/clothing/shoes/bhop/rocket
	name = "rocket boots"
	desc = "Very special boots with built-in rocket thrusters! SHAZBOT!"
	icon_state = "rocketboots"
	icon = 'modular_dripstation/icons/obj/clothing/shoes.dmi'
	actions_types = list(/datum/action/cooldown/boost/brocket)
	jumpdistance = 20 //great for throwing yourself into walls and people at high speeds
	jumpspeed = 5

/datum/action/cooldown/boost/brocket
	name = "Activate Rocket Boots"
	desc = "Activates the boot's rocket propulsion system, allowing the user to hurl themselves great distances."