//ALL OF THIS IS MONKESTATION EDIT

/datum/export/space_salvage
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "space salvage"

/datum/export/space_salvage/syndicate
	unit_name = "syndicate salvage"

/datum/export/space_salvage/syndicate/blackbox
	cost = CARGO_CRATE_VALUE * 25 //good luck getting it though lmao
	unit_name = "syndicate data recorder"
	export_types = list(/obj/item/syndicate_blackbox)

/datum/export/space_salvage/syndicate/key
	cost = CARGO_CRATE_VALUE * 3 //you can get them from traitors, but explorers can get them from deep storage and depot (even if nobody spawns) and the other syndicate roles. sell that shit, dont give it to sec. trust me bro.
	unit_name = "syndicate encryption device"
	export_types = list(/obj/item/encryptionkey/syndicate)

/datum/export/space_salvage/syndicate/id_card
	cost = CARGO_CRATE_VALUE * 2 //appears anywhere there are syndicate corpses, so worth less than the key but still valuable
	unit_name = "syndicate identification card"
	export_types = list(/obj/item/card/id/advanced/chameleon)
