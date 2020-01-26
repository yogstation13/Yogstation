/datum/fab_design
	var/name = "TEST"
	var/cost = 100
	var/id = "test"
	var/item = /obj/item
	var/requiredResearch = list()
	var/construction_limit = FALSE
	var/constructed

/datum/fab_design/proc/Make(mob/living/carbon/user, obj/machinery/crewFab/fab)
	if(construction_limit)
		if(constructed)
			return
	if(fab.points >= cost)
		fab.points -= cost
		if(item)
			var/obj/item/O = new item(user.loc)
			if(construction_limit)
				constructed = TRUE
			user.put_in_hands(O)
		return TRUE
	return FALSE


/datum/fab_design/welder
	name = "Welding Tool"
	cost = 250
	id = "welder"
	item = /obj/item/weldingtool

/datum/fab_design/adv_welder
	name = "Advanced Purifying Tool"
	cost = 500
	id = "adv_welder"
	item = /obj/item/weldingtool/experimental/infection
	requiredResearch = list("advanced_purifier")

/obj/item/weldingtool/experimental/infection
	name = "experimental purifying tool"
	desc = "An experimental purifying tool capable of self-fuel generation and less harmful to the eyes."
	max_fuel = 30

/datum/fab_design/ammo
	name = "4x Rifle Ammo"
	cost = 500
	id = "rifle_ammo"
	item = /obj/item/storage/backpack/duffelbag/infection/ammo

/datum/fab_design/p_ammo
	name = "3x Pistol Ammo"
	cost = 250
	id = "pistol_ammo"
	item = /obj/item/storage/backpack/duffelbag/infection/pistol_ammo

/datum/fab_design/lammo
	name = "3x Lazarus Ammo for Rifles"
	cost = 700
	id = "lammo"
	item = /obj/item/storage/backpack/duffelbag/infection/ammo_lazarus
	requiredResearch = list("lazarus_rounds")

/datum/fab_design/pammo
	name = "3x Purifier Ammo for Rifles"
	cost = 1200
	id = "pammo"
	item = /obj/item/storage/backpack/duffelbag/infection/ammo_purifier
	requiredResearch = list("purifier")

/datum/fab_design/healing_gel
	name = "Healing Gel Patch"
	cost = 150
	id = "gel"
	item = /obj/item/reagent_containers/pill/patch/synthflesh/infection
	requiredResearch = list("healing_gel")

/obj/item/reagent_containers/pill/patch/synthflesh/infection
	name = "healing gel patch"
	desc = "Helps with brute and burn injuries."
	list_reagents = list(/datum/reagent/medicine/synthflesh = 25)

/datum/fab_design/firstaid
	name = "First-aid Kit"
	cost = 300
	id = "medkit"
	item = /obj/item/storage/firstaid/regular

/datum/fab_design/bertha
	name = "Big Bertha"
	cost = 2500
	id = "bertha"
	item = /obj/item/minigunbackpack/infection
	construction_limit = TRUE
	requiredResearch = list("big_bertha")

/datum/fab_design/grass
	name = "'Grasscutter' Pistol"
	cost = 500
	id = "grass"
	item = /obj/item/gun/energy/pulse/pistol/infection
	requiredResearch = list("grasscutter")

/datum/fab_design/bio_armor
	name = "Bio-integrated Armor"
	cost = 750
	id = "armor"
	item = /obj/item/clothing/suit/armor/bulletproof/infection
	requiredResearch = list("bio_armor")

/datum/fab_design/mech_armor
	name = "Bio-assisted Mechanized Armor"
	cost = 1000
	id= "mecho"
	item = /obj/item/storage/backpack/duffelbag/infection/mech
	requiredResearch = list("mech_armor")

/datum/fab_design/jugger_armor
	name = "'Juggernaut' Armor"
	cost = 1750
	id = "jugg"
	construction_limit = TRUE
	item = /obj/item/storage/backpack/duffelbag/infection/jugger
	requiredResearch = list("juggernaut")

/datum/fab_design/sample
	name = "Sample Extractor"
	cost = 100
	id = "samp"
	item = /obj/item/implanter/blob