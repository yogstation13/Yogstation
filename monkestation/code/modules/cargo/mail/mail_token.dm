/obj/item/cargo/mail_token
	name = "mail token"
	desc = "A plastic mail token. Part of a new program to get Nanotrasen cargo employees to deliver mail.\
	Can be exported to Central Command for an increase to the budget. The back of the token seems to have barcode on it for handling tips."
	icon = 'monkestation/code/modules/cargo/mail/mail.dmi'
	w_class = WEIGHT_CLASS_TINY
	icon_state = "mailtoken-1"
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT)
	var/datum/bank_account/token_handler_account

/obj/item/cargo/mail_token/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BARCODES, INNATE_TRAIT) // Don't allow anyone to override our pricetag component with a barcode

/datum/export/mail_token
	cost = CARGO_CRATE_VALUE
	unit_name = "mail token"
	k_elasticity = 0
	export_types = list(/obj/item/cargo/mail_token)
