/obj/item/storage/box/syndie_kit/cluwnification
	name = "Cluwne Burger Happy Meal (with mimanas)"

/obj/item/storage/box/syndie_kit/cluwnification/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/burger/cluwneburger(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana/mime(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana/mime(src)
	new /obj/item/reagent_containers/food/snacks/fries(src)
	new /obj/item/reagent_containers/food/drinks/soda_cans/cola(src)
	new /obj/item/toy/plush/goatplushie/angry(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/imp_mindslave
	name = "Mindslave Implant (with injector)"

/obj/item/storage/box/syndie_kit/imp_mindslave/PopulateContents()
	new /obj/item/implanter/mindslave(src)

/obj/item/storage/box/syndie_kit/imp_greytide
	name = "Greytide Implant (with injector)"

/obj/item/storage/box/syndie_kit/imp_greytide/PopulateContents()
	new /obj/item/implanter/greytide(src)

///obj/item/storage/box/syndie_kit/xeno_infestation_kit //disabled as creating a xenomorph infestation is not very helpful, but left it in here incase you want to add it
//	name = "Xenomorph Infestation Starter Kit"
//
///obj/item/storage/box/syndie_kit/xeno_infestation_kit/PopulateContents()
//	new /obj/item/autosurgeon/hivenode(src)
//	for(var/i in 1 to 3)
//		new /obj/item/organ/body_egg/alien_embryo(src)

/obj/item/storage/box/syndie_kit/xeno_organ_kit //Just a kit with some basic xeno organs in it and an autosurgeon, as they are kinda rare and cool
	name = "Xenomorph Organ Kit"

/obj/item/storage/box/syndie_kit/xeno_organ_kit/PopulateContents()
	new /obj/item/autosurgeon/plasmavessel(src)
	new /obj/item/organ/alien/resinspinner(src)
	new /obj/item/organ/alien/neurotoxin(src)
	new /obj/item/organ/alien/acid(src)
	//new /obj/item/organ/alien/hivenode(src) //disabled as a hive node is fairly pointless if you arent dealing with xenos have an egg sac, or know someone else with one.
	//new /obj/item/organ/alien/eggsac(src) //disabled as an egg sac is not very helpful for a traitor and can ruin some rounds...   *ahem*
