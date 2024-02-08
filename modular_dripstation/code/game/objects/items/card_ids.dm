/obj/item/card/id/departmental_budget
	icon = 'modular_dripstation/icons/obj/card.dmi'
	icon_state = "budgetcard"

/obj/item/card/id/departmental_budget/car
	icon_state = "car_budget"

/obj/item/card/id/departmental_budget/sec
	icon_state = "sec_budget"

/obj/item/card/id/syndicate/nuke
	name = "operative card"
	registered_name = "operative"
	assignment = "Nuclear Squad"
	originalassignment = "Nuclear Squad"
	registered_age = null
	forged = TRUE
	anyone = TRUE
	registered_age = null

/obj/item/card/id/syndicate/nuke_leader
	name = "squad leader card"
	registered_name = "leader"
	assignment = "Nuclear Squad"
	originalassignment = "Nuclear Squad"
	registered_age = null
	forged = TRUE
	anyone = TRUE
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	registered_age = null