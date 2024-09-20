/datum/outfit/rebel
	name = "Rebel"

	uniform = /obj/item/clothing/under/citizen/rebel
	accessory = /obj/item/clothing/accessory/armband/rebel
	suit = /obj/item/clothing/suit/armor/civilprotection
	head = /obj/item/clothing/head/beanie/black
	shoes = /obj/item/clothing/shoes/brownboots
	gloves = /obj/item/clothing/gloves/fingerless

	suit_store = /obj/item/gun/ballistic/automatic/pistol/usp
	belt = /obj/item/storage/belt/civilprotection

	l_pocket = /obj/item/flashlight/seclite
	r_pocket = /obj/item/reagent_containers/pill/patch/medkit

/datum/outfit/rebel/pre_equip(mob/living/carbon/human/H)
	H.cmode_music = 'sound/music/combat/vortalcombat.ogg'
