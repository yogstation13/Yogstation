// syndicate depot, meant to be a safe space for syndicate ghostroles to evacuate to if they're knocked out and to provide supplies and materials for their comrades.

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/depot_syndicate
	name = "Syndicate Depot Worker"
	prompt_name = "a syndicate depot worker"
	you_are_text = "You are a depot worker, employed at a Syndicate depot."
	flavour_text = "Produce and move supplies for Syndicate bases in the region, as well as ensure they are safely evacuated should they be lost. Do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base or approach active Nanotrasen installations. Remember that you still need to satisfy escalation requirements in order to send bombs or grenades to the NT installation. However, you may freely explore your surrounding within your current space quadrant (Z-Level), and may fly to other Syndicate bases in space to deliver and move supplies with the permission of the Quartermaster."
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
	important_text = "DO NOT abandon the base or approach active Nanotrasen installations.  Remember that you still need to satisfy escalation requirements in order to send bombs or grenades to the NT installation. You are here to protect it, and cannot perform deliveries."
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
	important_text = "DO NOT abandon the base or approach active Nanotrasen installations.  Remember that you still need to satisfy escalation requirements in order to send bombs or grenades to the NT installation. You can, however, authorise depot workers to perform deliveries outside the local quadrant (Z-level) to other space outposts (but not go yourself), and may freely explore the local quadrant (Z-level) alongside them."
	outfit = /datum/outfit/syndicate_empty/depot/quartermaster

/datum/outfit/syndicate_empty/depot/quartermaster
	name = "Syndicate Depot Quartermaster"
	id_trim = /datum/id_trim/chameleon/operative/nuke_leader //extra access, including opening EVA storage
	uniform = /obj/item/clothing/under/syndicate/sniper
	ears = /obj/item/radio/headset/syndicate/alt/leader
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol/aps = 1
	)

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

/area/ruin/space/has_grav/syndicate_depot/shipbreaking_control
	name = "Syndicate Depot Shipbreaking Magnet Control"


//misc things; fluff, stun-capable turrets

/obj/machinery/porta_turret/syndicate/depot
	name = "depot turret"
	desc = "A ballistic machine-gun auto-turret. This one has had one of its barrels replaced with a taser."
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'

//shipbreaking features
/obj/machinery/computer/shipbreaker/syndicate_depot
	name = "shipbreaking magnet console"
	desc = "A computer linked to the depot's shipbreaking magnet, capable of pulling in abandoned ships from any location."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = COLOR_SOFT_RED
	mapped_start_area = /area/ruin/space/has_grav/syndicate_depot/shipbreaking

/area/ruin/space/has_grav/syndicate_depot/shipbreaking
	name = "Syndicate Depot Shipbreaking Zone"

/obj/item/storage/toolbox/syndicate/shipbreaking
	name = "suspicious salvage toolbox"

/obj/item/storage/toolbox/syndicate/shipbreaking/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/electric/hacked_raynewelder(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool(src)
	new /obj/item/extinguisher/mini(src)

/obj/item/weldingtool/electric/hacked_raynewelder //id make it a subtype of the rayne welder but then id have to override shit
	name = "modified laser welding tool"
	desc = "A Rayne corp laser cutter and welder. This one seems to have been refitted by the Syndicate for general salvage use, though the removal of its safety measures has slightly reduced its efficiency."
	icon = 'monkestation/icons/obj/rayne_corp/rayne.dmi'
	icon_state = "raynewelder"
	inhand_icon_state = "raynewelder"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/engineering_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/engineering_righthand.dmi'
	light_power = 1
	light_color = LIGHT_COLOR_FLARE
	tool_behaviour = NONE
	toolspeed = 0.3
	power_use_amount = 25
	// We don't use fuel
	change_icons = FALSE
	max_fuel = 20

/obj/item/melee/sledgehammer/syndicate_depot //fuck you

/obj/item/melee/sledgehammer/syndicate_depot/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && user)
		/// This will already do low damage, so it doesn't need to be intercepted earlier
		to_chat(user, span_danger("\The [src] is too heavy to attack effectively without being wielded!"))
		return
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/humantarget = target
		if(!HAS_TRAIT(target, TRAIT_SPLEENLESS_METABOLISM) && humantarget.get_organ_slot(ORGAN_SLOT_SPLEEN) && !isnull(humantarget.dna.species.mutantspleen))
			var/obj/item/organ/internal/spleen/target_spleen = humantarget.get_organ_slot(ORGAN_SLOT_SPLEEN)
			target_spleen.apply_organ_damage(5)
	if(!proximity_flag)
		return

	if(target.uses_integrity)
		if(!QDELETED(target))
			if(istype(get_area(target), /area/ruin/space/has_grav/syndicate_depot/shipbreaking))
				if(isstructure(target))
					target.take_damage(force * demolition_mod, BRUTE, MELEE, FALSE, null, 20) // Breaks "structures pretty good"
				if(ismachinery(target))
					target.take_damage(force * demolition_mod, BRUTE, MELEE, FALSE, null, 20) // A luddites friend, Sledghammer good at break machine
			playsound(src, 'sound/effects/bang.ogg', 40, 1)
