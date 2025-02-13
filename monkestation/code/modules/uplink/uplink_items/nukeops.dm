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

/datum/uplink_item/ammo/LMG
	name = "6.5 FMJ Quarad drum"
	desc = "A surplus 120 round drum of FMJ bullets for the Quarad"
	item = /obj/item/ammo_box/magazine/c65xeno_drum/evil
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/LMG/incendiary
	name = "6.5 Inferno Quarad drum"
	desc = "A 120 round drum of Inferno bullets for the Quarad. They leave a trail of fire"
	item = /obj/item/ammo_box/magazine/c65xeno_drum/incendiary/evil
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/ammo/LMG/pierce
	name = "6.5 UDS Quarad drum"
	desc = "No, NOT depleted uranium. 120 round drum of piercing and irradiating bullets for the Quarad"
	item = /obj/item/ammo_box/magazine/c65xeno_drum/pierce/evil
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE

/datum/uplink_item/dangerous/Evil_Quarad
	name = "Syndicate-Enhanced Light Suppression Weapon"
	desc = "A heavily modified Quarad LMG, complete with bluespace barrel extender and retooled recoil reduction. Takes 120 round drums, good for suppressive fire."
	item = /obj/item/gun/ballistic/automatic/quarad_lmg/evil
	cost = 16
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE