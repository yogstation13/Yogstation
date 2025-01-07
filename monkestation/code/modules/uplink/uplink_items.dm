///Override for any unique checks for specific items, by default returns TRUE
/datum/uplink_item/proc/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	return TRUE

/datum/uplink_item/dangerous/lever_action
	name = "Pump action Shotgun"
	desc = "A classic sturdy and robust shotgun. Fits five shells."
	item = /obj/item/gun/ballistic/shotgun/lethal
	cost = 7

//NEW TOT SHOTGUN AMMO BOXES
/datum/uplink_item/ammo/trickshot
	name = "Trickshot Shell Box"
	desc = "A box with 10 trickshot shells, capable of bouncing up to five times, they are made for the most talented trickshooters around."
	cost = 3
	item = /obj/item/storage/box/trickshot

/datum/uplink_item/ammo/uraniumpen
	name = "Uranium Penetrator Box"
	desc = "A box with 10 uranium penetrators, capable to penetrating walls and objects, but not people. Works best with thermals!"
	cost = 3
	item = /obj/item/storage/box/uraniumpen

/datum/uplink_item/ammo/beeshot
	name = "Beeshot Box"
	desc = "A box with 10 Beeshot shells. Creates very angry bees upon impact. Not as strong as buckshot."
	cost = 3
	item = /obj/item/storage/box/beeshot

//END OF NEW TOT SHOTGUN AMMO
