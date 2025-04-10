GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))

/proc/get_uplink_items(antagonist = null, allow_sales = TRUE, allow_restricted = TRUE, uplink_type = "Uplink")
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(!I.item)
			continue
		if(I.include_uplinks.len && !(uplink_type in I.include_uplinks))
			continue
		if(antagonist)
			if(I.include_antags.len)
				if(!(antagonist in I.include_antags))
					continue
			if(I.exclude_antags.len)
				if(antagonist in I.exclude_antags)
					continue
		if(I.player_minimum && I.player_minimum > GLOB.joined_player_list.len)
			continue
		if (I.restricted && !allow_restricted)
			continue

		if(!filtered_uplink_items[I.category])
			filtered_uplink_items[I.category] = list()
		filtered_uplink_items[I.category][I.name] = I
		if(I.limited_stock < 0 && !I.cant_discount && I.item && I.cost > 1)
			sale_items += I
	if(allow_sales)
		var/datum/team/nuclear/nuclear_team
		if (antagonist == ROLE_OPERATIVE) 					// uplink code kind of needs a redesign
			nuclear_team = locate() in GLOB.antagonist_teams	// the team discounts could be a in a GLOB with this design but it would make sense for them to be team specific...
		if (!nuclear_team)
			create_uplink_sales(3, "Discounted Gear", 1, sale_items, filtered_uplink_items)
		else
			if (!nuclear_team.team_discounts)
				// create 5 unlimited stock discounts
				create_uplink_sales(5, "Discounted Team Gear", -1, sale_items, filtered_uplink_items)
				// Create 10 limited stock discounts
				create_uplink_sales(10, "Limited Stock Team Gear", 1, sale_items, filtered_uplink_items)
				nuclear_team.team_discounts = list("Discounted Team Gear" = filtered_uplink_items["Discounted Team Gear"], "Limited Stock Team Gear" = filtered_uplink_items["Limited Stock Team Gear"])
			else
				for(var/cat in nuclear_team.team_discounts)
					for(var/item in nuclear_team.team_discounts[cat])
						var/datum/uplink_item/D = nuclear_team.team_discounts[cat][item]
						var/datum/uplink_item/O = filtered_uplink_items[initial(D.category)][initial(D.name)]
						O.refundable = FALSE

				filtered_uplink_items["Discounted Team Gear"] = nuclear_team.team_discounts["Discounted Team Gear"]
				filtered_uplink_items["Limited Stock Team Gear"] = nuclear_team.team_discounts["Limited Stock Team Gear"]


	return filtered_uplink_items

/proc/create_uplink_sales(num, category_name, limited_stock, sale_items, uplink_items)
	if (num <= 0)
		return

	if(!uplink_items[category_name])
		uplink_items[category_name] = list()

	for (var/i in 1 to num)
		var/datum/uplink_item/I = pick_n_take(sale_items)
		var/datum/uplink_item/A = new I.type
		var/discount = A.get_discount()
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		A.limited_stock = limited_stock
		if(A.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		A.category = category_name
		A.cost = max(round(A.cost * discount),1)
		A.name += " ([round(((initial(A.cost)-A.cost)/initial(A.cost))*100)]% off!)"
		A.desc += " Normally costs [initial(A.cost)] TC. All sales final. [pick(disclaimer)]"
		A.item = I.item
		uplink_items[category_name][A.name] = A


/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null // Path to the item to spawn.
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/cost = 0
	var/refund_amount = 0 // specified refund amount in case there needs to be a TC penalty for refunds.
	var/refundable = FALSE
	var/surplus = 100 // Chance of being included in the surplus crate.
	var/cant_discount = FALSE
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	var/list/include_uplinks = list("Uplink") // Uplink types this is in
	var/list/include_antags = list() // Game modes to allow this item in.
	var/list/exclude_antags = list() // Game modes to disallow this item from.
	var/list/restricted_roles = list() //If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/player_minimum //The minimum crew size needed for this item to be added to uplinks.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	var/restricted = FALSE // Adds restrictions for VR/Events
	var/list/restricted_species //Limits items to a specific species. Hopefully.
	var/illegal_tech = TRUE // Can this item be deconstructed to unlock certain techweb research nodes?
	/// the manufacturer of the item. Gives up to a 20% discount if you're from that corporation
	var/datum/corporation/manufacturer

/datum/uplink_item/proc/get_discount()
	return pick(4;0.75,2;0.5,1;0.25)

/datum/uplink_item/proc/purchase(mob/user, datum/component/uplink/U)
	var/atom/A = spawn_item(item, user, U)
	if(refundable)
		var/refund = cost
		if(manufacturer && user.mind.is_employee(manufacturer))
			refund = CEILING(cost*0.8, 1)
		A.AddComponent(/datum/component/refundable, user.mind, refund)
	if(purchase_log_vis && U.purchase_log)
		U.purchase_log.LogPurchase(A, src, cost)

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(ishuman(user) && istype(A, /obj/item))
		var/mob/living/carbon/human/H = user
		if(H.put_in_hands(A))
			to_chat(H, "[A] materializes into your hands!")
			return A
	to_chat(user, "[A] materializes onto the floor.")
	return A

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = UPLINK_CATEGORY_DISCOUNTS

//All bundles and telecrystals
/datum/uplink_item/bundles_TC
	category = UPLINK_CATEGORY_BUNDLES
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/bundles_TC/chemical
	name = "Bioterror bundle"
	desc = "For the madman: Contains a handheld Bioterror chem sprayer, a Bioterror foam grenade, a box of lethal chemicals, a dart pistol, \
			box of syringes, Donksoft assault rifle, and some riot darts. Remember: Seal suit and equip internals before use."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	cost = 30 // normally 42
	manufacturer = /datum/corporation/traitor/donkco
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/bulldog
	name = "Bulldog bundle"
	desc = "Lean and mean: Optimized for people that want to get up close and personal. Contains the popular \
			Bulldog shotgun, two 12g buckshot drums, and a pair of Thermal imaging goggles."
	item = /obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	cost = 13 // normally 16
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/c20r
	name = "C-20r bundle"
	desc = "Old Faithful: The classic C-20r, bundled with two magazines and a (surplus) suppressor at discount price."
	item = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	cost = 14 // normally 16
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Cybernetic Implants Bundle"
	desc = "A random selection of cybernetic implants. Guaranteed 5 high quality implants. Comes with an autosurgeon."
	item = /obj/item/storage/box/cyber_implants
	cost = 40
	manufacturer = /datum/corporation/traitor/cybersun
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/medical
	name = "Medical bundle"
	desc = "The support specialist: Aid your fellow operatives with this medical bundle. Contains a tactical medkit, \
			a Donksoft LMG, a box of riot darts and a pair of magboots to rescue your friends in no-gravity environments."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	cost = 15 // normally 20
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/sniper
	name = "Sniper bundle"
	desc = "Elegant and refined: Contains a collapsed sniper rifle in an expensive carrying case, \
			two soporific knockout magazines, a free surplus suppressor, and a sharp-looking tactical turtleneck suit. \
			We'll throw in a free red tie if you order NOW."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 20 // normally 26
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/firestarter
	name = "Spetsnaz Pyro bundle"
	desc = "For systematic suppression of carbon lifeforms in close quarters: Contains a lethal New Russian backpack spray, Elite hardsuit, \
			Stechkin APS pistol, two magazines, a minibomb and a stimulant syringe. \
			Order NOW and comrade Boris will throw in an extra tracksuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/firestarter
	cost = 30
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/bundles_TC/contract_kit
	name = "Contract Kit"
	desc = "The Syndicate have offered you the chance to become a contractor, take on kidnapping contracts for TC and cash payouts. Upon purchase, \
			you'll be granted your own contract uplink embedded within the supplied tablet computer. Additionally, you'll be granted \
			standard contractor gear to help with your mission - comes supplied with the tablet, specialised space suit, chameleon jumpsuit and mask, \
			agent card, specialised contractor baton, and three randomly selected low cost items. Can include otherwise unobtainable items."
	item = /obj/item/storage/box/syndicate/contract_kit
	cost = 20
	player_minimum = 20
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/bundles_TC/contract_kit/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(is_species(user, /datum/species/plasmaman))
		spawn_path = /obj/item/storage/box/syndicate/contract_kit/plasmaman
	..()

/datum/uplink_item/bundles_TC/bundle_A
	name = "Syndi-kit Tactical"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			These items are collectively worth more than 20 telecrystals, but you do not know which specialization \
			you will receive. May contain discontinued and/or exotic items."
	item = /obj/item/storage/box/syndicate/bundle_A
	cost = 20 //These are 20 TC for a reason; sacrifice modularity for a pre-determined kit that will define your strategy
	exclude_antags = list(ROLE_OPERATIVE, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/bundles_TC/bundle_B
	name = "Syndi-kit Special"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			In Syndi-kit Special, you will receive items used by famous Syndicate agents of the past. Collectively worth more than 20 telecrystals, the Syndicate loves a good throwback."
	item = /obj/item/storage/box/syndicate/bundle_B
	cost = 20 //See above
	exclude_antags = list(ROLE_OPERATIVE, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/bundles_TC/surplus
	name = "Syndicate Surplus Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 50 TC."
	item = /obj/structure/closet/crate
	cost = 20
	player_minimum = 25
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration
	var/starting_crate_value = 50

/datum/uplink_item/bundles_TC/surplus/super
	name = "Super Surplus Crate"
	desc = "A dusty SUPER-SIZED from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 125 TC."
	cost = 40
	player_minimum = 40
	starting_crate_value = 125

/datum/uplink_item/bundles_TC/surplus/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	. = ..()
	var/obj/structure/closet/crate/spawned_crate = .
	var/list/uplink_items = get_uplink_items(null, FALSE)
	var/crate_value = starting_crate_value
	while(crate_value)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]

		if(!I.surplus || prob(100 - I.surplus))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		var/obj/goods = new I.item(spawned_crate)
		if(U.purchase_log)
			U.purchase_log.LogPurchase(goods, I, 0)
	return spawned_crate

/datum/uplink_item/bundles_TC/random
	name = "Random Item"
	desc = "Picking this will purchase a random item. Useful if you have some TC to spare or if you haven't decided on a strategy yet."
	item = /obj/item/stack/sheet/cardboard
	cost = 0
	illegal_tech = FALSE

/datum/uplink_item/bundles_TC/random/purchase(mob/user, datum/component/uplink/U)
	var/list/uplink_items = U.uplink_items
	var/list/possible_items = list()
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(src == I || !I.item)
				continue
			if(U.telecrystals < I.cost)
				continue
			if(I.limited_stock == 0)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		SSblackbox.record_feedback("tally", "traitor_random_uplink_items_gotten", 1, initial(I.name))
		U.MakePurchase(user, I)

/datum/uplink_item/bundles_TC/telecrystal
	name = "1 Raw Telecrystal"
	desc = "A telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal
	cost = 1
	// Don't add telecrystals to the purchase_log since
	// it's just used to buy more items (including itself!)
	purchase_log_vis = FALSE

/datum/uplink_item/bundles_TC/telecrystal/five
	name = "5 Raw Telecrystals"
	desc = "Five telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/bundles_TC/telecrystal/twenty
	name = "20 Raw Telecrystals"
	desc = "Twenty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

// Dangerous Items
/datum/uplink_item/dangerous
	category = UPLINK_CATEGORY_CONSPICUOUS

/datum/uplink_item/dangerous/busterarm
	name = "Buster Arm"
	desc = "A box containing a combat-focused prosthetic left arm that can be attached on contact; It is intended for close combat and possesses immense strength. With it, the user\
	can send people and heavy objects flying and even tear down solid objects like they're wet paper. To close the distance with ranged opponents, a grappling hook can be ejected\
	from the arm which momentarily keeps victims in place. Due to its unorthodox nature, the box includes 3 monkey cubes to familiarize the user with the arm functions. Users are \
	warned that the arm renders them unable to wear gloves and sticks out of most outerwear."
	item = /obj/item/storage/box/syndie_kit/buster
	cost = 15
	manufacturer = /datum/corporation/traitor/cybersun
	surplus = 0

/datum/uplink_item/dangerous/gasharpoon
	name = "GasHarpoon"
	desc = "A repurposed space-whaling tool attached to a glove, can be used as a sturdy weapon in both hands, or worn as a glove to allow access to its harpoon."
	item = /obj/item/clothing/gloves/gasharpoon
	cost = 10
	surplus = 0

/datum/uplink_item/dangerous/rawketlawnchair
	name = "84mm Rocket Propelled Grenade Launcher"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. \
		Guaranteed to send your target out with a bang or your money back!"
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = 8
	surplus = 30
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/dangerous/bananashield
	name = "Bananium Energy Shield"
	desc = "A clown's most powerful defensive weapon, this personal shield provides near immunity to ranged energy attacks \
		by bouncing them back at the ones who fired them. It can also be thrown to bounce off of people, slipping them, \
		and returning to you even if you miss. WARNING: DO NOT ATTEMPT TO STAND ON SHIELD WHILE DEPLOYED, EVEN IF WEARING ANTI-SLIP SHOES."
	item = /obj/item/shield/energy/bananium
	cost = 16
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/dangerous/clownsword
	name = "Bananium Energy Sword"
	desc = "An energy sword that is incapable of physical harm, but will slip anyone it contacts, be it by melee attack, thrown \
	impact, or just stepping on it. Beware friendly fire, as even anti-slip shoes will not protect against it."
	item = /obj/item/melee/transforming/energy/sword/bananium
	cost = 3
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "A handheld chemical sprayer that allows a wide dispersal of selected chemicals. Especially tailored by Vahlen \
			Pharmaceuticals, the deadly blend it comes stocked with will disorient, damage, and disable your foes... \
			Use with extreme caution, to prevent exposure to yourself and your fellow operatives."
	item = /obj/item/reagent_containers/spray/chemsprayer/bioterror
	cost = 20
	surplus = 0
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/dangerous/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3

/datum/uplink_item/dangerous/shotgun
	name = "Bulldog Shotgun"
	desc = "A fully-loaded semi-automatic drum-fed shotgun. Compatible with all 12g rounds. Designed for close \
			quarter anti-personnel engagements."
	item = /obj/item/gun/ballistic/shotgun/bulldog
	cost = 8
	surplus = 40
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun. The C-20r fires .45 rounds with a \
			24-round magazine and is compatible with suppressors."
	item = /obj/item/gun/ballistic/automatic/c20r
	cost = 10
	surplus = 40
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/doublesword
	name = "Double-Bladed Energy Sword"
	desc = "The double-bladed energy sword does slightly more damage than a standard energy sword and will deflect \
			all energy projectiles, but requires two hands to wield."
	item = /obj/item/melee/dualsaber
	player_minimum = 25
	cost = 16
	include_antags = list(ROLE_OPERATIVE) // yogs: infiltration

/datum/uplink_item/dangerous/doublesword/get_discount()
	return pick(4;0.8,2;0.65,1;0.5)

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/melee/transforming/energy/sword/saber
	cost = 8
	exclude_antags = list(ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/dangerous/backstab
	name = "Backstabbing Switchblade"
	desc = "This switchblade has a unique shape that makes it especially lethal when lodged in someone's backside. \
			Still does a moderate amount of damage when applied from the front."
	item = /obj/item/switchblade/backstab
	cost = 3
	// backstabs are pretty funny, clown ops can have this one

/datum/uplink_item/dangerous/bostaff
	name = "Bo Staff"
	desc = "A wielded wooden staff that can be used to incapacitate opponents if intending to disarm."
	item = /obj/item/melee/bostaff
	cost = 8
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/dangerous/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending \
			against other attacks. Pair with an Energy Sword for a killer combination."
	item = /obj/item/shield/energy
	cost = 16
	surplus = 20
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fueled by a portion of highly flammable biotoxins stolen previously from Nanotrasen \
			stations. Make a statement by roasting the filth in their own greed. Use with caution."
	item = /obj/item/gun/flamethrower/full
	cost = 4
	surplus = 40
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed or the meaty fists of a hulk."
	item = /obj/item/clothing/gloves/rapid
	cost = 8
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/dangerous/guardian
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an \
			organic host as a home base and source of fuel. Holoparasites come in various types and share damage with their host."
	item = /obj/item/guardiancreator/tech
	cost = 15
	manufacturer = /datum/corporation/traitor/cybersun
	surplus = 0
	exclude_antags = list(ROLE_INFILTRATOR, ROLE_INTERNAL_AFFAIRS)
	player_minimum = 25
	restricted = TRUE
	refundable = TRUE

// nukies don't get the 3 TC discount
/datum/uplink_item/dangerous/guardian/nuclear
	cost = 15
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	exclude_antags = list()

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A fully-loaded Aussec Armoury belt-fed machine gun. \
			This deadly weapon has a massive 50-round magazine of devastating 7.12x82mm ammunition."
	item = /obj/item/gun/ballistic/automatic/l6_saw
	cost = 20
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/minigun
	name = "M-546 Osprey"
	desc = "A fully-loaded minigun which packs a big punch. \
			This deadly giant weapon has a massive 500-round magazine of devastating 5.46mm caseless ammunition.\
			Slaughter your enemies through sheer force, prone to overheating with extended use. We made this gun so advanced that it fires the whole bullet.\
			Thats 60% more bullet per bullet and no more useless casings!"
	item = /obj/item/minigunbackpack
	cost = 30
	surplus = 0
	cant_discount = TRUE
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/rifle
	name = "M-90gl Rifle"
	desc = "A fully-loaded, specialized three-round burst rifle that fires 5.56mm ammunition from a 30 round magazine \
			with a toggleable 40mm underbarrel grenade launcher."
	item = /obj/item/gun/ballistic/automatic/m90
	cost = 18
	surplus = 50
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
			Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
			Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
			deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	item = /obj/item/clothing/gloves/powerfist
	cost = 6
	manufacturer = /datum/corporation/traitor/waffleco
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/dangerous/vxtvulhammer
	name = "Vxtvul Hammer"
	desc = "The Vxtvul Hammer is a sledgehammer once utilized by the ancient Vxtrin species. \
			This weapon must be wielded in two hands to be used effectively, but possesses high armor penetration. \
			In addition, the user can charge the hammer to enable a thunderous blow that will decimate construction in a single hit, \
			do sizeable damage to mechs, or shatter people off of their feet. The battery is charged by the user's concentration."
	item = /obj/item/melee/vxtvulhammer
	cost = 8
	include_antags = list(ROLE_OPERATIVE) //Only traitor preterni can buy the implant version

/datum/uplink_item/dangerous/nukiedmr
	name = "K-41s Designated Marksman Rifle"
	desc = "A long-range rifle that fires powerful 7.62 rounds from an 11-round magazine. It possesses \
			a short-range scope to better see over distances."
	item = /obj/item/gun/ballistic/automatic/k41s
	cost = 12
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/sniper
	name = "Sniper Rifle"
	desc = "Ranged fury, Syndicate style. Guaranteed to cause shock and awe or your TC back!"
	item = /obj/item/gun/ballistic/rifle/sniper_rifle/syndicate
	cost = 16
	surplus = 25
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 10-round magazines and is compatible \
			with suppressors. Ammo is included"
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 5
	exclude_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/dangerous/pistol/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(HAS_TRAIT_FROM(user, TRAIT_PACIFISM, ROUNDSTART_TRAIT))
		spawn_path = /obj/item/gun/ballistic/automatic/pistol/pacifist
		to_chat(user, span_notice("Your employer has loaded your purchased weapon with non-lethal ammunition"))
	..()

/datum/uplink_item/dangerous/bolt_action
	name = "Surplus Rifle"
	desc = "A horribly outdated bolt action weapon. You've got to be desperate to use this."
	item = /obj/item/gun/ballistic/rifle/boltaction
	cost = 1
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/dangerous/revolver
	name = "Syndicate Revolver"
	desc = "A brutally simple Syndicate revolver that fires .357 Magnum rounds and has 7 chambers."
	item = /obj/item/gun/ballistic/revolver
	cost = 6
	surplus = 50

/datum/uplink_item/dangerous/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade darts with a 20-round magazine."
	item = /obj/item/gun/ballistic/automatic/c20r/toy
	cost = 5
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 0
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/dangerous/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating \
			riot grade darts, that can briefly incapacitate someone in just one volley."
	item = /obj/item/gun/ballistic/automatic/l6_saw/toy
	cost = 10
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 0
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/dangerous/foampistol
	name = "Toy Pistol with Riot Darts"
	desc = "An innocent-looking toy pistol designed to fire foam darts. Comes loaded with riot-grade \
			darts effective at incapacitating a target."
	item = /obj/item/gun/ballistic/automatic/toy/pistol/riot
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 10

/datum/uplink_item/dangerous/watergun
	name = "Extended Capacity Hyper-Soaker"
	desc = "A simple yet effective way of applying chemicals to a target's skin. \
			Comes with a high-power nozzle and larger tank."
	item = /obj/item/gun/water/syndicate
	cost = 2
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 10

/datum/uplink_item/dangerous/hardlightbow
	name = "Hardlight Bow"
	desc = "A modern bow that can fabricate hardlight arrows, designed for silent takedowns of targets."
	item = /obj/item/gun/ballistic/bow/energy/syndicate
	cost = 6
	player_minimum = 25
	surplus = 25
	exclude_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/dangerous/nuclear_energy_fire_axe
	name = "Energy Fire Axe"
	desc = "A terrifying axe with a blade of pure energy, able to tear down structures with ease. \
			Easier to store than a standard fire axe while inactive."
	item = /obj/item/fireaxe/energy
	cost = 10
	include_antags = list(ROLE_OPERATIVE)
	surplus = 0

// Stealthy Weapons
/datum/uplink_item/stealthy_weapons
	category = UPLINK_CATEGORY_STEALTH_WEAPONS

/datum/uplink_item/stealthy_weapons/combatglovesplus
	name = "Combat Gloves Plus"
	desc = "A pair of gloves that are fireproof and shock resistant, however unlike the regular Combat Gloves this one uses nanotechnology \
			to learn the abilities of krav maga to the wearer."
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	cost = 5
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	surplus = 0

/datum/uplink_item/stealthy_weapons/cqc
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing."
	item = /obj/item/book/granter/martial/cqc
	cost = 13
	surplus = 0

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any \
			space a small item can."
	item = /obj/item/gun/syringe/syndicate
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 4
	surplus = 50

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Looks like a plush toy carp, but just add water and it becomes a real-life space carp! Activate in \
			your hand before use so it knows not to kill you."
	item = /obj/item/toy/plush/carpplushie/dehy_carp
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/stealthy_weapons/derringer
	name = "Derringer Pistol"
	desc = "A concealable double-chamber pistol loaded with individual .357 rounds. Fits in boots."
	item = /obj/item/gun/ballistic/revolver/derringer
	cost = 3
	manufacturer = /datum/corporation/traitor/donkco
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	item = /obj/item/pen/red/edagger
	cost = 2
	manufacturer = /datum/corporation/traitor/donkco

/datum/uplink_item/stealthy_weapons/donkbat
	name = "Toy Baseball Bat"
	desc = "A weighted solid plastic baseball bat, perfect for knocking the wind out of people."
	item = /obj/item/melee/classic_baton/donkbat
	cost = 6
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 0

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique known as Sleeping Carp. You will master unarmed combat, \
			deflecting all ranged weapon fire when throwmode is enabled, but you also refuse to use dishonorable ranged weaponry."
	item = /obj/item/book/granter/martial/carp
	cost = 14
	player_minimum = 20
	surplus = 0
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/stealthy_weapons/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A short bow mounted across a tiller in miniature. \
	Small enough to fit into a pocket or slip into a bag unnoticed. \
	It will synthesize and fire bolts tipped with some debilitating \
	toxins that will irradiate and tire, causing them to \
	be silenced. It can produce an infinite number \
	of bolts, but takes time to automatically recharge after each shot."
	item = /obj/item/gun/energy/kinetic_accelerator/crossbow
	cost = 5
	surplus = 30
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_weapons/origami_kit
	name = "Boxed Origami Kit"
	desc = "This box contains a guide on how to craft masterful works of origami, allowing you to transform normal pieces of paper into \
			perfectly aerodynamic (and potentially lethal) paper airplanes."
	item = /obj/item/storage/box/syndie_kit/origami_bundle
	cost = 14
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0
	exclude_antags = list(ROLE_OPERATIVE) //clown ops intentionally left in, because that seems like some s-tier shenanigans.

/datum/uplink_item/stealthy_weapons/traitor_chem_bottle
	name = "Poison Kit"
	desc = "An assortment of deadly and illegal chemicals packed into a compact box. Comes prepackaged in large syringes for more precise application."
	item = /obj/item/storage/box/syndie_kit/chemical
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 5
	surplus = 50

/datum/uplink_item/stealthy_weapons/romerol_kit
	name = "Romerol"
	desc = "A highly experimental bioterror agent which creates dormant nodules to be etched into the grey matter of the brain. \
			On death, these nodules take control of the dead body, causing limited revivification, \
			along with slurred speech, aggression, and the ability to infect others with this agent."
	item = /obj/item/storage/box/syndie_kit/romerol
	cost = 25
	surplus = 0 //Hijack-only, don't let this exist in surplus
	cant_discount = TRUE
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Sleepy Pen"
	desc = "A syringe disguised as a functional pen, filled with a potent mix of drugs, including a \
			strong anesthetic and a chemical that prevents the target from speaking. \
			The pen holds one dose of the mixture. Note that before the target \
			falls asleep, they will be able to move and act."
	item = /obj/item/pen/blue/sleepy
	cost = 4
	manufacturer = /datum/corporation/traitor/waffleco
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_weapons/suppressor
	name = "Suppressor"
	desc = "This suppressor will silence the shots of the weapon it is attached to for increased stealth and superior ambushing capability. It is compatible with many small ballistic guns including the Stechkin and C-20r, but not revolvers or energy guns."
	item = /obj/item/suppressor
	cost = 1
	surplus = 10
	exclude_antags = list(ROLE_CLOWNOP)

// Ammunition
/datum/uplink_item/ammo
	category = UPLINK_CATEGORY_AMMO
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "Pair of 10mm Handgun Magazines"
	desc = "A box that contains two additional 10-round 10mm magazines; compatible with the Stechkin Pistol."
	item = /obj/item/storage/box/syndie_kit/pistolammo
	cost = 1
	exclude_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/ammo/pistol/random
	name = "Random 10mm Handgun Magazines"
	desc = "A box that contains four random 10-round 10mm magazines at a discount; compatible with the Stechkin Pistol."
	item = /obj/item/storage/box/syndie_kit/pistolammo/random
	cost = 2 // same mentality as the 357. You can get 4 mags for 2-4 TC, so giving in to the random chance give you a deal

/datum/uplink_item/ammo/pistol/cs
	name = "Pair of 10mm Caseless Magazines"
	desc = "A box that contains two additional 10-round 10mm magazines; compatible with the Stechkin Pistol. \
			These rounds will leave no casings behind when fired."
	item = /obj/item/storage/box/syndie_kit/pistolcaselessammo

/datum/uplink_item/ammo/pistol/ap
	name = "10mm Armor-Piercing Magazine"
	desc = "An additional 10-round 10mm magazine; compatible with the Stechkin Pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap

/datum/uplink_item/ammo/pistol/hp
	name = "10mm Hollow-Point Magazine"
	desc = "An additional 10-round 10mm magazine; compatible with the Stechkin Pistol. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp

/datum/uplink_item/ammo/pistol/sleepy
	name = "Pair of 10mm Soporific Magazines"
	desc = "A box that contains 2 additional 10-round 10mm magazines; compatible with the Stechkin Pistol. \
			These rounds will deliver small doses of tranqulizers on hit, knocking the target out after a few successive hits."
	item = /obj/item/storage/box/syndie_kit/pistolsleepyammo

/datum/uplink_item/ammo/pistol/fire
	name = "10mm Incendiary Magazine"
	desc = "An additional 10-round 10mm magazine; compatible with the Stechkin Pistol. \
			Loaded with incendiary rounds which inflict reduced damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire

/datum/uplink_item/ammo/pistol/emp
	name = "10mm EMP Magazine"
	desc = "An additional 10-round 10mm magazine; compatible with the Stechkin pistol. \
			Loaded with bullets which release micro-electromagnetic pulses on hit, disrupting electronics on the target hit."
	item = /obj/item/ammo_box/magazine/m10mm/emp

/datum/uplink_item/ammo/pistol/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/ammo/shotgun
	cost = 2
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/shotgun/bag
	name = "12g Ammo Duffel Bag"
	desc = "A duffel bag containing three 12g buckshot drums, three 12g slug drums, and two 12g flechette drums for the Bulldog shotgun, bundled together at a discount."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun
	cost = 12 //Instead of 18

/datum/uplink_item/ammo/shotgun/bag/random
	name = "Randomized 12g Ammo Duffel Bag"
	desc = "A duffel bag containing 10 random drum mags for the Bulldog shotgun, bundled together at a big discount."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun/random
	cost = 10 // Random ammo, so its cheaper?

/datum/uplink_item/ammo/shotgun/buck
	name = "12g Buckshot Drum"
	desc = "An additional 8-round buckshot magazine for use with the Bulldog shotgun.\
			Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g

/datum/uplink_item/ammo/shotgun/dragon
	name = "12g Dragon's Breath Drum"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. \
			'I'm a fire starter, twisted fire starter!'"
	item = /obj/item/ammo_box/magazine/m12g/dragon

/datum/uplink_item/ammo/shotgun/frag
	name = "12g Frag-12 Drum"
	desc = "An alternative 8-round frag-12 magazine for use in the Bulldog shotgun. \
			'Collateral is my favorite kind of damage!'"
	cost = 3
	item = /obj/item/ammo_box/magazine/m12g/frag

/datum/uplink_item/ammo/shotgun/meteor
	name = "12g Meteorslug Shells"
	desc = "An alternative 8-round meteorslug magazine for use in the Bulldog shotgun. \
			Great for blasting airlocks off their frames and knocking down enemies."
	item = /obj/item/ammo_box/magazine/m12g/meteor

/datum/uplink_item/ammo/shotgun/slug
	name = "12g Slug Drum"
	desc = "An additional 8-round slug magazine for use with the Bulldog shotgun. \
			Now 8 times less likely to shoot your pals."
	item = /obj/item/ammo_box/magazine/m12g/slug

/datum/uplink_item/ammo/shotgun/flechette
	name = "12g Flechette Drum"
	desc = "An alternative 8-round flechette magazine for use with the Bulldog shotgun. \
			Tighter spread and armor penetration; make 'em bleed."
	cost = 3
	item = /obj/item/ammo_box/magazine/m12g/flechette

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader Box"
	desc = "A box with two .357 speed loaders. These speed loaders contain seven .357 rounds each; usable with the Syndicate revolver."
	item = /obj/item/storage/box/syndie_kit/revolverammo
	cost = 1
	exclude_antags = list(ROLE_CLOWNOP)
	illegal_tech = FALSE

/datum/uplink_item/ammo/revolver/random
	name = "Random .357 Speed Loader Box"
	desc = "A box with four random .357 speed loaders. Who knows what fun toys you might get?"
	item = /obj/item/storage/box/syndie_kit/revolverammo/random
	cost = 2// four would cost between 2 and 4 TC, so i think its fair

/datum/uplink_item/ammo/revolver/ironfeather
	name = ".357 Ironfeather Speed Loader Box"
	desc = "A box with two .357 Ironfeather speed loaders. These speed loaders contain seven .357 Ironfeather shells; usable with the Syndicate revolver. \
			Ironfeather shells contain six pellets which are less damaging than buckshot but mildly better over range."
	item = /obj/item/storage/box/syndie_kit/revolvershotgunammo

/datum/uplink_item/ammo/revolver/nutcracker
	name = ".357 Nutcracker Speed Loader"
	desc = "A speed loader that contains seven .357 Nutcracker rounds; usable with the Syndicate revolver. \
			These rounds lose moderate stopping power in exchange for being able to rapidly destroy doors and windows."
	item = /obj/item/ammo_box/a357/nutcracker

/datum/uplink_item/ammo/revolver/metalshock
	name = ".357 Metalshock Speed Loader"
	desc = "A speed loader that contains seven .357 Metalshock rounds; usable with the Syndicate revolver. \
			These rounds convert some lethality into an electric payload, which can bounce between targets."
	item = /obj/item/ammo_box/a357/metalshock

/datum/uplink_item/ammo/revolver/heartpiercer
	name = ".357 Heartpiercer Speed Loader"
	desc = "A speed loader that contains seven .357 Heartpiercer rounds; usable with the Syndicate revolver. \
			These rounds are less damaging, but penetrate through armor and up to two bodies at once."
	item = /obj/item/ammo_box/a357/heartpiercer

/datum/uplink_item/ammo/revolver/wallstake
	name = ".357 Wallstake Speed Loader"
	desc = "A speed loader that contains seven .357 Wallstake rounds; usable with the Syndicate revolver. \
			These blunt rounds are slightly less damaging but can knock people against walls."
	item = /obj/item/ammo_box/a357/wallstake

/datum/uplink_item/ammo/rifle
	name = "5.56mm Toploader Magazine"
	desc = "An additional 30-round 5.56mm magazine; suitable for use with the M-90gl rifle. \
			These bullets pack less punch than 7.12x82mm rounds, but they still offer more power than .45 ammo."
	item = /obj/item/ammo_box/magazine/m556
	cost = 4
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/rifle/ap
	name = "5.56mm Armor-Piercing Toploader Magazine"
	desc = "An additional 30-round 5.56mm magazine; suitable for use with the M-90gl rifle. \
			These rounds are less damaging but puncture through armor easily."
	item = /obj/item/ammo_box/magazine/m556/ap
	cost = 6

/datum/uplink_item/ammo/rifle/inc
	name = "5.56mm Incendiary Toploader Magazine"
	desc = "An additional 30-round 5.56mm magazine; suitable for use with the M-90gl rifle. \
			These rounds are less damaging but ignite targets."
	item = /obj/item/ammo_box/magazine/m556/inc

/datum/uplink_item/ammo/a40mm
	name = "40mm Grenade"
	desc = "A 40mm HE grenade for use with the M-90gl's under-barrel grenade launcher. \
			Your teammates will ask you to not shoot these down small hallways."
	item = /obj/item/ammo_casing/a40mm
	cost = 2
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/smg/bag
	name = ".45 Ammo Duffel Bag"
	desc = "A duffel bag containing five standard .45 magazines, two AP .45 magazines, and two HP .45 magazines for the C-20r submachine gun, bundled together at a discount."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/smg
	cost = 20 //instead of 29 TC
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/smg/bag/random
	name = "Randomized .45 Ammo Duffel Bag"
	desc = "A duffel bag containing eleven randomly picked, standard .45 magazines for the C-20r submachine gun, bundled together at a big discount."
	cost = 18 // bit cheaper for more random crap
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/smg/random

/datum/uplink_item/ammo/smg
	name = ".45 SMG Magazine"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 3
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/smg/ap
	name = ".45 Armor-Piercing SMG Magazine"
	desc = "An additional 24-round armor-piercing .45 magazine suitable for use with the C-20r submachine gun. \
			These rounds deal reduced damage but will bypass most protective gear."
	item = /obj/item/ammo_box/magazine/smgm45/ap
	cost = 4

/datum/uplink_item/ammo/smg/hp
	name = ".45 Hollow-Point SMG Magazine"
	desc = "An additional 24-round hollow-point .45 magazine suitable for use with the C-20r submachine gun. \
			These rounds deal high damage but are weak against body armor."
	item = /obj/item/ammo_box/magazine/smgm45/hp

/datum/uplink_item/ammo/smg/venom
	name = ".45 Venom SMG Magazine"
	desc = "An additional 24-round venom .45 magazine suitable for use with the C-20r submachine gun. \
			These rounds deal reduced damage but inject venom into targets."
	item = /obj/item/ammo_box/magazine/smgm45/venom
	cost = 4

/datum/uplink_item/ammo/nukiedmr
	name = "7.62 Rifle Magazine"
	desc = "A standard 11-round magazine for the K-41s DMR. Filled with 7.62 rounds."
	item = /obj/item/ammo_box/magazine/ks762
	cost = 3
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/nukiedmr/raze
	name = "7.62 Raze Rifle Magazine"
	desc = "An alternative 11-round magazine for the K-41s DMR. Filled with Raze 7.62 rounds. \
			These rounds do notably less damage, but release radium dust in targets that severely damages their DNA structure."
	item = /obj/item/ammo_box/magazine/ks762/raze
	cost = 4

/datum/uplink_item/ammo/nukiedmr/pen
	name = "7.62 Anti-Material Rifle Magazine"
	desc = "An alternative 11-round magazine for the K-41s DMR. Filled with anti-material 7.62 rounds. \
			These rounds offer less stopping power, but pierce through a couple of objects before stopping."
	item = /obj/item/ammo_box/magazine/ks762/pen
	cost = 5

/datum/uplink_item/ammo/nukiedmr/vulcan
	name = "7.62 Vulcan Rifle Magazine"
	desc = "An alternative 11-round magazine for the K-41s DMR. Filled with Vulcan 7.62 rounds. \
			These rounds are loaded with an incendiary payload that causes fire to erupt out upon impact."
	item = /obj/item/ammo_box/magazine/ks762/vulcan
	cost = 4

/datum/uplink_item/ammo/sniper
	name = ".50 Magazine"
	desc = "An additional standard 6-round magazine for use with .50 sniper rifles."
	item = /obj/item/ammo_box/magazine/sniper_rounds
	cost = 4
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/sniper/penetrator
	name = ".50 Penetrator Magazine"
	desc = "A 5-round magazine of penetrator ammo designed for use with .50 sniper rifles. \
			Can pierce walls and multiple enemies."
	item = /obj/item/ammo_box/magazine/sniper_rounds/penetrator
	cost = 5

/datum/uplink_item/ammo/sniper/soporific
	name = ".50 Soporific Magazine"
	desc = "A 3-round magazine of soporific ammo designed for use with .50 sniper rifles. Put your enemies to sleep today!"
	item = /obj/item/ammo_box/magazine/sniper_rounds/soporific
	cost = 6

/datum/uplink_item/ammo/machinegun
	cost = 6
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/machinegun/basic
	name = "7.12x82mm Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use with the L6 SAW. \
			By the time you need to use this, you'll already be standing on a pile of corpses."
	item = /obj/item/ammo_box/magazine/mm712x82

/datum/uplink_item/ammo/machinegun/ap
	name = "7.12x82mm (Armor-Piercing) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; equipped with special properties \
			to puncture even the most durable armor."
	item = /obj/item/ammo_box/magazine/mm712x82/ap
	cost = 9

/datum/uplink_item/ammo/machinegun/hollow
	name = "7.12x82mm (Hollow-Point) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; equipped with hollow-point tips to help \
			with the unarmored masses of crew."
	item = /obj/item/ammo_box/magazine/mm712x82/hollow

/datum/uplink_item/ammo/machinegun/inc
	name = "7.12x82mm (Incendiary) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; tipped with a special flammable \
			mixture that'll ignite anyone struck by the bullet. Some men just want to watch the world burn."
	item = /obj/item/ammo_box/magazine/mm712x82/incen

/datum/uplink_item/ammo/rocket
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/rocket/basic
	name = "84mm HE Rocket"
	desc = "A low-yield anti-personnel HE rocket. Gonna take you out in style!"
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 4

/datum/uplink_item/ammo/rocket/hedp
	name = "84mm HEDP Rocket"
	desc = "A high-yield HEDP rocket; extremely effective against armored targets, as well as surrounding personnel. \
			Strike fear into the hearts of your enemies."
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 6

/datum/uplink_item/ammo/pistolaps
	name = "9mm Handgun Magazine"
	desc = "An additional 15-round 9mm magazine, compatible with the Stechkin APS pistol, found in the Spetsnaz Pyro bundle."
	item = /obj/item/ammo_box/magazine/pistolm9mm
	cost = 2
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 0
	illegal_tech = FALSE

/datum/uplink_item/ammo/bioterror
	name = "Box of Bioterror Syringes"
	desc = "A box full of preloaded syringes, containing various chemicals that seize up the victim's motor \
			and broca systems, making it impossible for them to move or speak for some time."
	item = /obj/item/storage/box/syndie_kit/bioterror
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 6
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/ammo/bolt_action
	name = "Surplus Rifle Clip"
	desc = "A stripper clip used to quickly load bolt action rifles. Contains 5 rounds."
	item = 	/obj/item/ammo_box/a762
	cost = 1
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/dark_gygax/bag
	name = "Dark Gygax Ammo Bag"
	desc = "A duffel bag containing ammo for three full reloads of the incendiary carbine and flash bang launcher that are equipped on a standard Dark Gygax exosuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/dark_gygax
	cost = 4
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/ammo/mauler/bag
	name = "Mauler Ammo Bag"
	desc = "A duffel bag containing ammo for three full reloads of the LMG, scattershot carbine, and SRM-8 missile launcher that are equipped on a standard Mauler exosuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/mauler
	cost = 6
	include_antags = list(ROLE_OPERATIVE)

//Grenades and Explosives
/datum/uplink_item/explosives
	category = UPLINK_CATEGORY_EXPLOSIVES

/datum/uplink_item/explosives/bioterrorfoam
	name = "Bioterror Foam Grenade"
	desc = "A powerful chemical foam grenade which creates a deadly torrent of foam that will mute, blind, confuse, \
			mutate, and irritate carbon lifeforms. Specially brewed by Tiger Cooperative chemical weapons specialists \
			using additional spore toxin. Ensure suit is sealed before use."
	item = /obj/item/grenade/chem_grenade/bioterrorfoam
	cost = 5
	surplus = 35
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/explosives/bombanana
	name = "Bombanana"
	desc = "A banana with an explosive taste! Discard the peel quickly, as it will explode with the force of a Syndicate minibomb \
		a few seconds after the banana is eaten."
	item = /obj/item/reagent_containers/food/snacks/grown/banana/bombanana
	cost = 4 //it is a bit cheaper than a minibomb because you have to take off your helmet to eat it, which is how you arm it
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/explosives/buzzkill
	name = "Buzzkill Grenade Box"
	desc = "A box with three grenades that release a swarm of angry bees upon activation. These bees indiscriminately attack friend or foe \
			with random toxins."
	item = /obj/item/storage/box/syndie_kit/bee_grenades
	cost = 6
	manufacturer = /datum/corporation/bolsynpowell
	surplus = 35
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/c4
	cost = 1

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 8 //20% discount!
	cant_discount = TRUE
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	item = /obj/item/storage/backpack/duffelbag/syndie/x4
	cost = 4
	cant_discount = TRUE
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/clown_bomb_clownops
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 15
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/explosives/detomatix
	name = "BomberMan Program"
	desc = "This program gives you four opportunities to detonate PDAs and computers of crewmembers \
			who have their message feature enabled. The concussive effect from the explosion \
			will knock the recipient out for a short period, and deafen them for longer."
	item = /obj/item/computer_hardware/hard_drive/portable/syndicate/bomberman
	cost = 6
	manufacturer = /datum/corporation/traitor/cybersun
	restricted = TRUE
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/detomatix/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/portable/syndicate/bomberman/bombdisk = .
	var/datum/computer_file/program/bomberman/program = bombdisk.find_file_by_name("bomberman")
	var/code = program.bombcode

	to_chat(user, span_warning("Insert the disk into a modular computer and interact with it with the File Manager to download the program. Your BomberMan code is : [code]."))
	if(user.mind)
		user.mind.store_memory("BomberMan code for [U.parent] : [code]")

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains five EMP grenades and an EMP implant with three uses. Useful to disrupt communications, \
			security's energy weapons and silicon lifeforms when you're in a tight spot."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 2
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/explosives/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/explosives/ducky
	name = "Exploding Rubber Duck"
	desc = "A seemingly innocent rubber duck. When placed, it arms, and will violently explode when stepped on."
	item = /obj/item/deployablemine/traitor
	cost = 4
	manufacturer = /datum/corporation/traitor/waffleco
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/explosives/virus_grenade
	name = "Fungal Tuberculosis Grenade"
	desc = "A primed bio-grenade packed into a compact box. Comes with five Bio Virus Antidote Kit (BVAK) \
			autoinjectors for rapid application on up to two targets each, a syringe, and a bottle containing \
			the BVAK solution."
	item = /obj/item/storage/box/syndie_kit/tuberculosisgrenade
	cost = 12
	surplus = 35
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	restricted = TRUE

/datum/uplink_item/explosives/grenadier
	name = "Grenadier's belt"
	desc = "A belt containing 26 lethally dangerous and destructive grenades. Comes with an extra multitool and screwdriver."
	item = /obj/item/storage/belt/grenade/full
	include_antags = list(ROLE_OPERATIVE)
	cost = 22
	surplus = 0

/datum/uplink_item/explosives/bigducky
	name = "High Yield Exploding Rubber Duck"
	desc = "A seemingly innocent rubber duck. When placed, it arms, and will violently explode when stepped on. \
			This variant has been fitted with high yield X4 charges for a larger explosion."
	item = /obj/item/deployablemine/traitor/bigboom
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards, \
			opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"
	item = /obj/item/pizzabox/bomb
	cost = 6
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 8

/datum/uplink_item/explosives/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 3
	manufacturer = /datum/corporation/traitor/waffleco
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate bomb is a fearsome device capable of massive destruction. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so. \
			The bomb core can be pried out and manually detonated with other explosives."
	item = /obj/item/sbeacondrop/bomb
	cost = 11
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/syndicate_bomb/emp
	name = "Syndicate EMP Bomb"
	desc = "A variation of the syndicate bomb designed to produce a large EMP effect."
	item = /obj/item/sbeacondrop/emp
	cost = 7

/datum/uplink_item/explosives/syndicate_bomb/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 2

/datum/uplink_item/explosives/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate detonator is a companion device to the Syndicate bomb. Simply press the included button \
			and an encrypted radio frequency will instruct all live Syndicate bombs to detonate. \
			Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of \
			the blast radius before using the detonator."
	item = /obj/item/syndicatedetonator
	cost = 3
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/explosives/frag_grenade
	name = "Frag Grenade"
	desc = "Simple, but lethal. Anything adjacent when it explodes will be heavily damaged. Likely to cause a small hull breach."
	item = /obj/item/grenade/syndieminibomb/concussion/frag
	cost = 3
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach \
			in addition to dealing high amounts of damage to nearby personnel."
	item = /obj/item/grenade/syndieminibomb
	cost = 6
	include_antags = list(ROLE_OPERATIVE)
	exclude_antags = list(ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/explosives/tearstache
	name = "Tearstache Grenade"
	desc = "A teargas grenade that launches sticky moustaches onto the face of anyone not wearing a clown or mime mask. The moustaches will \
		remain attached to the face of all targets for one minute, preventing the use of breath masks and other such devices."
	item = /obj/item/grenade/chem_grenade/teargas/moustache
	cost = 3
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/explosives/viscerators
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred \
			any non-operatives in the area."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 5
	surplus = 35
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/explosives/wheelchair
	name = "Explosive Wheelchair"
	desc = "A wheelchair with a high yield bomb strapped to it... why would anyone ever want this?"
	item = /obj/item/wheelchair/explosive
	cost = 4
	surplus = 0
	limited_stock = 1
	include_objectives = list(/datum/objective/martyr)

/datum/uplink_item/explosives/suicide_vest
	name = "Suicide Vest"
	desc = "An autolocking, voice activated suicide vest. The electronics inside are so crude it only functions in inclusive mode. Once it's on, it can never be removed."
	item = /obj/item/clothing/suit/unalivevest
	cost = 7
	manufacturer = /datum/corporation/traitor/donkco

//Support and Mechs
/datum/uplink_item/support
	category = UPLINK_CATEGORY_SUPPORT
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/support/clown_reinforcement
	name = "Clown Reinforcements"
	desc = "Call in an additional clown to share the fun, equipped with full starting gear, but no telecrystals."
	item = /obj/item/antag_spawner/nuke_ops/clown
	cost = 20
	include_antags = list(ROLE_CLOWNOP)
	restricted = TRUE

/datum/uplink_item/support/reinforcement
	name = "Reinforcements"
	desc = "Call in an additional team member. They won't come with any gear, so you'll have to save some telecrystals \
			to arm them as well."
	item = /obj/item/antag_spawner/nuke_ops
	cost = 25
	refundable = TRUE
	include_antags = list(ROLE_OPERATIVE)
	restricted = TRUE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Syndicate Assault Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel. \
			Comes equipped with a self-resupplying LMG, a grenade launcher, energy sword, emag, pinpointer, flash and crowbar."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refundable = TRUE
	cost = 65
	restricted = TRUE

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Syndicate Medical Cyborg"
	desc = "A combat medical cyborg. Has limited offensive potential, but makes more than up for it with its support capabilities. \
			It comes equipped with a nanite hypospray, a medical beamgun, combat defibrillator, full surgical kit including an energy saw, an emag, pinpointer and flash. \
			Thanks to its organ storage bag, it can perform surgery as well as any humanoid."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refundable = TRUE
	cost = 35
	restricted = TRUE

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Syndicate Saboteur Cyborg"
	desc = "A streamlined engineering cyborg, equipped with covert modules. Also incapable of leaving the welder in the shuttle. \
			Aside from regular Engineering equipment, it comes with a special destination tagger that lets it traverse disposals networks. \
			Its chameleon projector lets it disguise itself as a Nanotrasen cyborg, on top it has thermal vision and a pinpointer."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refundable = TRUE
	cost = 35
	restricted = TRUE

/datum/uplink_item/support/gygax
	name = "Dark Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent \
			for hit-and-run style attacks. Features an incendiary carbine, flash bang launcher, teleporter, ion thrusters and a Tesla energy array."
	item = /obj/mecha/combat/gygax/dark/loaded
	cant_discount = TRUE
	cost = 60 //Yogs change

/datum/uplink_item/support/honker
	name = "Dark H.O.N.K."
	desc = "A clown combat mech equipped with bombanana peel and tearstache grenade launchers, as well as the ubiquitous HoNkER BlAsT 5000."
	item = /obj/mecha/combat/honker/dark/loaded
	cost = 35 //Yogs change
	include_antags = list(ROLE_CLOWNOP)
	cant_discount = TRUE

/datum/uplink_item/support/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly military-grade exosuit. Features long-range targeting, thrust vectoring \
			and deployable smoke. Comes equipped with an LMG, scattershot carbine, missile rack, an antiprojectile armor booster and a Tesla energy array."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cant_discount = TRUE
	cost = 105 //Yogs change

/datum/uplink_item/support/mamba
	name = "Black Mamba Exosuit"
	desc = "A stealthy, quick, and deadly combat exosuit, this modified sidewinder chassis is capable of suddenly striking and retreating while \
			the effects of its venomous weapons take hold. Comes with a venom carbine, dual daggers, and an anti-projectile armor booster."
	item = /obj/mecha/combat/sidewinder/mamba/loaded
	cant_discount = TRUE
	cost = 75

// Stealth Items
/datum/uplink_item/stealthy_tools
	category = UPLINK_CATEGORY_STEALTH_GADGETS

/datum/uplink_item/stealthy_tools/spy_bug
	name = "Box of Spy Bugs"
	desc = "A box of 10 spy bugs. These attach onto the target invisibly and cannot be removed, and broadcast all they hear to the secure syndicate channel.\
	Can be attached to animals and objects. Does not come with a syndicate encryption key."
	item = /obj/item/storage/box/syndie_kit/bugs
	cost = 1
/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access \
			from other identification cards. The access is cumulative, so scanning one card does not erase the \
			access gained from another. In addition, they can be forged to display a new assignment and name. \
			This can be done an unlimited amount of times. Some Syndicate areas and devices can only be accessed \
			with these cards."
	item = /obj/item/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it, and can be \
			activated to display their exact viewing location and nearby security camera blind spots. Knowing when \
			an artificial intelligence is watching you is useful for knowing when to maintain cover, and finding nearby \
			blind spots can help you identify escape routes."
	item = /obj/item/multitool/ai_detect
	cost = 1
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/stealthy_tools/pseudocider
	name = "Pseudocider"
	desc = "Disguised as a common pocket watch, the pseudocider will convincingly feign your fall, making you invisible \
			completely silent as you slip away from the scene, or into a better position! You will not be able to take \
			any actions for the 7 second duration."
	item = /obj/item/pseudocider
	cost = 8
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_tools/shadowcloak
	name = "Cloaker Belt"
	desc = "A tactical belt that renders the wearer invisible while active. Has a short charge that is refilled in darkness; only charges when in use."
	item = /obj/item/storage/belt/military/shadowcloak
	cost = 10
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_tools/nuclearshadowcloak
	name = "Cloaker Belt"
	desc = "A tactical belt that renders the wearer invisible while active. Has a short charge that is refilled in darkness; only charges when in use."
	item = /obj/item/storage/belt/military/shadowcloak
	cost = 20
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_tools/syndireverse
	name = "Bluespace Projectile Weapon Disrupter"
	desc = "Hidden in an ordinary-looking playing card, this device will teleport an opponent's gun to your hand when they fire at you. Just make sure to hold this in your hand!"
	item = /obj/item/syndicateReverseCard
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anyone on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	manufacturer = /datum/corporation/traitor/cybersun
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_tools/chameleon/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(is_species(user, /datum/species/plasmaman))
		spawn_path = /obj/item/storage/box/syndie_kit/chameleon/plasmaman
	..()

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't \
			move the projector from their hand. Disguised users move slowly, and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 7
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/device_tools/projector
	name = "Holographic Object Projector"
	item = /obj/item/device/holoprojector
	desc = "A device for masters of deception and trickery. This item allows you to scan objects and create \
			holograms of them. The holograms will dissipate when interacted with. You can replace the stock \
			parts it comes with to increase the maximum number of holograms and variety of scannable objects."
	cost = 4
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Codespeak Manual"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random concepts and drinks to anyone listening. \
			This manual teaches you this Codespeak. You can also hit someone else with the manual in order to teach them. This is the deluxe edition, which has unlimited uses."
	item = /obj/item/codespeak_manual/unlimited
	cost = 3
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/stealthy_tools/combatbananashoes
	name = "Combat Banana Shoes"
	desc = "While making the wearer immune to most slipping attacks like regular combat clown shoes, these shoes \
		can generate a large number of synthetic banana peels as the wearer walks, slipping up would-be pursuers. They also \
		squeak significantly louder."
	item = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	cost = 6
	surplus = 0
	include_antags = list(ROLE_CLOWNOP)

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-recharging, short-ranged EMP device disguised as a working flashlight. \
			Useful for disrupting headsets, cameras, doors, lockers and borgs during stealth operations. \
			Attacking a target with this flashlight will direct an EM pulse at it and consumes a charge."
	item = /obj/item/flashlight/emp
	cost = 2 //yogs no one uses this lol
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 30

/datum/uplink_item/stealthy_tools/emplight/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity \
			and appearance."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 4
	manufacturer = /datum/corporation/traitor/vahlen
	surplus = 30
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip/syndicate
	cost = 2
	manufacturer = /datum/corporation/traitor/waffleco
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip/syndicate
	cost = 4
	exclude_antags = list()
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/stealthy_tools/jammer
	name = "Signal Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated. Blocks suit sensors, but does not affect binary chat."
	item = /obj/item/jammer
	cost = 5
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar, a floor tile and some contraband inside."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30

/datum/uplink_item/stealthy_tools/armorpolish
	name = "Armor Polish"
	desc = "This two use polish will strengthen clothing to be as strong as a standard-issue armor vest.  \
			Reinforced with nanite technology, you are able to stay looking good while bashing heads in. \
			Beware, you can only polish suits and headgear!"
	item = /obj/item/armorpolish
	cost = 2

/datum/uplink_item/stealthy_tools/mousecubes
	name = "Box of Mouse Cubes"
	desc = "A box with twenty four Waffle Co. brand mouse cubes. Deploy near wiring. \
			Caution: Product may rehydrate when exposed to water."
	item = /obj/item/storage/box/monkeycubes/syndicate/mice
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/stealthy_tools/angelcoolboy
	name = "Syndicate Angel Potion"
	desc = "After many failed attempts, the syndicate has reverse engineered an angel potion smuggled off of the lava planet V-227. \
			Preliminary testing found that of the most common species, neither plasmamen nor polysmorph were capable of sprouting wings."
	cost = 2
	item = /obj/item/reagent_containers/glass/bottle/potion/flight/syndicate

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = UPLINK_CATEGORY_SPACE_SUITS
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This red and black Syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Nanotrasen crew members are trained to report red space suit \
			sightings, however."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 4
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/suits/hardsuit
	name = "Syndicate Hardsuit"
	desc = "The feared suit of a Syndicate nuclear agent. Features slightly better armoring and a built in jetpack \
			that runs off standard atmospheric tanks. Toggling the suit in and out of \
			combat mode will allow you all the mobility of a loose fitting uniform without sacrificing armoring. \
			Additionally the suit is collapsible, making it small enough to fit within a backpack. \
			Nanotrasen crew who spot these suits are known to panic."
	item = /obj/item/clothing/suit/space/hardsuit/syndi
	cost = 8
	exclude_antags = list(ROLE_OPERATIVE, ROLE_INFILTRATOR) //you can't buy it in nuke, because the elite hardsuit costs the same while being better // yogs: infiltration

/datum/uplink_item/suits/hardsuit/elite
	name = "Elite Syndicate Hardsuit"
	desc = "An upgraded, elite version of the Syndicate hardsuit. It features fireproofing, and also \
			provides the user with superior armor and mobility compared to the standard Syndicate hardsuit."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 8
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	exclude_antags = list()

/datum/uplink_item/suits/hardsuit/shielded
	name = "Shielded Syndicate Hardsuit"
	desc = "An upgraded version of the standard Syndicate hardsuit. It features a built-in energy shielding system. \
			The shields can handle up to three impacts within a short duration and will rapidly recharge while not under fire."
	item = /obj/item/clothing/suit/space/hardsuit/shielded/syndi
	cost = 30
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	exclude_antags = list()

// Devices and Tools
/datum/uplink_item/device_tools
	category = UPLINK_CATEGORY_MISC

/datum/uplink_item/device_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. \
			This pack contains three as well as a crayon for changing their appearances."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 20

/datum/uplink_item/device_tools/airshoes
	name = "Air Shoes"
	desc = "Popular in underground racing rings, these shoes come with built-in jets, allowing the users to reach high speeds for prolonged durations and short bursts. \
	Users should keep in mind that despite being easier to control than their Wheely cousins, these will not protect you from high-speed impacts."
	item = /obj/item/clothing/shoes/airshoes
	cost = 4
	manufacturer = /datum/corporation/traitor/cybersun
	surplus = -1
	restricted = TRUE

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targeting Device"
	desc = "Use this to select the landing zone of your assault pod."
	item = /obj/item/assault_pod
	cost = 30
	surplus = 0
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	restricted = TRUE

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to and talk with silicon-based lifeforms, \
			such as AI units and cyborgs, over their private binary channel. Caution should \
			be taken while doing this, as unless they are allied with you, they are programmed to report such intrusions."
	item = /obj/item/encryptionkey/binary
	cost = 2
	surplus = 75
	restricted = TRUE

/datum/uplink_item/device_tools/magboots
	name = "Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station \
			during gravitational generator failures. These reverse-engineered knockoffs of Nanotrasen's \
			'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 2

/datum/uplink_item/device_tools/briefcase_launchpad
	name = "Briefcase Launchpad"
	desc = "A briefcase containing a launchpad, a device able to teleport items and people to and from targets up to eight tiles away from the briefcase. \
			Also includes a remote control, disguised as an ordinary folder. Touch the briefcase with the remote to link it."
	surplus = 0
	item = /obj/item/storage/briefcase/launchpad
	cost = 6
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/device_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the main network, set up motion alerts and track a target. \
			Bugging cameras allows you to disable them remotely."
	item = /obj/item/camera_bug
	cost = 1
	manufacturer = /datum/corporation/traitor/cybersun
	surplus = 90

/datum/uplink_item/device_tools/military_belt
	name = "Chameleon Chest Rig"
	desc = "A robust seven-slot set of webbing that is capable of holding all manner of tactical equipment. This one is capable of disguising itself."
	item = /obj/item/storage/belt/chameleon/syndicate
	cost = 1
	exclude_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, electromagnetic card, or emag, is a small card that unlocks hidden functions \
			in electronic devices, subverts intended functions, and easily breaks security mechanisms."
	item = /obj/item/card/emag
	cost = 6

/datum/uplink_item/device_tools/fakenucleardisk
	name = "Decoy Nuclear Authentication Disk"
	desc = "It's just a normal disk. Visually it's identical to the real deal, but it won't hold up under closer scrutiny by the Captain. \
			Don't try to give this to us to complete your objective, we know better!"
	item = /obj/item/disk/nuclear/fake
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 1

/datum/uplink_item/device_tools/frame
	name = "F.R.A.M.E. Program"
	desc = "This program allows you to use five viruses which when used cause the targeted \
			computer to become a new uplink with zero TC, and immediately become unlocked. \
			You will receive the unlock code upon activating the virus, \
			and the new uplink may be charged with telecrystals normally."
	item = /obj/item/computer_hardware/hard_drive/portable/syndicate/frame
	cost = 4
	manufacturer = /datum/corporation/traitor/waffleco
	restricted = TRUE

/datum/uplink_item/device_tools/frame/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/portable/syndicate/frame/framedisk = .
	var/datum/computer_file/program/frame/program = framedisk.find_file_by_name("frame")
	var/code = program.framecode

	to_chat(user, span_warning("Insert the disk into a modular computer and interact with it with the File Manager to download the program. Your F.R.A.M.E. code is : [code]."))
	if(user.mind)
		user.mind.store_memory("F.R.A.M.E. code for [U.parent] : [code]")

/datum/uplink_item/device_tools/failsafe
	name = "Failsafe Uplink Code"
	desc = "When entered the uplink will self-destruct immediately."
	item = /obj/item/computer_hardware/hard_drive/portable/syndicate // Doesn't spawn
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0
	restricted = TRUE
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP, ROLE_INFILTRATOR) // Yogs: infiltration
	illegal_tech = FALSE

/datum/uplink_item/device_tools/failsafe/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!U)
		return
	U.has_failsafe = TRUE
	U.failsafe_code = U.generate_code()
	var/code = "[islist(U.failsafe_code) ? english_list(U.failsafe_code) : U.failsafe_code]"
	to_chat(user, span_warning("The new failsafe code for this uplink is now : [code]."))
	if(user.mind)
		user.mind.store_memory("Failsafe code for [U.parent] : [code]")
	return U.parent //For log icon

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "A suspicious black and red syndicate toolbox. It comes loaded with a full speedy tool set including a \
			multitool and combat gloves that are resistant to shocks and heat. It is very compact and will \
			fit in any standard Nanotrasen backpack."
	item = /obj/item/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/toolboxreal
	name = "Deluxe Syndicate Toolbox"
	desc = "A syndicate toolbox that comes stocked with ultra-fast syndicate tools. Be careful, as \
			these tools are more obviously marked and will be easily spotted by anyone observant."
	item = /obj/item/storage/toolbox/syndicate/real
	cost = 2

/datum/uplink_item/device_tools/tactical_gloves
	name = "Tactical Fingerless Gloves"
	desc = "A pair of simple fabric gloves without fingertips that allow one to perform tasks faster and act quicker in unarmed manuevers. \
			Also greatly assists with the carrying of bodies, while not letting anyone else take them from you!"
	item = /obj/item/clothing/gloves/fingerless/bigboss
	cost = 2

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. \
			Be careful with wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/aiModule/hacked
	cost = 4
	manufacturer = /datum/corporation/traitor/cybersun
	exclude_antags = list(ROLE_INFILTRATOR)

/datum/uplink_item/device_tools/hypnotic_flash
	name = "Hypnotic Flash"
	desc = "A modified flash able to hypnotize targets. If the target is not in a mentally vulnerable state, it will only confuse and pacify them temporarily."
	item = /obj/item/assembly/flash/hypnotic
	cost = 7
	manufacturer = /datum/corporation/traitor/vahlen

/datum/uplink_item/device_tools/illegal_ammo_disk
	name = "Illegal Ammo Design Disk"
	desc = "A design disk for an autolathe that permits it to print all types of 10mm and .357 ammunition."
	item = /obj/item/disk/design_disk/illegal_ammo
	cost = 4
	exclude_antags = list(ROLE_OPERATIVE) //Buy your own ammo you lazy sods

/datum/uplink_item/device_tools/illegal_ammo_disk/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3 // Can print EMP.

/datum/uplink_item/device_tools/medgun
	name = "Medbeam Gun"
	desc = "A wonder of Syndicate engineering, the Medbeam gun, or Medi-Gun enables a medic to keep his fellow \
			operatives in the fight, even while under fire. Don't cross the streams!"
	item = /obj/item/gun/medbeam
	cost = 8
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/medgun_uber
	name = "Augmented Medbeam Gun"
	desc = "An augmented version of the classic Medbeam Gun that we picked up off the corpse of a german scientist. \
			It has an invulnerability mode that can be activated for a few seconds after healing for a long while. \
			This one comes uncharged, so be sure to give it a whirl before getting into combat. Goes well with a M-546 Osprey."
	item = /obj/item/gun/medbeam/uber
	cost = 25
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/mdrive
	name = "Mirage Drive"
	desc = "An experimental device created as a byproduct of research into faster than light travel. \
		Utilizing magnetic coils, the mirage drive is able to generate kinetic energy and use it in a \
		way that moves the user to their destination at a speed comparable to teleportation, so long \
		as an unobstructed path between the user and the target exists."
	item = /obj/item/mirage_drive
	cost = 7
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities or tesla balls towards it. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	item = /obj/item/sbeacondrop
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	include_objectives = list(/datum/objective/hijack, /datum/objective/martyr, /datum/objective/nuclear) //yogs
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/device_tools/roburger_recipe
	name = "Roburger crafting recipe"
	desc = "This book contains legendary knowledge about how to make roburgers. \
			Roburgers turn people into cyborgs when eaten after a short while. \
			This book doesn't disappear after use, so consider hiding it somewhere."
	item = /obj/item/book/granter/crafting_recipe/roburgers
	cost = 14
	include_objectives = list(/datum/objective/hijack, /datum/objective/martyr, /datum/objective/nuclear) //yogs: give sole_survivors the roburger
	exclude_antags = list(ROLE_INFILTRATOR)

/datum/uplink_item/device_tools/supermatter_delaminator
	name = "Antinoblium Shard"
	desc = "A special variant of supermatter crystal reverse engineered by syndicate scientists using samples retrieved by agents. \
			Attaching this to an active supermatter crystal will destabilize the internal crystal well, causing a resonance cascade. \
			Ensures a storm of EMP waves that blacks out the entire station and eventually the full delamination of the crystal. \
			Comes with a secure radiation shielded containment box, special tweezers and usage instructions."
	item = /obj/item/storage/box/syndie_kit/supermatter_delaminator
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	include_objectives = list(/datum/objective/hijack, /datum/objective/martyr, /datum/objective/nuclear) //yogs
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to a power grid and activated, this large device lights up and places excessive \
			load on the grid, causing a station-wide blackout. The sink is large and cannot be stored in most \
			traditional bags and boxes. Caution: Will explode if the powernet contains sufficient amounts of energy."
	item = /obj/item/powersink
	cost = 8
	manufacturer = /datum/corporation/traitor/waffleco
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/device_tools/rad_laser
	name = "Radioactive Microlaser"
	desc = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapacitate all but the most protected \
			of humanoids. It has two settings: intensity, which controls the power of the radiation, \
			and wavelength, which controls the delay before the effect kicks in."
	item = /obj/item/healthanalyzer/rad_laser
	cost = 4
	manufacturer = /datum/corporation/traitor/donkco

/datum/uplink_item/device_tools/stimpack
	name = "Stimpack"
	desc = "Stimpacks, the tool of many great heroes, make you nearly immune to stuns and knockdowns for about \
			5 minutes after injection."
	item = /obj/item/reagent_containers/autoinjector/medipen/stimpack/large // Yogs -- Stimpack change
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	surplus = 90

/datum/uplink_item/device_tools/dodge_cloak
	name = "Shadow Cloak"
	desc = "A highly advanced cloak that renders the user transparent over time and able to dodge attacks. Moving, \
			dodging attacks, or suffering an EMP will reduce or remove the transperency temporarily."
	item = /obj/item/clothing/neck/cloak/ranger/syndie
	cost = 30
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "Included is a combat stimulant injector \
			for rapid healing, a medical night vision HUD for quick identification of injured personnel, \
			and other supplies helpful for a field medic."
	item = /obj/item/storage/firstaid/tactical
	cost = 4
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/hypospray_kit
	name = "Syndicate Combat Hypospray Kit"
	desc = "An advanced kit containing a combat hypospray and a wide variety of vials containing \"perfectly legal chemicals\" to treat combatants."
	item = /obj/item/storage/firstaid/hypospray/syndicate
	cost = 5
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. \
			You can also drop it underfoot to slip people."
	item = /obj/item/soap/syndie
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 50
	illegal_tech = FALSE

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffel Bag"
	desc = "A red and black duffel bag containing all surgery tools, a surgical mat, \
			a normal MMI, an implant case, a straitjacket, and a muzzle. The surgery tools are twice as fast compared to normal surgery tools."
	manufacturer = /datum/corporation/traitor/vahlen
	item = /obj/item/storage/backpack/duffelbag/syndie/surgery
	cost = 2

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Syndicate channel with other agents that have the same key."
	item = /obj/item/encryptionkey/syndicate
	cost = 2
	surplus = 75
	restricted = TRUE

/datum/uplink_item/device_tools/syndietome
	name = "Syndicate Tome"
	desc = "Using rare artifacts acquired at great cost, the Syndicate has reverse engineered \
			the seemingly magical books of a certain cult. Though lacking the esoteric abilities \
			of the originals, these inferior copies are still quite useful, being able to provide \
			both weal and woe on the battlefield, even if they do occasionally bite off a finger."
	item = /obj/item/storage/book/bible/syndicate
	cost = 5

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These goggles can be turned to resemble common eyewear found throughout the station. \
			They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, \
			emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms \
			and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 4

/datum/uplink_item/device_tools/potion
	name = "Syndicate Sentience Potion"
	item = /obj/item/slimepotion/slime/sentience/nuclear
	desc = "A potion recovered at great risk by undercover Syndicate operatives and then subsequently modified with Syndicate technology. \
			Using it will make any animal sentient, and bound to serve you, as well as implanting an internal radio for communication and an internal ID card for opening doors."
	cost = 4
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	restricted = TRUE

/datum/uplink_item/device_tools/potion/traitor
	name = "Lesser Syndicate Sentience Potion"
	item = /obj/item/slimepotion/slime/sentience/traitor
	desc = "The Syndicate have recently synthesized artificial sentience potions thanks to stolen slime cores. \
			Using it will make any animal sentient, and bound to serve you in your dastardly deeds."
	cost = 2
	limited_stock = 2 //only buy two, prevents certain mushroom shenanigans
	include_antags = list() //clear the list
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP, ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/device_tools/suspiciousphone
	name = "Protocol CRAB-17 Phone"
	desc = "The Protocol CRAB-17 Phone, a phone borrowed from an unknown third party, it can be used to crash the space market, funneling the losses of the crew to your bank account.\
	The crew can move their funds to a new banking site though, unless they HODL, in which case they deserve it."
	item = /obj/item/suspiciousphone
	cost = 7
	manufacturer = /datum/corporation/traitor/waffleco
	limited_stock = 1
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/device_tools/syndie_bodybag
	name = "Syndicate Prisoner Transport Bag"
	desc = "An alteration of Nanotrasen's environmental protection bag which has been used in several high-profile kidnappings. \
			Designed to keep a victim unconscious, alive, and secured until they are transported to a required location. \
			Comes with a remote that burns victims for emergencies."
	item = /obj/item/storage/box/syndie_kit/prisonerbag
	cost = 2

/datum/uplink_item/device_tools/holo_sight
	name = "Attachment Kit"
	desc = "A box of attachments to be used on any common firearm. Use a screwdriver to remove attachments."
	item = /obj/item/storage/box/syndie_kit/attachments
	cost = 1
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/holo_sight
	name = "Holographic Sight"
	desc = "A high-tech holographic sight that improves the aim of the weapon it's attached to."
	item = /obj/item/attachment/scope/holo
	cost = 2
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/vert_grip
	name = "Vertical Grip"
	desc = "A vertical foregrip that reduces the shock of firing a weapon. Extra handy for higher recoil guns like the sniper rifle."
	item = /obj/item/attachment/grip/vertical
	cost = 2
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/laser_sight
	name = "Laser Sight"
	desc = "An aesthetic laser sight that improves your accuracy and shows you where you're aiming."
	item = /obj/item/attachment/laser_sight
	cost = 2
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/device_tools/mechpilotguide
	name = "Mech Piloting for Dummies"
	desc = "A step-by-step guide on how to effectively pilot a mech, written in such a way that even a clown could understand."
	item = /obj/item/book/granter/mechpiloting
	cost = 5	//this is genuinely a REALLY strong effect, don't sleep on it

/datum/uplink_item/device_tools/physiology_guide
	name = "Guide to First Aid"
	desc = "A book that improves the reader's physiological knowledge."
	item = /obj/item/book/granter/skill/physiology
	cost = 3

/datum/uplink_item/device_tools/mechanics_guide
	name = "Nuclear Engineering for Dummies"
	desc = "A book that improves the reader's mechanical skills."
	item = /obj/item/book/granter/skill/mechanics
	cost = 3

/datum/uplink_item/device_tools/technical_guide
	name = "Hacking 101"
	desc = "A book that improves the reader's technical abilities."
	item = /obj/item/book/granter/skill/technical
	cost = 3

/datum/uplink_item/device_tools/science_guide
	name = "Statistical Mechanics and Thermodynamics"
	desc = "A book that improves the reader's scientific proficiency."
	item = /obj/item/book/granter/skill/science
	cost = 3

/datum/uplink_item/device_tools/mech_drop
	name = "Orbital Mech Drop Fulton"
	desc = "A heavy-duty transport pack that can be used to store and summon mecha that you have stored with it. Refundable if never used."
	item = /obj/item/extraction_pack/mech_drop
	cost = 4
	refundable = TRUE
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/device_tools/loic_remote
	name = "Low Orbit Ion Cannon Remote"
	desc = "The Syndicate has recently installed a remote satellite nearby capable of generating a localized ion storm every 20 minutes. \
			However, your local authorities will be informed of your general location when it is activated."
	item = /obj/item/device/loic_remote
	// TODO: When /datum/corporation/self is pickable for non-AI traitors, add it here.
	limited_stock = 1 // Might be too annoying if someone had mulitple.
	cost = 5 // Lacks the precision that a hacked law board (at 4 TCs) would give, but can be used on the go.
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)


// Implants
/datum/uplink_item/implants
	category = UPLINK_CATEGORY_IMPLANTS
	surplus = 50


/datum/uplink_item/implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		// All implants are half off and can be as low as one TC.
		cost = max(1, ROUND_UP(cost/2))

/datum/uplink_item/implants/reusable
	name = "Reusable Autosurgeon"
	desc = "An empty autosurgeon, but unlike others can be used multiple times. More suspicious than others."
	item = /obj/item/autosurgeon/suspicious/reusable
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 5
	// Nukies have no use for this and their autosurgeons are already multi-use
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will inject a chemical \
			cocktail which removes all incapacitating effects, lets the user run faster and has a mild healing effect."
	item = /obj/item/storage/box/syndie_kit/imp_adrenal
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	player_minimum = 25

/datum/uplink_item/implants/antistun
	name = "Upgraded CNS Rebooter Implant"
	desc = "This implant will stimulate muscle movements to help you get back up on your feet faster after being stunned. \
			This version is modified to help reduce exhaustion during combat. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/suspicious/anti_stun
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	surplus = 0

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated at the user's will. It will attempt to free the \
			user from common restraints such as handcuffs."
	item = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 5
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/implants/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			The more implants inside of you, the higher the explosive power. \
			This will permanently destroy your body, however."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 2
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			Upon death, releases a massive explosion that will wipe out everything nearby."
	item = /obj/item/storage/box/syndie_kit/imp_macrobomb
	cost = 20
	include_antags = list(ROLE_OPERATIVE)
	restricted = TRUE

/datum/uplink_item/implants/radio
	name = "Internal Syndicate Radio Implant"
	desc = "An implant injected into the body, allowing the use of an internal Syndicate radio. \
			Used just like a regular headset, but can be disabled to use external headsets normally and to avoid detection."
	item = /obj/item/storage/box/syndie_kit/imp_radio
	cost = 4
	manufacturer = /datum/corporation/traitor/donkco
	restricted = TRUE

/datum/uplink_item/implants/reviver
	name = "Syndicate Reviver Implant"
	desc = "A more powerful and experimental version of the one utilized by Nanotrasen, this implant will attempt to revive and heal you if you are critically injured. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/suspicious/reviver
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/implants/stealthimplant
	name = "Stealth Implant"
	desc = "This one-of-a-kind implant will make you almost invisible if you play your cards right. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	item = /obj/item/storage/box/syndie_kit/imp_stealth
	manufacturer = /datum/corporation/traitor/donkco
	cost = 8

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small bluespace \
			pocket capable of storing two regular-sized items."
	item = /obj/item/storage/box/syndie_kit/imp_storage
	cost = 8

/datum/uplink_item/implants/thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you thermal vision. Comes with a free autosurgeon."
	item = /obj/item/autosurgeon/thermal_eyes
	cost = 8
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated at the user's will. Has no telecrystals and must be charged by the use of physical telecrystals. \
			Undetectable (except via surgery), and excellent for escaping confinement."
	item = /obj/item/storage/box/syndie_kit/imp_uplink
	cost = UPLINK_IMPLANT_TELECRYSTAL_COST //4 TC
	// An empty uplink is kinda useless.
	surplus = 0
	restricted = TRUE

/datum/uplink_item/implants/mindshield
	name = "Syndicate Brainwash Denial Implant"
	desc = "An implant injected into the body, to deny brainwashing attempts."
	item = /obj/item/storage/box/syndie_kit/imp_mindshield
	limited_stock = 3
	player_minimum = 30
	illegal_tech = FALSE // This is a cheap knockoff of NT tech.
	surplus = 5
	cost = 1
	manufacturer = /datum/corporation/traitor/waffleco

/datum/uplink_item/implants/xray
	name = "X-ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/suspicious/xray_eyes
	cost = 10
	surplus = 0
	include_antags = list(ROLE_OPERATIVE)

/datum/uplink_item/implants/mantis
	name = "G.O.R.L.E.X. Mantis Blade"
	desc = "One G.O.R.L.E.X Mantis blade implant able to be retracted inside your body at will for easy storage and concealing. Two blades can be used at once."
	item = /obj/item/autosurgeon/suspicious/syndie_mantis
	cost = 6
	surplus = 0
	exclude_antags = list(ROLE_INFILTRATOR) // yogs: infiltration

/datum/uplink_item/implants/stechkin_implant
	name = "Stechkin arm implant"
	desc = "A modified version of the Stechkin pistol placed inside of the forearm to allow for easy concealment."
	item = /obj/item/autosurgeon/suspicious/stechkin_implant
	cost = 9

/datum/uplink_item/implants/noslipall
	name = "Slip Prevention Implant"
	desc = "An implant that uses advanced sensors to detect when you are slipping and utilize motors in order to prevent it."
	item = /obj/item/autosurgeon/suspicious/noslipall
	cost = 6	//tax for them being nigh impossible to steal or lose

/datum/uplink_item/implants/airshoes
	name = "Air Shoes Implant"
	desc = "As a result of extreme popularity of the Air Shoes an implant version was developed. Just like the boots there are jets allowing the users to reach high speeds for prolonged durations and short bursts."
	item = /obj/item/autosurgeon/suspicious/airshoes
	cost = 6	//2 tc tax for them being nigh impossible to steal or lose
	manufacturer = /datum/corporation/traitor/cybersun

/datum/uplink_item/implants/spinal
	name = "Neural Overclocker Implant"
	desc = "Stimulates your central nervous system in order to enable you to perform muscle movements faster. Careful not to overuse it."
	item = /obj/item/autosurgeon/suspicious/spinalspeed
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 12
	exclude_antags = list(ROLE_INFILTRATOR, ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/implants/spinal/nukie
	cost = 20
	exclude_antags = list()
	include_antags = list(ROLE_INFILTRATOR, ROLE_OPERATIVE, ROLE_CLOWNOP)

/datum/uplink_item/implants/emp_shield
	name = "EMP Shield Implant"
	desc = "Developed by Cybersun to assist with the S.E.L.F. movement, this implant will protect you and your insides from electromagnetic interference. \
			Due to technical limitations, it will overload and shut down for a short time if triggered too often."
	manufacturer = /datum/corporation/traitor/cybersun
	item = /obj/item/storage/box/syndie_kit/emp_shield
	cost = 6

// Events
/datum/uplink_item/services
	category = "Services"
	include_antags = list(ROLE_INFILTRATOR, ROLE_OPERATIVE)
	surplus = 0
	restricted = TRUE

/datum/uplink_item/services/manifest_spoof
	name = "Crew Manifest Spoof"
	desc = "A button capable of adding a single person to the crew manifest."
	item = /obj/item/service/manifest
	cost = 4
	limited_stock = 1

/datum/uplink_item/services/fake_ion
	name = "Fake Ion Storm"
	desc = "Fakes an ion storm announcment. A good distraction, especially if the AI is weird anyway."
	item = /obj/item/service/ion
	cost = 7

/datum/uplink_item/services/fake_meteor
	name = "Fake Meteor Announcement"
	desc = "Fakes an meteor announcment. A good way to get any C4 on the station exterior, or really any small explosion, brushed off as a meteor hit."
	item = /obj/item/service/meteor
	cost = 7

/datum/uplink_item/services/fake_rod
	name = "Fake Immovable Rod"
	desc = "Fakes an immovable rod announcement. Good for a short-lasting distraction."
	item = /obj/item/service/rodgod
	cost = 6 //less likely to be believed

//Infiltrator shit
/datum/uplink_item/infiltration
	category = UPLINK_CATEGORY_INFILTRATION
	include_antags = list(ROLE_INFILTRATOR)
	surplus = 0

/datum/uplink_item/infiltration/extra_stealthsuit
	name = "Extra Chameleon Hardsuit"
	desc = "An infiltration hardsuit, capable of changing it's appearance instantly."
	item = /obj/item/clothing/suit/space/hardsuit/infiltration
	cost = 10

/datum/uplink_item/infiltration/access_kit
	name = "Access Kit"
	desc = "A secret device, reverse engineered by gear retrieved from previous Nanotrasen infiltration missions. Allows you to spoof an ID card to have the assignment and access of a single low-level job."
	item = /obj/item/access_kit/syndicate
	limited_stock = 1
	cost = 5

//Race-specific items
/datum/uplink_item/race_restricted
	category = UPLINK_CATEGORY_SPECIES
	surplus = 0

/datum/uplink_item/race_restricted/syndilamp
	name = "Extra-Bright Lantern"
	desc = "We heard that ex'hai such as yourself really like lamps, so we decided to grant you early access to a prototype \
	Syndicate brand \"Extra-Bright Lantern™\". Enjoy."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/race_restricted/syndigenetics
	name = "Fire Breath implanter"
	desc = "Recently Vahlen scientists have found the formula of genetical patterns that is needed to activate vuulen genes to grant them the ability to breath fire."
	cost = 6
	manufacturer = /datum/corporation/traitor/vahlen
	item = /obj/item/dnainjector/firebreath
	restricted_species = list(SPECIES_LIZARD, SPECIES_LIZARD_DRACONID)

/datum/uplink_item/race_restricted/flyingfang
	name = "Flying Fang Tablet"
	desc = "This tablet contains a set of old vuulek fighting techniques, increasing your melee combat effectiveness but preventing you from using armor, most common stun weapons, or guns."
	cost = 14
	item = /obj/item/book/granter/martial/flyingfang
	restricted_species = list(SPECIES_LIZARD, SPECIES_LIZARD_DRACONID)

/datum/uplink_item/race_restricted/hammerimplant
	name = "Vxtvul Hammer Implant"
	desc = "An implant which will fold a Vxtvul hammer into your chassis upon injection. \
			This hammer can be retracted and wielded in two hands as an effective armor-piercing weapon. \
			It can be charged by the user's concentration, which permits a single blow that will decimate construction, \
			fling bodies, and heavily damage mechs. Vir'ln krx'tai, lost one."
	cost = 10
	item = /obj/item/autosurgeon/suspicious/syndie_hammer
	restricted_species = list(SPECIES_PRETERNIS)

/datum/uplink_item/race_restricted/hammerimplant/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost = max(1, ROUND_UP(cost/2))

/datum/uplink_item/race_restricted/killertomatos
	name = "Killer Tomatoes"
	desc = "The Syndicates local gardeners brewed these up for our plant comrades (does not work against fellow plants)."
	cost = 3
	manufacturer = /datum/corporation/traitor/donkco
	item = /obj/item/seeds/tomato/killer
	restricted_species = list(SPECIES_PODPERSON)

/datum/uplink_item/race_restricted/radiationbomb
	name = "Radiation grenade"
	desc = "A radiation bomb guaranteed to irradiate the fuck out of non-gaseous lifeforms."
	cost = 4
	manufacturer = /datum/corporation/traitor/waffleco
	item = /obj/item/grenade/chem_grenade/radiation
	restricted_species = list(SPECIES_PLASMAMAN)

/datum/uplink_item/race_restricted/hulk
	name = "Hulk Mutator"
	desc = "Stolen research from a SIC scientist who went postal led to the development of this revolutionary mutator. Causes extreme muscle growth, enough to punch through walls, and practically limitless stamina, at the cost of reduced cognitive ability, and green skin pigmentation."
	cost = 12
	manufacturer = /datum/corporation/traitor/vahlen
	item = /obj/item/dnainjector/hulkmut
	restricted_species = list(SPECIES_HUMAN)

// Role-specific items
/datum/uplink_item/role_restricted
	category = UPLINK_CATEGORY_ROLE
	exclude_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	surplus = 0

/datum/uplink_item/role_restricted/ancient_jumpsuit
	name = "Ancient Jumpsuit"
	desc = "A tattered old jumpsuit that will provide absolutely no benefit to you. It fills the wearer with a strange compulsion to blurt out 'glorf'."
	item = /obj/item/clothing/under/color/grey/glorf
	cost = 20
	restricted_roles = list("Assistant")
	surplus = 0

/datum/uplink_item/role_restricted/oldtoolboxclean
	name = "Ancient Toolbox"
	desc = "An iconic toolbox design notorious with Assistants everywhere, this design was especially made to become more robust the more telecrystals it has inside it! Tools and insulated gloves included."
	item = /obj/item/storage/toolbox/mechanical/old/clean
	cost = 2
	restricted_roles = list("Assistant")
	surplus = 0

/datum/uplink_item/role_restricted/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	restricted_roles = list("Clown")
	surplus = 0 //No fun unless you're the clown!

/datum/uplink_item/role_restricted/honker
	name = "Dark H.O.N.K."
	desc = "A clown combat mech equipped with bombanana peel and tearstache grenade launchers, as well as the ubiquitous HoNkER BlAsT 5000."
	item = /obj/mecha/combat/honker/dark/crew/loaded
	cost = 20
	restricted_roles = list("Clown")
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0

/datum/uplink_item/role_restricted/reticence
	name = "Retience Exosuit"
	desc = "A popular product for pantomime performers. For when you need to silence a target a little more... permanently. Comes equipped with advanced cloaking technology, a Quietus carbine, and an RCD."
	item = /obj/mecha/combat/reticence/loaded
	cost = 20
	restricted_roles = list("Mime")
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 0

/datum/uplink_item/role_restricted/arm_medical_gun
	name = "Arm Mounted Medical Beamgun"
	desc = "An arm mounted medical beamgun to heal your best buds (disclaimer: does not come with friends)."
	item = /obj/item/autosurgeon/medibeam
	restricted_roles = list("Medical Doctor", "Chief Medical Officer", "Paramedic", "Mining Medic") //yogs
	cost = 8
	manufacturer = /datum/corporation/traitor/vahlen

/datum/uplink_item/role_restricted/arm_medical_gun/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		// All implants are half off (rounded) and can be as low as one TC.
		cost = max(1, ROUND_UP(cost/2))

/datum/uplink_item/role_restricted/brainwash_disk
	name = "Brainwashing Surgery Program"
	desc = "A disk containing the procedure to perform a brainwashing surgery, allowing you to implant an objective onto a target. \
	Insert into an Operating Console to enable the procedure."
	item = /obj/item/disk/surgery/brainwashing
	restricted_roles = list("Medical Doctor", "Chief Medical Officer", "Roboticist", "Research Director") //yogs
	player_minimum = 28
	cost = 5
	manufacturer = /datum/corporation/traitor/vahlen

/datum/uplink_item/role_restricted/cat_grenade
	name = "Feral Cat Delivery Grenade"
	desc = "The feral cat delivery grenade contains 5 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	item = /obj/item/grenade/spawnergrenade/feral_cats
	cost = 4
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Psychiatrist")///why? Becuase its funny that a person in charge of your mental wellbeing has a cat granade..<---(he cant spell)

/datum/uplink_item/role_restricted/blastcannon
	name = "Blast Cannon"
	desc = "A highly specialized weapon, the Blast Cannon is actually relatively simple. It contains an attachment for a tank transfer valve mounted to an angled pipe specially constructed \
			withstand extreme pressure and temperatures, and has a mechanical trigger for triggering the transfer valve. Essentially, it turns the explosive force of a bomb into a narrow-angle \
			blast wave \"projectile\". Aspiring scientists may find this highly useful, as forcing the pressure shockwave into a narrow angle seems to be able to bypass whatever quirk of physics \
			disallows explosive ranges above a certain distance, allowing for the device to use the theoretical yield of a transfer valve bomb, instead of the factual yield."
	item = /obj/item/gun/blastcannon
	cost = 14							//High cost because of the potential for extreme damage in the hands of a skilled scientist.
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Research Director", "Scientist")

/datum/uplink_item/role_restricted/armoredmechsuit
	name = "Cybersun Mech Pilot's Suit"
	desc = "A black and red stylishly armored mech pilot's suit used by Cybersun's elite mecha pilots. Provides potent protection both inside and outside a mech."
	item = /obj/item/clothing/under/costume/mech_suit/cybersun
	cost = 4
	manufacturer = /datum/corporation/traitor/cybersun
	restricted_roles = list("Research Director", "Scientist", "Roboticist")

/datum/uplink_item/role_restricted/coral_generator
	name = "IA-C01G AORTA 'Coral' Generator"
	desc = "An experimental generator that can be attatched to a mech, provides a massive speedboost when active at the cost of greater power consumption."
	item = /obj/item/mecha_parts/mecha_equipment/coral_generator
	cost = 10
	manufacturer = /datum/corporation/traitor/cybersun
	restricted_roles = list("Research Director", "Scientist", "Roboticist")

/datum/uplink_item/role_restricted/gorillacubes
	name = "Box of Gorilla Cubes"
	desc = "A box with three Waffle Co. brand gorilla cubes. Eat big to get big. \
			Caution: Product may rehydrate when exposed to water."
	item = /obj/item/storage/box/gorillacubes
	cost = 6
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Geneticist", "Chief Medical Officer")

/datum/uplink_item/role_restricted/deadlydonut
	name = "Box of Singulonuts"
	desc = "A box with six Waffle Co. brand Singulonuts. Banned in four sectors for their sheer calorie content. \
			Caution: Product known to the safety board of Nanotrasen to increase risks of stomach cancer and cause instant obesity. \ Disguised as a regular box of regular donuts."
	item = /obj/item/storage/fancy/donut_box/deadly
	cost = 6
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Assistant", "Cook", "Clerk")
	illegal_tech = FALSE

/datum/uplink_item/role_restricted/clown_bomb
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 7
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/spider_injector
	name = "Australicus Slime Mutator"
	desc = "Crikey mate, it's been a wild travel from the Australicus sector but we've managed to get \
			some special spider extract from the giant spiders down there. Use this injector on a gold slime core \
			to create a few of the same type of spiders we found on the planets over there. They're a bit tame until you \
			also give them a bit of sentience though."
	item = /obj/item/reagent_containers/syringe/spider_extract
	cost = 10
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Research Director", "Scientist", "Roboticist")
	include_objectives = list(/datum/objective/hijack, /datum/objective/martyr) //yogs reduces grief potential

/datum/uplink_item/role_restricted/honksword
	name = "Bike Horn Energy Sword"
	desc = "All the features of the original energy sword, with additional fun! Functionally identical to a bike horn when concealed. Activating it produces a loud, distinctive noise."
	item = /obj/item/melee/transforming/energy/sword/bikehorn
	cost = 9 //1tc more than esword as it's a little more stealthy
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/clowncar
	name = "Clown Car"
	desc = "The Clown Car is the ultimate transportation method for any worthy clown! \
			Simply insert your bikehorn and get in, and get ready to have the funniest ride of your life! \
			You can ram any spacemen you come across and stuff them into your car, kidnapping them and locking them inside until \
			someone saves them or they manage to crawl out. Be sure not to ram into any walls or vending machines, as the springloaded seats \
			are very sensitive. Now with our included lube defense mechanism which will protect you against any angry shitcurity! \
			Premium features can be unlocked with a cryptographic sequencer!"
	item = /obj/vehicle/sealed/car/clowncar
	cost = 20
	player_minimum = 25
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/concealed_weapon_bay
	name = "Concealed Weapon Bay"
	desc = "A modification for non-combat mechas that allows them to equip one piece of equipment designed for combat mechs. \
			It also hides the equipped weapon from plain sight. \
			Only one can fit on a mecha."
	item = /obj/item/mecha_parts/concealed_weapon_bay
	cost = 3
	manufacturer = /datum/corporation/traitor/donkco
	restricted_roles = list("Roboticist", "Research Director")

/datum/uplink_item/role_restricted/nuclear_ejection
	name = "Emergency Ejection System"
	desc = "An exosuit modification designed to quickly eject the pilot after the exosuit suffers catastrophic damage. \
			Cybersun Industries is not liable for any injuries suffered during the ejection sequence."
	item = /obj/item/mecha_parts/mecha_equipment/emergency_eject
	cost = 3
	manufacturer = /datum/corporation/traitor/cybersun
	restricted_roles = list("Roboticist", "Research Director")

/datum/uplink_item/role_restricted/haunted_magic_eightball
	name = "Haunted Magic Eightball"
	desc = "Most magic eightballs are toys with dice inside. Although identical in appearance to the harmless toys, this occult device reaches into the spirit world to find its answers. \
			Be warned, that spirits are often capricious or just little assholes. To use, simply speak your question aloud, then begin shaking."
	item = /obj/item/toy/eightball/haunted
	cost = 2
	manufacturer = /datum/corporation/traitor/donkco
	restricted_roles = list("Chaplain","Curator")
	limited_stock = 1 //please don't spam deadchat

/datum/uplink_item/role_restricted/his_grace
	name = "His Grace"
	desc = "An incredibly dangerous weapon recovered from a station overcome by the grey tide. Once activated, He will thirst for blood and must be used to kill to sate that thirst. \
	His Grace grants gradual regeneration and complete stun immunity to His wielder, but be wary: if He gets too hungry, He will become impossible to drop and eventually kill you if not fed. \
	However, if left alone for long enough, He will fall back to slumber. \
	To activate His Grace, simply unlatch Him."
	item = /obj/item/his_grace
	cost = 20
	restricted_roles = list("Chaplain", "Assistant")
	surplus = 0 //This is a hijack item. Do not add this into surplus.

/datum/uplink_item/role_restricted/horror
	name = "Horror-in-a-box"
	desc = "When dissecting the head of a dead Nanotrasen scientist, our surgeons noticed an incredibly peculiar creature inside and managed to extract it into safe containment. \
	Either a failed experiment or otherworldly monster, this creature has been trained to aid whoever wakes it up. If you aren't afraid of it entering your head, it can prove a useful ally. \
	We take no responsibility for your newfound madness and accept no refunds."
	item = /obj/item/horrorspawner
	cost = 14
	surplus = 0
	restricted_roles = list("Curator")
	player_minimum = 20

/datum/uplink_item/role_restricted/explosive_hot_potato
	name = "Exploding Hot Potato"
	desc = "A potato rigged with explosives. On activation, a special mechanism is activated that prevents it from being dropped. \
			The only way to get rid of it if you are holding it is to attack someone else with it, causing it to latch to that person instead."
	item = /obj/item/hot_potato/syndicate
	cost = 12
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 0
	restricted_roles = list("Cook", "Botanist", "Clown", "Mime")

/datum/uplink_item/role_restricted/ez_clean_bundle
	name = "EZ Clean Grenade Bundle"
	desc = "A box with three cleaner grenades using the trademark Waffle Co. formula. Serves as a cleaner and causes acid damage to anyone standing nearby. \
			The acid only affects carbon-based creatures."
	item = /obj/item/storage/box/syndie_kit/ez_clean
	cost = 6
	manufacturer = /datum/corporation/traitor/waffleco
	surplus = 20
	restricted_roles = list("Janitor")

/datum/uplink_item/role_restricted/mimery
	name = "Guide to Advanced Mimery Series"
	desc = "The classical two part series on how to further hone your mime skills. Upon studying the series, the user should be able to make 3x1 invisible walls, and shoot bullets out of their fingers. \
			Obviously only works for Mimes."
	cost = 12
	item = /obj/item/storage/box/syndie_kit/mimery
	restricted_roles = list("Mime")
	surplus = 0

/datum/uplink_item/role_restricted/pressure_mod
	name = "Kinetic Accelerator Pressure Mod"
	desc = "A modification kit which allows Kinetic Accelerators to do greatly increased damage while indoors. \
			Occupies 35% mod capacity."
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 5 //you need two for full damage, so total of 10 for maximum damage
	manufacturer = /datum/corporation/traitor/donkco // Unless you're donk co, then it's 8
	limited_stock = 2 //you can't use more than two!
	restricted_roles = list("Shaft Miner", "Mining Medic") //yogs

/datum/uplink_item/role_restricted/magillitis_serum
	name = "Magillitis Serum Autoinjector"
	desc = "A single-use autoinjector which contains an experimental serum that causes rapid muscular growth in Hominidae. \
			Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	item = /obj/item/reagent_containers/autoinjector/magillitis
	cost = 15
	manufacturer = /datum/corporation/traitor/waffleco
	restricted_roles = list("Geneticist", "Chief Medical Officer")

/datum/uplink_item/role_restricted/modified_syringe_gun
	name = "Modified Syringe Gun"
	desc = "A syringe gun that fires DNA injectors instead of normal syringes."
	item = /obj/item/gun/syringe/dna
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 14
	restricted_roles = list("Geneticist", "Chief Medical Officer")

/datum/uplink_item/role_restricted/chemical_gun
	name = "Rapid Syringe Gun"
	desc = "A modified syringe gun with a rotating drum, capable of holding and quickly firing six syringes."
	item = /obj/item/gun/syringe/rapidsyringe
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	restricted_roles = list("Chemist", "Chief Medical Officer", "Virologist")

/datum/uplink_item/role_restricted/chemical_art
	name = "Psychotic Brawl Notes"
	desc = "Notes taken from an experienced user of bath salts, written in their own blood. Reading it will \
			greatly randomize the effectiveness of your punches. Best when combined with several narcotics."
	item = /obj/item/book/granter/martial/psychotic_brawling
	manufacturer = /datum/corporation/traitor/vahlen
	cost = 8
	restricted_roles = list("Chemist", "Chief Medical Officer", "Psychiatrist")

/datum/uplink_item/role_restricted/reverse_bear_trap
	name = "Reverse Bear Trap"
	desc = "An ingenious execution device worn on (or forced onto) the head. Arming it starts a 1-minute kitchen timer mounted on the bear trap. When it goes off, the trap's jaws will \
	violently open, instantly killing anyone wearing it by tearing their jaws in half. To arm, attack someone with it while they're not wearing headgear, and you will force it onto their \
	head after three seconds uninterrupted."
	cost = 5
	item = /obj/item/reverse_bear_trap
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/reverse_revolver
	name = "Reverse Revolver"
	desc = "A revolver that always fires at its user. \"Accidentally\" drop your weapon, then watch as the greedy corporate pigs blow their own brains all over the wall. \
	The revolver itself is actually real. Only clumsy people, and clowns, can fire it normally. Comes in a box of hugs. Honk."
	cost = 8
	manufacturer = /datum/corporation/traitor/waffleco
	item = /obj/item/storage/box/hug/reverse_revolver
	restricted_roles = list("Clown")

/datum/uplink_item/role_restricted/hierophant_antenna
	name = "Hierophant's Antenna"
	desc = "Amplifies the reception signals of the hierophant staff, allows the herald's power to reach the station!"
	cost = 7
	manufacturer = /datum/corporation/traitor/cybersun
	item = /obj/item/hierophant_antenna
	restricted_roles = list("Shaft Miner")

/datum/uplink_item/role_restricted/mining_charge_hacker
	name = "Mining Charge Hacker"
	desc = "Looks and functions like an advanced mining scanner, but allows mining charges to be placed anywhere and destroy more than rocks. \
	Use it on a mining charge to override its safeties. Reduces explosive power of mining charges due to the modification of their internals."
	cost = 4
	manufacturer = /datum/corporation/traitor/cybersun
	item = /obj/item/t_scanner/adv_mining_scanner/syndicate
	restricted_roles = list("Shaft Miner","Quartermaster","Mining Medic")

/datum/uplink_item/role_restricted/letterbomb
	name = "Explosive letter"
	desc = "A letter with a pipe bomb in it, select the recipient and send it on it's merry way."
	item = /obj/item/mail/explosive
	cost = 1
	restricted_roles = list("Quartermaster","Cargo Technician")

/datum/uplink_item/role_restricted/energy_fire_axe
	name = "Energy Fire Axe"
	desc = "A terrifying axe with a blade of pure energy, able to tear down structures with ease. \
			Easier to store than a standard fire axe while inactive."
	item = /obj/item/fireaxe/energy
	cost = 10
	restricted_roles = list("Station Engineer","Atmospheric Technician","Network Admin","Chief Engineer")

/datum/uplink_item/role_restricted/syndie_mmi
	name = "Syndicate MMI"
	desc = "A syndicate developed man-machine-interface which will mindslave any brain inserted into it, for as long as it's in. Cyborgs made with this MMI will be permanently slaved to you through a Zeroth law but otherwise function normally. Safeguards are in place to maintain the Zeroth law regardless of law changes."
	item = /obj/item/mmi/syndie
	cost = 3
	restricted_roles = list("Roboticist", "Research Director")

/datum/uplink_item/role_restricted/cmag
	name = "Jestographic Sequencer"
	desc = "The jestographic sequencer, also known as a cmag, is a small card that inverts the access on any door it's used on. Perfect for locking command out of their own departments. Honk!"
	item = /obj/item/card/cmag
	cost = 4 // Not as "destructive" as the emag. In addition, less features than the normal emag. Increase price once more impactful features are added.
	restricted_roles = list("Clown")

// Pointless
/datum/uplink_item/badass
	category = UPLINK_CATEGORY_BADASS
	surplus = 0

/datum/uplink_item/badass/costumes/obvious_chameleon
	name = "Broken Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Please note that this kit did NOT pass quality control."
	item = /obj/item/storage/box/syndie_kit/chameleon/broken

/datum/uplink_item/badass/costumes
	surplus = 0
	include_antags = list(ROLE_OPERATIVE, ROLE_CLOWNOP)
	cost = 4
	cant_discount = TRUE

/datum/uplink_item/badass/costumes/centcom_official
	name = "CentCom Official Costume"
	desc = "Ask the crew to \"inspect\" their nuclear disk and weapons system, and then when they decline, pull out a fully automatic rifle and gun down the Captain. \
			Radio headset does not include encryption key. No gun included."
	item = /obj/item/storage/box/syndie_kit/centcom_costume

/datum/uplink_item/badass/costumes/clown
	name = "Clown Costume"
	desc = "Nothing is more terrifying than clowns with fully automatic weaponry."
	item = /obj/item/storage/backpack/duffelbag/clown/syndie

/datum/uplink_item/badass/crafting_weapons
	name = "Makeshift Weapons"
	desc = "A one use book that grants access to a number of secret crafting recipes once it has been read."
	item = /obj/item/book/granter/crafting_recipe/weapons
	cost = 2
	cant_discount = TRUE
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiefedora
	name = "Syndicate Fedora"
	desc = "This Syndicate Fedora of micro-woven adamantium silk is sure to prove your style! Layered with protective fibers! \
			The fedora can be activated to extend sharp blades out from its rim, functioning as a saw-like melee weapon that can be thrown for immense damage. Upon successfully hitting an object, the fedora will boomerang back to your hands."
	item = /obj/item/clothing/head/det_hat/evil
	cost = 6

/datum/uplink_item/badass/balloon
	name = "Syndicate Balloon"
	desc = "For showing that you are THE BOSS: A useless red balloon with the Syndicate logo on it. \
			Can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 20
	cant_discount = TRUE
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 5000 space credits. Useful for bribing personnel, or purchasing goods \
			and services at lucrative prices. The briefcase also feels a little heavier to hold; it has been \
			manufactured to pack a little bit more of a punch if your client needs some convincing."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 1
	restricted = TRUE

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a thin and sharp metal edge, \
			making them slightly more robust than a normal deck of cards. \
			You can also play card games with them or leave them on your victims."
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco
	surplus = 40
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2
	manufacturer = /datum/corporation/traitor/donkco
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiebears
	name = "Omnizine Gummy Bears"
	desc = "Omnizine infused gummy bears. Grape flavor. Chew throughly!"
	item = /obj/item/storage/pill_bottle/gummies/omnizine
	cost = 1
	manufacturer = /datum/corporation/traitor/vahlen
	surplus_nullcrates = 0 //not because its too strong, but rather because it shouldn't be polluting the pool for other items
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiebears/sleepy
	name = "Sleepy Gummy Bears"
	desc = "Sodium Thiopental infused gummy bears. Berry flavor."
	item = /obj/item/storage/pill_bottle/gummies/sleepy
	cost = 2
	manufacturer = /datum/corporation/traitor/vahlen
	surplus_nullcrates = 1 //rare. I feel sorry for the poor bastard that gets scammed by these
	illegal_tech = FALSE

/datum/uplink_item/badass/syndietape
	name = "Guerrilla Tape"
	desc = "New from Donk Co! Stick it to the man with this ultra-adhesive roll of tape! Grabs on tight, and holds on tight, using our patented adhesive formula. Ten times stronger than our leading competitors!"
	item = /obj/item/stack/tape/guerrilla
	cost = 1
	manufacturer = /datum/corporation/traitor/donkco

/datum/uplink_item/badass/antagcape
	name = "Red Syndicate Cape"
	desc = "A cape to show off your small-time thuggery."
	item = /obj/item/clothing/neck/skillcape/antag
	cost = 10
	illegal_tech = FALSE

/datum/uplink_item/badass/antagcapetrimmed
	name = "Bloody Shiny Syndicate Cape"
	desc = "A cape to show off your grand villainous deeds."
	item = /obj/item/clothing/neck/skillcape/trimmed/antag
	cost = 20
	illegal_tech = FALSE

/datum/uplink_item/badass/syndistamp
	name = "Syndicate Stamp"
	desc = "Even evil needs to do paperwork."
	item = /obj/item/stamp/syndiround
	cost = 1
	illegal_tech = FALSE

/// NT Uplink items
/datum/uplink_item/nt
	surplus = 0 // Chance of being included in the surplus crate.
	include_uplinks = list("NTUplink")
	illegal_tech = FALSE
	cant_discount = TRUE //no i dont want amber erts with tasers thanks
	var/required_ert_uplink = null //Do we need a specific uplink? Defaults to universal.

/datum/uplink_item/nt/energy_weps
	category = UPLINK_CATEGORY_ENERGY

/datum/uplink_item/nt/energy_weps/egun
	name = "Energy Gun"
	desc = "A standard energy gun with disable and laser modes equipped."
	item = /obj/item/gun/energy/e_gun
	cost = 3
	limited_stock = 2 //One for you and a friend, no infinite guns though
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/energy_weps/tac_egun
	name = "Tactical Energy Gun"
	desc = "A military-grade augmented energy gun, fitted with a tasing mode."
	item = /obj/item/gun/energy/e_gun/stun
	cost = 20
	limited_stock = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/energy_weps/mini_egun
	name = "Miniature Energy Gun"
	desc = "A smaller model of the standard energy gun that holds much less charge."
	item = /obj/item/gun/energy/e_gun/mini
	cost = 1
	limited_stock = 1

/datum/uplink_item/nt/energy_weps/laserrifle
	name = "Laser Rifle"
	desc = "An abnormality in energy weaponry. Chambers a laser magazine which can be recharged externally."
	item = /obj/item/gun/ballistic/automatic/laser
	cost = 8
	limited_stock = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/energy_weps/m1911
	name = "Spur"
	desc = "A legendary slowly self-charging pistol with massive recoil that deals more damage the more charge it has."
	item = /obj/item/gun/energy/polarstar/spur
	cost = 10
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/energy_weps/pulsecarbine
	name = "Pulse Carbine"
	desc = "A severely lethal energy carbine that fires additionaly fires pulse rounds. Must be recharged instead of reloaded."
	item = /obj/item/gun/energy/pulse/carbine
	cost = 45
	required_ert_uplink = NT_ERT_TROOPER //Medics and engies can buy pulse pistols

/datum/uplink_item/nt/energy_weps/pulsepistol
	name = "Pulse Pistol"
	desc = "A severely lethal but compact version of the Pulse Carbine design. Holds significantly less charge. \
			Must be recharged instead of reloaded."
	item = /obj/item/gun/energy/pulse/pistol
	cost = 35

/datum/uplink_item/nt/energy_weps/hardlightbow
	name = "HL-P1 Multipurpose Combat Bow"
	desc = "An expensive hardlight bow designed by Nanotrasen and often sold to the SIC's espionage branch. Capable of firing disabler, energy, pulse, and taser bolts."
	item = /obj/item/gun/ballistic/bow/energy/ert
	cost = 75 //Doesn't need to be recharged but also fires once every now and then instead of being spammable

/datum/uplink_item/nt/energy_weps/pulsedestroyer
	name = "Pulse Destroyer"
	desc = "LOG-ENTRY ERROR. DEATH. DEATH. DEATH. KILL. DESTROY. NONE LEFT ALIVE."
	item = /obj/item/gun/energy/pulse/destroyer
	cost = 100

/datum/uplink_item/nt/ball_weps
	category = UPLINK_CATEGORY_BALLISTIC
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/ball_weps/boarder
	name = "NT-ARG 'Boarder' Rifle"
	desc = "A heavy-damage 3-round burst assault rifle. Chambered in 5.56mm."
	item = /obj/item/gun/ballistic/automatic/ar
	cost = 18
	limited_stock = 1

/datum/uplink_item/nt/ball_weps/lwtdmr
	name = "LWT-650 DMR"
	desc = "A designated marksman rifle that deals hefty damage. Chambered in .308."
	item = /obj/item/gun/ballistic/automatic/lwt650
	cost = 10
	limited_stock = 1

/datum/uplink_item/nt/ball_weps/saber
	name = "NT-SABR 'Saber' SMG"
	desc = "A low-damage 3-round burst SMG. Chambered in 9mm."
	item = /obj/item/gun/ballistic/automatic/proto/unrestricted
	cost = 7

/datum/uplink_item/nt/ball_weps/wtcarbine
	name = "WT-550 Automatic Carbine"
	desc = "A classic 2-round burst carbine with a number of ammo options. Chambered in 4.6x30mm."
	item = /obj/item/gun/ballistic/automatic/wt550
	cost = 5
	required_ert_uplink = null

/datum/uplink_item/nt/ball_weps/m1911
	name = "M1911"
	desc = "A classic .45 sidearm with a small magazine capacity."
	item = /obj/item/gun/ballistic/automatic/pistol/m1911
	cost = 3
	required_ert_uplink = null

/datum/uplink_item/nt/ball_weps/tommygun
	name = "Thompson SMG"
	desc = "An archaic but incredibly effective high-capacity 4-round burst SMG. Wildly inaccurate. Can't fit in backpacks."
	item = /obj/item/gun/ballistic/automatic/tommygun
	cost = 9
	limited_stock = 2 // SAY HELLO TO MY LITTLE FRIEND

/datum/uplink_item/nt/ammo
	category = UPLINK_CATEGORY_AMMO
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/ammo/recharger
	name = "Weapon Recharger"
	desc = "Standard issue energy weapon recharger. Must be anchored in an APC-powered area."
	item = /obj/machinery/recharger
	cost = 2
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/ammo/powerpack
	name = "Power Pack"
	desc = "An additional 20-round laser magazine; suitable for use with the laser rifle."
	item = /obj/item/ammo_box/magazine/recharge
	cost = 5

/datum/uplink_item/nt/ammo/arg
	name = "5.56mm Magazine"
	desc = "An additional 30-round 5.56mm magazine; suitable for use with the NT-ARG."
	item = /obj/item/ammo_box/magazine/r556
	cost = 4

/datum/uplink_item/nt/ammo/arg/ap
	name = "5.56 AP Magazine"
	desc = "An alternative 30-round 5.56 magazine loaded with armor-piercing rounds; suitable for use with the NT-ARG."
	item = /obj/item/ammo_box/magazine/r556/ap
	cost = 6

/datum/uplink_item/nt/ammo/arg/inc
	name = "5.56 Incendiary Magazine"
	desc = "An alternative 30-round 5.56 magazine loaded with incendiary rounds; suitable for use with the NT-ARG."
	item = /obj/item/ammo_box/magazine/r556/inc

/datum/uplink_item/nt/ammo/arg/rubber
	name = "5.56 Rubber Magazine"
	desc = "An alternative 30-round 5.56 magazine loaded with less-lethal rounds; suitable for use with the NT-ARG."
	item = /obj/item/ammo_box/magazine/r556/rubber

/datum/uplink_item/nt/ammo/lwt
	name = ".308 Magazine"
	desc = "An additional 15-round .308 magazine; suitable for use with the LWT-650."
	item = /obj/item/ammo_box/magazine/m308
	cost = 2

/datum/uplink_item/nt/ammo/lwt/penetrator
	name = ".308 Penetrator Magazine"
	desc = "An alternative 15-round .308 penetrator magazine; suitable for use with the LWT-650. \
			These rounds do less damage but puncture bodies and body armor alike."
	item = /obj/item/ammo_box/magazine/m308/pen
	cost = 4

/datum/uplink_item/nt/ammo/lwt/laser
	name = ".308 Heavy Laser Magazine"
	desc = "An alternative 15-round .308 heavy laser magazine; suitable for use with the LWT-650. \
			These rounds fire heavy lasers which do much more than a standard laser. The magazine is rechargable like the laser rifle's."
	item = /obj/item/ammo_box/magazine/m308/laser
	cost = 7

/datum/uplink_item/nt/ammo/tommyammo
	name = ".45 Drum Magazine"
	desc = "An additional 50-round .45 drum magazine; suitable for use with the Thompson SMG."
	item = /obj/item/ammo_box/magazine/tommygunm45
	cost = 4

/datum/uplink_item/nt/ammo/m45ammo
	name = ".45 Handgun Magazine"
	desc = "An additional 8-round .45 magazine; suitable for use with the M1911."
	item = /obj/item/ammo_box/magazine/m45
	cost = 2
	required_ert_uplink = null

/datum/uplink_item/nt/ammo/saberammo
	name = "9mm Magazine"
	desc = "An additional 21-round 9mm magazine; suitable for use with the Saber SMG."
	item = /obj/item/ammo_box/magazine/smgm9mm
	cost = 1

/datum/uplink_item/nt/ammo/saberammo/ap
	name = "9mm AP Magazine"
	desc = "An additional 21-round 9mm magazine loaded with armor-piercing rounds; suitable for use with the Saber SMG."
	item = /obj/item/ammo_box/magazine/smgm9mm/ap
	cost = 2

/datum/uplink_item/nt/ammo/saberammo/inc
	name = "9mm Incendiary Magazine"
	desc = "An additional 21-round 9mm magazine loaded with incendiary rounds; suitable for use with the Saber SMG."
	item = /obj/item/ammo_box/magazine/smgm9mm/inc

/datum/uplink_item/nt/ammo/wt
	name = "4.6x30mm Magazine"
	desc = "An additional 20-round 4.6x30mm magazine; suitable for use with the WT-550."
	item = /obj/item/ammo_box/magazine/wt550m9
	cost = 2
	required_ert_uplink = null

/datum/uplink_item/nt/ammo/wt/ap
	name = "4.6x30mm AP Magazine"
	desc = "An additional 20-round 4.6x30mm magazine loaded with armor-piercing rounds; suitable for use with the WT-550."
	item = /obj/item/ammo_box/magazine/wt550m9/wtap
	cost = 4

/datum/uplink_item/nt/ammo/wt/ic
	name = "4.6x30mm Incendiary Magazine"
	desc = "An additional 20-round 4.6x30mm magazine loaded with incendiary rounds; suitable for use with the WT-550."
	item = /obj/item/ammo_box/magazine/wt550m9/wtic
	cost = 4

/datum/uplink_item/nt/ammo/wt/r
	name = "4.6x30mm Rubber Shot Magazine"
	desc = "An additional 20-round 4.6x30mm magazine loaded with less-lethal rounds; suitable for use with the WT-550."
	item = /obj/item/ammo_box/magazine/wt550m9/wtr
	cost = 1

/datum/uplink_item/nt/mech
	category = UPLINK_CATEGORY_EXOSUITS
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/mech/marauder
	name = "Marauder exosuit"
	desc = "A heavy-duty exosuit for when the going gets tough. Armed with three smoke bombs, and capable of mounting four pieces of equipment."
	item = /obj/mecha/combat/marauder
	cost = 12

/datum/uplink_item/nt/mech/seraph
	name = "Seraph exosuit"
	desc = "An ultra-heavy exosuit designed for destroying armies. Faster, tougher, and stronger than it's Marauder cousin."
	item = /obj/mecha/combat/marauder/seraph/unloaded
	cost = 30

/datum/uplink_item/nt/mech/laser
	name = "CH-PS Laser"
	desc = "A mounted laser cannon. Fires standard lasers."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	cost = 2

/datum/uplink_item/nt/mech/hades
	name = "FNX-99 Carbine"
	desc = "A mounted incendiary cannon. Fires bullets that do little damage, but light targets on fire."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	cost = 4

/datum/uplink_item/nt/mech/scattershot
	name = "LBX AC 10"
	desc = "A mounted shotgun. Fires a larger variant of buckshot, making it devastating at close range."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	cost = 4

/datum/uplink_item/nt/mech/lmg
	name = "Ultra AC 2"
	desc = "A mounted machine gun, fires in three round bursts."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	cost = 4

/datum/uplink_item/nt/mech/missile_launcher
	name = "SRM-8"
	desc = "A mounted missile rack."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	cost = 4

/datum/uplink_item/nt/mech/pulse
	name = "eZ-13"
	desc = "A mounted heavy pulse cannon capable of firing heavy pulses, which can destroy multiple walls at once as well as decimating soft targets."
	item = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	cost = 10

/datum/uplink_item/nt/mech/droid
	name = "Repair droid"
	desc = "A repair droid that will patch up most damage to a mech. Consumes a lot of power in the process."
	item = /obj/item/mecha_parts/mecha_equipment/repair_droid
	cost = 2

/datum/uplink_item/nt/mech/tesla
	name = "Tesla relay"
	desc = "A remote, passive recharger for mechs. Very, very slow."
	item = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	cost = 1

/datum/uplink_item/nt/mech/hadesammo
	name = "FNX-99 Ammunition"
	desc = "An ammo box for the FNX-99 carbine."
	item = /obj/item/mecha_ammo/incendiary
	cost = 1

/datum/uplink_item/nt/mech/scattershotammo
	name = "LBX AC 10 Ammunition"
	desc = "An ammo box for the LBX AC 10."
	item = /obj/item/mecha_ammo/scattershot
	cost = 1

/datum/uplink_item/nt/mech/ultrammo
	name = "Ultra AC 2 Ammunition"
	desc = "An ammo box for the Ultra AC 2"
	item = /obj/item/mecha_ammo/lmg
	cost = 1

/datum/uplink_item/nt/mech/missiles
	name = "SRM-8 Missiles"
	desc = "Additional missiles for the SRM-8 missile launcher."
	item = /obj/item/mecha_ammo/missiles_he
	cost = 1

/datum/uplink_item/nt/cqc
	category = UPLINK_CATEGORY_CQC

/datum/uplink_item/nt/cqc/esword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive."
	item = /obj/item/melee/transforming/energy/sword/saber
	cost = 8
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/eshield
	name = "Energy Shield"
	desc = "A shield that blocks all energy projectiles but is useless against physical attacks."
	item = /obj/item/shield/energy
	cost = 16
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/ntmantisblade
	name = "H.E.P.H.A.E.S.T.U.S. Mantis Blades"
	desc = "A pair of retractable arm-blade implants. Activating both will let you double-attack."
	item = /obj/item/storage/briefcase/nt_mantis
	cost = 14
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/sblade
	name = "Switchblade"
	desc = "A less flashy but surprisingly robust pocket knife."
	item = /obj/item/switchblade
	cost = 1

/datum/uplink_item/nt/cqc/cqc
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing."
	item = /obj/item/book/granter/martial/cqc
	cost = 13
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/teleshield
	name = "Telescopic Shield"
	desc = "A foldable shield that blocks attacks when active but can break."
	item = /obj/item/shield/riot/tele
	cost = 3
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/stunbaton
	name = "Stun Baton"
	desc = "A robust charged baton that will swiftly take down most criminals."
	item = /obj/item/melee/baton/loaded
	cost = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/cqc/telebaton
	name = "Telescopic Baton"
	desc = "A foldable baton that doesn't run on charge. Takes more hits to down, but swings faster."
	item = /obj/item/melee/classic_baton/telescopic
	cost = 1 //Engies and medics can buy these, like normal ERTs!

/datum/uplink_item/nt/cqc/flash
	name = "Flash"
	desc = "A bright flashing device that can disable silicons and blind humans."
	item = /obj/item/assembly/flash
	cost = 1

/datum/uplink_item/nt/support
	category = UPLINK_CATEGORY_NT_SUPPORT

/datum/uplink_item/nt/support/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, disrupt equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/c4
	cost = 1
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/x4
	name = "Composition X-4"
	desc = "A variety of plastic explosive with a stronger explosive charge. It is both safer to use and is capable of breaching even the most secure areas."
	item = /obj/item/grenade/plastic/x4
	cost = 3
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/medkit
	name = "Medic Kit"
	desc = "A station-standard medical kit. Stocked with sutures, regenerative mesh, medical gauze, \
			a health analyzer, and an epinephrine pen."
	item = /obj/item/storage/firstaid/regular
	cost = 1

/datum/uplink_item/nt/support/advmedkit
	name = "Tactical Combat Medic Kit"
	desc = "Included is a combat stimulant injector \
			for rapid healing, a medical night vision HUD for quick identification of injured personnel, \
			and other supplies helpful for a field medic."
	item = /obj/item/storage/firstaid/tactical
	cost = 4
	required_ert_uplink = NT_ERT_MEDIC //Only real medics get the good stuff

/datum/uplink_item/nt/support/healermech
	name = "Healer Nanite Serum"
	desc = "An auto-injector full of reverse-engineered syndicate healing nanites. These will quickly repair most damage on a patient, pre-filled with fifteen doses."
	item = /obj/item/reagent_containers/autoinjector/combat/healermech
	cost = 8
	required_ert_uplink = NT_ERT_MEDIC

/datum/uplink_item/nt/support/resurrectormech
	name = "Resurrector Nanite Serum"
	desc = "A single-use superdose of nanites capable of fully repairing a body, including replacing lost organs and limbs and restoring blood volume. Will do nothing to a living person."
	item = /obj/item/reagent_containers/autoinjector/medipen/resurrector
	cost = 8
	required_ert_uplink = NT_ERT_MEDIC

/datum/uplink_item/nt/support/medbeam
	name = "Medbeam Gun"
	desc = "A wonder of Nanotrasen engineering, the Medbeam gun, or Medi-Gun enables a medic to keep his fellow \
			officers in the fight, even while under fire. Don't cross the streams!"
	item = /obj/item/gun/medbeam
	cost = 7
	limited_stock = 1

/datum/uplink_item/nt/support/toolbelt
	name = "Full Toolbelt"
	desc = "Comes pre-stocked with every engineering tool you'll ever need."
	item = /obj/item/storage/belt/utility/full/engi
	cost = 1
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/advanced_toolbelt
	name = "Advanced toolbelt"
	desc = "A toolbelt filled with advanced tools, for when you need to work quickly."
	item = /obj/item/storage/belt/utility/chief/full/ert
	cost = 5
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/rcd
	name = "Rapid Construction Device"
	desc = "Standard RCD that can repair or destroy structures very quickly. Holds up to 160 matter units."
	item = /obj/item/construction/rcd/loaded
	cost = 2
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/combatrcd
	name = "Industrial RCD"
	desc = "Heavy combat RCD that holds up to 500 matter units."
	item = /obj/item/construction/rcd/combat
	cost = 5
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/advancedrcd
	name = "Advanced RCD"
	desc = "An RCD with improved capacity, although slightly less than an industrial RCD. However, it can construct and deconstruct from range."
	item = /obj/item/construction/rcd/arcd
	cost = 10
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/rcdammo
	name = "Compressed Matter Cartridge"
	desc = "Highly compressed matter that restores 160 matter units on an RCD."
	item = /obj/item/rcd_ammo
	cost = 1
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/support/foamnades
	name = "Box of Smart Metal Foam Grenades"
	desc = "A box of 7 smart metal foam grenades to patch hull breaches with."
	item = /obj/item/storage/box/smart_metal_foam
	cost = 1
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/hardsuit
	category = UPLINK_CATEGORY_HARDSUITS

/datum/uplink_item/nt/hardsuit/armor
	name = "Armor Vest"
	desc = "A standard issue security armor vest."
	item = /obj/item/clothing/suit/armor/vest
	cost = 1

/datum/uplink_item/nt/hardsuit/helmet
	name = "Helmet"
	desc = "A standard issue security helmet. Can have a seclite attached."
	item = /obj/item/clothing/head/helmet
	cost = 1

/datum/uplink_item/nt/hardsuit/bulletvest
	name = "Bulletproof Armor Vest"
	desc = "An armor vest that is extremely robust against ballistics but weak to everything else."
	item = /obj/item/clothing/suit/armor/bulletproof
	cost = 1

/datum/uplink_item/nt/hardsuit/bullethelmet
	name = "Bulletproof Helmet"
	desc = "A helmet that is extremely robust against ballistics but weak to everything else."
	item = /obj/item/clothing/head/helmet
	cost = 1

/datum/uplink_item/nt/hardsuit/riotvest
	name = "Riot Suit"
	desc = "A bulky suit that protects you against melee attacks but not much else."
	item = /obj/item/clothing/suit/armor/riot
	cost = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/hardsuit/riothelmet
	name = "Riot Helmet"
	desc = "A helmet that protects you against melee attacks but not much else."
	item = /obj/item/clothing/head/helmet/riot
	cost = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/hardsuit/cmd
	name = "ERT Commander Hardsuit"
	desc = "Show them who's boss."
	item = /obj/item/clothing/suit/space/hardsuit/ert
	cost = 5
	restricted_roles = list("Emergency Response Commander")

/datum/uplink_item/nt/hardsuit/sec
	name = "ERT Security Hardsuit"
	desc = "Make them fear the long arm of law."
	item = /obj/item/clothing/suit/space/hardsuit/ert/sec
	cost = 5
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/hardsuit/engi
	name = "ERT Engineering Hardsuit"
	desc = "HOW DID YOU DELAMINATE THE SM 5 MINUTES IN?"
	item = /obj/item/clothing/suit/space/hardsuit/ert/engi
	cost = 5
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/hardsuit/med
	name = "ERT Medical Hardsuit"
	desc = "Dying is illegal."
	item = /obj/item/clothing/suit/space/hardsuit/ert/med
	cost = 5
	required_ert_uplink = NT_ERT_MEDIC

/datum/uplink_item/nt/hardsuit/ds
	name = "MK.III SWAT Suit"
	desc = "A prototype hardsuit. Incredibly robust."
	item = /obj/item/clothing/suit/space/hardsuit/deathsquad
	cost = 100
	cant_discount = TRUE

/datum/uplink_item/nt/hardsuit/dsshield
	name = "MK.III Shielded SWAT Suit"
	desc = "A prototype hardsuit with shielding protection. Incredibly robust."
	item = /obj/item/clothing/suit/space/hardsuit/shielded/swat
	cost = 150
	cant_discount = TRUE

/datum/uplink_item/nt/gear
	category = UPLINK_CATEGORY_OTHER

/datum/uplink_item/nt/gear/secbelt
	name = "Stocked Security Belt"
	desc = "Standard issue security gear, all in a stylish belt."
	item = /obj/item/storage/belt/security/full
	cost = 2
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/gear/flashbangs
	name = "Box of Flashbangs"
	desc = "A box of 7 flashbangs to make the crew hate you."
	item = /obj/item/storage/box/flashbangs
	cost = 2
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/gear/handcuffs
	name = "Box of Handcuffs"
	desc = "A box of 7 pairs of handcuffs to keep prisoners in line."
	item = /obj/item/storage/box/handcuffs
	cost = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/gear/bowman
	name = "Bowman Headset"
	desc = "A headset specially crafted to protect your ears from any damage, including flashbangs."
	item = /obj/item/radio/headset/headset_cent/bowman
	cost = 1

/datum/uplink_item/nt/gear/sechud
	name = "Security HUDglasses"
	desc = "A pair of sunglasses fitted with a security HUD."
	item = /obj/item/clothing/glasses/hud/security/sunglasses
	cost = 1
	required_ert_uplink = NT_ERT_TROOPER

/datum/uplink_item/nt/gear/medhud
	name = "Medical HUDglasses"
	desc = "A pair of sunglasses fitted with a medical HUD."
	item = /obj/item/clothing/glasses/hud/health/sunglasses
	cost = 1
	required_ert_uplink = NT_ERT_MEDIC

/datum/uplink_item/nt/gear/mesonhud
	name = "Meson Sunglasses"
	desc = "A pair of sunglasses fitted with meson technology."
	item = /obj/item/clothing/glasses/meson/sunglasses
	cost = 1
	required_ert_uplink = NT_ERT_ENGINEER

/datum/uplink_item/nt/gear/thermalhud
	name = "Optical Thermal Scanner"
	desc = "A pair of goggles that provide thermal scanning vision through walls."
	item = /obj/item/clothing/glasses/thermal
	cost = 4

/datum/uplink_item/nt/gear/dsmask
	name = "MK.II SWAT mask"
	desc = "A strange mask that encrypts your voice so that only others wearing the mask can understand you, \
			but you won't be able to understand anyone who isn't wearing the mask. \
			Why would anyone spend this much on a mask?"
	item = /obj/item/clothing/mask/gas/sechailer/swat/encrypted
	cost = 10

/datum/uplink_item/nt/gear/ntstamp
	name = "CentCom Official Stamp"
	desc = "To let them know you're the real deal."
	item = /obj/item/stamp/cent
	cost = 1

/datum/uplink_item/nt/gear/ntposters
	name = "Box of Posters"
	desc = "A box of Nanotrasen-approved posters to boost crew morale."
	item = /obj/item/storage/box/official_posters
	cost = 1

/datum/uplink_item/nt/gear/syndiebears
	name = "Omnizine Gummy Bears"
	desc = "Omnizine infused gummy bears. Grape flavor. Chew throughly!"
	item = /obj/item/storage/pill_bottle/gummies/omnizine
	cost = 1

