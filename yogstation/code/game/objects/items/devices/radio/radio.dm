/obj/item/radio/security
	name = "security transceiver"
	desc = "A tactical communications device for those times when you need it."
	icon = 'yogstation/icons/obj/radio.dmi'
	icon_state = "walkietalkiesec"
	item_state = "walkietalkiesec"
	freerange = TRUE
	var/radio_freq =1359
	set_frequency(radio_freq)
	freqlock = TRUE
	keyslot = /obj/item/encryptionkey/headset_sec
