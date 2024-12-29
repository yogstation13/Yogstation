// syndicate depot, meant to be a safe space for syndicate ghostroles to evacuate to if they're knocked out and to provide supplies and materials for their comrades.

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/depot_syndicate
	name = "Syndicate Depot Worker"
	prompt_name = "a syndicate depot worker"
	you_are_text = "You are a depot worker, employed at a Syndicate depot."
	flavour_text = "Produce and move supplies for Syndicate bases in the region, as well as ensure they are safely evacuated should they be lost. Do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base or approach active Nanotrasen installations. However, you may freely explore your surrounding within your current space quadrant (Z-Level), and may fly to other Syndicate bases in space to deliver and move supplies with the permission of the Quartermaster."
	outfit = /datum/outfit/syndicate_empty/depot
	spawner_job_path = /datum/job/lavaland_syndicate/space

/datum/outfit/syndicate_empty/depot
	name = "Syndicate Depot Technician"
	suit = /obj/item/clothing/suit/hazardvest
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/utility/hardhat
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/flashlight
	box = /obj/item/storage/box/survival/syndie

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/depot_syndicate/guard
	name = "Syndicate Depot Guard"
	prompt_name = "a syndicate depot guard"
	you_are_text = "You are a security guard, employed at a Syndicate depot."
	flavour_text = "Protect the depot from enemy forces and prevent its destruction at all costs."
	important_text = "DO NOT abandon the base. You are here to protect it, and cannot perform deliveries."
	outfit = /datum/outfit/syndicate_empty/depot/guard

/datum/outfit/syndicate_empty/depot/guard
	name = "Syndicate Depot Guard"
	suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack/security
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/flashlight/seclite
	suit_store = /obj/item/gun/ballistic/shotgun/riot/sol/evil //silly evil gun

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/depot_syndicate/quartermaster
	name = "Syndicate Depot Quartermaster"
	prompt_name = "a syndicate depot quartermaster"
	you_are_text = "You are a Quartermaster, in charge of a Syndicate depot."
	flavour_text = "Operate the depot to ensure it continues to safely ship supplies for the Coalition's outposts in nearby space. Protect it to the last, and do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base. You can, however, authorise depot workers to perform deliveries outside the local quadrant (Z-level) to other space outposts (but not go yourself), and may freely explore the local quadrant (Z-level) alongside them."
	outfit = /datum/outfit/syndicate_empty/depot/quartermaster

/datum/outfit/syndicate_empty/depot/quartermaster
	name = "Syndicate Depot Quartermaster"
	id_trim = /datum/id_trim/chameleon/operative/nuke_leader //extra access, including opening EVA storage
	uniform = /obj/item/clothing/under/syndicate/sniper
	ears = /obj/item/radio/headset/syndicate/alt/leader
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	back = /obj/item/storage/backpack/satchel/leather
	head = /obj/item/clothing/head/hats/hos/beret/syndicate
	l_pocket = /obj/item/melee/energy/sword/saber
	r_pocket = /obj/item/flashlight/lantern/syndicate
	mask = /obj/item/clothing/mask/chameleon //under ANY OTHER CIRCUMSTANCE i'd make it a gps one, but this place is also the safe evacuation zone for any surviving space outpost operatives after a self-destruct event
	l_hand = /obj/item/gun/ballistic/automatic/pistol/aps

//ruin areas

/area/ruin/space/has_grav/syndicate_depot
	name = "Suspicious Asteroid" //i swear to god

/area/ruin/space/has_grav/syndicate_depot/control_room
	name = "Syndicate Depot Control Room"

/area/ruin/space/has_grav/syndicate_depot/security
	name = "Syndicate Depot Security Office"

/area/ruin/space/has_grav/syndicate_depot/cargo_bay
	name = "Syndicate Depot Cargo Bay"

/area/ruin/space/has_grav/syndicate_depot/crew_quarters
	name = "Syndicate Depot Crew Quarters"

/area/ruin/space/has_grav/syndicate_depot/infirmary
	name = "Syndicate Depot Infirmary"

/area/ruin/space/has_grav/syndicate_depot/engineering
	name = "Syndicate Depot Engineering"

/area/ruin/space/has_grav/syndicate_depot/eva_storage
	name = "Syndicate Depot EVA Storage"

/area/ruin/space/has_grav/syndicate_depot/vault
	name = "Syndicate Depot Vault"

/area/ruin/space/has_grav/syndicate_depot/hallway
	name = "Syndicate Depot Main Hallway"

/area/ruin/space/has_grav/syndicate_depot/manufacturing
	name = "Syndicate Depot Manufacturing"

/area/ruin/space/has_grav/syndicate_depot/hydroponics
	name = "Syndicate Depot Hydroponics"


//misc things; fluff, stun-capable turrets

/obj/machinery/porta_turret/syndicate/depot
	name = "depot turret"
	desc = "A ballistic machine-gun auto-turret. This one has had one of its barrels replaced with a taser."
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
