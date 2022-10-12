///////////////////////////////////////////CHEESE////////////////////////////////////////////
//cheese
/obj/item/reagent_containers/food/snacks/store/cheesewheel
	name = "cheese wheel or block"
	desc = "A wheel or block of cheese."
	icon = 'icons/obj/food/cheese.dmi'
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge or slice"
	icon = 'icons/obj/food/cheese.dmi'
	desc = "A wedge or slice of cheese."
	foodtype = DAIRY

//cheesemix
/obj/item/reagent_containers/food/snacks/cheesemix
	icon_state = "cheesemix"
	icon = 'icons/obj/food/cheese.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter milk" = 1)
	desc = "Cheese mix, ready to be heated."
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/cheesemix_heated
	icon_state = "cheesemix_heated"
	icon = 'icons/obj/food/cheese.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter cheese" = 1)
	desc = "Heated cheese mix, you can see curds floating."
	foodtype = DAIRY

//american cheese
/obj/item/reagent_containers/food/snacks/store/cheesewheel/american
	name = "american cheese block"
	desc = "A block of american plastic cheese."
	icon_state = "american_block"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/american
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("plastic" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge/american
	name = "american cheese slice"
	desc = "A slice of american plastic cheese. Nothing could be more fake."
	icon_state = "american_slice"
	filling_color = "#FFA51E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("plastic" = 1)

//blue
/obj/item/reagent_containers/food/snacks/store/cheesewheel/blue
	name = "blue cheese wheel"
	desc = "A big wheel of blue cheese."
	icon_state = "blue_wheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/blue
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("mold" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/blue
	name = "blue cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/blue

/obj/item/reagent_containers/food/snacks/cheesemix_heated/blue
	name = "heated blue cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/blue
	name = "blue cheese wedge"
	desc = "A wedge of blue cheese. The mold stands out sharply against the white creamy cheese."
	icon_state = "blue_wedge"
	filling_color = "#DAE1E8"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("mold" = 1)

//brie
/obj/item/reagent_containers/food/snacks/store/cheesewheel/brie
	name = "brie wheel"
	desc = "A big wheel of brie."
	icon_state = "brie_wheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/brie
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("creamy mold" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/brie
	name = "brie mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/brie

/obj/item/reagent_containers/food/snacks/cheesemix_heated/brie
	name = "heated brie mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/brie
	name = "brie wedge"
	desc = "A wedge of brie. Perfect with a cracker."
	icon_state = "brie_wedge"
	filling_color = "#F2E9B7"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("creamy mold" = 1)

//cheddar
/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar
	name = "cheddar wheel"
	desc = "A big wheel of delicious cheddar."
	icon_state = "cheesewheel"
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/cheesewheel/cheddar
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/cheddar
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cheddar" = 1)

/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(W.tool_behaviour == TOOL_WELDER)
		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/stack/sheet/cheese/new_item = new(usr.loc, 5)
			user.visible_message("[user.name] shaped [src] into a sturdier looking cheese with [W].", \
						 span_notice("You shape [src] into a sturdier looking cheese with [W]."), \
						 span_italics("You hear welding."))
			var/obj/item/reagent_containers/food/snacks/store/cheesewheel/cheddar/R = src
			qdel(src)
			var/replace = (user.get_inactive_held_item()==R)
			if (!R && replace)
				user.put_in_hands(new_item)

/obj/item/reagent_containers/food/snacks/cheesemix/cheddar
	name = "cheddar mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/cheddar

/obj/item/reagent_containers/food/snacks/cheesemix_heated/cheddar
	name = "heated cheddar mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar
	name = "cheddar wedge"
	desc = "A wedge of delicious cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewheel_slice"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheddar" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge/cheddar/custom
	name = "cheddar"
	icon_state = "cheesewheel_slice"
	filling_color = "#FFFFFF"
	foodtype = DAIRY

//feta
/obj/item/reagent_containers/food/snacks/store/cheesewheel/feta
	name = "feta cheese block"
	desc = "A big block of feta cheese."
	icon_state = "feta_block"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/feta
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("sheep" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/feta
	name = "feta cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/feta

/obj/item/reagent_containers/food/snacks/cheesemix_heated/feta
	name = "heated feta cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/feta
	name = "feta cheese slice"
	desc = "A slice of feta cheese. It crumbles easily in your hands."
	icon_state = "feta_slice"
	filling_color = "#EBEDE3"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("sheep" = 1)

//goat
/obj/item/reagent_containers/food/snacks/store/cheesewheel/goat
	name = "goat cheese wheel"
	desc = "A big wheel of goat cheese."
	icon_state = "goat_wheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/goat
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("goat" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/goat
	name = "goat cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/goat

/obj/item/reagent_containers/food/snacks/cheesemix_heated/goat
	name = "heated goat cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/goat
	name = "goat cheese wedge"
	desc = "A wedge of goat cheese. The aroma of goat is strong."
	icon_state = "goat_wedge"
	filling_color = "#FDFDFB"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("goat" = 1)

//halloumi
/obj/item/reagent_containers/food/snacks/store/cheesewheel/halloumi
	name = "halloumi cheese block"
	desc = "A big block of halloumi cheese."
	icon_state = "halloumi_block"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/halloumi
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/halloumi
	name = "halloumi cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/halloumi

/obj/item/reagent_containers/food/snacks/cheesemix_heated/halloumi
	name = "heated halloumi cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/halloumi
	name = "halloumi cheese slice"
	desc = "A slice of halloumi cheese. A meat substitute for vegitarians."
	icon_state = "halloumi_slice"
	filling_color = "#EDEFE4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 1)

//mozzarella
/obj/item/reagent_containers/food/snacks/store/cheesewheel/mozzarella
	name = "mozzarella cheese ball"
	desc = "A big ball of mozzarella cheese."
	icon_state = "mozzarella_ball"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/mozzarella
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cream" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/mozzarella
	name = "mozzarella cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/mozzarella

/obj/item/reagent_containers/food/snacks/cheesemix_heated/mozzarella
	name = "heated mozzarella cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/mozzarella
	name = "mozzarella cheese piece"
	desc = "A piece of mozzarella cheese. It needs to be on a pizza ASAP."
	icon_state = "mozzarella_piece"
	filling_color = "#FFFFF6"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cream" = 1)

//parmesan
/obj/item/reagent_containers/food/snacks/store/cheesewheel/parmesan
	name = "parmesan cheese wheel"
	desc = "A big wheel of parmesan cheese."
	icon_state = "parmesan_wheel"
	bitesize = 5
	volume = 200
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/parmesan
	list_reagents = list(/datum/reagent/consumable/nutriment = 100, /datum/reagent/consumable/nutriment/vitamin = 30, /datum/reagent/consumable/parmesan_delight = 20)
	tastes = list("salt" = 1, "magnificence" = 1, "italy" = 1)

/obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan
	name = "unmatured parmesan cheese wheel"
	desc = "A big wheel of unmature parmesan cheese."
	icon_state = "preparmesan_wheel"
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/cheese.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter salt" = 1)

/obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/ageCheese), 20 MINUTES)

/obj/item/reagent_containers/food/snacks/cheesewheel/preparmesan/proc/ageCheese()
	new /obj/item/reagent_containers/food/snacks/store/cheesewheel/parmesan(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/cheesemix/parmesan
	name = "parmesan cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/parmesan

/obj/item/reagent_containers/food/snacks/cheesemix_heated/parmesan
	name = "heated parmesan cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan
	name = "parmesan cheese wedge"
	desc = "A wedge of parmesan cheese. You feel incredibly artisnal holding this."
	icon_state = "parmesan_wedge"
	filling_color = "#F0DF9C"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/parmesan_delight = 4)
	tastes = list("salt" = 1, "magnificence" = 1, "italy" = 1)

//swiss
/obj/item/reagent_containers/food/snacks/store/cheesewheel/swiss
	name = "swiss cheese wheel"
	desc = "A big wheel of swiss cheese."
	icon_state = "swiss_wheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/swiss
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("holes" = 1)

/obj/item/reagent_containers/food/snacks/cheesemix/swiss
	name = "swiss cheese mix"
	cooked_type = /obj/item/reagent_containers/food/snacks/cheesemix_heated/swiss

/obj/item/reagent_containers/food/snacks/cheesemix_heated/swiss
	name = "heated swiss cheese mix"

/obj/item/reagent_containers/food/snacks/cheesewedge/swiss
	name = "swiss cheese wedge"
	desc = "A wedge of swiss cheese. The holes echo 'eat me' back to you."
	icon_state = "swiss_wedge"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("holes" = 1)

//bug cheese
/obj/item/reagent_containers/food/snacks/store/cheesewheel/bug
	name = "bug cheese ball"
	desc = "A big ball of gutlunch \"honey\", with a similar consistency to cheese."
	icon_state = "bug_ball"
	foodtype = SUGAR | MEAT //honey made by a carnivorous scavenging bug
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge/bug
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("a rather large serving of sugar" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/cheesewedge/bug
	name = "bug cheese piece"
	desc = "A piece of gutlunch \"honey\"."
	icon_state = "bug_piece"
	filling_color = "#ddedd5"
	foodtype = SUGAR | MEAT
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("a rather large serving of sugar" = 1, "meat" = 1)

//Regal rat cheese
/obj/item/reagent_containers/food/snacks/royalcheese
	name = "royal cheese"
	desc = "Ascend the throne. Consume the wheel. Feel the POWER."
	icon_state = "royalcheese"
	list_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/gold = 20, /datum/reagent/toxin/mutagen = 5)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("cheese" = 4, "royalty" = 1)
	foodtype = DAIRY