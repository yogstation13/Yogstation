#define FISHING_LOOT_NOTHING "nothing"
#define FISHING_LOOT_JUNK "junk"
#define FISHING_LOOT_COMMON "common"
#define FISHING_LOOT_UNCOMMON "uncommon"
#define FISHING_LOOT_RARE "rare"

/datum/component/fishable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/fishing_loot/loot = new /datum/fishing_loot/water

/datum/component/fishable/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE

/datum/component/fishable/proc/get_reward(fishing_power = 0)
	var/chance = list(
		FISHING_LOOT_JUNK = min(max(0,50 - fishing_power),25),
		FISHING_LOOT_COMMON = min(fishing_power / 5,50),
		FISHING_LOOT_UNCOMMON = min(fishing_power / 10,33),
		FISHING_LOOT_RARE = min(fishing_power / 20,25) 
		)

	var/chosen_rank = pickweight(chance)
	switch(chosen_rank)
		if(FISHING_LOOT_JUNK)
			return pick(loot.junk_loot)
		if(FISHING_LOOT_COMMON)
			return pick(loot.common_loot)
		if(FISHING_LOOT_UNCOMMON)
			return pick(loot.uncommon_loot)
		if(FISHING_LOOT_RARE)
			return pick(loot.rare_loot)
	return FISHING_LOOT_NOTHING

//lava fishing

/datum/component/fishable/lava
	loot = new /datum/fishing_loot/lava

//LOOT TABLES
/datum/fishing_loot
	var/list/junk_loot
	var/list/common_loot
	var/list/uncommon_loot
	var/list/rare_loot

/datum/fishing_loot/water
	junk_loot = list(
		/obj/item/trash/plate,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/shard
	)
	common_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish,
		/obj/item/reagent_containers/food/snacks/fish/salmon,
		/obj/item/reagent_containers/food/snacks/fish/bass,
		/obj/item/reagent_containers/food/snacks/bait/worm/leech
	)
	uncommon_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish/giant,
		/obj/item/reagent_containers/food/snacks/fish/shrimp,
		/obj/item/reagent_containers/food/snacks/fish/puffer,
		/obj/item/reagent_containers/food/snacks/fish/tuna,
		/mob/living/simple_animal/pet/axolotl
	)
	rare_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/squid,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/clothing/head/soft/fishfear/legendary,
		/mob/living/simple_animal/hostile/retaliate/gator
	)
/datum/fishing_loot/lava
	junk_loot = list(
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/shovel,
		/obj/item/shard,
		/obj/item/pickaxe,
		/obj/item/stack/sheet/mineral/sandstone,
		/obj/item/stack/sheet/mineral/coal
	)
	common_loot = list(
		/mob/living/simple_animal/hostile/asteroid/gutlunch,
		/obj/item/stack/sheet/bone,
		/obj/item/stack/sheet/animalhide/goliath_hide,
		/obj/item/claymore/ruin,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit

	)
	uncommon_loot = list(
		/obj/item/survivalcapsule,
		/obj/item/stack/sheet/ruinous_metal,
		/obj/item/stack/tile/brass,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/clothing/head/helmet/chaplain,
		/obj/item/clothing/suit/armor/riot/chaplain,
		/obj/item/nullrod/claymore,
		/obj/item/banner/cargo,
		/obj/structure/closet/crate/necropolis, //empty chest its a joke :)
		/obj/item/book/manual/ashwalker

	)
	rare_loot = list(
		/mob/living/simple_animal/hostile/mining_drone,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/obj/item/stack/sheet/mineral/mythril,
		/obj/structure/closet/crate/necropolis/tendril, //populated chest
		/obj/item/book_of_babel,
		/obj/item/bedsheet/cult,
		/obj/item/assembly/signaler/anomaly/bluespace,
		/obj/item/stack/sheet/mineral/abductor
		)
		
		