/datum/component/fishable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/fishing_loot/common_loot = new /datum/fishing_loot/water/common

/datum/component/fishable/proc/getCommonLoot()
	return pick(common_loot.rewards)

/datum/component/fishable/Initialize()
	if(!istype(parent, /turf))
		return COMPONENT_INCOMPATIBLE

//LOOT TABLES

/datum/fishing_loot
	var/list/rewards = list()

/datum/fishing_loot/water/common
	rewards = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish,
		/obj/item/reagent_containers/food/snacks/fish/goldfish/giant,
		/obj/item/reagent_containers/food/snacks/fish/salmon,
		/obj/item/reagent_containers/food/snacks/fish/bass,
		/obj/item/reagent_containers/food/snacks/fish/tuna,
		/obj/item/reagent_containers/food/snacks/fish/shrimp,
		/obj/item/reagent_containers/food/snacks/fish/squid,
		/obj/item/reagent_containers/food/snacks/fish/puffer,
		/obj/item/reagent_containers/food/snacks/bait/leech
		)
