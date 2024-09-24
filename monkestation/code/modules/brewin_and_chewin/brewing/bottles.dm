/obj/item/reagent_containers/cup/glass/bottle/small/brewing_bottle
	name = "Flash Bottle"
	desc = "A quickly printed bottle using a non-recycleable glass."
	icon =  'monkestation/code/modules/brewin_and_chewin/icons/bottle.dmi'
	icon_state = "brew_bottle"

	var/glass_name
	var/glass_desc

/obj/item/reagent_containers/cup/glass/bottle/small/brewing_bottle/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target.type in (typesof(/obj/item/reagent_containers/cup/glass) - typesof(/obj/item/reagent_containers/cup/glass/bottle)))
		if(glass_name)
			target.name = glass_name
		if(glass_desc)
			target.desc = glass_desc
	if(reagents.total_volume <= 0)
		glass_desc = null
		glass_name = null
