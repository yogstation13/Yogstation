GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))

/proc/get_uplink_items(datum/game_mode/gamemode = null, allow_sales = FALSE, allow_restricted = TRUE, uplink_type = "Uplink")
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(!I.item)
			continue
		if(I.include_uplinks.len && !(uplink_type in I.include_uplinks))
			continue
		if(I.include_modes.len)
			if(!gamemode && SSticker.mode && !(SSticker.mode.type in I.include_modes))
				continue
			if(gamemode && !(gamemode in I.include_modes))
				continue
		if(I.exclude_modes.len)
			if(!gamemode && SSticker.mode && (SSticker.mode.type in I.exclude_modes))
				continue
			if(gamemode && (gamemode in I.exclude_modes))
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
		if (gamemode == /datum/game_mode/nuclear) 					// uplink code kind of needs a redesign
			nuclear_team = locate() in GLOB.antagonist_teams	// the team discounts could be a in a GLOB with this design but it would make sense for them to be team specific...
		if (!nuclear_team)
			create_uplink_sales(2, "Discounted Gear", 1, sale_items, filtered_uplink_items)
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
	var/list/include_modes = list() // Game modes to allow this item in.
	var/list/exclude_modes = list() // Game modes to disallow this item from.
	var/list/restricted_roles = list() //If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/player_minimum //The minimum crew size needed for this item to be added to uplinks.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	var/restricted = FALSE // Adds restrictions for VR/Events
	var/list/restricted_species //Limits items to a specific species. Hopefully.
	var/illegal_tech = TRUE // Can this item be deconstructed to unlock certain techweb research nodes?
	/// the manufacturer of the item. Gives up to a 20% discount if you're from that corporation
	var/datum/corporation/manufacturer

/datum/uplink_item/proc/get_discount()
	return pick(4;0.9,2;0.8,1;0.75)

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

/datum/uplink_item/bundles_TC/surplus
	name = "Syndicate Surplus Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 50 TC."
	item = /obj/structure/closet/crate
	cost = 20
	player_minimum = 25
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops, /datum/game_mode/infiltration) // yogs: infiltration
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
	var/list/uplink_items = get_uplink_items(SSticker && SSticker.mode? SSticker.mode : null, FALSE)
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

/datum/uplink_item/dangerous
	category = "Conspicuous Weapons"

/datum/uplink_item/dangerous/combatknife
	name = "Combat Knife"
	desc = "A sharp, well maintained, and deadly combat knife from the old world. Slices through bone and flesh with ease."
	item = /obj/item/kitchen/knife/combat
	cost = 5

/datum/uplink_item/dangerous/crossbow
	name = "Rebar Crossbow"
	desc = "A heated rebar crossbow. Pretty good for being jury rigged, it has accurate and high damage single shots, with ammo you can hand craft."
	item = /obj/item/gun/ballistic/bow/crossbow/rebar
	cost = 7

/datum/uplink_item/dangerous/pistol
	name = "USP Match"
	desc = "A common 9mm pistol, easy to conceal and use."
	item = /obj/item/gun/ballistic/automatic/pistol/usp
	cost = 8

/datum/uplink_item/dangerous/smg
	name = "MP7 SMG"
	desc = "A SMG which packs a bunch with it's large bursts."
	item = /obj/item/gun/ballistic/automatic/mp7
	cost = 16
	surplus = 50

/datum/uplink_item/dangerous/m4a1
	name = "M4A1 Rifle"
	desc = "A old but still working service rifle with firepower, accuracy, and armor penetration to boot. Ammo may be difficult to find."
	item = /obj/item/gun/ballistic/automatic/m4a1
	cost = 20

/datum/uplink_item/armor
	category = UPLINK_CATEGORY_HARDSUITS

/datum/uplink_item/armor/civilprotectionvest
	name = "Civil Protection vest"
	desc = "A light and protective vest taken from combine civilprotection."
	item = /obj/item/clothing/suit/armor/civilprotection
	cost = 4

/datum/uplink_item/armor/rebeluniform
	name = "Rebel Uniform"
	desc = "A somewhat protective uniform with no tracking sensors, which is also decently low profile."
	item = /obj/item/clothing/under/citizen/rebel
	cost = 4

/datum/uplink_item/armor/hev
	name = "HEV Suit"
	desc = "A well preserved and incredibly rare suit retrieved from Black Mesa."
	item = /obj/item/clothing/suit/armor/nerd
	cost = 40

/datum/uplink_item/stealthy_weapons
	category = UPLINK_CATEGORY_STEALTH_WEAPONS

/datum/uplink_item/stealthy_weapons/traitor_chem_bottle
	name = "Poison Kit"
	desc = "An assortment of deadly and illegal chemicals packed into a compact box. Comes prepackaged in large syringes for more precise application."
	item = /obj/item/storage/box/syndie_kit/chemical
	cost = 7
	surplus = 50

/datum/uplink_item/ammo
	category = UPLINK_CATEGORY_AMMO
	surplus = 40

/datum/uplink_item/ammo/pistolaps
	name = "9mm Handgun Magazine"
	desc = "An additional 18-round 9mm magazine, compatible with the USP Match pistol."
	item = /obj/item/ammo_box/magazine/usp9mm
	cost = 4

/datum/uplink_item/ammo/smg
	name = "4.6x30mm SMG Magazine"
	desc = "A large capacity 45 round magazine for use with the MP7 SMG."
	item = /obj/item/ammo_box/magazine/mp7
	cost = 5

/datum/uplink_item/ammo/rebar
	name = "Rebar Bolt"
	desc = "A simple piece of sharpened rebar for use with the crossbow."
	item = /obj/item/ammo_casing/reusable/arrow/rebar
	cost = 1

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/c4
	cost = 2

/datum/uplink_item/explosives
	category = UPLINK_CATEGORY_EXPLOSIVES

/datum/uplink_item/explosives/frag_grenade
	name = "Grenade"
	desc = "Simple, but lethal. Anything adjacent when it explodes will be heavily damaged."
	item = /obj/item/grenade/syndieminibomb/bouncer
	cost = 5

/datum/uplink_item/stealthy_tools
	category = UPLINK_CATEGORY_STEALTH_GADGETS

/datum/uplink_item/stealthy_tools/jammer
	name = "Signal Jammer"
	desc = "This device will disrupt any nearby outgoing radio communication when activated. Blocks suit sensors, but does not affect binary chat."
	item = /obj/item/jammer
	cost = 5

/datum/uplink_item/stealthy_tools/lockpick
	name = "Lockpick"
	desc = "A simple metal lockpick, which can unlock normal, locked doors given enough time."
	item = /obj/item/lockpick
	cost = 2

/datum/uplink_item/misc
	category = UPLINK_CATEGORY_MISC

/datum/uplink_item/misc/medvial
	name = "Medvial"
	desc = "Easy to store, and use, this medvial can quickly provide a small amount of healing."
	item = /obj/item/reagent_containers/pill/patch/medkit/vial
	cost = 1

/datum/uplink_item/misc/medvial
	name = "Civil Protection Belt"
	desc = "A belt for easily carrying more things such as ammo."
	item = /obj/item/storage/belt/civilprotection
	cost = 4

/datum/uplink_item/misc/ration
	name = "Ration"
	desc = "A basic ration with food and water."
	item = /obj/item/storage/box/halflife/ration
	cost = 2

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
