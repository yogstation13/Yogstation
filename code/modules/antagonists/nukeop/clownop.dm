/datum/antagonist/nukeop/clownop
	name = "Clown Operative"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	job_rank = ROLE_CLOWNOP
	nukeop_outfit = /datum/outfit/syndicate/clownop
	preview_outfit = /datum/outfit/syndicate/clownop
	welcome_music = 'sound/ambience/antag/hornin.ogg'
	
/datum/antagonist/nukeop/leader/clownop
	name = "Clown Operative Leader"
	roundend_category = "clown operatives"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop/leader
	welcome_music = 'sound/ambience/antag/hornin.ogg'

/datum/antagonist/nukeop/leader/clownop/give_alias()
	title = pick("Head Honker", "Slipmaster", "Clown King", "Honkbearer")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/clownop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_CLOWNOP
	new_owner.special_role = ROLE_CLOWNOP
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has clown op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has clown op'ed [key_name(new_owner)].")



/datum/outfit/syndicate/clownop
	name = "Clown Operative - Basic"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/clown
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id/syndicate
	belt = /obj/item/modular_computer/tablet/pda/preset/clown
	backpack_contents = list(/obj/item/kitchen/knife/combat/survival,\
		/obj/item/reagent_containers/spray/waterflower/lube)
	implants = list(/obj/item/implant/sad_trombone)

	uplink_type = /obj/item/uplink/clownop

/datum/outfit/syndicate/clownop/no_crystals
	tc = 0

/datum/outfit/syndicate/clownop/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.dna.add_mutation(CLOWNMUT)

/datum/outfit/syndicate/clownop/leader
	name = "Clown Operative Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge/clownops
	command_radio = TRUE
