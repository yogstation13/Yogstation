/datum/outfit/centcom
	implants = list(/obj/item/implant/mindshield)
	box = /obj/item/storage/box/survival

/datum/outfit/centcom/official //Generic centcom person. Whatever rank you want that is Lieutenant or lower.
	name = "(CO-1)CentCom Official"

	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = null
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/beret/sec/centcom
	belt = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/pen
	back = /obj/item/storage/backpack/satchel
	r_pocket = /obj/item/pda/heads
	l_hand = /obj/item/clipboard
	id = /obj/item/card/id/centcom
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/official/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/pda/heads/pda = H.r_store
	pda.owner = H.real_name
	pda.ownjob = "CentCom Official"
	pda.update_label()

	var/obj/item/card/id/W = H.wear_id
	W.icon = 'icons/obj/card.dmi' //Bypasses modularisation.
	W.icon_state = "centcom"
	W.access = get_centcom_access("CentCom Official")
	W.access += ACCESS_WEAPONS
	W.assignment = "CentCom Official"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/captain //CentCom Captain. Essentially a station captain.
	name = "(CO-2)CentCom Captain"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/centcom
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/centhat
	belt = /obj/item/gun/energy/e_gun
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/silver
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/silver/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_silver" //Not gold because he doesn't command a station.
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Official")
	W.assignment = "CentCom Captain"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/major //CentCom Major.
	name = "(CO-3)CentCom Major"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/centcom
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/centhat
	neck = /obj/item/clothing/neck/pauldron
	belt = /obj/item/gun/energy/e_gun
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/silver
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/major/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/silver/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_silver" //Neither does this guy
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Official")
	W.assignment = "CentCom Major"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/commander //CentCom Commander.
	name = "(CO-4)CentCom Commodore"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/centcom
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	neck = /obj/item/clothing/neck/pauldron/commander
	belt = /obj/item/gun/ballistic/revolver/mateba //The time for negotiations have come to an end.
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/gold
	backpack_contents = list(/obj/item/ammo_box/a357 =2, /obj/item/restraints/handcuffs/cable/zipties=1, /obj/item/melee/classic_baton/telescopic=1)

/datum/outfit/centcom/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/gold/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_gold" //Important enough to have one.
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Commodore"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/colonel //CentCom Commander.
	name = "(CO-5)CentCom Colonel"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/centcom
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/centhat
	neck = /obj/item/clothing/neck/pauldron/colonel
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/gold
	backpack_contents = list(/obj/item/ammo_box/a357 =2, /obj/item/restraints/handcuffs/cable/zipties=1, /obj/item/melee/classic_baton/telescopic=1)

/datum/outfit/centcom/colonel/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/gold/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_gold"
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Colonel"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/rear_admiral //CentCom Rear-Admiral. Low-tier admiral.
	name = "(CO-6)CentCom Rear-Admiral"

	uniform = /obj/item/clothing/under/rank/centcom_admiral
	suit = null
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/centhat/admiral
	neck = null
	belt = /obj/item/gun/energy/e_gun //The time for negotiations have been reconsidered.
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/gold
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/rear_admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/gold/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_gold"
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Rear-Admiral"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/admiral //CentCom Admiral.
	name = "(CO-7)CentCom Admiral"

	uniform = /obj/item/clothing/under/rank/centcom_admiral
	suit = null
	shoes = /obj/item/clothing/shoes/sneakers/brown
	gloves = /obj/item/clothing/gloves/color/captain/centcom
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/centhat/admiral
	neck = /obj/item/clothing/neck/cape
	belt = /obj/item/gun/energy/pulse/pistol //THE TIME FOR NEGOTIATIONS HAVE COME TO AND END.
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/green
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/gold
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/gold/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_gold"
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Admiral"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake

/datum/outfit/centcom/grand_admiral //CentCom Grand Admiral. The final boss.
	name = "(NO-8)CentCom Grand Admiral"

	uniform = /obj/item/clothing/under/rank/centcom_admiral/grand
	suit = null
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/color/captain/centcom/admiral
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/centhat/admiral/grand
	neck = /obj/item/clothing/neck/cape/grand
	belt = /obj/item/gun/energy/pulse/pistol
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/green
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom/gold
	backpack_contents = list(/obj/item/restraints/handcuffs/cable/zipties=1)

/datum/outfit/centcom/grand_admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/gold/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_gold"
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Grand Admiral"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake
