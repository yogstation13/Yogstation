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

/datum/component/fishable/proc/get_reward(var/fishing_power = 0)
	var/chance = list(
		FISHING_LOOT_NOTHING = min(max(0,100 - fishing_power),50),
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
		/obj/item/reagent_containers/food/snacks/fish/tuna
	)
	rare_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/squid,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/clothing/head/soft/fishfear/legendary
	)
