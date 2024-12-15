// this is going to be so much work but let's see how far i can get
//-----------------
// Ordering:
// ROLES
// *Generic
// *Commander
// *Medic
// *Security Officer
// *Engineer
// *Janitor
// *Chaplain
// *Clown
// OTHER

/datum/antagonist/ert/generic
	name = "Emergency Response Officer"
	role = "Officer"
	outfit = /datum/outfit/centcom/ert/generic
	ert_job_path = /datum/job/ert/generic

/datum/antagonist/ert/generic/greet()
	..()
	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/ambience/antag/ert.ogg', 100, 0, use_reverb = FALSE) //monkestation addition

/datum/outfit/centcom/ert/generic
	name = "Emergency Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic
	box = /obj/item/storage/box/survival/ert
	uniform = /obj/item/clothing/under/rank/centcom/officer
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat/ert
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/space/ert
	suit_store = /obj/item/gun/energy/e_gun
	head = /obj/item/clothing/head/helmet/space/ert
	belt = /obj/item/tank/jetpack/oxygen/harness
	back = /obj/item/storage/backpack/ert/generic
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/knife/combat = 1,
	)
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/restraints/handcuffs

/datum/outfit/centcom/ert/generic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/cyberlink/nt_high/cyberlink = new()
	cyberlink.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/chest/nutriment/plus/nutriment_pump = new()
	nutriment_pump.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/commander
	name = "Code Green Emergency Response Team Commander"
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/generic/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander
	ert_job_path = /datum/job/ert/commander

/datum/outfit/centcom/ert/generic/commander
	name = "Code Green Emergency Response Team Commander"

	id = /obj/item/card/id/advanced/centcom/ert/generic/commander
	suit = /obj/item/clothing/suit/space/ert/commander
	head = /obj/item/clothing/head/helmet/space/ert/commander
	back = /obj/item/storage/backpack/ert/commander
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/knife/combat = 1,
		/obj/item/pinpointer/nuke = 1,
	)
	glasses = /obj/item/clothing/glasses/sunglasses/big //bigger sunglasses means they are cooler and have more authority
	additional_radio = /obj/item/encryptionkey/heads/captain
	skillchips = list(/obj/item/skillchip/disk_verifier, /obj/item/skillchip/job/research_director)

/datum/antagonist/ert/generic/commander/blue
	name = "Code Blue Emergency Response Team Commander"
	outfit = /datum/outfit/centcom/ert/generic/commander/blue

/datum/outfit/centcom/ert/generic/commander/blue
	name = "Code Blue Emergency Response Team Commander"

	shoes = /obj/item/clothing/shoes/magboots
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/knife/combat = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 1,
		/obj/item/ammo_box/magazine/m45 = 1,
	)
	l_hand = /obj/item/storage/lockbox/loyalty

/datum/outfit/centcom/ert/generic/commander/blue/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/sec_hud = new()
	sec_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/commander/red
	name = "Code Red Emergency Response Team Commander"
	outfit = /datum/outfit/centcom/ert/generic/commander/red

/datum/outfit/centcom/ert/generic/commander/red
	name = "Code Red Emergency Response Team Commander"

	id = /obj/item/card/id/advanced/centcom/ert
	suit = null
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/storage/belt/security/full/bola
	back = /obj/item/mod/control/pre_equipped/responsory/generic/commander
	backpack_contents = list(
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/knife/combat = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/storage/box/syndie_kit/imp_deathrattle/nanotrasen = 1,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 1,
		/obj/item/ammo_box/magazine/m45 = 2,
	)
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/holosign_creator/security
	l_hand = /obj/item/storage/lockbox/loyalty

/datum/outfit/centcom/ert/generic/commander/red/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/sec_hud = new()
	sec_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/medical
	name = "Code Green Medical Response Officer"
	role = "Medical Officer"
	outfit = /datum/outfit/centcom/ert/generic/medical
	ert_job_path = /datum/job/ert/medical

/datum/outfit/centcom/ert/generic/medical
	name = "Code Green Medical Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/medical
	gloves = /obj/item/clothing/gloves/latex/nitrile
	suit = /obj/item/clothing/suit/space/ert/medical
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/medical
	back = /obj/item/storage/backpack/ert/medical
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/belt/medical/paramedic = 1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/emergency_bed = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	additional_radio = /obj/item/encryptionkey/headset_med
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/antagonist/ert/generic/medical/blue
	name = "Code Blue Medical Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/medical

/datum/outfit/centcom/ert/generic/medical/blue
	name = "Code Blue Medical Response Officer"

	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/latex/surgical
	suit_store = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/box/medipens = 1,
		/obj/item/storage/belt/medical/ert = 1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/reagent_containers/hypospray/cmo = 1, //this shouldn't cause any problems?
		/obj/item/emergency_bed = 1,
		/obj/item/healthanalyzer/advanced = 1,
	)

/datum/antagonist/ert/generic/medical/red
	name = "Code Red Medical Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/medical/red

/datum/outfit/centcom/ert/generic/medical/red
	name = "Code Red Medical Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/medical
	suit = null
	gloves = /obj/item/clothing/gloves/latex/surgical
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/defibrillator/compact/combat/loaded/nanotrasen
	back = /obj/item/mod/control/pre_equipped/responsory/generic/medic
	backpack_contents = list(
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/box/medipens = 1,
		/obj/item/storage/belt/medical/paramedic = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/pinpointer/crew = 1,
		/obj/item/emergency_bed = 1,
		/obj/item/healthanalyzer/advanced = 1,
	)
	glasses = /obj/item/clothing/glasses/night
	r_pocket = /obj/item/holosign_creator/security
	additional_radio = /obj/item/encryptionkey/heads/cmo

/datum/outfit/centcom/ert/generic/medical/red/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/arm/item_set/surgery/surgery_toolset = new()
	surgery_toolset.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/eyes/hud/medical/med_hud = new()
	med_hud.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/brain/linked_surgery/serverlink = new()
	serverlink.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/security
	name = "Code Green Security Response Officer"
	role = "Security Officer"
	outfit = /datum/outfit/centcom/ert/generic/security
	ert_job_path = /datum/job/ert/security

/datum/outfit/centcom/ert/generic/security
	name = "Code Green Security Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/security
	suit = /obj/item/clothing/suit/space/ert/security
	head = /obj/item/clothing/head/helmet/space/ert/security
	back = /obj/item/storage/backpack/ert/security
	backpack_contents = list(
		/obj/item/knife/combat = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/storage/belt/security/full/bola = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/holosign_creator/security
	additional_radio = /obj/item/encryptionkey/headset_sec

/datum/antagonist/ert/generic/security/blue
	name = "Code Blue Security Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/security/blue

/datum/outfit/centcom/ert/generic/security/blue
	name = "Code Blue Security Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/security
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/ert/security
	suit_store = /obj/item/gun/energy/laser
	back = /obj/item/storage/backpack/ert/security
	backpack_contents = list(
		/obj/item/knife/combat = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/storage/belt/security/full/bola = 1,
	)

/datum/antagonist/ert/generic/security/red
	name = "Code Red Security Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/security/red

/datum/outfit/centcom/ert/generic/security/red
	name = "Code Red Security Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/security
	suit = null
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/storage/belt/security/full/bola
	back = /obj/item/mod/control/pre_equipped/responsory/generic/security
	backpack_contents = list(
		/obj/item/knife/combat = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/box/stingbangs = 1,
		/obj/item/shield/riot/tele = 1,
	)
	glasses = /obj/item/clothing/glasses/night
	additional_radio = /obj/item/encryptionkey/heads/hos

/datum/outfit/centcom/ert/generic/security/red/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/sec_hud = new()
	sec_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/engineer
	name = "Code Green Engineering Response Officer"
	role = "Engineering Officer"
	outfit = /datum/outfit/centcom/ert/generic/engineer
	ert_job_path = /datum/job/ert/engineer

/datum/outfit/centcom/ert/generic/engineer
	name = "Code Green Engineering Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/engineer
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/ert/engineer
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/engineer
	back = /obj/item/storage/backpack/ert/engineer
	backpack_contents = list(
		/obj/item/storage/belt/utility/full/engi = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/analyzer = 1,
		/obj/item/extinguisher = 1,
		/obj/item/pipe_dispenser = 1,
	)
	glasses = /obj/item/clothing/glasses/meson/engine
	additional_radio = /obj/item/encryptionkey/headset_eng
	skillchips = list(/obj/item/skillchip/job/engineer, /obj/item/skillchip/job/roboticist)

/datum/antagonist/ert/generic/engineer/blue
	name = "Code Blue Engineering Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/engineer/blue

/datum/outfit/centcom/ert/generic/engineer/blue
	name = "Code Blue Engineering Response Officer"

	shoes = /obj/item/clothing/shoes/magboots/advance
	suit_store = /obj/item/gun/energy/e_gun
	back = /obj/item/storage/backpack/ert/engineer
	backpack_contents = list(
		/obj/item/storage/belt/utility/full/powertools = 1,
		/obj/item/storage/box/rcd_upgrades = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/analyzer/ranged = 1,
		/obj/item/extinguisher/advanced = 1,
		/obj/item/pipe_dispenser = 1,
	)

/datum/outfit/centcom/ert/generic/engineer/blue/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic/diagnostic_hud = new()
	diagnostic_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/engineer/red
	name = "Code Red Engineering Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/engineer/red

/datum/outfit/centcom/ert/generic/engineer/red
	name = "Code Red Engineering Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/engineer
	shoes = /obj/item/clothing/shoes/combat
	suit = null
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/storage/bag/sheetsnatcher
	back = /obj/item/mod/control/pre_equipped/responsory/generic/engineer
	backpack_contents = list(
		/obj/item/construction/rcd/loaded/upgraded = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/analyzer/ranged = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/holosign_creator/atmos = 1,
		/obj/item/t_scanner = 1,
		/obj/item/stack/cable_coil = 1,
	)
	glasses = /obj/item/clothing/glasses/meson/night
	additional_radio = /obj/item/encryptionkey/heads/ce
	r_pocket = /obj/item/holosign_creator/security

/datum/outfit/centcom/ert/generic/engineer/red/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic/diagnostic_hud = new()
	diagnostic_hud.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/arm/item_set/toolset/toolset_implant = new()
	toolset_implant.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/janitor
	name = "Code Green Janitorial Response Officer"
	role = "Janitorial Officer"
	outfit = /datum/outfit/centcom/ert/generic/janitor
	ert_job_path = /datum/job/ert/janitor

/datum/outfit/centcom/ert/generic/janitor
	name = "Code Green Janitorial Response Officer"
	id = /obj/item/card/id/advanced/centcom/ert/generic/janitor
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/ert/janitor
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/janitor
	back = /obj/item/storage/backpack/ert/janitor
	backpack_contents = list(
		/obj/item/storage/belt/janitor/full = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/pushbroom = 1,
		/obj/item/reagent_containers/spray/drying = 1,
		/obj/item/grenade/chem_grenade/cleaner = 2,
	)
	l_hand = /obj/item/storage/bag/trash
	additional_radio = /obj/item/encryptionkey/headset_service
	skillchips = list(/obj/item/skillchip/job/janitor)

/datum/antagonist/ert/generic/janitor/blue
	name = "Code Blue Janitorial Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/janitor/blue

/datum/outfit/centcom/ert/generic/janitor/blue
	name = "Code Blue Janitorial Response Officer"
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit_store = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/storage/belt/janitor/full/ert = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/pushbroom = 1,
		/obj/item/reagent_containers/spray/drying = 1,
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/scythe/compact = 1,
		/obj/item/grenade/chem_grenade/antiweed = 1,
	)
	l_hand = /obj/item/storage/bag/trash/bluespace
	additional_radio = /obj/item/encryptionkey/headset_service
	skillchips = list(/obj/item/skillchip/job/janitor)

/datum/antagonist/ert/generic/janitor/red
	name = "Code Red Janitorial Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/janitor/red

/datum/outfit/centcom/ert/generic/janitor/red
	name = "Code Red Janitorial Response Officer"
	id = /obj/item/card/id/advanced/centcom/ert/janitor
	shoes = /obj/item/clothing/shoes/combat
	suit = null
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/storage/belt/janitor/full/ert
	back = /obj/item/mod/control/pre_equipped/responsory/generic/janitor
	backpack_contents = list(
		/obj/item/mop/advanced = 1,
		/obj/item/pushbroom = 1,
		/obj/item/reagent_containers/spray/drying = 1,
		/obj/item/grenade/clusterbuster/cleaner = 2,
		/obj/item/scythe/compact = 1,
		/obj/item/grenade/clusterbuster/antiweed = 1,
	)
	l_hand = /obj/item/storage/bag/trash/bluespace
	glasses = /obj/item/clothing/glasses/night
	additional_radio = /obj/item/encryptionkey/heads/hop

/datum/antagonist/ert/generic/chaplain
	name = "Code Green Religious Response Officer"
	role = "Religious Officer"
	outfit = /datum/outfit/centcom/ert/generic/chaplain
	ert_job_path = /datum/job/ert/chaplain

/datum/antagonist/ert/generic/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/outfit/centcom/ert/generic/chaplain
	name = "Code Green Religious Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/chaplain
	suit = /obj/item/clothing/suit/space/ert/chaplain
	suit_store = /obj/item/gun/energy/disabler
	head = /obj/item/clothing/head/helmet/space/ert/chaplain
	back = /obj/item/storage/backpack/ert
	backpack_contents = list(
		/obj/item/storage/belt/security/full/bola = 1,
		/obj/item/nullrod = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/holosign_creator/security
	additional_radio = /obj/item/encryptionkey/headset_sec
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/antagonist/ert/generic/chaplain/blue
	name = "Code Blue Religious Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/chaplain/blue

/datum/outfit/centcom/ert/generic/chaplain/blue
	name = "Code Blue Religious Response Officer"

	suit_store = /obj/item/gun/energy/e_gun
	shoes = /obj/item/clothing/shoes/magboots
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	backpack_contents = list(
		/obj/item/nullrod = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/storage/belt/security/full/bola = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	additional_radio = /obj/item/encryptionkey/headset_sec
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/antagonist/ert/generic/chaplain/red
	name = "Code Red Religious Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/chaplain/red

/datum/outfit/centcom/ert/generic/chaplain/red
	name = "Code Red Religious Response Officer"
	id = /obj/item/card/id/advanced/centcom/ert/chaplain
	suit = null
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	suit_store = /obj/item/gun/energy/e_gun/stun
	head = null
	belt = /obj/item/nullrod/scythe/talking/chainsword
	back = /obj/item/mod/control/pre_equipped/responsory/generic/chaplain
	backpack_contents = list(
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 2,
		/obj/item/reagent_containers/hypospray/combat/heresypurge = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/belt/security/full/bola = 1,
	)
	glasses = /obj/item/clothing/glasses/night
	additional_radio = /obj/item/encryptionkey/heads/hos

/datum/outfit/centcom/ert/generic/chaplain/red/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/sec_hud = new()
	sec_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/clown
	name = "Code Honk Entertainment Response Officer"
	role = "Entertainment Officer"
	outfit = /datum/outfit/centcom/ert/generic/clown
	plasmaman_outfit = /datum/outfit/plasmaman/party_comedian
	ert_job_path = /datum/job/ert/clown

/datum/antagonist/ert/generic/clown/New()
	. = ..()
	name_source = GLOB.clown_names //they are a clown after all

/datum/outfit/centcom/ert/generic/clown
	name = "Code Honk Entertainment Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/clown
	box = /obj/item/storage/box/survival/ert
	uniform = /obj/item/clothing/under/rank/civilian/clown
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes
	suit = /obj/item/clothing/suit/space/ert/clown
	suit_store = null
	head = /obj/item/clothing/head/helmet/space/ert/clown
	belt = /obj/item/tank/jetpack/oxygen/harness
	back = /obj/item/storage/backpack/ert/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/food/pie/cream = 3,
	)
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/bikehorn
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties/fake
	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/centcom/ert/generic/clown/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	suit_store = pick(
			/obj/item/tank/internals/emergency_oxygen/engi/clown/n2o,
			/obj/item/tank/internals/emergency_oxygen/engi/clown/bz,
			/obj/item/tank/internals/emergency_oxygen/engi/clown/helium,
			)

/datum/outfit/centcom/ert/generic/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.dna.add_mutation(/datum/mutation/human/clumsy)
	for(var/datum/mutation/human/clumsy/M in H.dna.mutations)
		M.mutadone_proof = TRUE
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	ADD_TRAIT(H, TRAIT_NAIVE, INNATE_TRAIT)
	fan.show_to(H)
	H.faction |= FACTION_CLOWN
	if(!ishuman(H))
		return
	var/obj/item/organ/internal/butt/butt = H.get_organ_slot(ORGAN_SLOT_BUTT)
	if(butt)
		butt.Remove(H, 1)
		QDEL_NULL(butt)
		butt = new/obj/item/organ/internal/butt/clown
		butt.Insert(H)

	var/obj/item/organ/internal/bladder/bladder = H.get_organ_slot(ORGAN_SLOT_BLADDER)
	if(bladder)
		bladder.Remove(H, 1)
		QDEL_NULL(bladder)
		bladder = new/obj/item/organ/internal/bladder/clown
		bladder.Insert(H)

/datum/antagonist/ert/generic/clown/funny
	name = "Code Honk! Entertainment Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/clown/funny

/datum/outfit/centcom/ert/generic/clown/funny
	name = "Code Honk! Entertainment Response Officer"

	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/food/pie/cream = 3,
		/obj/item/stack/sheet/mineral/bananium/five = 1,
	)
	l_pocket = /obj/item/bikehorn/golden

/datum/outfit/centcom/ert/generic/clown/funny/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/chest/knockout/punch_implant = new()
	punch_implant.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/clown/funnier
	name = "Code HONK!! Entertainment Response Officer"
	outfit = /datum/outfit/centcom/ert/generic/clown/funnier

/datum/outfit/centcom/ert/generic/clown/funnier
	name = "Code HONK!! Entertainment Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	suit = null
	suit_store = /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot
	head = null
	belt = /obj/item/storage/belt/military/snack/pie
	back = /obj/item/mod/control/pre_equipped/responsory/generic/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/superlube = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		/obj/item/stack/sheet/mineral/bananium/five = 1,
		/obj/item/suppressor = 1,
		/obj/item/ammo_box/magazine/toy/smgm45/riot = 3,

	)
	glasses = /obj/item/clothing/glasses/night
	additional_radio = /obj/item/encryptionkey/heads/hop
	l_pocket = /obj/item/bikehorn/golden

/datum/outfit/centcom/ert/generic/clown/funnier/pre_equip(mob/living/carbon/human/H, visualsOnly)
	return

/datum/outfit/centcom/ert/generic/clown/funnier/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/chest/knockout/punch_implant = new()
	punch_implant.Insert(H, drop_if_replaced = FALSE)

//------
// Other
//------

/datum/antagonist/ert/generic/deathsquad
	name = "Elite Deathsquad Commando"
	role = "Commando"
	outfit = /datum/outfit/centcom/ert/generic/deathsquad
	ert_job_path = /datum/job/ert/deathsquad

/datum/antagonist/ert/generic/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/outfit/centcom/ert/generic/deathsquad
	name = "Elite Deathsquad Commando"

	id = /obj/item/card/id/advanced/black/deathsquad
	box = /obj/item/storage/box/survival/ert
	uniform = /obj/item/clothing/under/rank/centcom/military
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/combat/swat
	suit = null
	suit_store = /obj/item/gun/energy/pulse/loyalpin
	head = null
	belt = /obj/item/storage/belt/military/assault
	back = /obj/item/mod/control/pre_equipped/apocryphal/elite
	backpack_contents = list(
		/obj/item/storage/box/medipens/advanced = 1,
		/obj/item/storage/box/c4 = 1,
		/obj/item/storage/box/x4 = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/gun/ballistic/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 3,
	)
	glasses = /obj/item/clothing/glasses/thermal
	l_pocket = /obj/item/melee/energy/sword/saber/purple //I am going to end to this, once and for all!
	r_pocket = /obj/item/shield/energy
	additional_radio = /obj/item/encryptionkey/heads/captain
	implants = list(/obj/item/implant/krav_maga)

/datum/outfit/centcom/ert/generic/deathsquad/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/organ/internal/cyberimp/brain/anti_drop/nodrop = new()
	nodrop.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/brain/anti_stun/rebooter = new()
	rebooter.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/chest/reviver/reviver_implant = new()
	reviver_implant.Insert(H, drop_if_replaced = FALSE)
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/sec_hud = new()
	sec_hud.Insert(H, drop_if_replaced = FALSE)

/datum/antagonist/ert/generic/deathsquad/dust
	name = "Elite Deathsquad Commando"
	outfit = /datum/outfit/centcom/ert/generic/deathsquad/dust

/datum/outfit/centcom/ert/generic/deathsquad/dust
	name = "Elite Deathsquad Commando (Do or Die!)"
	implants = list(/obj/item/implant/dust, /obj/item/implant/krav_maga)


