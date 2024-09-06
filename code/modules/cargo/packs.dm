/datum/supply_pack
	var/name = "Crate"
	var/group = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 700 // Minimum cost, or infinite points are possible.
	var/access = FALSE
	var/access_view = FALSE
	var/access_any = FALSE
	var/list/contains = null
	var/crate_name = "crate"
	var/desc = ""//no desc by default
	var/crate_type = /obj/structure/closet/crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/DropPodOnly = FALSE//only usable by the Bluespace Drop Pod via the express cargo console
	var/admin_spawned = FALSE
	var/small_item = FALSE //Small items can be grouped into a single crate.
	var/budget_radioactive = FALSE //Overwrite budget crate into radiation protective crate

/datum/supply_pack/proc/generate(atom/A, datum/bank_account/paying_account)
	var/obj/structure/closet/crate/C
	if(paying_account)
		if(budget_radioactive)
			C = new /obj/structure/closet/crate/secure/owned/radiation(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_MED))
			C = new /obj/structure/closet/crate/secure/owned/medical(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_ENG))
			C = new /obj/structure/closet/crate/secure/owned/engineering(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SCI))
			C = new /obj/structure/closet/crate/secure/owned/science(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SRV))
			C = new /obj/structure/closet/crate/secure/owned/hydroponics(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_SEC))
			C = new /obj/structure/closet/crate/secure/owned/gear(A, paying_account)
		else if(paying_account == SSeconomy.get_dep_account(ACCOUNT_CIV))
			C = new /obj/structure/closet/crate/secure/owned/civ(A, paying_account)
		else
			C = new /obj/structure/closet/crate/secure/owned(A, paying_account)
		C.name = "[crate_name] - Purchased by [paying_account.account_holder]"
	else
		C = new crate_type(A)
		C.name = crate_name
	if(access)
		C.req_access = list(access)
	if(access_any)
		C.req_one_access = access_any

	fill(C)
	return C

/datum/supply_pack/proc/get_cost()
	. = cost
	. *= SSeconomy.pack_price_modifier

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	if (admin_spawned)
		for(var/item in contains)
			var/atom/A = new item(C)
			A.flags_1 |= ADMIN_SPAWNED_1
	else
		for(var/item in contains)
			new item(C)

// If you add something to this list, please group it by type and sort it alphabetically instead of just jamming it in like an animal

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/emergency
	group = "Emergency"

/datum/supply_pack/emergency/bio
	name = "Biological Emergency Crate"
	desc = "This crate holds 2 full bio suits which will protect you from viruses."
	cost = 2000
	contains = list(/obj/item/clothing/head/bio_hood/general,
					/obj/item/clothing/head/bio_hood/general,
					/obj/item/clothing/suit/bio_suit/general,
					/obj/item/clothing/suit/bio_suit/general,
					/obj/item/storage/bag/bio,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile)
	crate_name = "bio suit crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three sets of well-rounded, decently-protective armor and helmet. Requires Security access to open."
	cost = 2000
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/suit/armor/vest/alt,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec)
	crate_name = "armor crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Armory //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security/armory
	group = "Armory"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/ar2
	name = "OSIPR Crate"
	desc = "Contains two Overwatch Standard Issue Pulse Rifles. Requires Armory access to open."
	cost = 15000
	contains = list(/obj/item/gun/ballistic/automatic/ar2,
					/obj/item/gun/ballistic/automatic/ar2)
	crate_name = "osipr gun crate"

/datum/supply_pack/security/armory/mp7
	name = "MP7 Crate"
	desc = "Contains two MP7 submachine guns. Requires Armory access to open."
	cost = 12000
	contains = list(/obj/item/gun/ballistic/automatic/mp7,
					/obj/item/gun/ballistic/automatic/mp7)
	crate_name = "mp7 gun crate"

/datum/supply_pack/security/armory/spas12
	name = "SPAS-12 Crate"
	desc = "Contains two SPAS-12 shotguns. Requires Armory access to open."
	cost = 12000
	contains = list(/obj/item/gun/ballistic/shotgun/spas12,
					/obj/item/gun/ballistic/shotgun/spas12)
	crate_name = "spas-12 gun crate"

/datum/supply_pack/security/armory/usp
	name = "USP Match Crate"
	desc = "Contains two USP Match pistols. Requires Armory access to open."
	cost = 10000
	contains = list(/obj/item/gun/ballistic/automatic/pistol/usp,
					/obj/item/gun/ballistic/automatic/pistol/usp)
	crate_name = "usp match gun crate"

/datum/supply_pack/security/armory/uspammo
	name = "USP Match Ammo Crate"
	desc = "Contains four USP Match magazines. Requires Armory access to open."
	cost = 6000
	contains = list(/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm)
	crate_name = "usp match ammo crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engineering
	group = "Engineering"
	crate_type = /obj/structure/closet/crate/engineering


//////////////////////////////////////////////////////////////////////////////
/////////////////////// Canisters & Materials ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials
	group = "Canisters & Materials"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets"
	desc = "Let some nice light in with fifty glass sheets!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/metal50
	name = "50 Metal Sheets"
	desc = "Any construction project begins with a good stack of fifty metal sheets!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/metal/fifty)
	crate_name = "metal sheets crate"

/datum/supply_pack/materials/wood50
	name = "50 Wood Planks"
	desc = "Turn cargo's boring metal groundwork into beautiful panelled flooring and much more with fifty wooden planks!"
	cost = 2000
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "wood planks crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical
	group = "Medical"
	access_view = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

/datum/supply_pack/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	desc = "Contains many different blood packs for reintroducing blood to patients."
	cost = 3500
	contains = list(/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood/APlus,
					/obj/item/reagent_containers/blood/AMinus,
					/obj/item/reagent_containers/blood/BPlus,
					/obj/item/reagent_containers/blood/BMinus,
					/obj/item/reagent_containers/blood/OPlus,
					/obj/item/reagent_containers/blood/OMinus)
	crate_name = "blood freezer"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/medical/medipen_variety
	name = "Medipen Variety-Pak"
	desc = "Contains eight different medipens in three different varieties, to assist in quickly treating seriously injured patients."
	cost = 2000
	contains = list(/obj/item/reagent_containers/autoinjector/medipen,
					/obj/item/reagent_containers/autoinjector/medipen,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/ekit,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
					/obj/item/reagent_containers/autoinjector/medipen/blood_loss,
	)
	crate_name = "medipen crate"

/datum/supply_pack/medical/firstaid_single
	name = "First Aid Kit Single-Pack"
	desc = "Contains one first aid kit for healing most types of wounds."
	cost = 150
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/regular)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidbruises_single
	name = "Bruise Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing bruises and broken bones."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/brute)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidburns_single
	name = "Burn Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing severe burns."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/fire)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidtoxins_single
	name = "Toxin Treatment Kit Single-Pack"
	desc = "Contains one first aid kit focused on healing damage dealt by heavy toxins."
	cost = 100
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/toxin)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidoxygen_single
	name = "Oxygen Deprivation Kit Single-Pack"
	desc = "Contains three first aid kits focused on helping oxygen deprivation victims."
	cost = 70 //oxygen damage tends to be far rarer and these kits use perf which is objectively bad without any toxin healing
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/o2)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidadvanced_single
	name = "Advanced Treatment Kit Single-Pack"
	desc = "Contains one advanced first aid kit able to heal many advanced ailments."
	cost = 600
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/advanced)
	crate_type = /obj/structure/closet/crate/secure/cheap

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Service //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/service
	group = "Service"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic
	group = "Food & Hydroponics"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/hydroponics
	access_view = ACCESS_HYDROPONICS

/datum/supply_pack/organic/food
	name = "Food Crate"
	desc = "Allow the citizens a treat with this crate filled with specially preserved old world foods." // yogs
	cost = 2000
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/reagent_containers/food/condiment/cinnamon, // Yogs -- Adds cinnamon shakers to this crate
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/slab/monkey)
	crate_name = "food crate"

/datum/supply_pack/organic/rations
	name = "Ration Crate"
	desc = "A crate of five ration packs, made for easy distribution." // yogs
	cost = 1500
	contains = list(/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration)
	crate_name = "ration crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/artsupply
	name = "Art Supplies"
	desc = "Make some happy little accidents with six canvasses, two easels, and two rainbow crayons!"
	cost = 400
	contains = list(/obj/structure/easel,
					/obj/structure/easel,
					/obj/item/canvas/nineteenXnineteen,
					/obj/item/canvas/nineteenXnineteen,
					/obj/item/canvas/twentythreeXnineteen,
					/obj/item/canvas/twentythreeXnineteen,
					/obj/item/canvas/twentythreeXtwentythree,
					/obj/item/canvas/twentythreeXtwentythree,
					/obj/item/toy/crayon/rainbow,
					/obj/item/toy/crayon/rainbow)
	crate_name = "art supply crate"
	crate_type = /obj/structure/closet/crate/wooden

