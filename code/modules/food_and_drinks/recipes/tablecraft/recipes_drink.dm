// This is the home of drink related tablecrafting recipes, I have opted to only let players bottle fancy boozes to reduce the number of entries.

///////////////// Booze & Bottles ///////////////////

/datum/crafting_recipe/kong
	name = "Kong"
	result = /obj/item/reagent_containers/food/drinks/bottle/kong
	time = 3 SECONDS
	reqs = list(
		/datum/reagent/consumable/ethanol/whiskey = 100,
		/obj/item/reagent_containers/food/snacks/monkeycube = 1,
		/obj/item/reagent_containers/food/drinks/bottle = 1
	)
	category = CAT_DRINK

/datum/crafting_recipe/candycornliquor
	name = "Candy Corn Liquor"
	result = /obj/item/reagent_containers/food/drinks/bottle/candycornliquor
	time = 3 SECONDS
	reqs = list(
		/datum/reagent/consumable/ethanol/whiskey = 100,
		/obj/item/reagent_containers/food/snacks/candy_corn = 1,
		/obj/item/reagent_containers/food/drinks/bottle = 1
	)
	category = CAT_DRINK

/datum/crafting_recipe/lizardwine
	name = "Lizard Wine"
	time = 4 SECONDS
	reqs = list(
		/obj/item/organ/tail/lizard = 1,
		/datum/reagent/consumable/ethanol = 100,
		/obj/item/reagent_containers/food/drinks/bottle = 1
	)
	blacklist = list(/obj/item/organ/tail/lizard/fake)
	result = /obj/item/reagent_containers/food/drinks/bottle/lizardwine
	category = CAT_DRINK

/datum/crafting_recipe/moonshinejug
	name = "Moonshine Jug"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/ethanol/moonshine = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/moonshine
	category = CAT_DRINK

/datum/crafting_recipe/hoochbottle
	name = "Hooch Bottle"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/obj/item/storage/box/papersack = 1,
		/datum/reagent/consumable/ethanol/hooch = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/hooch
	category = CAT_DRINK

/datum/crafting_recipe/blazaambottle
	name = "Blazaam Bottle"
	time = 20
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/ethanol/blazaam = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/blazaam
	category = CAT_DRINK

/datum/crafting_recipe/champagnebottle
	name = "Champagne Bottle"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/ethanol/champagne = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/champagne
	category = CAT_DRINK

/datum/crafting_recipe/trappistbottle
	name = "Trappist Bottle"
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle/small = 1,
		/datum/reagent/consumable/ethanol/trappist = 50
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/trappist
	category = CAT_DRINK

/datum/crafting_recipe/goldschlagerbottle
	name = "Goldschlager Bottle"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/ethanol/goldschlager = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/goldschlager
	category = CAT_DRINK

/datum/crafting_recipe/patronbottle
	name = "Patron Bottle"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/ethanol/patron = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/patron
	category = CAT_DRINK

/datum/crafting_recipe/nothingbottle
	name = "Nothing Bottle"
	time = 3 SECONDS
	reqs = list(
		/obj/item/reagent_containers/food/drinks/bottle = 1,
		/datum/reagent/consumable/nothing = 100
	)
	result = /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	category = CAT_DRINK

