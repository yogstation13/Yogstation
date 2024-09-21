/obj/item/seeds/lavaland/ember
	name = "pack of embershroom mycelium"
	desc = "This mycelium grows into embershrooms, a species of bioluminescent mushrooms native to Xen."
	icon_state = "mycelium-ember"
	species = "ember"
	plantname = "Embershroom Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism, /datum/plant_gene/trait/glow, /datum/plant_gene/trait/fire_resistance)
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/drug/space_drugs = 0.04, /datum/reagent/consumable/entpoly = 0.04)

/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	name = "mushroom stem"
	desc = "A long mushroom stem. It's slightly glowing. This may have useful properties."
	icon = 'icons/obj/halflife/xenflora.dmi'
	icon_state = "mushroom_stem"
	seed = /obj/item/seeds/lavaland/ember
	can_distill = FALSE
	//distill_reagent = /datum/reagent/consumable/ethanol/embershroomcream
	grind_results = list(/datum/reagent/toxin/mushroom_powder = 0)

/obj/structure/flora/ash/stem_shroom
	icon_state = "t_mushroom"
	name = "numerous xenian mushrooms"
	desc = "A large number of xenian mushrooms, some of which have long, fleshy stems, which look harvestable if you have something sharp on hand. They're radiating light!"
	icon = 'icons/obj/halflife/xenflora.dmi'
	light_range = 1.5
	light_power = 1.5
	light_color = "#af7575"
	harvested_name = "xenian mushrooms"
	harvested_desc = "A few tiny xenian mushrooms around larger stumps. You can already see them growing back."
	harvest = /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem
	harvest_time = 40
	harvest_message_low = "You pick and slice the cap off a mushroom, leaving the stem."
	harvest_message_med = "You pick and decapitate several mushrooms for their stems."
	harvest_message_high = "You acquire a number of stems from these mushrooms."
	regrowth_time_low = 4000
	regrowth_time_high = 6000
	max_integrity = 200

/obj/structure/flora/xen
	name = "xen flora base type"
	icon = 'icons/obj/halflife/xenflora.dmi'
	max_integrity = 200
	var/breakmats = null

/obj/structure/flora/xen/deconstruct(disassembled = TRUE)
	if(breakmats)
		new breakmats(loc)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/flora/xen/leafy
	name = "leafy xen plant"
	desc = "A green, leafy looking Xen plant. You may be able to break it for something."
	icon_state = "leafy"
	light_range = 1.5
	light_power = 1
	light_color = "#28533a"
	breakmats = /obj/item/reagent_containers/food/snacks/xenbranch

/obj/item/reagent_containers/food/snacks/xenbranch
	name = "xenian branch"
	desc = "An branch from some xenian plant. It's green, so that might mean it could be possibly used for medicinal purposes."
	tastes = list("bitterness" = 1)
	filling_color = "#0f6e37"
	bitesize = 5
	list_reagents = list(/datum/reagent/medicine/biogel = 20)
	foodtype = GROSS
	icon = 'icons/obj/halflife/xenflora.dmi'
	icon_state = "branch"

/obj/structure/flora/xen/tinyshrooms
	name = "tiny xen plant"
	desc = "A small collection of purple mushroom like plants. Doesn't seem very useful, but glows ever so slightly."
	icon_state = "tinyshrooms"
	light_range = 1
	light_power = 0.5
	light_color = "#703d68"

