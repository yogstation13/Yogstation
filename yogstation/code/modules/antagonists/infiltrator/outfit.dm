/datum/outfit/infiltrator // RIP
	name = "Syndicate Infiltrator"

	uniform = /obj/item/clothing/under/chameleon/syndicate
	shoes = /obj/item/clothing/shoes/chameleon/noslip/syndicate
	gloves = /obj/item/clothing/gloves/chameleon/syndicate
	back = /obj/item/storage/backpack/chameleon/syndicate
	ears = /obj/item/radio/headset/chameleon/syndicate
	id = /obj/item/card/id/syndicate
	mask = /obj/item/clothing/mask/chameleon/syndicate
	belt = /obj/item/modular_computer/tablet/pda/preset/syndicate
	box = /obj/item/storage/box/survival/engineer
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/gun/ballistic/automatic/pistol=1)

/datum/outfit/infiltrator/post_equip(mob/living/carbon/human/H)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/dusting/E = new/obj/item/implant/dusting(H)
	E.implant(H)
	var/datum/team/infiltrator/team
	for (var/T in GLOB.antagonist_teams)
		if (istype(T, /datum/team/infiltrator))
			var/datum/team/infiltrator/infil_team = T
			if (H.mind in infil_team.members)
				team = infil_team
				break
	var/obj/item/implant/infiltrator/U = new/obj/item/implant/infiltrator(H, H.key, team)
	U.implant(H)
	var/obj/item/implant/radio/syndicate/S = new/obj/item/implant/radio/syndicate(H)
	S.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()

	var/obj/item/card/id/card = H.wear_id
	if(istype(card))
		card.registered_name = H.real_name
		card.assignment = "Assistant"
		card.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
		card.update_label()
	
	var/obj/item/pda/pda = H.belt
	if(istype(pda))
		pda.owner = H.real_name
		pda.ownjob = "Assistant"
		pda.update_label()
