/datum/food_processor_process
	var/input
	var/list/blacklist
	var/output
	var/time = 40
	var/required_machine = /obj/machinery/processor

/datum/food_processor_process/meat
	input = /obj/item/reagent_containers/food/snacks/meat/slab
	output = /obj/item/reagent_containers/food/snacks/raw_meatball  //YOGS - Bigotry rule
	blacklist = list(/obj/item/reagent_containers/food/snacks/meat/slab,
		/obj/item/reagent_containers/food/snacks/meat/slab/corgi,
		/obj/item/reagent_containers/food/snacks/meat/slab/xeno,
		/obj/item/reagent_containers/food/snacks/meat/slab/bear,
		/obj/item/reagent_containers/food/snacks/meat/slab/chicken)

/datum/food_processor_process/cutlet
	input = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain
	output = /obj/item/reagent_containers/food/snacks/raw_meatball
	blacklist = list(/obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/bear,
		/obj/item/reagent_containers/food/snacks/meat/cutlet/chicken)

/datum/food_processor_process/human
	input = /obj/item/reagent_containers/food/snacks/meat/slab/human
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/human
	blacklist = null

/datum/food_processor_process/cutlet/human
	input = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/human
	blacklist = null

/datum/food_processor_process/corgi
	input = /obj/item/reagent_containers/food/snacks/meat/slab/corgi
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/corgi
	blacklist = null

/datum/food_processor_process/xeno
	input = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/xeno
	blacklist = null

/datum/food_processor_process/cutlet/xeno
	input = /obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/xeno
	blacklist = null

/datum/food_processor_process/meat/bear
	input = /obj/item/reagent_containers/food/snacks/meat/slab/bear
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/bear
	blacklist = null

/datum/food_processor_process/cutlet/bear
	input = /obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	output = /obj/item/reagent_containers/food/snacks/raw_meatball/bear
	blacklist = null

/datum/food_processor_process/bacon
	input = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet
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
	output = /obj/item/reagent_containers/food/snacks/spaghetti/raw

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
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/blue
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/blue

/datum/food_processor_process/briemix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/brie
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/brie

/datum/food_processor_process/cheddarmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/cheddar
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar

/datum/food_processor_process/fetamix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/feta
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/feta

/datum/food_processor_process/goatmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/goat
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/goat

/datum/food_processor_process/halloumimix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/halloumi
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/halloumi

/datum/food_processor_process/mozzarellamix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/mozzarella
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/mozzarella

/datum/food_processor_process/parmesanmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/parmesan
	output = /obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan

/datum/food_processor_process/swissmix
	input = /obj/item/reagent_containers/food/snacks/cheesemix_heated/swiss
	output = /obj/item/reagent_containers/food/snacks/store/cheesewheel/swiss