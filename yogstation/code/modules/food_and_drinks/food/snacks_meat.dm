//yogs - Ports Dolphins!!!

/obj/item/reagent_containers/food/snacks/dolphinmeat
  name = "dolphin fillet"
  desc = "A fillet of spess dolphin meat."
  icon_state = "fishfillet"
  list_reagents = list("nutriment" = 3, "vitamin" = 2)
  bitesize = 6
  filling_color = "#FA8072"
  tastes = list("fish" = 1,"cruelty" = 2)
  foodtype = MEAT

/obj/item/reagent_containers/food/snacks/dolphinmeat/Initialize()
  . = ..()
  eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
