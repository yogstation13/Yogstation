/obj/item/food/cake/yellow_cake
	name = "yellow cake"
	desc = "A chalky yellow cake.. has a weird aura about it."
	icon_state = "yellow_cake"
	food_reagents = list(
		/datum/reagent/uranium = 18,
		/datum/reagent/consumable/sugar = 12,
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/toxin/polonium = 12,
	)
	tastes = list("uranium" = 2, "chalk" = 4)
	foodtypes = GRAIN | DAIRY | SUGAR | GROSS
	slice_type = /obj/item/food/cakeslice/yellow_cake

/obj/item/food/cake/yellow_cake/make_processable()
	..()
	radiation_pulse(src, 50)

/obj/item/food/cakeslice/yellow_cake
	name = "yellow cake slice"
	desc = "A chalky yellow cake.. has a weird aura about it."
	icon_state = "yellow_cake_slice"
	food_reagents = list(
		/datum/reagent/uranium = 3,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/toxin/polonium = 2,
	)
	tastes = list("uranium" = 2, "chalk" = 4)
	foodtypes = GRAIN | DAIRY | SUGAR | GROSS
