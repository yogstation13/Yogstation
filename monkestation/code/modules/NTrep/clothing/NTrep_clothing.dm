/obj/item/clothing/under/rank/centcom/nanotrasen_representative
	name = "representative's suit"
	desc = "Worn by those who work for the company. But don't let that fool you, they are pretty okay."
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/icons/obj/clothing/jobs/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing.dmi'
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing-digi.dmi'
	icon_state = "representative_jumpsuit"
	can_adjust = FALSE


/obj/item/clothing/under/rank/centcom/nanotrasen_representative/skirt
	name = "representative's suitskirt"
	desc = "Worn by those who work for the company. But don't let that fool you, they are pretty okay."
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/icons/obj/clothing/jobs/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_jumpskirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hats/nanotrasen_representative
	name = "representative's hat"
	desc = "Born to be obsessive and snotty."
	icon = 'monkestation/icons/obj/clothing/jobs/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_hat"

/obj/item/clothing/suit/armor/vest/nanotrasen_representative
	name = "representative's armored vest"
	desc = "The pen is mightier than the sword but a sword still hurts."
	icon = 'monkestation/icons/obj/clothing/jobs/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_vest"

/obj/item/clothing/suit/armor/vest/nanotrasen_representative/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)


/obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe
	name = "representative's bathrobe"
	desc = "For those who are lazy and fit right in this time and place."
	inhand_icon_state = "dg_suit"
	icon = 'monkestation/icons/obj/clothing/jobs/nanotrasen_representative_clothing_item.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/jobs/nanotrasen_representative_clothing.dmi'
	icon_state = "representative_bathrobe"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor_type = /datum/armor/nanotrasen_representative_bathrobe

/datum/armor/nanotrasen_representative_bathrobe
	melee = 25
	bullet = 10
	energy = 10
	bomb = 10
	fire = -10 //more flammable
	acid = 10
	wound = 10

/obj/item/storage/secure/briefcase/cash
// LOADSAMONEY
/obj/item/storage/secure/briefcase/cash/PopulateContents()
	..()
	for(var/iterator in 1 to 5)
		new /obj/item/stack/spacecash/c500(src)

/obj/item/storage/bag/garment/nanotrasen_representative
	name = "representative's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the Nanotrasen representative."

/obj/item/storage/bag/garment/nanotrasen_representative/PopulateContents()
	new /obj/item/clothing/under/rank/centcom/nanotrasen_representative(src)
	new /obj/item/clothing/under/rank/centcom/nanotrasen_representative/skirt(src)
	new /obj/item/clothing/head/hats/nanotrasen_representative(src)
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe(src)
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/laceup(src)

/obj/item/storage/bag/garment/stolen
	name = "stolen garment bag"
	desc = "Somewhere a CentCom commander is livid about their drycleaning going missing."

/obj/item/storage/bag/garment/stolen/PopulateContents()
	new /obj/item/clothing/head/hats/centhat(src)
	new /obj/item/clothing/under/rank/centcom/commander(src)
	new /obj/item/clothing/suit/armor/centcom_formal(src)
	new /obj/item/clothing/gloves/tackler/combat(src)
	new /obj/item/clothing/shoes/laceup(src)



