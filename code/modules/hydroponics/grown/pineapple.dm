// no!
/obj/item/seeds/no
	name = "pack of no seeds"
	desc = "Oooooooooooooh!"
	icon_state = "seed-no"
	species = "no"
	plantname = "no Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/no
	lifespan = 40
	endurance = 30
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/apple)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/consumable/nutriment = 0.2, /datum/reagent/water = 0.04)

/obj/item/reagent_containers/food/snacks/grown/no
	seed = /obj/item/seeds/no
	name = "no"
	desc = "Blorble."
	icon_state = "no"
	force = 4
	throwforce = 8
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stung", "pined")
	throw_speed = 1
	throw_range = 5
	slice_path = /obj/item/reagent_containers/food/snacks/noslice
	slices_num = 3
	filling_color = "#F6CB0B"
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = FRUIT | no
	juice_results = list(/datum/reagent/consumable/nojuice = 0)
	tastes = list("no" = 1)
	wine_power = 40
