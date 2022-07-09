// Clothing //

/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 5 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = /obj/item/clothing/head/helmet/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 4 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = /obj/item/clothing/under/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 4)
	time = 4 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = /obj/item/clothing/head/beret/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 2)
	time = 4 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = /obj/item/clothing/head/beanie/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 2)
	time = 4 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = /obj/item/clothing/mask/bandana/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 1)
	time = 2.5 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = /obj/item/clothing/suit/ghost_sheet
	time = 0.5 SECONDS
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/cowboyboots
	name = "Cowboy Boots"
	result = /obj/item/clothing/shoes/cowboy
	reqs = list(/obj/item/stack/sheet/leather = 2)
	time = 4.5 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/lizardboots
	name = "Lizard Skin Boots"
	result = /obj/effect/spawner/lootdrop/lizardboots
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1, /obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/lizardhat
	name = "Lizard Cloche Hat"
	result = /obj/item/clothing/head/lizard
	time = 1 SECONDS
	reqs = list(/obj/item/organ/tail/lizard = 1)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/lizardhat_alternate
	name = "Lizard Cloche Hat"
	result = /obj/item/clothing/head/lizard
	time = 1 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/kittyears
	name = "Kitty Ears"
	result = /obj/item/clothing/head/kitty/genuine
	time = 1 SECONDS
	reqs = list(/obj/item/organ/tail/cat = 1,
				/obj/item/organ/ears/cat = 1)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/footwrapsgoliath
	name = "Goliath Hide Footwraps"
	result = /obj/item/clothing/shoes/xeno_wraps/goliath
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/footwrapsdragon
	name = "Ash Drake Hide Footwraps"
	result = /obj/item/clothing/shoes/xeno_wraps/dragon
	reqs = list(/obj/item/stack/sheet/animalhide/ashdrake = 1, /obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/footwrapscarpdragon
	name = "Carp Dragon Hide Footwraps"
	result = /obj/item/clothing/shoes/xeno_wraps/carpdragon
	reqs = list(/obj/item/stack/sheet/animalhide/carpdragon = 1, /obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/mummy
	name = "Mummification Bandages (Mask)"
	result = /obj/item/clothing/mask/mummy
	time = 1 SECONDS
	tools = list(/obj/item/nullrod/egyptian)
	reqs = list(/obj/item/stack/sheet/cloth = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/mummy/body
	name = "Mummification Bandages (Body)"
	result = /obj/item/clothing/under/mummy
	reqs = list(/obj/item/stack/sheet/cloth = 5)

/datum/crafting_recipe/chestwrap
	name = "Loincloth and Chestwrap"
	result = /obj/item/clothing/under/chestwrap
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 1)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/raider_leather
	name = "Scavenged Rags"
	result = /obj/item/clothing/under/raider_leather
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/rods = 2, 
				/obj/item/stack/sheet/leather = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/tribal_wraps
	name = "Metal Plated Rags"
	result = /obj/item/clothing/under/tribal
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/sheet/leather = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/ash_robe
	name = "Tribal Robes"
	result = /obj/item/clothing/under/ash_robe
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/cloth = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/ash_robe/young
	name = "Tribal Rags"
	result = /obj/item/clothing/under/ash_robe/young

/datum/crafting_recipe/ash_robe/hunter
	name = "Hunter Tribal Rags"
	result = /obj/item/clothing/under/ash_robe/hunter

/datum/crafting_recipe/ash_robe/chief
	name = "Chief Tribal Rags"
	result = /obj/item/clothing/under/ash_robe/chief

/datum/crafting_recipe/ash_robe/shaman
	name = "Shaman Tribal Rags"
	result = /obj/item/clothing/under/ash_robe/shaman

/datum/crafting_recipe/ash_robe/tunic
	name = "Tribal Tunic"
	result = /obj/item/clothing/under/ash_robe/tunic
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)

/datum/crafting_recipe/ash_robe/dress
	name = "Tribal Dress"
	result = /obj/item/clothing/under/ash_robe/dress
	reqs = list(/obj/item/stack/sheet/cloth = 3)

/datum/crafting_recipe/shamanash
	name = "Shaman Skull"
	result = /obj/item/clothing/head/shamanash
	reqs = list(/obj/item/stack/sheet/cloth = 1, 
				/obj/item/stack/sheet/bone = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/tribalmantle
	name = "Ornate Mantle"
	result = /obj/item/clothing/neck/cloak/tribalmantle
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/leathercape
	name = "Brown Leather Cape"
	result = /obj/item/clothing/suit/hooded/cloak/goliath/desert
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 5)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE

/datum/crafting_recipe/hidemantle
	name = "Hide Mantle"
	result = /obj/item/clothing/suit/leather_mantle
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 2)
	category = CAT_APPAREL
	subcategory = CAT_CLOTHING
	always_availible = FALSE


// Armor //

/datum/crafting_recipe/bonearmor
	name = "Bone Armor"
	result = /obj/item/clothing/suit/armor/bone
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/heavybonearmor
	name = "Heavy Bone Armor"
	result = /obj/item/clothing/suit/armor/bone/heavy
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 3)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/tribalcoat
	name = "Tribal Coat"
	result = /obj/item/clothing/suit/armor/tribalcoat
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 2,
			/obj/item/stack/sheet/bone = 2)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = /obj/item/clothing/gloves/bracer
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/skullhelm
	name = "Skull Helmet"
	result = /obj/item/clothing/head/helmet/skull
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/shamanhat
	name = "Shaman Headdress"
	result = /obj/item/clothing/head/helmet/shaman
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/resincrown
	name = "Resin Crown"
	result = /obj/item/clothing/head/crown/resin
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/ashresin = 2,
		/obj/item/stack/sheet/mineral/mythril = 1)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = /obj/item/clothing/suit/hooded/cloak/goliath
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/sinew = 1,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2) //it takes 4 goliaths to make 1 cloak if the plates are skinned
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/pathkasa
	name = "Pathfinder Kasa"
	result = /obj/item/clothing/head/helmet/kasa
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 4,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 10) //3 spiders assuming you get leather from one
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/pathcloak
	name = "Pathfinder Cloak"
	result = /obj/item/clothing/suit/armor/pathfinder
	time = 5 SECONDS
	reqs = list(/obj/item/clothing/suit/hooded/cloak/goliath = 1,
				/obj/item/stack/sheet/animalhide/goliath_hide = 2, //2 plates for the cloak plus 2 here plus 3 for plating the armor = 7 total
				/obj/item/stack/sheet/sinew = 6)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/pathtreads
	name = "Pathfinder Treads"
	result = /obj/item/clothing/shoes/pathtreads
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 2)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = /obj/item/clothing/suit/hooded/cloak/drake
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/ashdrake = 5)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/carpsuit
	name = "Space Dragon Armour"
	result = /obj/item/clothing/suit/space/hardsuit/carp/dragon
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 10,
				/obj/item/stack/sheet/sinew = 2,
				/obj/item/stack/sheet/animalhide/carpdragon = 5)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

/datum/crafting_recipe/hydrogen_hardsuit
	name = "Metallic Hydrogen Elder Atmosian Hardsuit"
	result = /obj/item/clothing/suit/space/hardsuit/elder_atmosian
	time = 10 SECONDS
	reqs = list(/obj/item/clothing/suit/armor/elder_atmosian = 1,
	    	/obj/item/clothing/head/helmet/elder_atmosian = 1,
			/obj/item/clothing/head/hardhat/atmos = 1,
			/obj/item/clothing/suit/fire/atmos = 1,
			/obj/item/stack/sheet/mineral/diamond = 5,
			/obj/item/stack/sheet/mineral/metal_hydrogen = 10)
	category = CAT_APPAREL
	subcategory = CAT_ARMOR

// Equipment //

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = /obj/item/storage/belt/fannypack
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 2 SECONDS
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/ghettojetpack
	name = "Improvised Jetpack"
	result = /obj/item/tank/jetpack/improvised
	time = 3 SECONDS
	reqs = list(/obj/item/tank/internals/oxygen = 2, /obj/item/extinguisher = 1, /obj/item/pipe = 3, /obj/item/stack/cable_coil = MAXCOIL)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT
	tools = list(TOOL_WRENCH, TOOL_WELDER, TOOL_WIRECUTTER)

/datum/crafting_recipe/hudsunmeson
	name = "Meson Sunglasses"
	result = /obj/item/clothing/glasses/meson/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1, 
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	blacklist = list(/obj/item/clothing/glasses/sunglasses/cheap)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmesonremoval
	name = "Meson HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	blacklist = list(/obj/item/clothing/glasses/sunglasses/cheap)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	blacklist = list(/obj/item/clothing/glasses/sunglasses/cheap)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	blacklist = list(/obj/item/clothing/glasses/sunglasses/cheap)
	
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/beergoggles
	name = "Beer Goggles"
	result = /obj/item/clothing/glasses/sunglasses/reagent
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	blacklist = list(/obj/item/clothing/glasses/sunglasses/cheap)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/beergogglesremoval
	name = "Beer Goggles removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/reagent = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = /obj/item/clothing/accessory/talisman
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = /obj/item/clothing/accessory/skullcodpiece
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/skilt
	name = "Sinew Kilt"
	result = /obj/item/clothing/accessory/skilt
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 1,
				 /obj/item/stack/sheet/sinew = 2)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/resinband
	name = "Resin armband"
	result = /obj/item/clothing/accessory/resinband
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/ashresin = 3)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/sinewbelt
	name = "Sinew Belt"
	result = /obj/item/storage/belt/mining/primitive
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/sinew = 4)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/medpouchcloth
	name = "Cloth Medicinal Pouch"
	result = /obj/item/storage/bag/medpouch
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/cloth = 3)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/medpouchleather //whatever material tickles your fancy.
	name = "Leather Medicinal Pouch"
	result = /obj/item/storage/bag/medpouch
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/quiver
	name = "Quiver"
	result = /obj/item/storage/belt/quiver
	time = 8 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 3,
				/obj/item/stack/sheet/sinew = 4)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT

/datum/crafting_recipe/goliathgloves
	name = "Goliath Gloves"
	result = /obj/item/clothing/gloves/color/black/goliath
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_APPAREL
	subcategory = CAT_EQUIPMENT
