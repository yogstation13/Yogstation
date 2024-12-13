/obj/item/radio/headset/headset_secmed
	name = "brig physician radio headset"
	desc = "This is used by your secure doctor."
	icon_state = "sec_headset"
	worn_icon_state = "sec_headset"
	keyslot = /obj/item/encryptionkey/headset_secmed

/obj/item/radio/headset/headset_old
	name =  "old radio headset"
	desc =  "A headset years past its prime."

/obj/item/radio/headset/headset_old/alt
	name =  "old security bowman headset"
	desc =  "A headset years past its prime. Protects ears from flashbangs."
	keyslot = /obj/item/encryptionkey/headset_uncommon
	icon_state = "med_headset_alt"
	worn_icon_state = "med_headset_alt"

/obj/item/radio/headset/headset_old/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/radio/headset/heads/headset_old
	name =  "\proper old commander headset"
	desc =  "A authoritative headset years past its prime. Dust cakes its old design."
