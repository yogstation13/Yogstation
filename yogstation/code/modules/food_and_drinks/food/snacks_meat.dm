//yogs - Ports Dolphins!!!

/obj/item/reagent_containers/food/snacks/dolphinmeat
  name = "dolphin fillet"
  desc = "A fillet of spess dolphin meat."
  icon_state = "fishfillet"
  list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
  bitesize = 6
  filling_color = "#FA8072"
  tastes = list("fish" = 1,"cruelty" = 2)
  foodtype = MEAT

/obj/item/reagent_containers/food/snacks/dolphinmeat/Initialize()
  . = ..()
  eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")

/obj/item/reagent_containers/food/snacks/monkeycube/goat
	name = "goat cube"
	desc = "A Goat Tech Industries goat cube. Just add water!"
	icon = 'yogstation/icons/obj/food/food.dmi'
	icon_state = "goatcube"
	bitesize = 20
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("fur" = 1, "blood" = 1, "rage" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/retaliate/goat