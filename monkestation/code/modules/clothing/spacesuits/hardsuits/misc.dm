/obj/item/clothing/suit/space/hardsuit/hop
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-hop"
	max_integrity = 300
	armor_type = /datum/armor/hardsuit/hop
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/hop

/obj/item/clothing/head/helmet/space/hardsuit/hop
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-hop"
	max_integrity = 300
	armor_type = /datum/armor/hardsuit/hop
	hardsuit_type = "hop"

//----------------
// Mining Hardsuit
//----------------
/obj/item/clothing/suit/space/hardsuit/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	icon_state = "hardsuit-mining"
	armor_type = /datum/armor/hardsuit/mining/explorer
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/gun/energy/recharge/kinetic_accelerator, //i imagine this suit has a bunch of hooks and pockets for tools :P
		/obj/item/storage/bag/ore,
		/obj/item/pickaxe,
		/obj/item/tank/jetpack/mining,
		/obj/item/tank/jetpack/oxygen/captain,
		)

/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	armor_type = /datum/armor/hardsuit/mining/explorer
	hardsuit_type = "mining"
	light_outer_range = 7

/datum/armor/hardsuit/mining/explorer
	bullet = 30
	laser = 30

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)

	MakeHelmet()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

//----------------------------------------
// Clown Hardsuit  PRAISE THE HONKMOTHER!
//----------------------------------------
/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit made by Honk! Co. that protects against hazardous, low-humor environments. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	armor_type = /datum/armor/hardsuit/clown
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/bikehorn,//essential for deep space clown survival
		)

/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment."
	icon_state = "hardsuit0-clown"
	armor_type = /datum/armor/hardsuit/clown
	hardsuit_type = "clown"

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(is_clown_job(H.mind?.assigned_role))
		return TRUE
	else
		to_chat(M, span_clown("ERROR: CLOWN COLLEGE DIPLOMA NOT FOUND")) //better enroll in clown college bucko
		return FALSE

//-------------------
// Security Hardsuit
//-------------------
/obj/item/clothing/suit/space/hardsuit/sec
	name = "security hardsuit"
	desc = "A special suit designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit-sec"
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/species/suit_digi.dmi'
	armor_type = /datum/armor/hardsuit/sec
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/sec
	allowed = list(
		/obj/item/tank/jetpack/security,
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/gun/microfusion,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/storage/belt/holster/detective,
		/obj/item/storage/belt/holster/nukie,
		/obj/item/storage/belt/holster/energy,
		/obj/item/clothing/mask/breath/sec_bandana,
	)

/obj/item/clothing/head/helmet/space/hardsuit/sec
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	armor_type = /datum/armor/hardsuit/sec
	hardsuit_type = "sec"

/obj/item/clothing/head/helmet/space/hardsuit/sec/New(loc, ...)
	. = ..()
	hud_glasses = new /obj/item/clothing/glasses/hud/security(src)
