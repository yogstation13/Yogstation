/datum/uplink_item/stealthy_weapons/romerol_kit
	surplus = 10 //very rare from lootboxes

/datum/uplink_item/dangerous/clownoppin
	surplus = 80

/datum/uplink_item/dangerous/clownopsuperpin
	surplus = 80

/datum/uplink_item/bundles_tc/cyber_implants
	surplus = 30

/datum/uplink_item/bundles_tc/medical
	surplus = 40

/datum/uplink_item/support/gygax
	surplus = 40

/datum/uplink_item/support/honker
	surplus = 60

/datum/uplink_item/suits/cybersun_juggernaut_suit
	name = "Cybersun Juggernaut Suit Access Card"
	desc = "Developed by Cybersun for use in clearing heavy space bear infestations in asteroid belt operations.\
	 It now has a new purpose as the heavy operation suit of the Syndicate. By purchasing this you get a special Authorization Key to the only suit in storage at Firebase Balthazord."
	item = /obj/item/keycard/syndicate_suit_storage
	cost = 20
	purchasable_from = UPLINK_NUKE_OPS
	limited_stock = 1

/datum/uplink_item/stealthy_tools/amogus_potion
	name = "Mysterious potion"
	desc = "A strange red potion that's said to turn you into a tiny red space man at 3AM, seems to work at any time though. \
			Drinking this potion will turn you very small allowing you to be carried in backpacks by your fellow operatives, \
			seems to not make goblins or monkeys any smaller though. No money refunds."
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	item = /obj/item/amogus_potion
	cost = 7
