#define ICE_CREAM_VANILLA 1
#define ICE_CREAM_CHOCOLATE 2
#define ICE_CREAM_STRAWBERRY 3
#define ICE_CREAM_BLUE 4
#define ICE_CREAM_LEMON 5
#define ICE_CREAM_CARAMEL 6
#define ICE_CREAM_BANANA 7
#define ICE_CREAM_ORANGE 8
#define ICE_CREAM_PEACH 9
#define ICE_CREAM_CHERRY_CHOCOLATE 10
#define ICE_CREAM_MEAT_LOVERS 11
#define CONE_CAKE 12
#define CONE_CHOC 13

/obj/machinery/ice_cream_vat
	name = "ice cream vat"
	desc = "Ding-aling ding dong. Get your Nanotrasen-approved ice cream!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	var/selected_ice_cream = ICE_CREAM_VANILLA
	var/selected_cone = CONE_CAKE
	var/static/list/starting_contents_list = list(
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/vanilla = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/chocolate = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/strawberry = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/blue = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/lemon_sorbet = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/caramel = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/banana = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/orange_creamsicle = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/peach = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/cherry_chocolate = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_scoop/meat = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake = 5,
												/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate = 5)

///////////////////
//ICE CREAM CONES//
///////////////////

/obj/item/reagent_containers/food/snacks/ice_cream_cone
	name = "ice cream cone base"
	desc = "Please report this, as this should not meant to be seen."
	icon = 'icons/obj/kitchen.dmi'
	bitesize = 3
	foodtype = GRAIN
	var/ice_creamed = FALSE //FALSE when empty, TRUE when scooped
	var/extra_reagent = null //For adding chems to specific cones
	var/extra_reagent_amount = 1 //Amount of extra_reagent to add to cone

/obj/item/reagent_containers/food/snacks/ice_cream_cone/Initialize(mapload)
	. = ..()
	create_reagents(20)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 4)
	if(extra_reagent != null)
		reagents.add_reagent(extra_reagent, extra_reagent_amount)

/obj/item/reagent_containers/food/snacks/ice_cream_cone/cake
	name = "cake ice cream cone"
	desc = "Delicious cake cone, but no ice cream."
	icon_state = "icecream_cone_waffle"
	tastes = list("bland" = 6)
	extra_reagent = /datum/reagent/consumable/nutriment
	
/obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate
	name = "chocolate ice cream cone"
	desc = "Delicious chocolate cone, but no ice cream."
	icon_state = "icecream_cone_chocolate"
	tastes = list("bland" = 4, "chocolate" = 6)
	extra_reagent = /datum/reagent/consumable/coco
