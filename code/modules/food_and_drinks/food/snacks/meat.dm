/obj/item/reagent_containers/food/snacks/meat
	var/subjectname = ""
	var/subjectjob = null

/obj/item/reagent_containers/food/snacks/meat/slab
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	dried_type = /obj/item/reagent_containers/food/snacks/sosjerky/healthy
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/cooking_oil = 2) //Meat has fats that a food processor can process into cooking oil
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain
	slices_num = 3
	filling_color = "#FF0000"
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/plain, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_slice(obj/item/reagent_containers/food/snacks/meat/raw_cutlet/slice, reagents_per_slice)
	..()
	var/mutable_appearance/filling = mutable_appearance(icon, "raw_cutlet_coloration")
	filling.color = filling_color
	slice.add_overlay(filling)
	slice.filling_color = filling_color
	slice.name = "raw [name] cutlet"
	slice.meat_type = name

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[name] steak"

///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/human
	name = "meat"
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/human/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/plain/human, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later mayb

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_slice(obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain/human/slice, reagents_per_slice)
	..()
	slice.subjectname = subjectname
	slice.subjectjob = subjectjob
	if(subjectname)
		slice.name = "raw [subjectname] cutlet"
	else if(subjectjob)
		slice.name = "raw [subjectjob] cutlet"

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/meat/S, cooking_efficiency)
	..()
	S.subjectname = subjectname
	S.subjectjob = subjectjob
	if(subjectname)
		S.name = "[subjectname] meatsteak"
	else if(subjectjob)
		S.name = "[subjectjob] meatsteak"


/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Because jello wasn't offensive enough to vegans."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin/slimejelly = 3)
	filling_color = "#00FFFF"
	tastes = list("slime" = 1, "jelly" = 1)
	foodtype = MEAT | RAW | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Edible rocks, welcome to the future."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/iron = 3)
	filling_color = "#A9A9A9"
	tastes = list("rock" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "From the slime pen to the rune to the kitchen, science."
	filling_color = "#66CDAA"
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Delicious dino damage."
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain/human/lizard
	filling_color = "#6B8E23"
	tastes = list("meat" = 4, "scales" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/plain/human/lizard, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	icon_state = "plantmeat"
	desc = "All the joys of healthy eating with all the fun of cannibalism."
	filling_color = "#E9967A"
	tastes = list("salad" = 1, "wood" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Ow, the edge."
	filling_color = "#202020"
	tastes = list("darkness" = 1, "meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nothing says tasty like maggot filled radioactive mutant flesh."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/uranium = 3)
	tastes = list("maggots" = 1, "the inside of a reactor" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	icon_state = "mothmeat"
	desc = "Unpleasantly powdery and dry. Kind of pretty, though."
	filling_color = "#BF896B"
	tastes = list("dust" = 1, "powder" = 1, "meat" = 2)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	name = "bone"
	icon_state = "skeletonmeat"
	desc = "There's a point where this needs to stop, and clearly we have passed it."
	filling_color = "#F0F0F0"
	tastes = list("bone" = 1)
	slice_path = null  //can't slice a bone into cutlets
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	name = " meat (rotten)"
	icon_state = "rottenmeat"
	desc = "Halfway to becoming fertilizer for your garden."
	filling_color = "#6B8E23"
	tastes = list("brains" = 1, "meat" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	icon_state = "etherealmeat"
	desc = "So shiny you feel like ingesting it might make you shine too"
	filling_color = "#97ee63"
	list_reagents = list(/datum/reagent/consumable/liquidelectricity = 3, /datum/reagent/consumable/tinlux = 3)
	tastes = list("pure electricity" = 2, "meat" = 1)
	foodtype = RAW | MEAT | TOXIC

////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	name = "synthmeat"
	icon_state = "meat_old"
	desc = "A synthetic slab of meat."
	foodtype = RAW | MEAT //hurr durr chemicals were harmed in the production of this meat thus its non-vegan.

/obj/item/reagent_containers/food/snacks/meat/slab/synthmeat/MakeGrillable()
	AddComponent(/datum/component/grillable,/obj/item/reagent_containers/food/snacks/meat/steak/synth, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	icon_state = "meatproduct"
	desc = "A slab of station reclaimed and chemically processed meat product."
	tastes = list("meat flavoring" = 2, "modified starches" = 2, "natural & artificial dyes" = 1, "butyric acid" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/meatproduct, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/monkey
	name = "monkey meat"
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/mouse
	name = "mouse meat"
	desc = "A slab of mouse meat. Best not eat it raw."
	foodtype = MICE

/obj/item/reagent_containers/food/snacks/meat/slab/corgi
	name = "corgi meat"
	desc = "Tastes like... well you know..."
	tastes = list("meat" = 4, "a fondness for wearing hats" = 1)
	foodtype = RAW | MEAT | GROSS

/obj/item/food/meat/slab/mothroach
	name = "mothroach meat"
	desc = "A light slab of meat."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/pug
	name = "pug meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/killertomato
	name = "killer tomato meat"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	filling_color = "#FF0000"
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/killertomato
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/slab/killertomato/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/killertomato, rand(70 SECONDS, 85 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/bear
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/medicine/morphine = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cooking_oil = 6)
	filling_color = "#FFB6C1"
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/bear
	tastes = list("meat" = 1, "salmon" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/bear/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/bear, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)


/obj/item/reagent_containers/food/snacks/meat/slab/xeno
	name = "xeno meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	bitesize = 4
	filling_color = "#32CD32"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/xeno
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/xeno
	tastes = list("meat" = 1, "acid" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/xeno/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/xeno, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/spider
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#7CFC00"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/spider
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/spider
	tastes = list("cobwebs" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/spider/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/spider, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/slab/goliath
	name = "goliath meat"
	desc = "A slab of goliath meat. It's not very edible now, but it cooks great in lava."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 5, /datum/reagent/consumable/cooking_oil = 3)
	icon_state = "goliathmeat"
	tastes = list("meat" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/goliath/burn()
	visible_message("[src] finishes cooking!")
	new /obj/item/reagent_containers/food/snacks/meat/steak/goliath(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/meat/slab/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/blood = 5, /datum/reagent/consumable/cooking_oil = 1)
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4
	tastes = list("meat" = 1, "wheat" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/meat/slab/gorilla
	name = "gorilla meat"
	desc = "Much meatier than monkey meat."
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 5) //Plenty of fat!

/obj/item/reagent_containers/food/snacks/meat/rawbacon
	name = "raw piece of bacon"
	desc = "A raw piece of bacon."
	icon_state = "bacon"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cooking_oil = 3)
	filling_color = "#B22222"
	tastes = list("bacon" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/rawbacon/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/bacon, rand(25 SECONDS, 45 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/bacon
	name = "piece of bacon"
	desc = "A delicious piece of bacon."
	icon_state = "baconcooked"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 2)
	filling_color = "#854817"
	tastes = list("bacon" = 1)
	foodtype = MEAT | BREAKFAST
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/meat/slab/gondola
	name = "gondola meat"
	desc = "According to legends of old, consuming raw gondola flesh grants one inner peace."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/tranquility = 5, /datum/reagent/consumable/cooking_oil = 3)
	tastes = list("meat" = 4, "tranquility" = 1)
	filling_color = "#9A6750"
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/gondola
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/gondola/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/gondola, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/reagent_containers/food/snacks/meat/slab/penguin
	name = "penguin meat"
	icon_state = "birdmeat"
	desc = "A slab of penguin meat."
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/cooking_oil = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/penguin
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/penguin
	filling_color = "#B22222"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/reagent_containers/food/snacks/meat/slab/penguin/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/steak/penguin, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE) //Add medium rare later maybe?

/obj/item/reagent_containers/food/snacks/meat/slab/blessed
	name = "blessed meat"
	icon_state = "shadowmeat"
	desc = "It is covered in a strange darkness."
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3) //pretty healthy, chap could start a cult diner.
	slice_path = null  //its perfect as it is, why would you want to defile it
	cooked_type = null
	filling_color = "#202020"
	tastes = list("holyness" = 1, "meat" = 1, "dread" = 1)
	foodtype = MEAT | RAW | GROSS //they just don't understand how tasty it really is

/obj/item/reagent_containers/food/snacks/meat/slab/blessed/weak
	name = "lesser blessed meat"
	icon_state = "shadowmeat"
	desc = "It is covered in a strange darkness. This slab's magical properties appear to be drastically weakened due to the synthetic nature of the meat."

/obj/item/reagent_containers/food/snacks/meat/slab/plagued
	name = "meat"
	desc = "A slab of disease-ridden meat. Eating it is a questionable idea."
	icon_state = "meat"
	dried_type = /obj/item/reagent_containers/food/snacks/sosjerky/
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/cooking_oil = 2, /datum/reagent/plaguebacteria = 3) //It is infected by plague
	slice_path = /obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain
	slices_num = 3
	filling_color = "#FF0000"
	tastes = list("meat" = 2, "decay" = 1)
	foodtype = MEAT | RAW

////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/steak
	name = "steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#B22222"
	foodtype = MEAT
	tastes = list("meat" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet
	slices_num = 3
	juice_results = list(/datum/reagent/consumable/drippings = 15)
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/meat/steak/plain
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/plain/human
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/steak/killertomato
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	name = "killer tomato steak"
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/steak/bear
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	name = "bear steak"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/xeno
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	name = "xeno steak"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/spider
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	name = "spider steak"
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/goliath
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash = null
	tastes = list("meat" = 1, "rock" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/gondola
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	name = "gondola steak"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/penguin
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	name = "penguin steak"
	icon_state = "birdsteak"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/plain/human/lizard
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "lizard steak"
	icon_state = "birdsteak"
	tastes = list("juicy chicken" = 3, "scales" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/meatproduct
	name = "thermally processed meat product"
	icon_state = "meatproductsteak"
	tastes = list("enhanced char" = 2, "suspicious tenderness" = 2, "natural & artificial dyes" = 2, "emulsifying agents" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/synth
	slice_path = /obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "synthsteak"
	desc = "A synthetic meat steak. It doesn't look quite right, now does it?"
	icon_state = "meatsteak_old"
	tastes = list("meat" = 4, "cryoxandone" = 1)

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
	var/meat_type = "meat"
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/plain, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[meat_type] cutlet"



/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain/human/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/plain/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	if(subjectname)
		S.name = "[subjectname] [initial(S.name)]"
	else if(subjectjob)
		S.name = "[subjectjob] [initial(S.name)]"

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/killertomato
	name = "raw killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/killertomato/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/bear
	name = "raw bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/bear/MakeGrillable()
	AddComponent(/datum/component/grillable,/obj/item/reagent_containers/food/snacks/meat/cutlet/bear, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/xeno
	name = "raw xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/xeno/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/xeno, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/spider
	name = "raw spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/spider/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/spider, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/gondola
	name = "raw gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/gondola/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/gondola, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/penguin
	name = "raw penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/reagent_containers/food/snacks/meat/raw_cutlet/penguin/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/meat/cutlet/penguin, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

//Cooked cutlets

/obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
	foodtype = MEAT
	juice_results = list(/datum/reagent/consumable/drippings = 5)
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	name = "killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	name = "bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	name = "xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	name = "spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	name = "gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	name = "penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)
