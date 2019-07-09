/obj/item/borg/upgrade/janispray
	name = "janitor chem sprayer"
	desc = "A utility used to spray large amounts of cleaning reagents in a given area. It regenerates space cleaner using cell charge."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/janitor

/obj/item/borg/upgrade/janispray/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/reagent_containers/spray/chemsprayer/janitor/A = locate() in R
		if(A)
			to_chat(user, "<span class='warning'>This unit is already equipped with a janitor chem sprayer module.</span>")
			return FALSE

		A = new /obj/item/reagent_containers/spray/chemsprayer/janitor(R.module)
		R.module.basic_modules += A
		R.module.add_module(A, FALSE, TRUE)

/obj/item/borg/upgrade/janispray/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/reagent_containers/spray/chemsprayer/janitor/A in R.module.modules)
			R.module.remove_module(A, TRUE)

		var/obj/item/reagent_containers/spray/chemsprayer/janitor/M = new (R.module)
		R.module.basic_modules += M
		R.module.add_module(M, FALSE, TRUE)