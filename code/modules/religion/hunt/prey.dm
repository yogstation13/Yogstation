/obj/item/food/meat/religioustrophy
	name = "Prime Cut"
	desc = "A bloody trophy taken as proof of a successful hunt. It's still oozing blood"
	icon_state = "primecut"
	bite_consumption = 5
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 15,
		/datum/reagent/water/holywater = 10,
	)
	tastes = list("Holy Purpose" = 5)
	foodtypes = MEAT | RAW | GORE


/mob/living/basic/deer/prey
	name = "Prey of the Hunt"
	desc = "A hapless deer, chosen as prey for the Great Hunt"
	butcher_results = list(/obj/item/food/meat/slab = 3, /obj/item/food/meat/religioustrophy = 1)
