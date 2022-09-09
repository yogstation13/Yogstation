// Weapons

/datum/crafting_recipe/pin_removal
	name = "Pin Removal"
	result = /obj/item/gun
	reqs = list(/obj/item/gun = 1)
	parts = list(/obj/item/gun = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	time = 1.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/strobeshield
	name = "Strobe Shield"
	result = /obj/item/shield/riot/flash
	reqs = list(/obj/item/wallframe/flasher = 1,
				/obj/item/assembly/flash/handheld = 1,
				/obj/item/shield/riot = 1)
	blacklist = list(/obj/item/shield/riot/buckler, /obj/item/shield/riot/tele)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/molotov
	name = "Molotov"
	result = /obj/item/reagent_containers/food/drinks/bottle/molotov
	reqs = list(/obj/item/reagent_containers/glass/rag = 1,
				/obj/item/reagent_containers/food/drinks/bottle = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/melee/baton/cattleprod
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/teleprod
	name = "Teleprod"
	result = /obj/item/melee/baton/cattleprod/teleprod
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/rods = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/ore/bluespace_crystal = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/restraints/legcuffs/bola
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6)
	time = 2 SECONDS //15 faster than crafting them by hand!
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/watcherbola
	name = "Watcher Bola"
	result = /obj/item/restraints/legcuffs/bola/watcher
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 2,
				/obj/item/restraints/handcuffs/cable/sinew = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/gonbola
	name = "Gonbola"
	result = /obj/item/restraints/legcuffs/bola/gonbola
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/stack/sheet/metal = 6,
				/obj/item/stack/sheet/animalhide/gondola = 1)
	time = 4 SECONDS
	category= CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/tailclub
	name = "Tail Club"
	result = /obj/item/tailclub
	reqs = list(/obj/item/organ/tail/lizard = 1,
	            /obj/item/stack/sheet/metal = 1)
	blacklist = list(/obj/item/organ/tail/lizard/fake)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/tailwhip
	name = "Liz O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip
	reqs = list(/obj/item/organ/tail/lizard = 1,
	            /obj/item/stack/cable_coil = 1)
	blacklist = list(/obj/item/organ/tail/lizard/fake)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/catwhip
	name = "Cat O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip/kitty
	reqs = list(/obj/item/organ/tail/cat = 1,
	            /obj/item/stack/cable_coil = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/greatruinousknife
	name = "Great Ruinous Knife"
	result = /obj/item/kitchen/knife/ritual/holy/strong
	reqs = list(/obj/item/kitchen/knife/ritual/holy = 1,
	            /obj/item/stack/sheet/ruinous_metal = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bloodyruinousknife
	name = "Blood Soaked Ruinous Knife"
	result = /obj/item/kitchen/knife/ritual/holy/strong/blood
	reqs = list(/obj/item/kitchen/knife/ritual/holy/strong = 1,
	            /obj/item/stack/sheet/runed_metal = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/pipebow
	name = "Pipe Bow"
	result = /obj/item/gun/ballistic/bow/pipe
	reqs = list(/obj/item/pipe = 5,
				/obj/item/stack/sheet/plastic = 5,
				/obj/item/weaponcrafting/silkstring = 1)
	time = 45 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/maint
	name = "Makeshift Bow"
	result = /obj/item/gun/ballistic/bow/maint
	reqs = list(/obj/item/pipe = 5,
           		/obj/item/stack/tape = 3, 
				/obj/item/stack/cable_coil = 10)
	time = 45 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/woodenbow
	name = "Wooden Bow"
	result = /obj/item/gun/ballistic/bow
	reqs = list(/obj/item/stack/sheet/mineral/wood = 8,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/weaponcrafting/silkstring = 1)
	time = 12 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/woodencrossbow
	name = "Wooden Crossbow"
	result = /obj/item/gun/ballistic/bow/crossbow
	reqs = list(/obj/item/gun/ballistic/bow = 1,
				/obj/item/stack/sheet/mineral/wood = 2,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/weaponcrafting/stock = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 16 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = /obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/pipe = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/stack/packageWrap = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/gauss
	name = "Makeshift gauss rifle"
	reqs = list(/obj/item/stock_parts/cell = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/tape = 1,
				/obj/item/stack/rods = 4,
				/obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER,TOOL_WELDER,TOOL_WRENCH)
	result = /obj/item/gun/ballistic/gauss
	time = 12
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = /obj/item/twohanded/required/chainsaw
	reqs = list(/obj/item/circular_saw = 1,
				/obj/item/stack/cable_coil = 3,
				/obj/item/stack/sheet/plasteel = 5)
	tools = list(TOOL_WELDER)
	time = 5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/twohanded/spear
	reqs = list(/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/shard = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/shard = 1)
	time = 4 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/extendohand
	name = "Extendo-Hand"
	reqs = list(/obj/item/bodypart/r_arm/robot = 1, /obj/item/clothing/gloves/boxing = 1)
	result = /obj/item/extendohand
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chemical_payload
	name = "Chemical Payload (C4)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 3 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chemical_payload2
	name = "Chemical Payload (Gibtonite)"
	result = /obj/item/bombcore/chemical
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/twohanded/required/gibtonite = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/grenade/chem_grenade = 2)
	time = 5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/goliathshield
	name = "Goliath shield"
	result = /obj/item/shield/riot/goliath
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4,
				/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonesword
	name = "Bone Sword"
	result = /obj/item/claymore/bone
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 3,
				/obj/item/stack/sheet/sinew = 2)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bone_bow
	name = "Bone Bow"
	result = /obj/item/gun/ballistic/bow/ashen
	time = 20 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 8,
				/obj/item/stack/sheet/sinew = 4)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonedagger
	name = "Bone Dagger"
	result = /obj/item/kitchen/knife/combat/bone
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = /obj/item/twohanded/bonespear
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4,
				 /obj/item/stack/sheet/sinew = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = /obj/item/twohanded/fireaxe/boneaxe
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 6,
				 /obj/item/stack/sheet/sinew = 3)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/chitinspear
	name = "Chitin Spear"
	result = /obj/item/twohanded/bonespear/chitinspear //take a bonespear, reinforce it with some chitin and resin, profit?
	time = 7.5 SECONDS
	reqs = list(/obj/item/twohanded/bonespear = 1,
				/obj/item/stack/sheet/sinew = 3,
				/obj/item/stack/sheet/ashresin = 1,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 6)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "Pneumatic Cannon"
	result = /obj/item/pneumatic_cannon/ghetto
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/packageWrap = 8,
				/obj/item/pipe = 2)
	time = 5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

// Shank - Makeshift weapon that can embed on throw
/datum/crafting_recipe/shank
	name = "Shank"
	reqs = list(/obj/item/shard = 1,
				/obj/item/stack/rods = 1,
				/obj/item/stack/cable_coil = 10)
	result = /obj/item/kitchen/knife/shank
	time = 1 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON


// Ammo

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 2,
				/obj/item/stock_parts/micro_laser/ultra = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/dragonsbreath
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1, /datum/reagent/phosphorus = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/micro_laser/ultra = 1,
				/obj/item/stock_parts/subspace/crystal = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised
	reqs = list(/obj/item/grenade/chem_grenade = 1,
				/obj/item/stack/sheet/metal = 1,
				/obj/item/stack/cable_coil = 1,
				/datum/reagent/fuel = 10)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/laserbuckshot
	name = "Laser Buckshot Shell"
	result = /obj/item/ammo_casing/shotgun/laserbuckshot
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/adv = 1,
				/obj/item/stock_parts/micro_laser/high = 2)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/thundershot
	name = "Thundershot Shell"
	result = /obj/item/ammo_casing/shotgun/thundershot
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stock_parts/capacitor/super = 1,
				/datum/reagent/teslium = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/depleteduraniumslug
	name = "Depleted Uranium Slug Shell"
	result = /obj/item/ammo_casing/shotgun/uraniumpenetrator
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/obj/item/stack/sheet/mineral/uranium = 2,
				/obj/item/stack/rods = 2,
				/datum/reagent/thermite = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/cryoshot
	name = "Cryoshot Shell"
	result = /obj/item/ammo_casing/shotgun/cryoshot
	reqs = list(/obj/item/ammo_casing/shotgun/techshell = 1,
				/datum/reagent/medicine/c2/rhigoxane = 5)
	tools = list(TOOL_SCREWDRIVER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/laserslug
	name = "Bolts"
	result = /obj/item/ammo_casing/caseless/bolts
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(TOOL_WIRECUTTER)
	time = 0.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/wood_arrow
	name = "Wood Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/wood
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
				/obj/item/stack/sheet/silk = 1,
				/obj/item/stack/rods = 1) //1 metal sheet = 2 rods= 2 arrows
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/ashen_arrow
	name = "Fire hardened arrow"
	result = /obj/item/ammo_casing/caseless/arrow/ash
	tools = list(TOOL_WELDER)
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow/wood = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bone_tipped_arrow
	name = "Bone Tipped Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 1,
				/obj/item/stack/sheet/sinew = 1,
				/obj/item/ammo_casing/caseless/arrow/ash = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bone_arrow
	name = "Bone Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bone
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 1,
				/obj/item/stack/sheet/sinew = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/chitin_arrow
	name = "Chitin Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/chitin
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow/bone = 1,
				/obj/item/stack/sheet/sinew = 1,
				/obj/item/stack/sheet/ashresin = 1,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 2)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bamboo_arrow
	name = "Bamboo Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bamboo
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/bamboo = 2)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/bronze_arrow
	name = "Bronze arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bronze
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1,
				/obj/item/stack/tile/bronze = 1,
				/obj/item/stack/sheet/silk = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/glass_arrow
	name = "Glass arrow"
	result = /obj/item/ammo_casing/caseless/arrow/glass
	time = 3 SECONDS
	reqs = list(/obj/item/shard = 1, 
				/obj/item/stack/rods = 1, 
				/obj/item/stack/cable_coil = 3)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO

/datum/crafting_recipe/plasma_glass_arrow
	name = "Plasma glass arrow"
	result = /obj/item/ammo_casing/caseless/arrow/glass/plasma
	time = 3 SECONDS
	reqs = list(/obj/item/shard/plasma = 1,
				/obj/item/stack/rods = 1, 
				/obj/item/stack/cable_coil = 3)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
