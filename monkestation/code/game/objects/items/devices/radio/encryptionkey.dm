/obj/item/encryptionkey/headset_secmed
	name = "brig physician radio encryption key"
	icon_state = "cypherkey_security"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_MEDICAL = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_security
	greyscale_colors = "#820a16#280b1a"

/obj/item/encryptionkey/headset_uncommon
	name = "dusty encryption key"
	channels = list(RADIO_CHANNEL_UNCOMMON = 1)

/obj/item/encryptionkey/heads/blueshield
	name = "\proper the blueshield's encryption key"
	icon_state = "cypherkey_centcom"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_centcom
	greyscale_colors = "#1d2657#dca01b"
