/obj/item/encryptionkey/headset_medsup
	name = "medical supply radio encryption key"
	desc = "An encryption key for mining medic headsets. To access the medical channel, use :m. For cargo, use :u."
	icon_state = "cargo_cypherkey"
	channels = list("Supply" = 1, "Medical" = 1)

/obj/item/encryptionkey/headset_medsec
	name = "medical security radio encryption key"
	desc = "An encryption key for brig physician headsets. To access the medical channel, use :m. For security, use :s."
	icon_state = "sec_cypherkey"
	channels = list("Security" = 1, "Medical" = 1)
