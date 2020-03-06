/obj/item/reagent_containers/food/snacks/pie/buttcinnpie
	name = "butterscotch cinnamon pie"
	desc = "Just like goat mom used to make!"
	icon = 'yogstation/icons/obj/food/piecake.dmi'
	icon_state = "buttcinnpie"
	slice_path = /obj/item/reagent_containers/food/snacks/buttcinnpieslice
	slices_num = 5
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/cinnamon = 1)
	tastes = list("cinnamon" = 1, "determination" = 1)

/obj/item/reagent_containers/food/snacks/buttcinnpieslice
	name = "butterscotch cinnamon pie slice"
	desc = "A slice of butterscotch cinnamon pie. Just one."
	icon = 'yogstation/icons/obj/food/piecake.dmi'
	icon_state = "buttcinnpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#D2691E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/cinnamon = 5, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("cinnamon" = 1, "determination" = 1)