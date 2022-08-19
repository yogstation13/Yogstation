/obj/item/reagent_containers/food/snacks/fish
	name = "debug fish"
	desc = "If you see this, get help!"
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
	length = rand(min_length,max_length)
	weight = rand(min_weight,max_weight)
	list_reagents = list(/datum/reagent/consumable/nutriment = (3 * slices_num ? slices_num : 1), /datum/reagent/consumable/nutriment/vitamin = (2 * slices_num ? slices_num : 1))
	. = ..()

/obj/item/reagent_containers/food/snacks/fish/proc/GetChumValue()
	return //not used yet

/obj/item/reagent_containers/food/snacks/fish/examine(mob/user)
	. = ..()
	. += "It's [length] inch[length > 1 ? "es" : ""] and [weight] ounce[weight > 1 ? "s" : ""]!"

/obj/item/reagent_containers/food/snacks/fish/attack_self(mob/M)
	if(showoff_overlay)
		stop_overlay()
		return
		
	M.setDir(SOUTH)
	showoff_overlay = mutable_appearance(icon,icon_state)
	M.add_overlay(showoff_overlay)
	showoffer = M
	M.visible_message("[M] shows off [src]. It's [length] inch[length > 1 ? "es" : ""] long and weighs [weight] ounce[weight > 1 ? "s" : ""]!", \
						 span_notice("You show off [src]. It's [length] inch[length > 1 ? "es" : ""] long and weighs [weight] ounce[weight > 1 ? "s" : ""]!"))
	RegisterSignal(M,COMSIG_ATOM_DIR_CHANGE,.proc/stop_overlay,TRUE)

/obj/item/reagent_containers/food/snacks/fish/proc/stop_overlay()
	if(showoffer && showoff_overlay)
		UnregisterSignal(showoffer,COMSIG_ATOM_DIR_CHANGE)
		showoffer.cut_overlay(showoff_overlay)
		showoffer = null
		showoff_overlay = null

/obj/item/reagent_containers/food/snacks/fish/goldfish
	name = "galactic goldfish"
	desc = "It's so... small!"
	icon_state = "fish_goldfish"
	min_length = 1
	max_length = 2
	min_weight = 2
	max_weight = 8
	slices_num = 1

/obj/item/reagent_containers/food/snacks/fish/goldfish/giant
	name = "giant galactic goldfish"
	desc = "It's so... big!"
	icon_state = "fish_goldfish_big"
	min_length = 6
	max_length = 19
	min_weight = 24
	max_weight = 144
	slices_num = 2

/obj/item/reagent_containers/food/snacks/fish/salmon
	name = "space salmon"
	desc = "I thought they were supposed to be red..."
	icon_state = "fish_salmon"
	min_length = 28
	max_length = 32
	min_weight = 8
	max_weight = 12
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/bass
	name = "big bang bass"
	desc = "How am I supposed to play this thing?"
	icon_state = "fish_bass"
	min_length = 12
	max_length = 32
	min_weight = 128
	max_weight = 192
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/tuna
	name = "temporal tuna"
	desc = "You can tune a piano but you can't tuna fish!"
	icon_state = "fish_tuna"
	min_length = 15
	max_length = 79
	min_weight = 18
	max_weight = 1000
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/shrimp
	name = "space shrimp"
	desc = "He looks a little shrimpy."
	icon_state = "fish_shrimp"
	min_length = 1
	max_length = 6
	min_weight = 1
	max_weight = 3
	slices_num = null //just eat as is

/obj/item/reagent_containers/food/snacks/fish/squid
	name = "space squid"
	desc = "Like the game?"
	icon_state = "fish_squid"
	min_length = 18
	max_length = 24
	min_weight = 4
	max_weight = 9
	slices_num = 3

/obj/item/reagent_containers/food/snacks/fish/puffer
	name = "plasma pufferfish"
	desc = "It doesn't look like it's made of plasma..."
	icon_state = "fish_puffer"
	min_length = 1
	max_length = 1.4
	min_weight = 1
	max_weight = 2
	slices_num = 2

/obj/item/reagent_containers/food/snacks/carpmeat/fish //basic fish fillet (no carpotoxin) for fish butchering
	name = "fish fillet"
	desc = "A fillet of spess fish meat."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)

//SPECIAL FISH

/obj/item/reagent_containers/food/snacks/fish/rat
	name = "ratfish"
	desc = "Better find some underwater cheese!"
	icon_state = "fish_rat"
	min_length = 1
	max_length = 5
	min_weight = 1
	max_weight = 8
	tool_behaviour = TOOL_WIRECUTTER //yooo ratfish be cuttin wires n shit
	toolspeed = 0.5


	
