/datum/uplink_item/device_tools/syndie_glue
	name = "Glue"
	desc = "A cheap bottle of one use syndicate brand super glue. \
			Use on any item to make it undroppable. \
			Be careful not to glue an item you're already holding!"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/syndie_glue
	cost = 2

/datum/uplink_item/device_tools/neutered_borer_egg
	name = "Neutered borer egg"
	desc = "A borer egg specifically bred to aid operatives. \
			It will obey every command and protect whatever operative they first see when hatched. \
			Unfortunately due to extreme radiation exposure, they cannot reproduce. \
			It was put into a cage for easy tranportation"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/neutered_borer_spawner
	cost = 20
	surplus = 40
	refundable = TRUE

/datum/uplink_item/stealthy_tools/chameleonheadsetdeluxe
	name = "Advanced Chameleon Headset"
	desc = "A premium model Chameleon Headset. All the features you love of the original, but now with flashbang \
			protection, voice amplification, memory-foam, HD Sound Quality, and extra-wide spectrum dial. Usually reserved \
			for high-ranking Cybersun officers, a few spares have been reserved for field agents."
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/radio/headset/chameleon/advanced
	cost = 2

/datum/uplink_item/device_tools/plasma_license
	name = "License to Murderbone"
	desc = "A contract abusing a loophole found by plasmamen to invade halls with harmful gases \
			without repercussion or warning, garnering no attention from any higher powers. \
			Has to be signed by purchaser to be considered valid."
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/card/plasma_license
	cost = 20

/datum/uplink_item/device_tools/super_kitty_ears
	name = "Super Syndie-Kitty Ears"
	desc = "Developed by several Interdyne Pharmaceutics scientists and Wizard Federation archmages during a record-breaking rager, \
			this set of feline ears combines the finest of bio-engineering and thamaturgy to allow the user to transform to and from a cat at will, \
			granting them all the benefits (and downsides) of being a true feline, such as ventcrawling. \
			However, this form will be clad in blood-red Syndicate armor, making its origin somewhat obvious."
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/organ/internal/ears/cat/super/syndie
	cost = 16 // double the price of stealth implant
	surplus = 5
	limited_stock = 1
