/datum/factory_design
	var/name = "TEST"
	var/item = null
	var/id = "test"
	var/construction_limit = FALSE
	var/constructed = FALSE
	var/requiredResearch = list()
	var/create = 1

/datum/factory_design/proc/Make(mob/living/carbon/user, obj/machinery/crewFab/fab)
	if(construction_limit)
		if(constructed)
			return FALSE
	var/obj/machinery/factory/dispenser/thing = pick(GLOB.factory_dispensers)
	thing.AddItem(item, create)
	if(construction_limit)
		constructed = TRUE
	return TRUE

/datum/factory_design/welder
	name = "Welding Tool"
	id = "welder"
	item = /obj/item/weldingtool

/datum/factory_design/adv_welder
	name = "Advanced Purifying Tool"
	id = "adv_welder"
	item = /obj/item/weldingtool/experimental/infection
	requiredResearch = list("advanced_purifier")


/datum/factory_design/ammo
	name = "4x Rifle Ammo"
	id = "rifle_ammo"
	item = /obj/item/ammo_box/magazine/m556/infection
	create = 4

/datum/factory_design/p_ammo
	name = "3x Pistol Ammo"
	id = "pistol_ammo"
	item = /obj/item/ammo_box/magazine/m10mm/infection
	create = 3

/datum/factory_design/lammo
	name = "3x Lazarus Ammo for Rifles"
	id = "lammo"
	item = /obj/item/ammo_box/magazine/m556/infection/lazarus
	requiredResearch = list("lazarus_rounds")
	create = 3

/datum/factory_design/pammo
	name = "3x Purifier Ammo for Rifles"
	id = "pammo"
	item = /obj/item/ammo_box/magazine/m556/infection/purifier
	requiredResearch = list("purifier")
	create = 3

/datum/factory_design/healing_gel
	name = "3x Healing Gel Patch"
	id = "gel"
	item = /obj/item/reagent_containers/pill/patch/synthflesh/infection
	requiredResearch = list("healing_gel")
	create = 3


/datum/factory_design/firstaid
	name = "First-aid Kit"
	id = "medkit"
	item = /obj/item/storage/firstaid/regular

/datum/factory_design/bertha
	name = "Big Bertha"
	id = "bertha"
	item = /obj/item/minigunbackpack/infection
	construction_limit = TRUE
	requiredResearch = list("big_bertha")

/datum/factory_design/grass
	name = "'Grasscutter' Pistol"
	id = "grass"
	item = /obj/item/gun/energy/pulse/pistol/infection
	requiredResearch = list("grasscutter")

/datum/factory_design/bio_armor
	name = "Bio-integrated Armor"
	id = "armor"
	item = /obj/item/clothing/suit/armor/bulletproof/infection
	requiredResearch = list("bio_armor")

/datum/factory_design/mech_armor
	name = "Bio-assisted Mechanized Armor"
	id= "mecho"
	item = /obj/item/storage/backpack/duffelbag/infection/mech
	requiredResearch = list("mech_armor")

/datum/factory_design/jugger_armor
	name = "'Juggernaut' Armor"
	id = "jugg"
	construction_limit = TRUE
	item = /obj/item/storage/backpack/duffelbag/infection/jugger
	requiredResearch = list("juggernaut")

/datum/factory_design/sample
	name = "Sample Extractor"
	id = "samp"
	item = /obj/item/implanter/blob

/datum/factory_design/beacon
	name = "Orbital Bombardment Beacon"
	id = "beacon"
	item = /obj/item/flashlight/glowstick/cyan/orb