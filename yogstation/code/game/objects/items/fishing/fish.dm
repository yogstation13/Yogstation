/obj/item/reagent_containers/food/snacks/fish
	name = "development fish"
	desc = "if you see this, get help"
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "bass"

	//food handling
	tastes = list("fishy" = 1)
	foodtype = MEAT | SEAFOOD
	slice_path = /obj/item/reagent_containers/food/snacks/carpmeat/fish

	//fish handling stuff
	var/length = 0
	var/weight = 0
	var/min_length = 1
	var/max_length = 10
	var/min_weight = 1
	var/max_weight = 15


	throwforce = 10
	var/mob/showoffer
	var/mutable_appearance/showoff_overlay

/obj/item/reagent_containers/food/snacks/fish/Initialize(mapload)
	. = ..()
	length = rand(min_length,max_length)
	weight = rand(min_weight,max_weight)
	list_reagents = list(/datum/reagent/consumable/nutriment = (3 * slices_num), /datum/reagent/consumable/nutriment/vitamin = (2 * slices_num))

/obj/item/reagent_containers/food/snacks/fish/proc/GetChumValue()
	return //not used yet

/obj/item/reagent_containers/food/snacks/fish/examine(mob/user)
	. = ..()
	. += "It's [length] inches and [weight] ounces!"

/obj/item/reagent_containers/food/snacks/fish/attack_self(mob/M)
	if(showoff_overlay)
		stop_overlay()
		return
		
	M.setDir(SOUTH)
	showoff_overlay = mutable_appearance(icon,icon_state)
	M.add_overlay(showoff_overlay)
	showoffer = M
	M.visible_message("[M] shows off [src]. It's [length] inches long and weighs [weight] ounces!", \
						 span_notice("You show off [src]. It's [length] inches long and weighs [weight] ounces!"))
	RegisterSignal(M,COMSIG_ATOM_DIR_CHANGE,.proc/stop_overlay,TRUE)

/obj/item/reagent_containers/food/snacks/fish/proc/stop_overlay()
	if(showoffer && showoff_overlay)
		UnregisterSignal(showoffer,COMSIG_ATOM_DIR_CHANGE)
		showoffer.cut_overlay(showoff_overlay)
		showoffer = null
		showoff_overlay = null

/obj/item/reagent_containers/food/snacks/fish/goldfish
	name = "galactic goldfish"
	desc = "it's so... small!"
	icon_state = "fish_goldfish"
	min_length = 1
	max_length = 2
	min_weight = 2
	max_weight = 8
	slices_num = 1

/obj/item/reagent_containers/food/snacks/fish/goldfish/giant
	name = "giant galactic goldfish"
	desc = "it's so... big!"
	icon_state = "fish_goldfish_big"
	min_length = 6
	max_length = 19
	min_weight = 24
	max_weight = 144
	slices_num = 2

/obj/item/reagent_containers/food/snacks/fish/salmon
	name = "space salmon"
	desc = "i thought they were supposed to be red"
	icon_state = "fish_salmon"
	min_length = 28
	max_length = 32
	min_weight = 8
	max_weight = 12
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/bass
	name = "big bang bass"
	desc = "how am I supposed to play this thing?"
	icon_state = "fish_bass"
	min_length = 12
	max_length = 32
	min_weight = 128
	max_weight = 192
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/tuna
	name = "temporal tuna"
	desc = "you can tune a piano but you can't tuna fish"
	icon_state = "fish_tuna"
	min_length = 15
	max_length = 79
	min_weight = 18
	max_weight = 1000
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/shrimp
	name = "space shrimp"
	desc = "he looks a little shrimpy"
	icon_state = "fish_shrimp"
	min_length = 1
	max_length = 6
	min_weight = 1
	max_weight = 3
	slices_num = null //just eat as is

/obj/item/reagent_containers/food/snacks/fish/squid
	name = "space squid"
	desc = "like the game?"
	icon_state = "fish_squid"
	min_length = 18
	max_length = 24
	min_weight = 4
	max_weight = 9
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/puffer
	name = "plasma pufferfish"
	desc = "it doesn't look like it's made of plasma..."
	icon_state = "fish_puffer"
	min_length = 1
	max_length = 1.4
	min_weight = 1
	max_weight = 2
	slices_num = 2

/obj/item/reagent_containers/food/snacks/carpmeat/fish //basic fish fillet (no carpotoxin) for fish butchering
	name = "fish fillet"
	desc = "A fillet of spess fish meat."
	icon_state = "fishfillet"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	bitesize = 6
	filling_color = "#FA8072"
	tastes = list("fish" = 1)
	foodtype = SEAFOOD


	
