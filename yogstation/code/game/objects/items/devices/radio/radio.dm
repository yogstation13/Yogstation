/obj/item/radio/security
	name = "security transceiver"
	desc = "A tactical communications device for those times when you need it."
	icon = 'yogstation/icons/obj/radio.dmi'
	icon_state = "walkietalkiesec"
	item_state = "walkietalkiesec"
	freerange = TRUE
	freqlock = TRUE
	keyslot = /obj/item/encryptionkey/headset_sec

/obj/item/radio/security/Initialize(mapload)
	set_frequency(1359)
	. = ..()
	
