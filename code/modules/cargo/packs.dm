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


/*
/datum/supply_pack/emergency/bio
	name = "Biological Emergency Crate"
	desc = "This crate holds 2 full bio suits which will protect you from viruses."
	cost = 500
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
*/

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three additional metropolice standard issue protective vests."
	cost = 300
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/civilprotection,
					/obj/item/clothing/suit/armor/civilprotection,
					/obj/item/clothing/suit/armor/civilprotection)
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
	desc = "Contains two Overwatch Standard Issue Pulse Rifles, that are only usable by authorised personnel. Requires Armory access to open."
	cost = 1500
	contains = list(/obj/item/gun/ballistic/automatic/ar2,
					/obj/item/gun/ballistic/automatic/ar2)
	crate_name = "osipr gun crate"

/datum/supply_pack/security/armory/ar2ammo
	name = "OSIPR Ammo Crate"
	desc = "Contains four OSIPR magazines. Requires Armory access to open."
	cost = 800
	contains = list(/obj/item/ammo_box/magazine/ar2,
					/obj/item/ammo_box/magazine/ar2,
					/obj/item/ammo_box/magazine/ar2,
					/obj/item/ammo_box/magazine/ar2)
	crate_name = "osipr ammo crate"

/datum/supply_pack/security/armory/mp7
	name = "MP7 Crate"
	desc = "Contains two MP7 submachine guns. Requires Armory access to open."
	cost = 900
	contains = list(/obj/item/gun/ballistic/automatic/mp7,
					/obj/item/gun/ballistic/automatic/mp7)
	crate_name = "mp7 gun crate"

/datum/supply_pack/security/armory/mp7ammo
	name = "MP7 Ammo Crate"
	desc = "Contains four MP7 magazines. Requires Armory access to open."
	cost = 600
	contains = list(/obj/item/ammo_box/magazine/mp7,
					/obj/item/ammo_box/magazine/mp7,
					/obj/item/ammo_box/magazine/mp7,
					/obj/item/ammo_box/magazine/mp7)
	crate_name = "mp7 ammo crate"

/datum/supply_pack/security/armory/spas12
	name = "SPAS-12 Crate"
	desc = "Contains two SPAS-12 shotguns. Requires Armory access to open."
	cost = 900
	contains = list(/obj/item/gun/ballistic/shotgun/spas12,
					/obj/item/gun/ballistic/shotgun/spas12)
	crate_name = "spas-12 gun crate"

/datum/supply_pack/security/armory/shotgunammo
	name = "Shotgun Buckshot Ammo Crate"
	desc = "Contains four boxes of buckshot. Requires Armory access to open."
	cost = 600
	contains = list(/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot)
	crate_name = "buckshot crate"

/datum/supply_pack/security/armory/coltpython
	name = "Colt Python Crate"
	desc = "Contains two Colt Python revolvers. Requires Armory access to open."
	cost = 900
	contains = list(/obj/item/gun/ballistic/revolver/coltpython,
					/obj/item/gun/ballistic/revolver/coltpython)
	crate_name = "colt python gun crate"

/datum/supply_pack/security/armory/revolverammo
	name = "Colt Python Ammo Crate"
	desc = "Contains four Colt Python speed loaders. Requires Armory access to open."
	cost = 600
	contains = list(/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357,
					/obj/item/ammo_box/a357)
	crate_name = "colt python ammo crate"

/datum/supply_pack/security/armory/usp
	name = "USP Match Crate"
	desc = "Contains two USP Match pistols. Requires Armory access to open."
	cost = 600
	contains = list(/obj/item/gun/ballistic/automatic/pistol/usp,
					/obj/item/gun/ballistic/automatic/pistol/usp)
	crate_name = "usp match gun crate"

/datum/supply_pack/security/armory/uspammo
	name = "USP Match Ammo Crate"
	desc = "Contains four USP Match magazines. Requires Armory access to open."
	cost = 400
	contains = list(/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm,
					/obj/item/ammo_box/magazine/usp9mm)
	crate_name = "usp match ammo crate"

/datum/supply_pack/security/armory/manhacks
	name = "Viscerator Crate"
	desc = "Contains three activatable viscerators. Requires Armory access to open."
	cost = 350
	contains = list(/obj/item/grenade/spawnergrenade/manhacks,
					/obj/item/grenade/spawnergrenade/manhacks,
					/obj/item/grenade/spawnergrenade/manhacks)
	crate_name = "viscerator crate"


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
	group = "Tools & Materials"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets"
	desc = "Let some nice light in with fifty glass sheets!"
	cost = 300
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/metal50
	name = "50 Metal Sheets"
	desc = "Any construction project begins with a good stack of fifty metal sheets!"
	cost = 300
	contains = list(/obj/item/stack/sheet/metal/fifty)
	crate_name = "metal sheets crate"

/datum/supply_pack/materials/wood50
	name = "50 Wood Planks"
	desc = "Turn cargo's boring metal groundwork into beautiful panelled flooring and much more with fifty wooden planks!"
	cost = 300
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "wood planks crate"

/datum/supply_pack/materials/tools
	name = "Tool Crate"
	desc = "Contains a handful of wrenches and crowbars."
	cost = 100
	contains = list(/obj/item/crowbar/large,
					/obj/item/crowbar/large,
					/obj/item/wrench,
					/obj/item/wrench)
	crate_name = "tool crate"

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
	cost = 300
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
	cost = 300
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

/datum/supply_pack/medical/medkit
	name = "Medkits"
	desc = "Contains 5 biogel medkits for rapid healing."
	cost = 150
	contains = list(/obj/item/reagent_containers/pill/patch/medkit,
					/obj/item/reagent_containers/pill/patch/medkit,
					/obj/item/reagent_containers/pill/patch/medkit,
					/obj/item/reagent_containers/pill/patch/medkit,
					/obj/item/reagent_containers/pill/patch/medkit,
	)
	crate_name = "medkit crate"

/datum/supply_pack/medical/medvial
	name = "Medvials"
	desc = "Contains 5 biogel medvials for rapid healing. Heals less than a medkit, but is applied quicker, and is easier to carry."
	cost = 120
	contains = list(/obj/item/reagent_containers/pill/patch/medkit/vial,
					/obj/item/reagent_containers/pill/patch/medkit/vial,
					/obj/item/reagent_containers/pill/patch/medkit/vial,
					/obj/item/reagent_containers/pill/patch/medkit/vial,
					/obj/item/reagent_containers/pill/patch/medkit/vial,
	)
	crate_name = "medvial crate"

/datum/supply_pack/medical/firstaid_single
	name = "First Aid Kit Single-Pack"
	desc = "Contains one first aid kit for healing most types of wounds."
	cost = 100
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
	cost = 75 //oxygen damage tends to be far rarer and these kits use perf which is objectively bad without any toxin healing
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/o2)
	crate_type = /obj/structure/closet/crate/secure/cheap

/datum/supply_pack/medical/firstaidadvanced_single
	name = "Advanced Treatment Kit Single-Pack"
	desc = "Contains one advanced first aid kit able to heal many advanced ailments."
	cost = 150
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
	desc = "Allow the citizens a treat with this crate filled with specially preserved old world foods." 
	cost = 300
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/reagent_containers/food/condiment/cinnamon, 
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/slab/chicken,
					/obj/item/reagent_containers/food/snacks/meat/slab/chicken,
					/obj/item/reagent_containers/food/snacks/meat/slab/monkey)
	crate_name = "food crate"

/datum/supply_pack/organic/rations
	name = "Ration Crate"
	desc = "A crate of five ration packs, made for easy distribution." 
	cost = 100
	contains = list(/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration,
					/obj/item/storage/box/halflife/ration)
	crate_name = "ration crate"


/datum/supply_pack/organic/loyaltyrations
	name = "Loyalty-grade Ration Crate"
	desc = "A crate of five loyalty-grade ration packs, made for easy distribution." 
	cost = 150
	contains = list(/obj/item/storage/box/halflife/loyaltyration,
					/obj/item/storage/box/halflife/loyaltyration,
					/obj/item/storage/box/halflife/loyaltyration,
					/obj/item/storage/box/halflife/loyaltyration,
					/obj/item/storage/box/halflife/loyaltyration)
	crate_name = "loyalty-grade ration crate"

/datum/supply_pack/organic/alcohol
	name = "Approved Ethanol Crate"
	desc = "A crate of five Combine Approved Ethanol Beverages, rated for citizen use." 
	cost = 50
	contains = list(/obj/item/reagent_containers/food/drinks/beer/light,
					/obj/item/reagent_containers/food/drinks/beer/light,
					/obj/item/reagent_containers/food/drinks/beer/light,
					/obj/item/reagent_containers/food/drinks/beer/light,
					/obj/item/reagent_containers/food/drinks/beer/light)
	crate_name = "approved ethanol crate"

/datum/supply_pack/organic/fancyalcohol
	name = "Exotic Alcohol Crate"
	desc = "A crate of five exotic old world alcoholic beverages. Probably too good for the common citizen to have." 
	cost = 300
	contains = list(/obj/item/reagent_containers/food/drinks/beer,
				/obj/item/reagent_containers/food/drinks/bottle/grappa,
				/obj/item/reagent_containers/food/drinks/bottle/gin,
				/obj/item/reagent_containers/food/drinks/bottle/hooch,
				/obj/item/reagent_containers/food/drinks/bottle/vodka)
	crate_name = "exotic alcohol crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/pickaxes
	name = "Pickaxe Crate"
	desc = "A crate of three pickaxes, for use in the mines." 
	cost = 100
	contains = list(/obj/item/pickaxe,
					/obj/item/pickaxe,
					/obj/item/pickaxe)
	crate_name = "pickaxe crate"

/datum/supply_pack/misc/water_miner
	name = "Water Harvester"
	desc = "A heavy duty water harvester. Can be placed over water and wrenched into place, then activated to automatically package water for reselling." 
	cost = 300
	contains = list(/obj/machinery/water_miner)
	crate_name = "water harvester crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/cleanup
	name = "Cleanup Suits Crate"
	desc = "Contains two yellow hazardous cleanup suits which protect against radiation and bites alike."
	cost = 150
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation)
	crate_name = "cleanup suits crate"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/misc/cleanupspray
	name = "Cleanup Sprayers Crate"
	desc = "Contains two cleanup solution sprayers, able to quickly get rid of Xenian growths."
	cost = 200
	contains = list(/obj/item/watertank/cleanup,
					/obj/item/watertank/cleanup)
	crate_name = "cleanup sprayers crate"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/misc/headsets
	name = "Headset Crate"
	desc = "Contains four radio headsets that will allow easy communication between people."
	cost = 100
	contains = list(/obj/item/radio/headset,
					/obj/item/radio/headset,
					/obj/item/radio/headset,
					/obj/item/radio/headset)
	crate_name = "headset crate"

/datum/supply_pack/misc/tobacco
	name = "Tobacco Products Crate"
	desc = "Contains four packs of cigarettes and a case of cigars. Made with combine approved tobacco-like substances."
	cost = 100
	contains = list(/obj/item/storage/fancy/cigarettes,
					/obj/item/storage/fancy/cigarettes,
					/obj/item/storage/fancy/cigarettes,
					/obj/item/storage/fancy/cigarettes,
					/obj/item/storage/fancy/cigarettes/cigars)
	crate_name = "headset crate"
