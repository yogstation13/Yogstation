/datum/outfit/ert
	name = "ERT Common"

	id = /obj/item/card/id/ert
	back = /obj/item/storage/backpack
	uniform = /obj/item/clothing/under/rank/centcom_officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt
	implants = list(/obj/item/implant/mindshield)
	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat=1,
		/obj/item/tank/internals/oxygen/tactical=1,
		/obj/item/tank/internals/emergency_oxygen/double=1,
		)

/datum/outfit/ert/commonleader
	head = /obj/item/clothing/head/beret/sec
	backpack_contents = list(
		/obj/item/clothing/mask/gas/sechailer/swat=1,
		/obj/item/tank/internals/oxygen/tactical=1,
		/obj/item/tank/internals/emergency_oxygen/double=1,
		/obj/item/stack/ore/bluespace_crystal/refined/nt/five=1
		)

/datum/outfit/ert/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

	H.ignores_capitalism = TRUE // Yogs -- Lets ERTs buy a damned smoke for christ's sake

/datum/outfit/ert/commander
	name = "ERT Commander"

	id = /obj/item/card/id/ert
	suit = /obj/item/clothing/suit/space/hardsuit/ert
	suit_store = /obj/item/gun/energy/e_gun
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert
	belt = /obj/item/storage/belt/security/full
	mask = /obj/item/clothing/mask/gas/sechailer
	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1
		)
	l_pocket = /obj/item/switchblade

/datum/outfit/ert/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return
	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/captain
	R.recalculateChannels()

/datum/outfit/ert/commander/alert
	name = "ERT Commander - High Alert"

	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/e_gun/stun
	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1
		)
	l_pocket = /obj/item/melee/transforming/energy/sword/saber

/datum/outfit/ert/security
	name = "ERT Security"

	id = /obj/item/card/id/ert/Security
	suit = /obj/item/clothing/suit/space/hardsuit/ert/sec
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert/security
	belt = /obj/item/storage/belt/security/full
	suit_store = /obj/item/gun/energy/e_gun
	mask = /obj/item/clothing/mask/gas/sechailer
	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/zipties=1,
		/obj/item/melee/baton/loaded=1
		)

/datum/outfit/ert/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hos
	R.recalculateChannels()

/datum/outfit/ert/security/alert
	name = "ERT Security - High Alert"
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/energy/e_gun/stun
	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1
		)


/datum/outfit/ert/medic
	name = "ERT Medic"

	id = /obj/item/card/id/ert/Medical
	suit = /obj/item/clothing/suit/space/hardsuit/ert/med
	suit_store = /obj/item/gun/medbeam
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/ert/medical
	belt = /obj/item/melee/classic_baton/telescopic
	mask = /obj/item/clothing/mask/gas/sechailer
	l_pocket = /obj/item/reagent_containers/autoinjector/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	backpack_contents = list(
		/obj/item/storage/firstaid/toxin=1,
		/obj/item/storage/firstaid/fire=1,
		/obj/item/storage/firstaid/brute=1
		)

/datum/outfit/ert/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/cmo
	R.recalculateChannels()

/datum/outfit/ert/medic/alert
	name = "ERT Medic - High Alert"
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	suit_store = /obj/item/gun/medbeam
	belt = /obj/item/defibrillator/compact/combat/loaded
	l_pocket = /obj/item/reagent_containers/autoinjector/combat/nanites
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi

	backpack_contents = list(
		/obj/item/storage/box/bodybags=1,
		/obj/item/storage/firstaid/toxin=1,
		/obj/item/storage/firstaid/fire=1,
		/obj/item/storage/firstaid/brute=1,
		/obj/item/storage/firstaid/o2=1,
		/obj/item/storage/firstaid/advanced=1,
		/obj/item/melee/classic_baton/telescopic = 1
		)

/datum/outfit/ert/engineer
	name = "ERT Engineer"

	id = /obj/item/card/id/ert/Engineer
	suit = /obj/item/clothing/suit/space/hardsuit/ert/engi
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	glasses =  /obj/item/clothing/glasses/meson/engine
	back = /obj/item/storage/backpack/ert/engineer
	belt = /obj/item/storage/belt/utility/full
	mask = /obj/item/clothing/mask/gas/sechailer
	l_pocket = /obj/item/rcd_ammo
	r_pocket= /obj/item/rcd_ammo
	backpack_contents = list(
		/obj/item/reagent_containers/autoinjector/medipen=1,
		/obj/item/melee/classic_baton/telescopic=1,
		/obj/item/construction/rcd/loaded=1
		)

/datum/outfit/ert/engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/ce
	R.recalculateChannels()

/datum/outfit/ert/engineer/alert
	name = "ERT Engineer - High Alert"
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	belt = /obj/item/storage/belt/utility/full/engi

	backpack_contents = list(
		/obj/item/reagent_containers/autoinjector/medipen=1,
		/obj/item/storage/box/smart_metal_foam=1,
		/obj/item/construction/rcd/combat=1
		)

/datum/outfit/ert/commander/inquisitor
	name = "Inquisition Commander"
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal
	belt = /obj/item/nullrod/scythe/talking/chainsword
	suit_store = /obj/item/gun/energy/e_gun
	mask = /obj/item/clothing/mask/gas/sechailer
	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/assembly/flash/handheld=1,
		/obj/item/grenade/flashbang=1,
		/obj/item/reagent_containers/spray/pepper=1
		)

/datum/outfit/ert/security/inquisitor
	name = "Inquisition Security"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	mask = /obj/item/clothing/mask/gas/sechailer
	suit_store = /obj/item/gun/energy/e_gun/stun

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/construction/rcd/loaded=1)

/datum/outfit/ert/medic/inquisitor
	name = "Inquisition Medic"

	r_hand = null
	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	belt = /obj/item/gun/energy/e_gun
	mask = /obj/item/clothing/mask/gas/sechailer
	l_pocket = /obj/item/reagent_containers/autoinjector/combat
	r_pocket = /obj/item/reagent_containers/autoinjector/combat/heresypurge
	suit_store = /obj/item/gun/medbeam

	backpack_contents = list(
		/obj/item/storage/box/engineer=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/storage/firstaid/toxin=1,
		/obj/item/storage/firstaid/fire=1,
		/obj/item/storage/firstaid/brute=1
		)

/datum/outfit/ert/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/heads/hop
	R.recalculateChannels()

/datum/outfit/ert/chaplain
	name = "ERT Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor // Chap role always gets this suit
	id = /obj/item/card/id/ert/chaplain
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/gas/sechailer
	back = /obj/item/storage/backpack/cultpack
	belt = /obj/item/storage/belt/soulstone
	suit_store = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/nullrod
	backpack_contents = list(
		/obj/item/storage/box/engineer=1
		)

/datum/outfit/ert/chaplain/inquisitor
	name = "Inquisition Chaplain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	r_pocket = /obj/item/grenade/chem_grenade/holy
	belt = /obj/item/storage/belt/soulstone/full/chappy
	backpack_contents = list(
		/obj/item/storage/box/engineer=1
		)

/datum/outfit/ert/janitor
	name = "ERT Janitor"

	id = /obj/item/card/id/ert/Janitor
	suit = /obj/item/clothing/suit/space/hardsuit/ert/jani
	suit_store = /obj/item/storage/bag/trash/bluespace
	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/janitor/full
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	mask = /obj/item/clothing/mask/gas/sechailer
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/storage/box/lights/mixed=1,\
		/obj/item/mop/advanced=1,\
		/obj/item/reagent_containers/glass/bucket=1,\
		/obj/item/grenade/clusterbuster/cleaner=1)

/datum/outfit/ert/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.keyslot = new /obj/item/encryptionkey/headset_service
	R.recalculateChannels()

/datum/outfit/ert/janitor/heavy
	name = "ERT Janitor - Heavy Duty"
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/reagent_containers/spray/chemsprayer/janitor=1,\
		/obj/item/storage/box/lights/mixed=1,\
		/obj/item/melee/classic_baton/telescopic=1,\
		/obj/item/grenade/clusterbuster/cleaner=3)

/datum/outfit/centcom_clown
	name = "Code Banana ERT"
	id = /obj/item/card/id/centcom
	belt = /obj/item/pda/clown
	ears = /obj/item/radio/headset/headset_cent
	uniform = /obj/item/clothing/under/rank/clown
	back = /obj/item/storage/backpack/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)


/datum/outfit/centcom_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.access += ACCESS_THEATRE
	W.update_label(W.registered_name, W.assignment)
	H.dna.add_mutation(CLOWNMUT)

/datum/outfit/centcom_clown/honk_squad
	name = "HONK Squad Trooper"
	back = /obj/item/storage/backpack/holding/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	l_pocket = /obj/item/bikehorn/golden
	r_pocket = /obj/item/shield/energy/bananium
	l_hand = /obj/item/pneumatic_cannon/pie/selfcharge
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/megaphone/clown = 1,
		/obj/item/reagent_containers/spray/chemsprayer/janitor/clown = 1,
		)
