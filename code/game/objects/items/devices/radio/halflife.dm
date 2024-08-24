/obj/item/radio/headset/civilprotection
	name = "civil protection headset"
	desc = "Protection for ears from loud songs, along with a functioning radio for metropolice forces."
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	keyslot = new /obj/item/encryptionkey/headset_sec
	radio_sounds = list('sound/voice/cpradio/on1.ogg', 'sound/voice/cpradio/on2.ogg')

/obj/item/radio/headset/headset_sec/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))
