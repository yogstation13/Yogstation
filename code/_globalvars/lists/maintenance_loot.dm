//Value guidelines.

#define W_ESSENTIAL 400
#define W_COMMON 140
#define W_UNCOMMON 40
#define W_RARE 20
#define W_MYTHICAL 10
#define W_LEGENDARY 1


//this will all be removed when i get around to it

//The very definition of maintenance loot. Stuff that engineers and others left around.
GLOBAL_LIST_INIT(maintenance_loot_traditional,list(
	/obj/item/pen = W_ESSENTIAL,
	/obj/item/pen/blue = W_COMMON,
	/obj/item/pen/red = W_COMMON,

))


//Has moderate mechanical usage; stuff that would actually benefit the player with the right situation and the right access.
GLOBAL_LIST_INIT(maintenance_loot_moderate,list(
	/obj/item/firing_pin/clown = W_MYTHICAL,
	/obj/item/grenade/barrier = W_MYTHICAL,
))

//Has serious mechanical usage or uplink stuff that antags would get for flavor.
GLOBAL_LIST_INIT(maintenance_loot_major,list(
	/obj/item/disk/nuclear/fake = W_MYTHICAL,
	/obj/item/enloudener = W_RARE,
	/obj/item/gun/flamethrower = W_RARE,
))

GLOBAL_LIST_INIT(maintenance_loot_makeshift,list(
	/obj/item/disk/nuclear/fake = W_MYTHICAL,
	/obj/item/enloudener = W_RARE,
	/obj/item/gun/flamethrower = W_RARE,
))

GLOBAL_LIST_INIT(maintenance_loot_minor,list(
	/obj/item/disk/nuclear/fake = W_MYTHICAL,
	/obj/item/enloudener = W_RARE,
	/obj/item/gun/flamethrower = W_RARE,
))


//Has significant round-defining mechanical usage; stuff you'd rarely find and would seriously benefit the player and alter the round significantly right off the bat. Major contraband goes here.
GLOBAL_LIST_INIT(maintenance_loot_serious,list(
	/obj/item/batterer = W_RARE,
	/obj/item/sharpener = W_MYTHICAL,
	/obj/item/clothing/head/sombrero/shamebrero = W_MYTHICAL,
))

GLOBAL_LIST_INIT(ratking_trash, list(//Garbage: used by the regal rat mob when spawning garbage.
			/obj/item/cigbutt,
			/obj/item/trash/cheesie,
			/obj/item/trash/candy,
			/obj/item/trash/chips,
			/obj/item/trash/pistachios,
			/obj/item/trash/plate,
			/obj/item/trash/popcorn,
			/obj/item/trash/raisins,
			/obj/item/trash/sosjerky,
			/obj/item/trash/syndi_cakes
))

GLOBAL_LIST_INIT(ratking_coins, list(//Coins: Used by the regal rat mob when spawning coins.
			/obj/item/coin/iron,
			/obj/item/coin/silver
))
