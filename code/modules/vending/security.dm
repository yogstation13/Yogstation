/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack communist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	panel_type = "panel6"
	light_mask = "sec-light-mask"
	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 8,
		/obj/item/restraints/handcuffs/cable/zipties = 16, //monkestation edit 10 to 16
		/obj/item/grenade/flashbang = 7, //monkestation edit: 4 to 7
		/obj/item/grenade/smokebomb/security = 7, //monkestation edit
		/obj/item/assembly/flash/handheld = 6, //monkestation edit: 5 to 6
		/obj/item/food/donut/plain = 12,
		/obj/item/storage/box/evidence = 6,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 7,
		/obj/item/ammo_box/magazine/m35/rubber = 14, //monkestation edit: Paco sec
		/obj/item/clothing/mask/gas/sechailer = 6, ////monkestation edit
		/obj/item/clothing/mask/whistle = 3, //monkestation edit
		/obj/item/bodycam_upgrade = 10, //monkestation edit: Security Liability Act
	)
	contraband = list(
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/storage/fancy/donut_box = 4, //monkestation edit 2 to 4
		/obj/item/melee/flyswatter = 1, //monkestation edit: everytime they play a round, there are two ahelp tickets about them
	)
	premium = list(
		/obj/item/storage/belt/security/webbing = 5,
		/obj/item/coin/antagtoken = 1,
		//monkestation removal
		// /obj/item/clothing/head/helmet/blueshirt = 1,
		// /obj/item/clothing/suit/armor/vest/blueshirt = 1,
		//moved to secdrobe
		/obj/item/clothing/gloves/tackler = 5,
		/obj/item/grenade/stingbang = 1,
		/obj/item/watertank/pepperspray = 2,
		/obj/item/storage/belt/holster/energy = 4,
		/obj/item/citationinator = 3, // monkestation edit: security assistants
		/obj/item/holosign_creator/security = 2, //monkestation edit
		/obj/item/modular_computer/laptop/preset/security = 3, //monkestation edit
		/obj/item/storage/box/pinpointer_pairs = 2, //monkestation edit
		/obj/item/dragnet_beacon = 3, //monkestation edit
		/obj/item/implanter/mindshield = 2, //monkestation edit
	)
	refill_canister = /obj/item/vending_refill/security
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 1.5
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(isgrenade(I))
		var/obj/item/grenade/G = I
		G.arm_grenade()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/security
	icon_state = "refill_sec"

//MONKESTATION EDIT START
/obj/item/security_voucher
	name = "security voucher"
	desc = "A token to redeem a piece of equipment. Use it on a SecTech vendor."
	icon = 'monkestation/icons/obj/items/security_voucher.dmi'
	icon_state = "security_voucher_primary"
	w_class = WEIGHT_CLASS_TINY

/obj/item/security_voucher/primary
	name = "security primary voucher"
	icon_state = "security_voucher_primary"

/obj/item/security_voucher/utility
	name = "security utility voucher"
	icon_state = "security_voucher_utility"

/obj/item/security_voucher/assistant
	name = "security assistant voucher"
	icon_state = "security_voucher_assistant"

/obj/machinery/vending/security/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/security_voucher))
		redeem_voucher(weapon, user)
		return
	return ..()

/obj/machinery/vending/security/proc/redeem_voucher(obj/item/security_voucher/voucher, mob/redeemer)
	var/static/list/set_types

	var/voucher_set = /datum/voucher_set/security

	if(istype(voucher, /obj/item/security_voucher/primary))
		voucher_set = /datum/voucher_set/security/primary
	if(istype(voucher, /obj/item/security_voucher/utility))
		voucher_set = /datum/voucher_set/security/utility
	if(istype(voucher, /obj/item/security_voucher/assistant))
		voucher_set = /datum/voucher_set/security/assistant
	set_types = list()
	for(var/datum/voucher_set/static_set as anything in subtypesof(voucher_set))
		set_types[initial(static_set.name)] = new static_set

	var/list/items = list()
	for(var/set_name in set_types)
		var/datum/voucher_set/current_set = set_types[set_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_set.icon, icon_state = current_set.icon_state)
		option.info = span_boldnotice(current_set.description)
		items[set_name] = option

	var/selection = show_radial_menu(redeemer, src, items, custom_check = FALSE, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	var/datum/voucher_set/chosen_set = set_types[selection]
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	for(var/item in chosen_set.set_items)
		new item(drop_location())

	SSblackbox.record_feedback("tally", "security_voucher_redeemed", 1, selection)
	qdel(voucher)
//MONKESTATION EDIT STOP
