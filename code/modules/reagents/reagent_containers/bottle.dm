//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30
	/// Base icon state of the filling overlay. Leave blank to use the default icon state
	var/filling_icon_state


/obj/item/reagent_containers/glass/bottle/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/glass/bottle/update_icon()
	cut_overlays()
	if(!filling_icon_state)
		filling_icon_state = icon_state
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[filling_icon_state]-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[filling_icon_state]-10"
			if(10 to 29)
				filling.icon_state = "[filling_icon_state]25"
			if(30 to 49)
				filling.icon_state = "[filling_icon_state]50"
			if(50 to 69)
				filling.icon_state = "[filling_icon_state]75"
			if(70 to INFINITY)
				filling.icon_state = "[filling_icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "epinephrine bottle"
	desc = "A small bottle. Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	list_reagents = list(/datum/reagent/toxin = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list(/datum/reagent/toxin/cyanide = 30)

/obj/item/reagent_containers/glass/bottle/spewium
	name = "spewium bottle"
	desc = "A small bottle of spewium."
	list_reagents = list(/datum/reagent/toxin/spewium = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "morphine bottle"
	desc = "A small bottle of morphine."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	desc = "A small bottle of Chloral Hydrate. Mickey's favorite!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 15)

/obj/item/reagent_containers/glass/bottle/mannitol
	name = "mannitol bottle"
	desc = "A small bottle of Mannitol. Useful for healing brain damage."
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "charcoal bottle"
	desc = "A small bottle of charcoal, which removes toxins and other chemicals from the bloodstream."
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "liquid plasma bottle"
	desc = "A small bottle of liquid plasma. Extremely toxic and reacts with micro-organisms inside blood."
	list_reagents = list(/datum/reagent/toxin/plasma = 30)

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle of formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia."
	list_reagents = list(/datum/reagent/ammonia = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine."
	list_reagents = list(/datum/reagent/diethylamine = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "Fluorosulfuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of fluorosulfuric acid."
	list_reagents = list(/datum/reagent/toxin/acid/fluacid = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 30)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	list_reagents = list(/datum/reagent/consumable/capsaicin = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	list_reagents = list(/datum/reagent/consumable/frostoil = 30)

/obj/item/reagent_containers/glass/bottle/traitor
	name = "syndicate bottle"
	desc = "A small bottle. Contains a random nasty chemical."
	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/reagent_containers/glass/bottle/traitor/Initialize()
	. = ..()
	extra_reagent = pick(/datum/reagent/toxin/polonium, /datum/reagent/toxin/histamine, /datum/reagent/toxin/formaldehyde, /datum/reagent/toxin/venom, /datum/reagent/toxin/fentanyl, /datum/reagent/toxin/cyanide)
	reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/glass/bottle/polonium
	name = "polonium bottle"
	desc = "A small bottle. Contains Polonium."
	list_reagents = list(/datum/reagent/toxin/polonium = 30)

/obj/item/reagent_containers/glass/bottle/magillitis
	name = "magillitis bottle"
	desc = "A small bottle. Contains a serum known only as 'magillitis'."
	list_reagents = list(/datum/reagent/magillitis = 5)

/obj/item/reagent_containers/glass/bottle/venom
	name = "venom bottle"
	desc = "A small bottle. Contains venom."
	list_reagents = list(/datum/reagent/toxin/venom = 30)

/obj/item/reagent_containers/glass/bottle/fentanyl
	name = "fentanyl bottle"
	desc = "A small bottle. Contains fentanyl."
	list_reagents = list(/datum/reagent/toxin/fentanyl = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "formaldehyde bottle"
	desc = "A small bottle. Contains formaldehyde."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/initropidril
	name = "initropidril bottle"
	desc = "A small bottle. Contains initropidril."
	list_reagents = list(/datum/reagent/toxin/initropidril = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium bottle"
	desc = "A small bottle. Contains pancuronium."
	list_reagents = list(/datum/reagent/toxin/pancuronium = 30)

/obj/item/reagent_containers/glass/bottle/sodium_thiopental
	name = "sodium thiopental bottle"
	desc = "A small bottle. Contains sodium thiopental."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 30)

/obj/item/reagent_containers/glass/bottle/coniine
	name = "coniine bottle"
	desc = "A small bottle. Contains coniine."
	list_reagents = list(/datum/reagent/toxin/coniine = 30)

/obj/item/reagent_containers/glass/bottle/curare
	name = "curare bottle"
	desc = "A small bottle. Contains curare."
	list_reagents = list(/datum/reagent/toxin/curare = 30)

/obj/item/reagent_containers/glass/bottle/amanitin
	name = "amanitin bottle"
	desc = "A small bottle. Contains amanitin."
	list_reagents = list(/datum/reagent/toxin/amanitin = 30)

/obj/item/reagent_containers/glass/bottle/histamine
	name = "histamine bottle"
	desc = "A small bottle. Contains histamine."
	list_reagents = list(/datum/reagent/toxin/histamine = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "antihistamine bottle"
	desc = "A small bottle of diphenhydramine."
	list_reagents = list(/datum/reagent/medicine/diphenhydramine = 30)

/obj/item/reagent_containers/glass/bottle/potass_iodide
	name = "anti-radiation bottle"
	desc = "A small bottle of potassium iodide."
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)

/obj/item/reagent_containers/glass/bottle/radscrub
	name = "Rad Scrub Plus bottle"
	desc = "A small bottle of Donk Co's Rad Scrub Plus."
	list_reagents = list(/datum/reagent/medicine/radscrub = 30)

/obj/item/reagent_containers/glass/bottle/salglu_solution
	name = "saline-glucose solution bottle"
	desc = "A small bottle of saline-glucose solution."
	icon_state = "bottle1"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "atropine bottle"
	desc = "A small bottle of atropine."
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/glass/bottle/romerol
	name = "romerol bottle"
	desc = "A small bottle of romerol. The REAL zombie powder."
	list_reagents = list(/datum/reagent/romerol = 30)

/obj/item/reagent_containers/glass/bottle/random_virus
	name = "Experimental disease culture bottle"
	desc = "A small bottle. Contains an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "Pierrot's Throat culture bottle"
	desc = "A small bottle. Contains H0NI<42 virion culture in synthblood medium."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "Rhinovirus culture bottle"
	desc = "A small bottle. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "Flu virion culture bottle"
	desc = "A small bottle. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/tumor
	name = "tumor culture bottle"
	desc = "A small bottle. Contains tumor culture in synthblood medium."
	spawned_disease = /datum/disease/advance/tumor

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "Retrovirus culture bottle"
	desc = "A small bottle. Contains a retrovirus culture in a synthblood medium."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS+ culture in synthblood medium."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "GBS culture bottle"
	desc = "A small bottle. Contains Gravitokinetic Bipotential SADS- culture in synthblood medium."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "Brainrot culture bottle"
	desc = "A small bottle. Contains Cryptococcus Cosmosis culture in synthblood medium."
	icon_state = "bottle3"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/sleepy
	name = "Sleepy virus culture bottle"
	desc = "A small bottle. Contains a sample of the SLPY Virus."
	spawned_disease = /datum/disease/sleepy

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "Magnitis culture bottle"
	desc = "A small bottle. Contains a small dosage of Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "Wizarditis culture bottle"
	desc = "A small bottle. Contains a sample of Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "Severe Anxiety culture bottle"
	desc = "A small bottle. Contains a sample of Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "Beesease culture bottle"
	desc = "A small bottle. Contains a sample of invasive Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "Spanish flu culture bottle"
	desc = "A small bottle. Contains a sample of Inquisitius."
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/jitters
	name = "Jitters culture bottle"
	desc = "A small bottle. Contains a sample of the Jitters."
	spawned_disease = /datum/disease/jitters

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "Fungal Tuberculosis culture bottle"
	desc = "A small bottle. Contains a sample of Fungal Tubercle bacillus."
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "BVAK bottle"
	desc = "A small bottle containing Bio Virus Antidote Kit."
	list_reagents = list(/datum/reagent/medicine/atropine = 5, /datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/perfluorodecalin = 10, /datum/reagent/medicine/spaceacillin = 10)

/obj/item/reagent_containers/glass/bottle/necropolis_seed
	name = "bowl of blood"
	desc = "A clay bowl containing a fledgling Necropolis, preserved in blood. A robust virologist may be able to unlock its full potential..."
	icon_state = "mortar"
	spawned_disease = /datum/disease/advance/necropolis

//Oldstation.dmm chemical storage bottles

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "hydrogen bottle"
	list_reagents = list(/datum/reagent/hydrogen = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "lithium bottle"
	list_reagents = list(/datum/reagent/lithium = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "carbon bottle"
	list_reagents = list(/datum/reagent/carbon = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "nitrogen bottle"
	list_reagents = list(/datum/reagent/nitrogen = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "oxygen bottle"
	list_reagents = list(/datum/reagent/oxygen = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "fluorine bottle"
	list_reagents = list(/datum/reagent/fluorine = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "sodium bottle"
	list_reagents = list(/datum/reagent/sodium = 30)

/obj/item/reagent_containers/glass/bottle/aluminium
	name = "aluminium bottle"
	list_reagents = list(/datum/reagent/aluminium = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "silicon bottle"
	list_reagents = list(/datum/reagent/silicon = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "phosphorus bottle"
	list_reagents = list(/datum/reagent/phosphorus = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "sulfur bottle"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "chlorine bottle"
	list_reagents = list(/datum/reagent/chlorine = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "potassium bottle"
	list_reagents = list(/datum/reagent/potassium = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "iron bottle"
	list_reagents = list(/datum/reagent/iron = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "copper bottle"
	list_reagents = list(/datum/reagent/copper = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury bottle"
	list_reagents = list(/datum/reagent/mercury = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "radium bottle"
	list_reagents = list(/datum/reagent/uranium/radium = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "water bottle"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "ethanol bottle"
	list_reagents = list(/datum/reagent/consumable/ethanol = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "sugar bottle"
	list_reagents = list(/datum/reagent/consumable/sugar = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "sulphuric acid bottle"
	list_reagents = list(/datum/reagent/toxin/acid = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "welding fuel bottle"
	list_reagents = list(/datum/reagent/fuel = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "silver bottle"
	list_reagents = list(/datum/reagent/silver = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "iodine bottle"
	list_reagents = list(/datum/reagent/iodine = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "bromine bottle"
	list_reagents = list(/datum/reagent/bromine = 30)
	
/obj/item/reagent_containers/glass/woodmug
	name = "wooden mug"
	desc = "Style is everything, whether it be an ashtray or a keychain or a kitchen timer, we’re living in an age of design, where the physical contours of an object are paramount. Look at this wooden mug, for instance, and see how much it deviates, in its conception, from the ordinary mug. Not much. It is round, tallish, has a handle just like any coffee mug. But it’s not an ordinary coffee mug. First of all its form is totally different; it’s made of wood, not ceramic or plastic. It’s an object that cannot be used casually and put it away, you would love to possess it."
	icon_state = "woodenmug"
	icon = 'icons/obj/drinks.dmi'
	volume = 30


//Yogs: Vials
/obj/item/reagent_containers/glass/bottle/vial
	name = "vial"
	desc = "A small vial for holding small amounts of reagents."
	icon_state = "vial"
	item_state = "atoxinbottle"	
	unique_reskin = list("vial" = "vial",
						"white vial" = "vial_white",
						"red vial" = "vial_red",
						"blue vial" = "vial_blue",
						"green vial" = "vial_green",
						"orange vial" = "vial_orange",
						"purple vial" = "vial_purple",
						"black vial" = "vial_black"
						)
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15
	disease_amount = 15
	/// Name that used as the base for pen renaming, so subtypes can have different names without having to worry about messing with it
	var/base_name = "vial"
	var/base_icon_state = "vial"
	/// List of icon_states that require the stripe overlay to look good. Not a very good way of doing it, but its the best I can come up with right now.
	var/list/striped_vial_skins = list("vial_white", "vial_red", "vial_blue", "vial_green", "vial_orange", "vial_purple", "vial_black", "viallarge_white", "viallarge_red", "viallarge_blue", "viallarge_green", "viallarge_orange", "viallarge_purple", "viallarge_black")

/obj/item/reagent_containers/glass/bottle/vial/Initialize()
	if(icon_state in striped_vial_skins)
		filling_icon_state = "[base_icon_state]stripe"
	..()

/obj/item/reagent_containers/glass/bottle/vial/attackby(obj/P, mob/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/t = pretty_filter(stripped_input(user, "What would you like the label to be?", text("[]", name), null))
		if (user.get_active_held_item() != P)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		name = "[base_name][t ? " ([t])" : ""]"
	else
		return ..()

/obj/item/reagent_containers/glass/bottle/vial/libital
	name = "vial (Libital)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 15)

/obj/item/reagent_containers/glass/bottle/vial/aiuri
	name = "vial (Aiuri)"
	icon_state = "vial_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 15)

/obj/item/reagent_containers/glass/bottle/vial/charcoal
	name = "vial (Charcoal)"
	icon_state = "vial_green"
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)

/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin
	name = "vial (Perfluorodecalin)"
	icon_state = "vial_blue"
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 15)

/obj/item/reagent_containers/glass/bottle/vial/epi
	name = "vial (Epinephrine)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 3)

/obj/item/reagent_containers/glass/bottle/vial/styptic
	name = "vial (Styptic Powder)"
	icon_state = "vial_orange"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 15)

/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine
	name = "vial (Silver Sulfadiazine)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 15)

/obj/item/reagent_containers/glass/bottle/vial/sal_acid
	name = "vial (Salicyclic Acid)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 15)

/obj/item/reagent_containers/glass/bottle/vial/oxandrolone
	name = "vial (Oxandrolone)"
	icon_state = "vial_black"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 15)

/obj/item/reagent_containers/glass/bottle/vial/calomel
	name = "vial (Calomel)"
	icon_state = "vial_black"
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/glass/bottle/vial/salbutamol
	name = "vial (Salbutamol)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 15)

/obj/item/reagent_containers/glass/bottle/vial/coagulant
	name = "vial (Coagulant)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/coagulant = 15)

/obj/item/reagent_containers/glass/bottle/vial/lavaland
	name = "vial (Lavaland Extract Mix)"
	icon_state = "vial_black"
	reagent_flags = 0
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 3, /datum/reagent/medicine/epinephrine = 6, /datum/reagent/medicine/lavaland_extract = 3, /datum/reagent/medicine/omnizine = 3)

/obj/item/reagent_containers/glass/bottle/vial/random_virus
	name = "Experimental disease culture vial"
	desc = "A small vial for holding small amounts of reagents. Contains an untested viral culture in synthblood medium."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/vial/cold
	name = "Rhinovirus culture vial"
	desc = "A small vial for holding small amounts of reagents. Contains XY-rhinovirus culture in synthblood medium."
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/vial/flu_virion
	name = "Flu virion culture vial"
	desc = "A small vial for holding small amounts of reagents. Contains H13N1 flu virion culture in synthblood medium."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/vial/large
	name = "large vial"
	base_name = "large vial"
	desc = "A large vial for holding a sizable amounts of reagents."
	icon_state = "viallarge"
	base_icon_state = "viallarge"
	unique_reskin = list("large vial" = "viallarge",
						"white large vial" = "viallarge_white",
						"red large vial" = "viallarge_red",
						"blue large vial" = "viallarge_blue",
						"green large vial" = "viallarge_green",
						"orange large vial" = "viallarge_orange",
						"purple large vial" = "viallarge_purple",
						"black large vial" = "viallarge_black"
						)
	w_class = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	disease_amount = 30

/obj/item/reagent_containers/glass/bottle/vial/large/omnizine
	name = "large vial (Omnizine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/brute
	name = "large vial (Brute)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/burn
	name = "large vial (Burn)"
	icon_state = "viallarge_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/tox
	name = "large vial (Toxic)"
	icon_state = "viallarge_green"
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/oxy
	name = "large vial (Oxygen)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/epi
	name = "large vial (Epinephrine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 24, /datum/reagent/medicine/coagulant = 6)

/obj/item/reagent_containers/glass/bottle/vial/large/combat
	name = "large vial (Combat Hypospray Mix)"
	icon_state = "viallarge_black"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/medicine/omnizine = 10, /datum/reagent/medicine/leporazine = 9, /datum/reagent/medicine/atropine = 9)

/obj/item/reagent_containers/glass/bottle/vial/large/stimulants
	name = "large vial (Stimulants)"
	icon_state = "viallarge_purple"
	list_reagents = list(/datum/reagent/medicine/stimulants = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/morphine
	name = "large vial (Morphine)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/vial/bluespace
	name = "bluespace vial"
	base_name = "bluespace vial"
	desc = "A small vial powered by experimental bluespace technology capable of holding 60 units."
	icon_state = "vialbluespace"
	base_icon_state = "vialbluespace"
	unique_reskin = list("bluespace vial" = "vialbluespace",
						"white bluespace vial" = "vialbluespace_white",
						"red bluespace vial" = "vialbluespace_red",
						"blue bluespace vial" = "vialbluespace_blue",
						"green bluespace vial" = "vialbluespace_green",
						"orange bluespace vial" = "vialbluespace_orange",
						"purple bluespace vial" = "vialbluespace_purple",
						"black bluespace vial" = "vialbluespace_black"
						)
	possible_transfer_amounts = list(5,10,15,30,45)
	volume = 60
