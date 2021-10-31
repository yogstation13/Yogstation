/obj/item/reagent_containers/food/snacks/fish
	name = "development fish"
	desc = "if you see this, get help"
	icon = 'yogstation/icons/obj/fishing/fishing.dmi'
	icon_state = "bass"
	tastes = list("fishy" = 1)
	foodtype = MEAT //maybe seafood!?!??!?!
	var/length = 0
	var/weight = 0
	var/min_length = 1
	var/max_length = 10
	var/min_weight = 1
	var/max_weight = 15

/obj/item/reagent_containers/food/snacks/fish/Initialize(mapload)
	. = ..()
	length = rand(min_length,max_length)
	weight = rand(min_weight,max_weight)

/obj/item/reagent_containers/food/snacks/fish/proc/GetChumValue()
	return //not used yet

/obj/item/reagent_containers/food/snacks/fish/examine(mob/user)
	. = ..()
	. += "It's [length] inches and [weight] oz!"

/obj/item/reagent_containers/food/snacks/fish/goldfish
	name = "galaxy goldfish"
	desc = "it's so... small!"
	icon_state = "fish_goldfish"
	min_length = 1
	max_length = 2
	min_weight = 2
	max_weight = 8

/obj/item/reagent_containers/food/snacks/fish/goldfish/giant
	name = "giant galaxy goldfish"
	desc = "it's so... big!"
	icon_state = "fish_goldfish_big"
	min_length = 6
	max_length = 19
	min_weight = 24
	max_weight = 144

/obj/item/reagent_containers/food/snacks/fish/salmon
	name = "space salmon"
	desc = "i thought they were supposed to be red"
	icon_state = "fish_salmon"
	min_length = 28
	max_length = 32
	min_weight = 8
	max_weight = 12

/obj/item/reagent_containers/food/snacks/fish/bass
	name = "big bang bass"
	desc = "how am I supposed to play this thing?"
	icon_state = "fish_bass"
	min_length = 12
	max_length = 32
	min_weight = 128
	max_weight = 192

/obj/item/reagent_containers/food/snacks/fish/tuna
	name = "temporal tuna"
	desc = "you can tune a piano but you can't tuna fish"
	icon_state = "fish_tuna"
	min_length = 15
	max_length = 79
	min_weight = 18
	max_weight = 1000

/obj/item/reagent_containers/food/snacks/fish/shrimp
	name = "space shrimp"
	desc = "he looks a little shrimpy"
	icon_state = "fish_shrimp"
	min_length = 1
	max_length = 6
	min_weight = 1
	max_weight = 3

/obj/item/reagent_containers/food/snacks/fish/squid
	name = "space squid"
	desc = "like the game?"
	icon_state = "fish_squid"
	min_length = 18
	max_length = 24
	min_weight = 4
	max_weight = 9

/obj/item/reagent_containers/food/snacks/fish/puffer
	name = "plasma pufferfish"
	desc = "it doesn't look like it's made of plasma..."
	icon_state = "fish_puffer"
	min_length = 1
	max_length = 1.4
	min_weight = 1
	max_weight = 2


	
