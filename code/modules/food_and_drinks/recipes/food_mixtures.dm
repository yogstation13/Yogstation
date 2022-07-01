/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = /datum/reagent/consumable/hot_coco
	results = list(/datum/reagent/consumable/hot_coco = 5)
	required_reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/coco = 1)
	required_temp = 320

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = /datum/reagent/consumable/coffee
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/tea
	name = "Tea"
	id = /datum/reagent/consumable/tea
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = /datum/reagent/consumable/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/corn_syrup
	name = /datum/reagent/consumable/corn_syrup
	id = /datum/reagent/consumable/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/caramel
	name = "Caramel"
	id = /datum/reagent/consumable/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/caramel_burned
	name = "Caramel burned"
	id = "caramel_burned"
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/nutriconversion
	name = "Peptide conversion"
	id = "peptide_conversion"
	results = list(/datum/reagent/consumable/nutriment/peptides = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment = 0.5)
	required_catalysts = list(/datum/reagent/medicine/metafactor = 0.5)

/datum/chemical_reaction/synthmeat
	name = "synthmeat"
	id = "synthmeat"
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE

/datum/chemical_reaction/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = /datum/reagent/consumable/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = /datum/reagent/consumable/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/carpmeat/imitation(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
	required_reagents = list(/datum/reagent/consumable/eggyolk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/cakebatter/vegan
	id = "vegancakebatter"
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

/datum/chemical_reaction/ricebowl
	name = "Rice Bowl"
	id = "ricebowl"
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	required_container = /obj/item/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/ricebowl/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/salad/ricebowl(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

////////////////////////////////////////////CHEESEMILK////////////////////////////////////////////
/datum/chemical_reaction/bluemilk
	name = "Blue Cheese Milk"
	id = "bluemilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/penicilliumroqueforti = 1)
	results = list(/datum/reagent/consumable/milk/blue = 30)

/datum/chemical_reaction/briemilk
	name = "Brie Cheese Milk"
	id = "briemilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/penicilliumcandidum = 1)
	results = list(/datum/reagent/consumable/milk/brie = 30)

/datum/chemical_reaction/cheddarmilk
	name = "Cheddar Cheese Milk"
	id = "cheddarmilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/cheddar = 30)

/datum/chemical_reaction/fetamilk
	name = "Feta Cheese Milk"
	id = "fetamilk"
	required_reagents = list(/datum/reagent/consumable/milk/sheep = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/feta = 30)

/datum/chemical_reaction/goatmilk
	name = "Goat Cheese Milk"
	id = "goatmilk"
	required_reagents = list(/datum/reagent/consumable/milk/goat = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/goatcheese = 30)

/datum/chemical_reaction/shoatmilk
	name = "Shoat Milk"
	id = "shoatmilk"
	required_reagents = list(/datum/reagent/consumable/milk/goat = 15, /datum/reagent/consumable/milk/sheep = 15)
	results = list(/datum/reagent/consumable/milk/shoat = 30)

/datum/chemical_reaction/halloumimilk
	name = "Halloumi Cheese Milk"
	id = "halloumimilk"
	required_reagents = list(/datum/reagent/consumable/milk/shoat = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/halloumi = 30)

/datum/chemical_reaction/mozzarellamilk
	name = "Mozzarella Cheese Milk"
	id = "mozzarellamilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/lemonjuice = 5)
	results = list(/datum/reagent/consumable/milk/mozzarella = 30)

/datum/chemical_reaction/parmesanmilk
	name = "Parmesan Cheese Milk"
	id = "parmesanmilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/sodiumchloride = 10)
	results = list(/datum/reagent/consumable/milk/parmesan = 30)

/datum/chemical_reaction/swissmilk
	name = "Swiss Cheese Milk"
	id = "swissmix"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/thermophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/swiss = 30)

////////////////////////////////////////////CHEESE////////////////////////////////////////////
/datum/chemical_reaction/american
	name = "American Cheese Block"
	id = "americancheeseblock"
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/american/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/store/cheesewheel/american(location)

/datum/chemical_reaction/bluemix
	name = "Blue Cheese Mix"
	id = "bluemix"
	required_reagents = list(/datum/reagent/consumable/milk/blue = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/bluemix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/blue(location)

/datum/chemical_reaction/briemix
	name = "Brie Cheese Mix"
	id = "briemix"
	required_reagents = list(/datum/reagent/consumable/milk/brie = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/briemix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/brie(location)

/datum/chemical_reaction/cheddarmix
	name = "Cheddar Cheese Mix"
	id = "cheddarmix"
	required_reagents = list(/datum/reagent/consumable/milk/cheddar = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/cheddarmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/cheddar(location)

/datum/chemical_reaction/fetamix
	name = "Feta Cheese Mix"
	id = "fetamix"
	required_reagents = list(/datum/reagent/consumable/milk/feta = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/fetamix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/feta(location)

/datum/chemical_reaction/goatmix
	name = "Goat Cheese Mix"
	id = "goatmix"
	required_reagents = list(/datum/reagent/consumable/milk/goatcheese = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/goatmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/goat(location)

/datum/chemical_reaction/halloumimix
	name = "Halloumi Cheese Mix"
	id = "halloumimix"
	required_reagents = list(/datum/reagent/consumable/milk/halloumi = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/halloumimix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/halloumi(location)

/datum/chemical_reaction/mozzarellamix
	name = "Mozzarella Cheese Mix"
	id = "mozzarellamix"
	required_reagents = list(/datum/reagent/consumable/milk/mozzarella = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/mozzarellamix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/mozzarella(location)

/datum/chemical_reaction/parmesanmix
	name = "Parmesan Cheese Mix"
	id = "parmesanmix"
	required_reagents = list(/datum/reagent/consumable/milk/parmesan = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/parmesanmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/parmesan(location)

/datum/chemical_reaction/swissmix
	name = "Swiss Cheese Mix"
	id = "swissmix"
	required_reagents = list(/datum/reagent/consumable/milk/swiss = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/swissmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cheesemix/swiss(location)

/datum/chemical_reaction/gravy
	name = "Gravy"
	id = /datum/reagent/consumable/gravy
	results = list(/datum/reagent/consumable/gravy = 2)
	required_reagents = list(/datum/reagent/consumable/drippings = 1, /datum/reagent/consumable/flour = 1)
	mix_message = "The solution begins to thicken."

datum/chemical_reaction/bugmix
	name = "Bug Cheese Mix"
	id = "bugmix"
	required_reagents = list(/datum/reagent/consumable/cream/bug = 25)
	required_catalysts = list(/datum/reagent/consumable/vitfro = 5)

/datum/chemical_reaction/bugmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/store/cheesewheel/bug(location)

