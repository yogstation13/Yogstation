/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	var/required_machine = /obj/machinery/processor

/datum/food_processor_process/meat
	input = /obj/item/reagent_containers/food/snacks/meat/slab
	output = /obj/item/reagent_containers/food/snacks/meatball  //YOGS - Bigotry rule

/datum/food_processor_process/bacon
	input = /obj/item/reagent_containers/food/snacks/meat/rawcutlet
	output = /obj/item/reagent_containers/food/snacks/meat/rawbacon

/datum/food_processor_process/potatowedges
	input = /obj/item/reagent_containers/food/snacks/grown/potato/wedges
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/food_processor_process/sweetpotato
	input = /obj/item/reagent_containers/food/snacks/grown/potato/sweet
	output = /obj/item/reagent_containers/food/snacks/yakiimo

/datum/food_processor_process/potato
	input = /obj/item/reagent_containers/food/snacks/grown/potato
	output = /obj/item/reagent_containers/food/snacks/tatortot

/datum/food_processor_process/carrot
	input = /obj/item/reagent_containers/food/snacks/grown/carrot
	output = /obj/item/reagent_containers/food/snacks/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/reagent_containers/food/snacks/grown/soybeans
	output = /obj/item/reagent_containers/food/snacks/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/reagent_containers/food/snacks/doughslice
	output = /obj/item/reagent_containers/food/snacks/spaghetti

/datum/food_processor_process/corn
	input = /obj/item/reagent_containers/food/snacks/grown/corn
	output = /obj/item/reagent_containers/food/snacks/tortilla

/datum/food_processor_process/parsnip
	input = /obj/item/reagent_containers/food/snacks/grown/parsnip
	output = /obj/item/reagent_containers/food/snacks/roastparsnip

/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null
	required_machine = /obj/machinery/processor/slime
	
/datum/food_processor_process/bluemix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/blue_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/blue

/datum/food_processor_process/briemix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/brie_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/brie

/datum/food_processor_process/cheddarmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/cheddar_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar

/datum/food_processor_process/fetamix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/feta_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/feta

/datum/food_processor_process/goatmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/goat_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/goat

/datum/food_processor_process/halloumimix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/halloumi_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/halloumi

/datum/food_processor_process/mozzarellamix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/mozzarella_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/mozzarella

/datum/food_processor_process/parmesanmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/parmesan_heated
	output = /obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan

/datum/food_processor_process/swissmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix/swiss_heated
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/swiss
