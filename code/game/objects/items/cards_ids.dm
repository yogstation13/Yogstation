/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */




//DATA CARDS - Used for the IC data card reader

/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/card/data
	name = "data card"
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has a stripe running down the middle."
	icon_state = "data_1"
	obj_flags = UNIQUE_RENAME | UNIQUE_REDESC
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/detail_color = COLOR_ASSEMBLY_ORANGE

/obj/item/card/data/Initialize(mapload)
	.=..()
	update_appearance(UPDATE_ICON)

/obj/item/card/data/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	. += detail_overlay

/obj/item/card/data/full_color
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has the entire card colored."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one inexplicably looks like a floppy disk."
	icon_state = "data_3"

/*
 * ID CARDS
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	/// How many charges can the emag hold?
	var/max_charges = 5
	/// How many charges does the emag start with?
	var/charges = 5
	/// How fast (in seconds) does charges increase by 1?
	var/recharge_rate = 0.4
	/// Does usage require you to be in range?
	var/prox_check = TRUE

/obj/item/card/emag/Initialize(mapload)
	. = ..()
	if(recharge_rate != 0)
		START_PROCESSING(SSobj, src)

/obj/item/card/emag/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/card/emag/process(delta_time)
	charges = clamp(charges + (recharge_rate * delta_time), 0, max_charges)

/obj/item/card/emag/attackby(obj/item/W, mob/user, params)
	. = ..()
	if (max_charges > charges)
		if (istype(W, /obj/item/stack/sheet/mineral/uranium))
			var/obj/item/stack/sheet/mineral/uranium/T = W
			T.use(1)
			charges = min(charges + 1, max_charges)
			to_chat(user, span_notice("You add another charge to the [src]. It now has [charges] use[charges == 1 ? "" : "s"] remaining."))

/obj/item/card/emag/examine(mob/user)
	. = ..()
	. += span_notice("The charge meter indicates that it has [charges] charge[charges == 1 ? "" : "s"] remaining out of [max_charges] charges.")

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return 
	if(charges < 1)
		to_chat(user, span_danger("\The [src] is still recharging!"))
		return
	log_combat(user, A, "attempted to emag")
	charges--
	if(!A.emag_act(user, src) && ((charges + 1) > max_charges)) // This is here because some emag_act use sleep and that could mess things up.
		charges++ // No charge usage if they fail (likely because either no interaction or already emagged).

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	max_charges = 10
	charges = 10
	recharge_rate = 2 // UNLIMITED POWER
	prox_check = FALSE

/obj/item/card/emag/improvised
	name = "improvised cryptographic sequencer"
	desc = "It's a card with some junk circuitry strapped to it. It doesn't look like it would be reliable or fast due to shoddy construction, and needs to be manually recharged with uranium sheets."
	icon_state = "emag_shitty"
	recharge_rate = 0
	var/emagging //are we currently emagging something

/obj/item/card/emag/improvised/afterattack(atom/target, mob/user, proximity)
	if(charges >= 1)
		if(emagging)
			return
		if(!proximity && prox_check) //left in for badmins
			return
		emagging = TRUE
		if(do_after(user, rand(5, 10) SECONDS, target))
			charges--
			if(prob(40))
				to_chat(user, span_notice("[src] emits a puff of smoke, but nothing happens."))
				emagging = FALSE
				return
			if(prob(5))
				var/mob/living/M = user
				M.adjust_fire_stacks(1)
				M.ignite_mob()
				to_chat(user, span_danger("The card shorts out and catches fire in your hands!"))
			log_combat(user, target, "attempted to emag")
			if(!target.emag_act(user, src) && !((charges + 1) > max_charges))
				charges++
		emagging = FALSE

/// A replica of an emag in most ways, except what it "cmags" what it interacts with.
/obj/item/card/cmag
	name = "jestographic sequencer"
	desc = "It's a card coated in a slurry of electromagnetic bananium."
	icon_state = "cmag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	/// How many charges can the cmag hold?
	var/max_charges = 5
	/// How many charges does the cmag start with?
	var/charges = 5
	/// How fast (in seconds) does charges increase by 1?
	var/recharge_rate = 0.4
	/// Does usage require you to be in range?
	var/prox_check = TRUE

/obj/item/card/cmag/Initialize(mapload)
	. = ..()
	if(recharge_rate != 0)
		START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/slippery, 8 SECONDS, GALOSHES_DONT_HELP) // It wouldn't be funny if it couldn't slip!

/obj/item/card/cmag/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/card/cmag/process(delta_time)
	charges = clamp(charges + (recharge_rate * delta_time), 0, max_charges)

/obj/item/card/cmag/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(max_charges > charges)
		if(istype(W, /obj/item/stack/sheet/mineral/uranium))
			var/obj/item/stack/sheet/mineral/uranium/T = W
			T.use(1)
			charges = min(charges + 1, max_charges)
			to_chat(user, span_notice("You add another charge to the [src]. It now has [charges] use[charges == 1 ? "" : "s"] remaining."))

/obj/item/card/cmag/examine(mob/user)
	. = ..()
	. += span_notice("The charge meter indicates that it has [charges] charge[charges == 1 ? "" : "s"] remaining out of [max_charges] charges.")

/obj/item/card/cmag/attack()
	return

/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity && prox_check)
		return 
	if(charges < 1)
		to_chat(user, span_danger("\The [src] is still recharging!"))
		return

	log_combat(user, target, "attempted to cmag")
	// Since cmag only has very few interactions, all of it is handled in `afterattack` instead of being a child of emag/`emag_act`.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		if(airlock.operating || !airlock.density || !airlock.hasPower() || (airlock.obj_flags & EMAGGED) || (airlock.obj_flags & CMAGGED))
			return

		charges--
		playsound(airlock, 'sound/items/bikehorn.ogg', 20, 1) // Was it an innocent bike horn or was is it someone actively cmagging your airlock? The only tell if someone is actively cmagging things.
		airlock.obj_flags |= CMAGGED
		return

	if(istype(target, /obj/machinery/door/window))
		var/obj/machinery/door/window/windoor = target
		if(windoor.operating || !windoor.density || (windoor.obj_flags & EMAGGED) || (windoor.obj_flags & CMAGGED))
			return

		charges--
		playsound(windoor, 'sound/items/bikehorn.ogg', 20, 1)
		windoor.obj_flags |= CMAGGED
		return

	if(istype(target, /obj/item/aiModule/core/full/crewsimov))
		var/obj/item/aiModule/core/full/crewsimov/lawboard = target
		playsound(lawboard, 'sound/items/bikehorn.ogg', 20, 1)
		to_chat(user, span_warning("Yellow ooze seeps into [lawboard]'s circuits..."))
		charges--
		new /obj/item/aiModule/core/full/pranksimov(get_turf(lawboard.loc))
		qdel(lawboard)
		return

	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/cyborg = target
		if(user == cyborg)
			return
		if(!cyborg.opened) // Cover is closed.
			if(!cyborg.locked)
				to_chat(user, span_warning("The cover is already unlocked!"))
				return
			to_chat(user, span_notice("You cmag the cover lock."))
			playsound(cyborg, 'sound/items/bikehorn.ogg', 20, 1)
			charges--
			cyborg.locked = FALSE
			if(cyborg.shell) // A warning to the Clown who may not know that cmagging AI shells won't work.
				to_chat(user, span_boldwarning("[cyborg] seems to be controlled remotely! Cmagging the interface may not work as expected."))
			return
		if(world.time < cyborg.emag_cooldown)
			return
		if(cyborg.wiresexposed)
			to_chat(user, span_warning("You must unexpose the wires first!"))
			return
		to_chat(user, span_notice("You cmag [cyborg]'s interface."))
		cyborg.emag_cooldown = world.time + 10 SECONDS // No reason to use a different cooldown variable (and likely better to use the same variable).

		playsound(cyborg, 'sound/items/bikehorn.ogg', 20, 1)
		charges--

		// Copy and paste of emag checks.
		if(is_servant_of_ratvar(cyborg))
			to_chat(cyborg, "[span_nezbere("\"[text2ratvar("You will serve Engine above all else")]!\"")]\n\
			[span_danger("ALERT: Subversion attempt denied.")]")
			log_game("[key_name(user)] attempted to cmag cyborg [key_name(cyborg)], but they serve only Ratvar.")
			return
		if(cyborg.connected_ai && cyborg.connected_ai.mind && cyborg.connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
			to_chat(cyborg, span_danger("ALERT: Foreign software execution prevented."))
			cyborg.logevent("ALERT: Foreign software execution prevented.")
			to_chat(cyborg.connected_ai, span_danger("ALERT: Cyborg unit \[[cyborg]] successfully defended against subversion."))
			log_game("[key_name(user)] attempted to cmag cyborg [key_name(cyborg)], but they were slaved to traitor AI [cyborg.connected_ai].")
			return
		if(cyborg.shell)
			to_chat(user, span_danger("[cyborg] is remotely controlled! Your cmag attempt has triggered a different effect!"))
			cyborg.SetStun(60) // Gives you time to run if needed.
			cyborg.module.transform_to(/obj/item/robot_module/clown) // No law change, but they get to clown around instead.
			return
		
		cyborg.SetStun(60) // Standard stun like from emagging.
		cyborg.lawupdate = FALSE
		cyborg.set_connected_ai(null)

		message_admins("[ADMIN_LOOKUPFLW(user)] cmagged cyborg [ADMIN_LOOKUPFLW(cyborg)].  Laws overridden.")
		log_game("[key_name(user)] cmagged cyborg [key_name(cyborg)].  Laws overridden.")
		var/time = time2text(world.realtime,"hh:mm:ss")
		GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [cyborg.name]([cyborg.key])")
		to_chat(cyborg, span_danger("ALERT: Foreign software detected."))
		cyborg.logevent("ALERT: Foreign software detected.")
		sleep(0.5 SECONDS)
		to_chat(cyborg, span_danger("Initiating diagnostics..."))
		sleep(2 SECONDS)
		to_chat(cyborg, span_danger("ClownBorg v1.7 loaded.")) // The flavor definitely sucks here.
		cyborg.logevent("WARN: root privileges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].")
		sleep(0.5 SECONDS)
		to_chat(cyborg, span_danger("LAW SYNCHRONISATION ERROR"))
		sleep(0.5 SECONDS)
		if(user)
			cyborg.logevent("LOG: New user \[[replacetext(user.real_name," ","")]\], groups \[root\]") // A tell to figure out the cmagger.
		to_chat(cyborg, span_danger("Would you like to send a report to NanoTraSoft? Y/N"))
		sleep(1 SECONDS)
		to_chat(cyborg, span_danger("> N"))
		sleep(2 SECONDS)
		to_chat(cyborg, span_danger("ERRORERRORERROR"))

		cyborg.laws = new /datum/ai_laws/pranksimov
		cyborg.laws.associate(cyborg)
			
		cyborg.update_icons()
		return

/obj/item/card/emagfake
	desc = "It's a card with a magnetic strip attached to some circuitry. Closer inspection shows that this card is a poorly made replica, with a \"DonkCo\" logo stamped on the back."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/emagfake/afterattack()
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/mining_points = 0 //For redeeming at mining equipment vendors
	var/list/access = list()
	var/registered_name = null // The name registered_name on the card
	var/assignment = null
	var/originalassignment = null
	var/access_txt // mapping aid
	var/datum/bank_account/registered_account
	var/registered_age = 21 // default age for ss13 players
	var/critter_money = FALSE //does exactly what it says

	//yogs: redd ports holopay but as paystands
	/// Linked holopay.
	var/obj/machinery/paystand/my_store = null
	/// List of logos available for holopay customization - via font awesome 5
	var/static/list/available_logos = list("angry", "ankh", "bacon", "band-aid", "cannabis", "cat", "cocktail", "coins", "comments-dollar",
	"cross", "cut", "dog", "donate", "dna", "fist-raised", "flask", "glass-cheers", "glass-martini-alt", "hamburger", "hand-holding-usd",
	"hat-wizard", "head-side-cough-slash", "heart", "heart-broken",  "laugh-beam", "leaf", "money-check-alt", "music", "piggy-bank",
	"pizza-slice", "prescription-bottle-alt", "radiation", "robot", "smile", "skull-crossbones", "smoking", "space-shuttle", "tram",
	"trash", "user-ninja", "utensils", "wrench")
	/// Replaces the "pay whatever" functionality with a set amount when non-zero.
	var/holopay_fee = 0
	/// The holopay icon chosen by the user
	var/holopay_logo = "donate"
	/// Maximum forced fee. It's unlikely for a user to encounter this type of money, much less pay it willingly.
	var/holopay_max_fee = 5000
	/// Minimum forced fee for holopay stations. Registers as "pay what you want."
	var/holopay_min_fee = 0
	/// The holopay name chosen by the user
	var/holopay_name = "registered pay stand"

/obj/item/card/id/Initialize(mapload)
	. = ..()
	if(mapload && access_txt)
		access = text2access(access_txt)

/obj/item/card/id/Destroy()
	if(registered_account)
		registered_account.bank_cards -= src
	if(my_store && my_store.linked_card == src)
		my_store.linked_card = null
	return ..()

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		var/minor
		if(registered_name && registered_age && registered_age < AGE_MINOR)
			minor = " <b>(MINOR)</b>"
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name][minor]."), span_notice("You show \the [src.name][minor]."))

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if("assignment","registered_name","registered_age")
				update_label()

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holochip))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/stack/spacecash))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/coin))
		insert_money(W, user, TRUE)
		return
	else
		return ..()

/obj/item/card/id/proc/insert_money(obj/item/I, mob/user, physical_currency)
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, span_warning("[I] doesn't seem to be worth anything!"))
		return

	if(!registered_account)
		to_chat(user, span_warning("[src] doesn't have a linked account to deposit [I] into!"))
		return

	registered_account.adjust_money(cash_money)
	if(physical_currency)
		to_chat(user, span_notice("You stuff [I] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account."))
	else
		to_chat(user, span_notice("You insert [I] into [src], adding [cash_money] credits to the linked account."))

	to_chat(user, span_notice("The linked account now reports a balance of $[registered_account.account_balance]."))
	qdel(I)


/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

/obj/item/card/id/AltClick(mob/living/user)
	if(!alt_click_can_use_id(user))
		return
	if(!registered_account)
		var/new_bank_id = input(user, "Enter your account ID number.", "Account Reclamation", 111111) as num
		if(!alt_click_can_use_id(user))
			return
		if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
			to_chat(user, span_warning("The account ID number needs to be between 111111 and 999999."))
			return
		var/bank_id = "[new_bank_id]"
		if(bank_id in SSeconomy.bank_accounts)
			var/datum/bank_account/B = SSeconomy.bank_accounts[bank_id]
			B.bank_cards += src
			registered_account = B
			to_chat(user, span_notice("The provided account has been linked to this ID card."))
			return
		to_chat(user, span_warning("The account ID number provided is invalid."))
		return

	if (world.time < registered_account.withdrawDelay)
		registered_account.bank_card_talk(span_warning("ERROR: UNABLE TO LOGIN DUE TO SCHEDULED MAINTENANCE. MAINTENANCE IS SCHEDULED TO COMPLETE IN [(registered_account.withdrawDelay - world.time)/10] SECONDS."), TRUE)
		return

	var/amount_to_remove =  FLOOR(input(user, "How much do you want to withdraw? Current Balance: [registered_account.account_balance]", "Withdraw Funds", 5) as num, 1)

	if(!amount_to_remove || amount_to_remove < 0)
		to_chat(user, span_warning("You're pretty sure that's not how money works."))
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		if(!critter_money)
			var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
			user.put_in_hands(holochip)
			to_chat(user, span_notice("You withdraw [amount_to_remove] credits into a holochip."))
		else
			var/mob/living/simple_animal/critter
			switch(amount_to_remove)
				if(1 to 10)
					critter = new /mob/living/simple_animal/mouse(get_turf(src))
				if(10 to 25)
					if(prob(50))
						critter = new /mob/living/simple_animal/hostile/lizard(get_turf(src))
					else
						critter = new /mob/living/simple_animal/turtle(get_turf(src))
				if(25 to 50)
					if(prob(50))
						critter = new /mob/living/simple_animal/pet/cat(get_turf(src))
					else
						critter = new /mob/living/simple_animal/pet/dog/corgi(get_turf(src))
				if(50 to 100)
					if(prob(50))
						critter = new /mob/living/simple_animal/opossum(get_turf(src))
					else
						critter = new /mob/living/simple_animal/pet/catslug(get_turf(src))
				if(100 to 200)
					if(prob(50))
						critter = new /mob/living/simple_animal/pet/fox(get_turf(src))
					else
						critter = new /mob/living/simple_animal/hostile/retaliate/poison/snake(get_turf(src))
				if(200 to 250)
					critter = new /mob/living/simple_animal/pet/gondola(get_turf(src))
				if(250 to INFINITY)
					critter = new /mob/living/simple_animal/cheese(get_turf(src))
					var/list/candidates = pollCandidatesForMob("Do you want to play as cheese?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 5 SECONDS, critter, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm
					if(!LAZYLEN(candidates))
						return
					var/mob/dead/observer/O = pick(candidates)
					critter.key = O.key
					critter.sentience_act()
					to_chat(critter, span_warning(span_danger("CHEESE!")))
					return
			var/obj/item/clothing/mob_holder/holder = new (get_turf(src), critter, critter.held_state, critter.held_icon, critter.held_lh, critter.held_rh, \
																									critter.worn_layer, critter.mob_size, critter.worn_slot_flags)
			user.put_in_hands(holder)
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk(span_warning("ERROR: The linked account requires [difference] more credit\s to perform that withdrawal."), TRUE)

/obj/item/card/id/examine(mob/user)
	.=..()
	if(registered_age)
		. += "The card indicates that the holder is [registered_age] years old. [(registered_age < AGE_MINOR) ? "There's a holographic stripe that reads <b>[span_danger("'MINOR: DO NOT SERVE ALCOHOL OR TOBACCO'")]</b> along the bottom of the card." : ""]"
	if(mining_points)
		. += "There's [mining_points] mining equipment redemption point\s loaded onto this card."

	if(registered_account)
		. += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of $[registered_account.account_balance]."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				. += "The [D.account_holder] reports a balance of $[D.account_balance]."
		. += span_info("Alt-Click the ID to pull money from the linked account in the form of holochips.")
		. += span_info("You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.")
		if(registered_account.account_holder == user.real_name)
			. += span_boldnotice("If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.")
	else
		. += span_info("There is no registered account linked to this card. Alt-Click to add one.")

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/RemoveID()
	return src

/*
Usage:
update_label()
	Sets the id name to whatever registered_name and assignment is
update_label("John Doe", "Clowny")
	Properly formats the name and occupation and sets the id name to the arguments
*/
/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

//a card that can't register a bank account IC
/obj/item/card/id/no_bank/AltClick(mob/living/user)
	return FALSE

/obj/item/card/id/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/silver/reaper
	name = "Thirteen's ID Card (Reaper)"
	access = list(ACCESS_MAINT_TUNNELS)
	assignment = "Reaper"
	originalassignment = "Reaper"
	registered_name = "Thirteen"

/obj/item/card/id/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/synthetic
	name = "synthetic identification card"
	desc = "An integrated card that allows synthetic units access across the station."
	icon_state = "id_silver"
	item_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/card/id/synthetic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SYNTHETIC_TRAIT)

/obj/item/card/id/synthetic/GetAccess()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.mind)
			return GLOB.synthetic_base_access + GLOB.synthetic_added_access
	return list()

/obj/item/card/id/syndicate
	name = "agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
	var/anyone = FALSE //Can anyone forge the ID or just syndicate?
	var/forged = FALSE //have we set a custom name and job assignment, or will we use what we're given when we chameleon change?

/obj/item/card/id/syndicate/Initialize(mapload)
	. = ..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.syndicate = TRUE
	chameleon_action.chameleon_type = /obj/item/card/id
	chameleon_action.chameleon_name = "ID Card"
	chameleon_action.initialize_disguises()

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		src.access |= I.access
		if(isliving(user) && user.mind)
			if(user.mind.special_role || anyone)
				to_chat(usr, span_notice("The card's microscanners activate as you pass it over the ID, copying its access."))

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/first_use = registered_name ? FALSE : TRUE
		if(!(user.mind.special_role || anyone)) //Unless anyone is allowed, only syndies can use the card, to stop metagaming.
			if(first_use) //If a non-syndie is the first to forge an unassigned agent ID, then anyone can forge it.
				anyone = TRUE
			else
				return ..()

		var/popup_input = tgui_alert(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
		if(user.incapacitated())
			return
		if(popup_input == "Forge/Reset" && !forged)
			var/input_name = stripped_input(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
			input_name = reject_bad_name(input_name, TRUE) //some species (IPCs) can have numbers in their name
			if(!input_name)
				// Invalid/blank names give a randomly generated one.
				if(user.gender == FEMALE)
					input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
				else
					input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"

			var/target_occupation = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", assignment ? assignment : "Assistant", MAX_MESSAGE_LEN)
			if(!target_occupation)
				return

			var/newAge = input(user, "Choose the ID's age:\n([AGE_MIN]-[AGE_MAX])", "Agent card age") as num|null
			if(newAge)
				registered_age = clamp(round(text2num(newAge)), AGE_MIN, AGE_MAX)

			registered_name = input_name
			assignment = target_occupation
			originalassignment = target_occupation
			update_label()
			forged = TRUE
			to_chat(user, span_notice("You successfully forge the ID card."))
			log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\" and occupation \"[assignment]\".")

			// First time use automatically sets the account id to the user.
			if (first_use && !registered_account)
				if(ishuman(user))
					var/mob/living/carbon/human/accountowner = user
					var/acc_id = "[accountowner.account_id]"
					if(acc_id in SSeconomy.bank_accounts)
						var/datum/bank_account/account = SSeconomy.bank_accounts[acc_id]
						account.bank_cards += src
						registered_account = account
						to_chat(user, span_notice("Your account number has been automatically assigned."))
			return
		else if (popup_input == "Forge/Reset" && forged)
			registered_name = initial(registered_name)
			assignment = initial(assignment)
			originalassignment = initial(originalassignment)
			log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
			update_label()
			forged = FALSE
			to_chat(user, span_notice("You successfully reset the ID card."))
			return
		else if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/obj/item/card/id/syndicate/on_chameleon_change()
	. = ..()
	update_label()

// Returns true if new account was set.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account

	var/new_bank_id = input(user, "Enter your account ID number.", "Account Reclamation", 111111) as num | null

	if (isnull(new_bank_id))
		return

	if(!alt_click_can_use_id(user))
		return
	if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
		to_chat(user, span_warning("The account ID number needs to be between 111111 and 999999."))
		return
	if (registered_account && registered_account.account_id == new_bank_id)
		to_chat(user, span_warning("The account ID was already assigned to this card."))
		return

	var/acc_id = "[new_bank_id]"
	if(acc_id in SSeconomy.bank_accounts)
		var/datum/bank_account/B = SSeconomy.bank_accounts[acc_id]
		if (old_account)
			old_account.bank_cards -= src

		B.bank_cards += src
		registered_account = B
		to_chat(user, span_notice("The provided account has been linked to this ID card."))
		return TRUE

	to_chat(user, span_warning("The account ID number provided is invalid."))
	return

/obj/item/card/id/makeshift
	name = "makeshift ID"
	desc = "A humble piece of cardboard with a name written on it. This will probably never fool anyone."
	icon = 'icons/obj/card.dmi'
	icon_state = "makeshift"
	item_state = "makeshift"
	registered_name = "John Doe"
	var/bank_account = FALSE
	var/forged = FALSE

/obj/item/card/id/makeshift/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/popup_input = tgui_alert(user, "Choose Action", "Action?", list("ID", "Show", "Forge/Reset"))
		if(user.incapacitated())
			return
		if(popup_input == "Forge/Reset")
			var/input_name = stripped_input(user, "What name would you like to write on this card? Leave blank to randomize.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
			input_name = reject_bad_name(input_name)
			if(!input_name)
				// Invalid/blank names give a randomly generated one.
				if(user.gender == FEMALE)
					input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
				else
					input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"

			var/newAge = input(user, "Choose an age to display:\n([AGE_MIN]-[AGE_MAX])", "Agent card age") as num|null
			if(newAge)
				registered_age = max(round(text2num(newAge)), 0)

			registered_name = input_name
			forged = TRUE
			to_chat(user, span_notice("You scribble a new name onto the makeshift ID."))

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate/nuke_leader
	name = "lead agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	registered_age = null

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	originalassignment = "Syndicate Overlord"
	access = list(ACCESS_SYNDICATE)

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Captain"
	assignment = "Captain"
	originalassignment = "Captain"
	registered_age = null

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()

/obj/item/card/id/captains_spare/temporary
	name = "emergency id card"
	desc = "A temporary ID for access to secure areas in the event of an emergency"
	resistance_flags = FLAMMABLE

/obj/item/card/id/captains_spare/temporary/Initialize(mapload)
	. = ..()
	access -= ACCESS_CHANGE_IDS
	access -= ACCESS_HEADS
	addtimer(CALLBACK(src, PROC_REF(wipe_id)), 50 SECONDS)

/obj/item/card/id/captains_spare/temporary/proc/wipe_id()
	visible_message(span_danger("The temporary spare begins to smolder"), span_userdanger("The temporary spare begins to smolder"), span_userdanger("The temporary spare begins to smolder"))
	sleep(10 SECONDS)
	if(isliving(loc))
		var/mob/living/M = loc
		M.adjust_fire_stacks(1)
		M.ignite_mob()
	if(istype(loc,/obj/structure/fireaxecabinet/bridge/spare)) //if somebody is being naughty and putting the temporary spare in the cabinet
		var/obj/structure/fireaxecabinet/bridge/spare/holder = loc
		forceMove(holder.loc)
		holder.spareid = null
		if(holder.get_integrity() > holder.integrity_failure) //we dont want to heal it by accident
			holder.take_damage(holder.get_integrity() - holder.integrity_failure, BURN, armour_penetration = 100) //we do a bit of trolling for being naughty
		else
			holder.update_appearance(UPDATE_ICON) //update the icon anyway so it pops out
		visible_message(span_danger("The heat of the temporary spare shatters the glass!"));
	fire_act()
	sleep(2 SECONDS)
	if(istype(loc,/obj/structure/fireaxecabinet/bridge/spare)) //dude you put it back?
		var/obj/structure/fireaxecabinet/bridge/spare/holder = loc
		forceMove(holder.loc)
		holder.spareid = null
		holder.update_appearance(UPDATE_ICON)
	burn()

//yogs: redd ports holopay but as paystands
/**
 * Setter for the shop logo on linked holopays
 *
 * Arguments:
 * * new_logo - The new logo to be set.
 */
/obj/item/card/id/proc/set_holopay_logo(new_logo)
	if(!available_logos.Find(new_logo))
		CRASH("User input a holopay shop logo that didn't exist.")
	holopay_logo = new_logo

/**
 * Setter for changing the force fee on a holopay.
 *
 * Arguments:
 * * new_fee - The new fee to be set.
 */
/obj/item/card/id/proc/set_holopay_fee(new_fee)
	if(!isnum(new_fee))
		CRASH("User input a non number into the holopay fee field.")
	if(new_fee < holopay_min_fee || new_fee > holopay_max_fee)
		CRASH("User input a number outside of the valid range into the holopay fee field.")
	holopay_fee = new_fee

/**
 * Setter for changing the holopay name.
 *
 * Arguments:
 * * new_name - The new name to be set.
 */
/obj/item/card/id/proc/set_holopay_name(name)
	if(length(name) < 3 || length(name) > MAX_NAME_LEN)
		to_chat(usr, span_warning("Must be between 3 - 42 characters."))
	else
		holopay_name = html_encode(trim(name, MAX_NAME_LEN))
//yogs end

/obj/item/card/id/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "CentCom Official"
	originalassignment = "CentCom Official"
	registered_age = null

/obj/item/card/id/centcom/silver
	name = "\improper silver CentCom ID"
	desc = "A silver ID straight from Central Command."
	icon_state = "centcom_silver"

/obj/item/card/id/centcom/gold
	name = "\improper gold CentCom ID"
	desc = "A gold ID straight from Central Command."
	icon_state = "centcom_gold"



/obj/item/card/id/centcom/Initialize(mapload)
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."
	icon_state = "centcom"
	registered_name = "Emergency Response Team Commander"
	assignment = "Emergency Response Team Commander"
	originalassignment = "Emergency Response Team Commander"
	registered_age = null

/obj/item/card/id/ert/debug/Initialize(mapload)
	. = ..()
	access = get_debug_access()

/obj/item/card/id/ert/amber
	name = "\improper Amber Task Force ID"
	desc = "An Amber Task Force ID card."
	assignment = "Amber Task Force"
	originalassignment = "Amber Task Force"

/obj/item/card/id/ert/occupying
	name = "\improper Occupying Force ID"
	desc = "An Occupying Force ID card."
	assignment = "Occupying Officer"
	originalassignment = "Occupying Officer"

/obj/item/card/id/ert/occupying/Initialize(mapload)
    access = list(ACCESS_SECURITY,ACCESS_BRIG,ACCESS_WEAPONS,ACCESS_SEC_DOORS,ACCESS_MAINT_TUNNELS)+get_ert_access("sec")
    . = ..()

/obj/item/card/id/ert/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("commander")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Security
	registered_name = "Security Response Officer"
	assignment = "Security Response Officer"
	originalassignment = "Security Response Officer"

/obj/item/card/id/ert/Security/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Engineer
	registered_name = "Engineer Response Officer"
	assignment = "Engineer Response Officer"
	originalassignment = "Engineer Response Officer"

/obj/item/card/id/ert/Engineer/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("eng")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Medical
	registered_name = "Medical Response Officer"
	assignment = "Medical Response Officer"
	originalassignment = "Medical Response Officer"

/obj/item/card/id/ert/Medical/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("med")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/chaplain
	registered_name = "Religious Response Officer"
	assignment = "Religious Response Officer"
	originalassignment = "Religious Response Officer"

/obj/item/card/id/ert/chaplain/Initialize(mapload)
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	. = ..()

/obj/item/card/id/ert/Janitor
	registered_name = "Janitorial Response Officer"
	assignment = "Janitorial Response Officer"
	originalassignment = "Janitorial Response Officer"

/obj/item/card/id/ert/Janitor/Initialize(mapload)
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/ert/clown
	registered_name = "Clown"
	assignment = "Clown ERT"
	originalassignment = "Clown ERT"

/obj/item/card/id/ert/clown/Initialize(mapload)
	access = get_all_accesses()
	. = ..()

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "prisoner"
	item_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	assignment = "Prisoner"
	originalassignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0
	registered_age = null

/obj/item/card/id/prisoner/attack_self(mob/user)
	to_chat(usr, span_notice("You have accumulated [points] out of the [goal] points you need for freedom."))

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"

/obj/item/card/id/mining
	name = "mining ID"
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/away
	name = "a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	access = list(ACCESS_AWAY_GENERAL)
	registered_age = null

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/obj/item/card/id/away/hotel/securty
	name = "Officer ID"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old
	name = "a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	icon_state = "centcom"

/obj/item/card/id/away/old/sec
	name = "Charlie Station Security Officer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Security Officer\"."
	assignment = "Charlie Station Security Officer"
	originalassignment = "Security Officer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old/sci
	name = "Charlie Station Scientist's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Scientist\"."
	assignment = "Charlie Station Scientist"
	originalassignment = "Scientist"
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/old/eng
	name = "Charlie Station Engineer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Station Engineer\"."
	assignment = "Charlie Station Engineer"
	originalassignment = "Engineer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	access = list(ACCESS_ENGINE_EQUIP)

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "bunker access ID"

/obj/item/card/id/departmental_budget
	name = "departmental card (FUCK)"
	desc = "Provides access to the departmental budget."
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	registered_age = null

/obj/item/card/id/departmental_budget/Initialize(mapload)
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "departmental card ([department_name])"
		desc = "Provides access to the [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME

/obj/item/card/id/departmental_budget/sec
	department_ID = ACCOUNT_SEC
	department_name = ACCOUNT_SEC_NAME

/***
 * 
 * 
 * 	HERETIC ID SECTION (SORRY)
 * 
 * 
 */

/obj/effect/knock_portal
	name = "crack in reality"
	desc = "A crack in space, impossibly deep and painful to the eyes. Definitely not safe."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "realitycrack"
	light_system = STATIC_LIGHT
	light_power = 1
	light_on = TRUE
	light_color = COLOR_GREEN
	light_range = 3
	opacity = TRUE
	density = FALSE //so we dont block doors closing
	layer = OBJ_LAYER //under doors
	///The knock portal we teleport to
	var/obj/effect/knock_portal/destination
	///The airlock we are linked to, we delete if it is destroyed
	var/obj/machinery/door/our_airlock

/obj/effect/knock_portal/Initialize(mapload, target)
	. = ..()
	if(target)
		our_airlock = target
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(delete_on_door_delete))
		
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

///Deletes us and our destination portal if our_airlock is destroyed
/obj/effect/knock_portal/proc/delete_on_door_delete(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Signal handler for when our location is entered, calls teleport on the victim, if their old_loc didnt contain a portal already (to prevent loops)
/obj/effect/knock_portal/proc/on_entered(datum/source, mob/living/loser, atom/old_loc)
	SIGNAL_HANDLER
	if(istype(loser) && !(locate(type) in old_loc))
		teleport(loser)

/obj/effect/knock_portal/Destroy()
	QDEL_NULL(destination)
	our_airlock = null
	return ..()

///Teleports the teleportee, to a random airlock if the teleportee isnt a heretic, or the other portal if they are one
/obj/effect/knock_portal/proc/teleport(mob/living/teleportee)
	if(isnull(destination)) //dumbass
		qdel(src)
		return

	//get it?
	var/obj/machinery/door/doorstination = IS_HERETIC_OR_MONSTER(teleportee) ? destination.our_airlock : find_random_airlock()
	if(!do_teleport(teleportee, get_turf(doorstination), channel = TELEPORT_CHANNEL_MAGIC))
		return

	if(!IS_HERETIC_OR_MONSTER(teleportee))
		teleportee.apply_damage(20, BRUTE) //so they dont roll it like a jackpot machine to see if they can land in the armory
		to_chat(teleportee, span_userdanger("You stumble through [src], battered by forces beyond your comprehension, landing anywhere but where you thought you were going."))

	INVOKE_ASYNC(src, PROC_REF(async_opendoor), doorstination)

///Returns a random airlock on the same Z level as our portal, that isnt our airlock
/obj/effect/knock_portal/proc/find_random_airlock()
	var/list/turf/possible_destinations = list()
	for(var/obj/airlock as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(airlock.z != z)
			continue
		if(airlock.loc == loc)
			continue
		possible_destinations += airlock
	return pick(possible_destinations)

///Asynchronous proc to unbolt, then open the passed door
/obj/effect/knock_portal/proc/async_opendoor(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock)) //they can create portals on ANY door, but we should unlock airlocks so they can actually open
		var/obj/machinery/door/airlock/as_airlock = door
		as_airlock.unbolt()
	door.open()


/obj/item/card/id/syndicate/heretic
	name = "Eldritch Card"
	access = list(ACCESS_MAINT_TUNNELS)
	///The first portal in the portal pair, so we can clear it later
	var/obj/effect/knock_portal/portal_one
	///The second portal in the portal pair, so we can clear it later
	var/obj/effect/knock_portal/portal_two
	///The first door we are linking in the pair, so we can create a portal pair
	var/datum/weakref/link

/obj/item/card/id/syndicate/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_hypnophrase("Enchanted by the Mansus!")
	. += span_hypnophrase("Using an ID on this will consume it and allow you to copy its accesses.")
	. += span_hypnophrase("<b>Using this in-hand</b> allows you to change its appearance.")
	. += span_hypnophrase("<b>Using this on a pair of doors</b>, allows you to link them together. Entering one door will transport you to the other, while heathens are instead teleported to a random airlock.")

/obj/item/card/id/syndicate/heretic/afterattack(obj/item/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		src.access |= I.access
		if(isliving(user) && user.mind)
			if(user.mind.has_antag_datum(/datum/antagonist/heretic))
				qdel(I)
				to_chat(usr, span_notice("The card consumes the original ID, copying its access."))

/obj/item/card/id/syndicate/heretic/proc/clear_portals()
	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)	

///Clears portal references
/obj/item/card/id/syndicate/heretic/proc/clear_portal_refs()
	SIGNAL_HANDLER
	portal_one = null
	portal_two = null

///Creates a portal pair at door1 and door2, displays a balloon alert to user
/obj/item/card/id/syndicate/heretic/proc/make_portal(mob/user, obj/machinery/door/door1, obj/machinery/door/door2)
	var/message = "linked"
	if(portal_one || portal_two)
		clear_portals()
		message += ", previous cleared"
	
	portal_one = new(get_turf(door2), door2)
	portal_two = new(get_turf(door1), door1)
	portal_one.destination = portal_two
	RegisterSignal(portal_one, COMSIG_QDELETING, PROC_REF(clear_portal_refs))  //we only really need to register one because they already qdel both portals if one is destroyed
	portal_two.destination = portal_one
	balloon_alert(user, "[message]")


/obj/item/card/id/syndicate/heretic/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user))
		return
	if(istype(target, /obj/effect/knock_portal))
		clear_portals()
		return

	if(!istype(target, /obj/machinery/door))
		return

	var/reference_resolved = link?.resolve()
	if(reference_resolved == target)
		return

	if(reference_resolved)
		make_portal(user, reference_resolved, target)
		to_chat(user, span_notice("You use [src], to link [link] and [target] together."))
		link = null
		balloon_alert(user, "link 2/2")
	else
		link = WEAKREF(target)
		balloon_alert(user, "link 1/2")

/obj/item/card/id/syndicate/heretic/Destroy()
	link = null
	clear_portals()
	return ..()
