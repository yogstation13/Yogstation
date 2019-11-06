///////////////////////////////////////////CHEESE////////////////////////////////////////////

//cheese
/obj/item/reagent_containers/food/snacks/store/cheesewheel
	name = "cheese wheel or block"
	desc = "A wheel or block of cheese"
	icon = 'icons/obj/food/cheese.dmi'
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge or slice"
	icon = 'icons/obj/food/cheese.dmi'
	desc = "A wedge or slice of cheese"
	foodtype = DAIRY

//cheesemix
/obj/item/reagent_containers/food/snacks/cheesemix
	icon_state = "tba"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter milk" = 1)
	foodtype = DAIRY

//american cheese
/obj/item/reagent_containers/food/snacks/store/cheesewheel/american
	name = "american cheese block"
	desc = "A block of american plastic cheese"
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/american
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("plastic" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge/american
	name = "american cheese slice"
	desc = "A slice of american plastic cheese"
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("plastic" = 1)

//blue
/obj/item/reagent_containers/food/snacks/store/cheesewheel/blue
	name = "blue cheese wheel"
	desc = "A big wheel of delcious Blue cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/blue
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("mould" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/blue
	name = "blue cheese mix"
	desc = "Blue cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/blue_heated

/obj/item/reagent_containers/food/snacks/cheesemix/blue_heated
	name = "heated blue cheese mix"
	desc = "Heated blue cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/blue
	name = "blue cheese wedge"
	desc = "A wedge of delicious Blue cheese. The cheese wheel it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("mould" = 1)

//brie
/obj/item/reagent_containers/food/snacks/store/cheesewheel/brie
	name = "brie wheel"
	desc = "A big wheel of delcious Brie."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/brie
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("creamy mould" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/brie
	name = "brie mix"
	desc = "Brie cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/brie_heated

/obj/item/reagent_containers/food/snacks/cheesemix/brie_heated
	name = "heated brie mix"
	desc = "Heated brie mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/brie
	name = "brie wedge"
	desc = "A wedge of delicious Brie. The cheese wheel it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("creamy mould" = 1)	

//cheddar
/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar
	name = "cheddar wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/cheesewheel/cheddar
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/cheddar
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cheddar" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/cheddar
	name = "cheddar mix"
	desc = "Cheddar cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/cheddar_heated

/obj/item/reagent_containers/food/snacks/cheesemix/cheddar_heated
	name = "heated cheddar mix"
	desc = "Heated cheddar mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar
	name = "cheddar wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewheel_slice"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheddar" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar/custom
	name = "cheddar"
	customfoodfilling = 0
	icon_state = "cheesewheel_slice"
	filling_color = "#FFFFFF"
	foodtype = DAIRY

//feta
/obj/item/reagent_containers/food/snacks/store/cheesewheel/feta
	name = "feta cheese block"
	desc = "A big block of delcious Feta cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/feta
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("sheep" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/feta
	name = "feta cheese mix"
	desc = "Feta cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/feta_heated

/obj/item/reagent_containers/food/snacks/cheesemix/feta_heated
	name = "heated feta cheese mix"
	desc = "Heated feta cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/feta
	name = "feta cheese slice"
	desc = "A slice of delicious Feta cheese. The cheese block it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("sheep" = 1)

//goat
/obj/item/reagent_containers/food/snacks/store/cheesewheel/goat
	name = "goat cheese wheel"
	desc = "A big wheel of delcious Goat cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/goat
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("goat" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/goat
	name = "goat cheese mix"
	desc = "Goat cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/goat_heated

/obj/item/reagent_containers/food/snacks/cheesemix/goat_heated
	name = "heated goat cheese mix"
	desc = "Heated goat cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/goat
	name = "goat cheese wedge"
	desc = "A wedge of delicious goat cheese. The cheese wheel it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("goat" = 1)

//halloumi
/obj/item/reagent_containers/food/snacks/store/cheesewheel/halloumi
	name = "halloumi cheese block"
	desc = "A big block of delcious Halloumi cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/halloumi
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/halloumi
	name = "halloumi cheese mix"
	desc = "Halloumi cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/halloumi_heated

/obj/item/reagent_containers/food/snacks/cheesemix/halloumi_heated
	name = "heated halloumi cheese mix"
	desc = "Heated halloumi cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/halloumi
	name = "halloumi cheese slice"
	desc = "A slice of delicious Halloumi cheese. The cheese block it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 1)

//mozzarella
/obj/item/reagent_containers/food/snacks/store/cheesewheel/mozzarella
	name = "mozzarella cheese ball"
	desc = "A big ball of delcious mozzarella cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/mozzarella
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cream" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/mozzarella
	name = "mozzarella cheese mix"
	desc = "Mozzarella cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/mozzarella_heated

/obj/item/reagent_containers/food/snacks/cheesemix/mozzarella_heated
	name = "heated mozzarella cheese mix"
	desc = "Heated mozzarella cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/mozzarella
	name = "mozzarella cheese piece"
	desc = "A piece of delicious Mozzarella cheese. The cheese ball it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cream" = 1)

//parmesan
/obj/item/reagent_containers/food/snacks/store/cheesewheel/parmesan
	name = "parmesan cheese wheel"
	desc = "A big wheel of delcious Parmesan cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/parmesan
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("salt" = 1)

/obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan
	name = "unmature parmesan cheese wheel"
	desc = "A big wheel of unmature Parmesan cheese."
	icon_state = "tba"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter salt" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/parmesan
	name = "parmesan cheese mix"
	desc = "Parmesan cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/parmesan_heated

/obj/item/reagent_containers/food/snacks/cheesemix/parmesan_heated
	name = "heated parmesan cheese mix"
	desc = "Heated parmesan cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan
	name = "parmesan cheese wedge"
	desc = "A wedge of delicious parmesan cheese. The cheese wheel it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("salt" = 1)

//swiss
/obj/item/reagent_containers/food/snacks/store/cheesewheel/swiss
	name = "swiss cheese wheel"
	desc = "A big wheel of delcious Swiss cheese."
	icon_state = "tba"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/swiss
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("holes" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/swiss
	name = "swiss cheese mix"
	desc = "Swiss cheese mix, it's a bit cold..."
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix/swiss_heated

/obj/item/reagent_containers/food/snacks/cheesemix/swiss_heated
	name = "heated swiss cheese mix"
	desc = "Heated swiss cheese mix, you can see curds floating."	

/obj/item/reagent_containers/food/snacks/cheesewedge/swiss
	name = "swiss cheese wedge"
	desc = "A wedge of delicious Swiss cheese. The cheese wheel it was cut from can't have gone far."
	icon_state = "tba"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("holes" = 1)
