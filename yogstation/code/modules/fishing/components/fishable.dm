#define FISHING_LOOT_BROKE "broke"
#define FISHING_LOOT_NOTHING "nothing"
#define FISHING_LOOT_JUNK "junk"
#define FISHING_LOOT_COMMON "common"
#define FISHING_LOOT_UNCOMMON "uncommon"
#define FISHING_LOOT_RARE "rare"

GLOBAL_LIST_INIT(fishing_table,init_fishing_table())

/proc/init_fishing_table()
	. = list()
	for(var/loot_table in subtypesof(/datum/fishing_loot))
		var/datum/fishing_loot/loot = new loot_table()
		.[loot.id] = loot

/datum/component/fishable
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/datum/fishing_loot/loot
	var/can_fish = TRUE
	var/population = 0
	var/growth = 0

/datum/component/fishable/Initialize(start_fishable = TRUE,datum/fishing_loot/loot_table = /datum/fishing_loot/water)
	if(!isturf(parent) && !ismachinery(parent))
		return COMPONENT_INCOMPATIBLE
	can_fish = start_fishable
	loot = loot_table
	RegisterSignal(src,COMSIG_CHUM_ATTEMPT,.proc/chum)
	population = loot.start_population
	growth = loot.start_growth
	if(growth > 0)
		START_PROCESSING(SSprocessing,src)

/datum/component/fishable/proc/chum(mob/user, obj/item/reagent_containers/food/snacks/chum/C)
	if(!loot.can_chum)
		return
	if(C.evil)
		interrupt()
		can_fish = FALSE
		loot = GLOB.fishing_table["syndicate"]
		growth = 0
		population = loot.max_population
		STOP_PROCESSING(SSprocessing,src)
		can_fish = TRUE
		return
	if(growth + C.growth > loot.max_growth) //don't let players chum above max
		to_chat(user,"Chumming [parent] would do nothing!")
		return
	growth += C.growth
	growth = min(growth,loot.max_growth)
	qdel(C) //bye
	to_chat(user,"You throw chum into [parent].")

/datum/component/fishable/process(delta)
	. = ..()
	population += growth
	population = min(population,loot.max_population)

/datum/component/fishable/proc/interrupt()
	SEND_SIGNAL(src,COMSIG_FISHING_INTERRUPT)

/datum/component/fishable/proc/get_reward(fishing_power = 0, fishing_flags = 0)
	if(!(fishing_flags & ROD_STRONG_LINE)) //if we don't have a strong line, always a 15% chance of catching nothing
		if(prob(15))
			return FISHING_LOOT_BROKE
	var/chance = list(
		FISHING_LOOT_JUNK = max(0,(25 - fishing_power)),
		FISHING_LOOT_COMMON = min(fishing_power / 2,55),
		FISHING_LOOT_UNCOMMON = min(fishing_power / 4,35),
		FISHING_LOOT_RARE = min(fishing_power / 16,10)
		)

	var/chosen_rank	= pickweight(chance)
	
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
	var/id
	var/list/junk_loot
	var/list/common_loot
	var/list/uncommon_loot
	var/list/rare_loot

	var/start_population = 10
	var/max_population = 20
	var/start_growth = 0.05
	var/max_growth = 0.1
	var/can_chum = TRUE

/datum/fishing_loot/water
	id = "water"

	junk_loot = list(
		/obj/item/trash/plate,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/shard
	)
	common_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish,
		/obj/item/reagent_containers/food/snacks/fish/salmon,
		/obj/item/reagent_containers/food/snacks/fish/bass,
		/obj/item/reagent_containers/food/snacks/bait/leech
		)
	uncommon_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/goldfish/giant,
		/obj/item/reagent_containers/food/snacks/fish/shrimp,
		/obj/item/reagent_containers/food/snacks/fish/puffer,
		/obj/item/reagent_containers/food/snacks/fish/tuna
	)
	rare_loot = list(
		/obj/item/reagent_containers/food/snacks/fish/rat,
		/obj/item/reagent_containers/food/snacks/fish/squid,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/clothing/head/soft/fishfear/legendary
	)

/datum/fishing_loot/syndicate
	id = "syndicate"
	can_chum = FALSE

/datum/fishing_loot/maintenance
	id = "maintenance"

/datum/fishing_loot/lavaland
	id = "lavaland"
