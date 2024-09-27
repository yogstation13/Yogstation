//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()
	var/datum/objective/steal/objective		//The objective datum for our objective

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/ar2
	name = "a overwatch standard issue pulse rifle."
	targetitem = /obj/item/gun/ballistic/automatic/ar2
	difficulty = 5
	excludefromjob = list("Divisional Lead", "Warden")

/datum/objective_item/steal/mask
	name = "a civil protection mask."
	targetitem = /obj/item/clothing/mask/gas/civilprotection
	difficulty = 4
	excludefromjob = list("Divisional Lead", "Warden")

/datum/objective_item/steal/documents
	name = "the administrator's secret documents."
	targetitem = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	difficulty = 6

//Unique Objectives
/datum/objective_item/unique/docs_red
	name = "the \"Red\" secret documents."
	targetitem = /obj/item/documents/syndicate/red
	difficulty = 10

/datum/objective_item/unique/docs_blue
	name = "the \"Blue\" secret documents."
	targetitem = /obj/item/documents/syndicate/blue
	difficulty = 10

/datum/objective_item/special/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/special/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Old ninja objectives.
/datum/objective_item/special/pinpointer/nuke
	name = "the District Administrator's pinpointer."
	targetitem = /obj/item/pinpointer
	difficulty = 10

/datum/objective_item/special/aegun
	name = "an advanced energy gun."
	targetitem = /obj/item/gun/energy/e_gun/nuclear
	difficulty = 10

/datum/objective_item/special/ddrill
	name = "a diamond drill."
	targetitem = /obj/item/pickaxe/drill/diamonddrill
	difficulty = 10

/datum/objective_item/special/boh
	name = "the Research Director's bag of holding."    //Just in case these are activated again this one is updated to reference the only one on station now. - Aquizit Jan '23
	targetitem = /obj/item/storage/backpack/holding
	difficulty = 10

/datum/objective_item/special/hypercell
	name = "a hyper-capacity power cell."
	targetitem = /obj/item/stock_parts/cell/hyper
	difficulty = 5

/datum/objective_item/special/laserpointer
	name = "a laser pointer."
	targetitem = /obj/item/laser_pointer
	difficulty = 5

/datum/objective_item/special/corgimeat
	name = "a piece of corgi meat."
	targetitem = /obj/item/reagent_containers/food/snacks/meat/slab/corgi
	difficulty = 5

/datum/objective_item/stack/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/stack/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboard."
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001

/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds."
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

/datum/objective_item/stack/gold
	name = "50 gold bars."
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars."
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10
