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
	mapped_start_area = /area/shipbreak/syndicate_depot

/area/shipbreak/syndicate_depot
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

/obj/item/weldingtool/electric/hacked_raynewelder //depot exclusive gamer loot now, not even necessary
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

//UNIQUE CARGO THEFT ITEM: SYNDICATE BLACKBOX
//syndicate blackboxes contain data that Nanotrasen REALLY wants: can be sold on the cargo shuttle for a hefty sum
//however, will make alert ghosts and radio syndicate outpost staff that it's been stolen

/obj/machinery/syndicate_blackbox_recorder
	name = "syndicate blackbox recorder"
	desc = "A modified blackbox recorder used by Syndicate outposts, usually documenting general happenings of outposts, but also more strategically exotic information such as supply manifests and strike team dispatches. While the black-box is inside, it can't be destroyed. A sticker on it says 'WARNING: REMOVAL OF BLACKBOX WILL SEND A DISTRESS SIGNAL'. Huh."
	density = TRUE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	armor_type = /datum/armor/machinery_blackbox_recorder
	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio //i hate this fucking code
	var/radio_channel = RADIO_CHANNEL_SYNDICATE
	var/obj/item/stored
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //meant to be breakable when box not inserted, but it might shit itself if i change resistance flags mid-operation

/obj/machinery/syndicate_blackbox_recorder/Initialize(mapload)
	. = ..()
	stored = new /obj/item/syndicate_blackbox(src)
	radio = new(src)
	radio.make_syndie()
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	radio.command = TRUE
	radio.use_command = TRUE

/obj/item/syndicate_blackbox
	name = "\proper syndicate black box"
	desc = "A large, heavily armoured black box bearing the insignia of the Syndicate coalition, containing extremely valuable intelligence data. It cannot be teleported with a cargo teleporter. It can be sold on the cargo shuttle to Central Command; getting it there, however..."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackcube"
	inhand_icon_state = "blackcube"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF



/obj/machinery/syndicate_blackbox_recorder/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/syndicate_blackbox))
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] clicks [I] into [src]!"), \
		span_notice("You press the device into [src], and it clicks into place. The tapes begin spinning again."))
		resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		var/area/A = get_area(loc)
		var/message = "Storage device re-connected in [initial(A.name)]."
		radio.talk_into(src, message, radio_channel)
		stored = I
		update_appearance()
		return
	if(istype(I, /obj/item/blackbox))
		user.visible_message(span_notice("[src] buzzes; seems like this type of black-box isn't compatible with the recorder."))
		playsound(src, 'sound/machines/uplinkerror.ogg', 50, TRUE)
		return
	return ..()

/obj/machinery/syndicate_blackbox_recorder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(stored)
		balloon_alert(user, "removing blackbox...")
		if(do_after(user, 60, target = src))
			stored.forceMove(drop_location())
			if(Adjacent(user))
				user.put_in_hands(stored)
			stored = null
			to_chat(user, span_notice("You remove the blackbox from [src]. The tapes stop spinning, and you hear an alarm from inside the recorder."))
			playsound(src, 'sound/effects/alert.ogg', 50, TRUE)
			notify_ghosts("A Syndicate black-box has been stolen!",
			source = src,
			header = "Explorers afoot!",
			)
			var/area/A = get_area(loc)
			var/message = "ALERT: Confidential storage device removed in [initial(A.name)]! Immediate response required!"
			radio.talk_into(src, message, radio_channel)
			resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
			update_appearance()
		return
	else
		to_chat(user, span_warning("It seems that the blackbox is missing..."))
		return

/obj/machinery/syndicate_blackbox_recorder/Destroy()
	if(stored)
		QDEL_NULL(radio)
		stored.forceMove(loc)
		new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/obj/machinery/syndicate_blackbox_recorder/update_icon_state()
	icon_state = "blackbox[stored ? null : "_b"]"
	return ..()

/obj/machinery/syndicatebomb/self_destruct/announce

	desc = "Do not taunt. Warranty invalid if exposed to high temperature. Not suitable for agents under 3 years of age. Alerts Syndicate personnel once armed."
	var/obj/item/radio/radio //i hate this fucking code
	var/radio_channel = RADIO_CHANNEL_SYNDICATE
	anchored = TRUE

/obj/machinery/syndicatebomb/self_destruct/announce/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.make_syndie()
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	radio.command = TRUE
	radio.use_command = TRUE


/obj/machinery/syndicatebomb/self_destruct/announce/activate()
	active = TRUE
	begin_processing()
	countdown.start()
	next_beep = world.time + 10
	detonation_timer = world.time + (timer_set * 10)
	var/area/A = get_area(loc)
	var/message = "ALERT: Self-destruct charge activated in [initial(A.name)]! Detonation in [timer_set] seconds! Evacuate the area immediately!"
	radio.talk_into(src, message, radio_channel)
	playsound(loc, 'sound/machines/click.ogg', 30, TRUE)
	update_appearance()
