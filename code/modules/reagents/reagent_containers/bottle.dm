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


/obj/item/reagent_containers/glass/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/glass/bottle/on_reagent_change(changetype)
	update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/glass/bottle/update_overlays()
	. = ..()
	if(!filling_icon_state)
		filling_icon_state = icon_state
	if(!reagents.total_volume)
		return
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
	. += filling

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
	name = "Fluorosulphuric Acid Bottle"
	desc = "A small bottle. Contains a small amount of fluorosulphuric acid."
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

/obj/item/reagent_containers/glass/bottle/traitor/Initialize(mapload)
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

/obj/item/reagent_containers/glass/bottle/ambusher_toxin
	name = "carpenter toxin bottle"
	desc = "A small bottle. Contains a toxin from an unknown source."
	list_reagents = list(/datum/reagent/toxin/ambusher_toxin = 30)

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

/obj/item/reagent_containers/glass/bottle/sulphur
	name = "sulphur bottle"
	list_reagents = list(/datum/reagent/sulphur = 30)

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

/obj/item/reagent_containers/glass/coffee_cup
	name = "coffee cup"
	desc = "A heat-formed plastic coffee cup. Can theoretically be used for other hot drinks, if you're feeling adventurous."
	icon = 'icons/obj/machines/coffeemaker.dmi'
	icon_state = "coffee_cup_e"
	base_icon_state = "coffee_cup"
	possible_transfer_amounts = list(10)
	volume = 30
	spillable = TRUE

/obj/item/reagent_containers/glass/coffee_cup/update_icon_state()
	icon_state = reagents.total_volume ? base_icon_state : "[base_icon_state]_e"
	return ..()


//Yogs: Vials
/obj/item/reagent_containers/glass/bottle/vial
	name = "vial"
	desc = "A vial for holding smaller amounts of reagents than a beaker."
	icon_state = "viallarge"
	base_icon_state = "viallarge"
	item_state = "atoxinbottle"	
	unique_reskin = list(
		"vial" = "viallarge",
		"white vial" = "viallarge_white",
		"red vial" = "viallarge_red",
		"blue vial" = "viallarge_blue",
		"green vial" = "viallarge_green",
		"orange vial" = "viallarge_orange",
		"purple vial" = "viallarge_purple",
		"black vial" = "viallarge_black"
	)
	possible_transfer_amounts = list(5, 10, 15, 30)
	reagent_flags = OPENCONTAINER_NOSPILL
	volume = 30
	disease_amount = 30
	/// Name that used as the base for pen renaming, so subtypes can have different names without having to worry about messing with it
	var/base_name = "vial"
	/// List of icon_states that require the stripe overlay to look good. Not a very good way of doing it, but its the best I can come up with right now.
	var/list/striped_vial_skins = list("vial_white", "vial_red", "vial_blue", "vial_green", "vial_orange", "vial_purple", "vial_black", "viallarge_white", "viallarge_red", "viallarge_blue", "viallarge_green", "viallarge_orange", "viallarge_purple", "viallarge_black")

/obj/item/reagent_containers/glass/bottle/vial/Initialize(mapload)
	if(icon_state in striped_vial_skins)
		filling_icon_state = "[base_icon_state]stripe"
	return ..()

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
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 15)
	custom_premium_price = 25

/obj/item/reagent_containers/glass/bottle/vial/aiuri
	name = "vial (Aiuri)"
	icon_state = "viallarge_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 15)
	custom_premium_price = 25

/obj/item/reagent_containers/glass/bottle/vial/charcoal
	name = "vial (Charcoal)"
	icon_state = "viallarge_green"
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)
	custom_premium_price = 25

/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin
	name = "vial (Perfluorodecalin)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 15)
	custom_premium_price = 25

/obj/item/reagent_containers/glass/bottle/vial/epi
	name = "vial (Epinephrine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 3)
	custom_premium_price = 25

/obj/item/reagent_containers/glass/bottle/vial/styptic
	name = "vial (Styptic Powder)"
	icon_state = "viallarge_orange"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 15)
	custom_premium_price = 30

/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine
	name = "vial (Silver Sulfadiazine)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 15)
	custom_premium_price = 30

/obj/item/reagent_containers/glass/bottle/vial/sal_acid
	name = "vial (Salicylic Acid)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 15)
	custom_premium_price = 50

/obj/item/reagent_containers/glass/bottle/vial/oxandrolone
	name = "vial (Oxandrolone)"
	icon_state = "viallarge_black"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 15)
	custom_premium_price = 50

/obj/item/reagent_containers/glass/bottle/vial/calomel
	name = "vial (Calomel)"
	icon_state = "viallarge_black"
	list_reagents = list(/datum/reagent/medicine/calomel = 15)
	custom_premium_price = 50

/obj/item/reagent_containers/glass/bottle/vial/salbutamol
	name = "vial (Salbutamol)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 15)
	custom_premium_price = 50

/obj/item/reagent_containers/glass/bottle/vial/coagulant
	name = "vial (Sanguirite)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/coagulant = 15)
	custom_premium_price = 50

/obj/item/reagent_containers/glass/bottle/vial/lavaland
	name = "vial (Lavaland Extract Mix)"
	icon_state = "viallarge_black"
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


// Bottles for mail goodies.

/obj/item/reagent_containers/glass/bottle/clownstears
	name = "bottle of distilled clown misery"
	desc = "A small bottle. Contains a mythical liquid used by sublime bartenders; made from the unhappiness of clowns."
	list_reagents = list(/datum/reagent/consumable/clownstears = 30)

/obj/item/reagent_containers/glass/bottle/saltpetre
	name = "saltpetre bottle"
	desc = "A small bottle. Contains saltpetre."
	list_reagents = list(/datum/reagent/saltpetre = 30)

/obj/item/reagent_containers/glass/bottle/flash_powder
	name = "flash powder bottle"
	desc = "A small bottle. Contains flash powder."
	list_reagents = list(/datum/reagent/flash_powder = 30)

///obj/item/reagent_containers/glass/bottle/exotic_stabilizer
	//name = "exotic stabilizer bottle"
	//desc = "A small bottle. Contains exotic stabilizer."
	//list_reagents = list(/datum/reagent/exotic_stabilizer = 30)

///obj/item/reagent_containers/glass/bottle/leadacetate
	//name = "lead acetate bottle"
	//desc = "A small bottle. Contains lead acetate."
	//list_reagents = list(/datum/reagent/toxin/leadacetate = 30)

/obj/item/reagent_containers/glass/bottle/caramel
	name = "bottle of caramel"
	desc = "A bottle containing caramalized sugar, also known as caramel. Do not lick."
	list_reagents = list(/datum/reagent/consumable/caramel = 30)

/obj/item/reagent_containers/glass/bottle/vial/omnizine
	name = "vial (Omnizine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)

/obj/item/reagent_containers/glass/bottle/vial/brute
	name = "vial (Brute)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 30)

/obj/item/reagent_containers/glass/bottle/vial/burn
	name = "vial (Burn)"
	icon_state = "viallarge_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 30)

/obj/item/reagent_containers/glass/bottle/vial/tox
	name = "vial (Toxic)"
	icon_state = "viallarge_green"
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/vial/oxy
	name = "vial (Oxygen)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 30)

/obj/item/reagent_containers/glass/bottle/vial/epi/full
	name = "vial (Epinephrine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 24, /datum/reagent/medicine/coagulant = 6)

/obj/item/reagent_containers/glass/bottle/vial/combat
	name = "vial (Combat Hypospray Mix)"
	icon_state = "viallarge_black"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/medicine/omnizine = 10, /datum/reagent/medicine/leporazine = 9, /datum/reagent/medicine/atropine = 9)

/obj/item/reagent_containers/glass/bottle/vial/stimulants
	name = "vial (Stimulants)"
	icon_state = "viallarge_purple"
	list_reagents = list(/datum/reagent/medicine/stimulants = 30)

/obj/item/reagent_containers/glass/bottle/vial/morphine
	name = "vial (Morphine)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/vial/bluespace
	name = "bluespace vial"
	base_name = "bluespace vial"
	desc = "A vial powered by experimental bluespace technology capable of holding 60 units."
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

/*
 *	Syrup bottles, basically a unspillable cup that transfers reagents upon clicking on it with a cup
 */

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle
	name = "syrup bottle"
	desc = "A bottle with a syrup pump to dispense the delicious substance directly into your coffee cup."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "syrup"
	fill_icon_state = "syrup"
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100)
	possible_transfer_amounts = list(5, 10)
	amount_per_transfer_from_this = 5
	spillable = FALSE
	///variable to tell if the bottle can be refilled
	var/cap_on = TRUE
	obj_flags = UNIQUE_RENAME | UNIQUE_REDESC

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle the pump cap.")
	. += span_notice("Use a pen on it to rename it.")
	return

//when you attack the syrup bottle with a container it refills it
/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/attackby(obj/item/attacking_item, mob/user, params)

	if(!cap_on)
		return ..()

	if(!check_allowed_items(attacking_item,target_self = TRUE))
		return

	if(attacking_item.is_refillable())
		if(!reagents.total_volume)
			balloon_alert(user, "bottle empty!")
			return TRUE

		if(attacking_item.reagents.holder_full())
			balloon_alert(user, "container full!")
			return TRUE

		flick("syrup_anim",src)

	attacking_item.update_appearance()
	update_appearance()

	return TRUE

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/AltClick(mob/user)
	cap_on = !cap_on
	if(!cap_on)
		icon_state = "syrup_open"
		balloon_alert(user, "removed pump cap")
	else
		icon_state = "syrup"
		balloon_alert(user, "put pump cap on")
	update_icon_state()
	return ..()

//types of syrups

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/caramel
	name = "bottle of caramel syrup"
	desc = "A pump bottle containing caramalized sugar, also known as caramel. Do not lick."
	list_reagents = list(/datum/reagent/consumable/caramel = 50)

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/liqueur
	name = "bottle of coffee liqueur syrup"
	desc = "A pump bottle containing mexican coffee-flavoured liqueur syrup. In production since 1936, HONK."
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 50)

/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/korta_nectar
	name = "bottle of korta syrup"
	desc = "A pump bottle containing korta syrup. A sweet, sugary substance made from crushed sweet korta nuts."
	list_reagents = list(/datum/reagent/consumable/korta_nectar = 50)

//secret syrup
/obj/item/reagent_containers/food/drinks/bottle/syrup_bottle/laughsyrup
	name = "bottle of laugh syrup"
	desc = "A pump bottle containing laugh syrup. The product of juicing Laughin' Peas. Fizzy, and seems to change flavour based on what it's used with!"
	list_reagents = list(/datum/reagent/consumable/laughsyrup = 50)


//Coffeepots: for reference, a standard cup is 30u, to allow 20u for sugar/sweetener/milk/creamer
/obj/item/reagent_containers/food/drinks/bottle/coffeepot
	icon = 'icons/obj/food/containers.dmi'
	name = "coffeepot"
	desc = "A large pot for dispensing that ambrosia of corporate life known to mortals only as coffee. Contains 4 standard cups."
	volume = 120
	icon_state = "coffeepot"
	fill_icon_state = "coffeepot"
	fill_icon_thresholds = list(0, 1, 30, 60, 100)

/obj/item/reagent_containers/food/drinks/bottle/coffeepot/bluespace
	icon = 'icons/obj/food/containers.dmi'
	name = "bluespace coffeepot"
	desc = "The most advanced coffeepot the eggheads could cook up: sleek design; graduated lines; connection to a pocket dimension for coffee containment; yep, it's got it all. Contains 8 standard cups."
	volume = 240
	icon_state = "coffeepot_bluespace"
	fill_icon_thresholds = list(0)
