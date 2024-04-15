//Outfits meant for admin-run events
//Specifically for those that don't fit elsewhere, mainly here to reduce risk of conflicts

/datum/outfit/syndicate_empty/icemoon_base/captain/event_rockandahardplace
	name = "EVENT - Syndicate Envoy"
	mask = /obj/item/clothing/mask/chameleon //NO GPS to avoid nanotrasen being cheeky bastards
	suit_store = null //empty because mateba spawns in locker
	implants = list(/obj/item/implant/weapons_auth) //remove recall implant to prevent my dumb ass from getting spaced
	uniform = /obj/item/clothing/under/syndicate/camo //drip
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/syndicate=1,
		/obj/item/codespeak_manual/unlimited=1,
		/obj/item/melee/classic_baton/telescopic=1
		)

/datum/outfit/syndicate_empty/icemoon_base/captain/event_rockandahardplace/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	H.ignores_capitalism = TRUE // begone capitalist pigdog!!!

/datum/outfit/syndicate_empty/icemoon_base/captain/event_rockandahardplace/prearmed
	name = "EVENT - Syndicate Envoy - Extra Gun"
	suit_store = /obj/item/gun/ballistic/revolver/mateba //extra gun
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/syndicate=1,
		/obj/item/codespeak_manual/unlimited=1,
		/obj/item/ammo_box/m44=2,
		/obj/item/melee/classic_baton/telescopic=1
		)

/datum/outfit/rockandahardplace_nanotrasenguy
	name = "EVENT - Nanotrasen Envoy" //Nanotrasen Envoy

	implants = list(/obj/item/implant/mindshield)
	box = /obj/item/storage/box/survival

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

/datum/outfit/rockandahardplace_nanotrasenguy/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/centcom/silver/W = H.wear_id
	W.icon = 'icons/obj/card.dmi'
	W.icon_state = "centcom_silver" //Neither does this guy
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Official")
	W.assignment = "Nanotrasen Envoy"
	W.originalassignment = "Nanotrasen Envoy"
	W.registered_name = H.real_name
	W.update_label()

	H.ignores_capitalism = TRUE // Yogs -- Lets Centcom guys buy a damned smoke for christ's sake
