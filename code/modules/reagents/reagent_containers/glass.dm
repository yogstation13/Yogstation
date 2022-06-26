/obj/item/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	resistance_flags = ACID_PROOF


/obj/item/reagent_containers/glass/attack(mob/M, mob/user, obj/target)
	if(!canconsume(M, user))
		return

	if(!spillable)
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	if(istype(M))
		if(user.a_intent == INTENT_HARM)
			var/R
			M.visible_message(span_danger("[user] splashes the contents of [src] onto [M]!"), \
							span_userdanger("[user] splashes the contents of [src] onto [M]!"))
			if(reagents)
				for(var/datum/reagent/A in reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"

			if(isturf(target) && reagents.reagent_list.len && thrownby)
				log_combat(thrownby, target, "splashed (thrown) [english_list(reagents.reagent_list)]")
				message_admins("[ADMIN_LOOKUPFLW(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] at [ADMIN_VERBOSEJMP(target)].")
			reagents.reaction(M, TOUCH)
			log_combat(user, M, "splashed", R)
			reagents.clear_reagents()
		else
			if(M != user)
				M.visible_message(span_danger("[user] attempts to feed something to [M]."), \
							span_userdanger("[user] attempts to feed something to you."))
				if(!do_mob(user, M))
					return
				if(!reagents || !reagents.total_volume)
					return // The drink might be empty after the delay, such as by spam-feeding
				M.visible_message(span_danger("[user] feeds something to [M]."), span_userdanger("[user] feeds something to you."))
				log_combat(user, M, "fed", reagents.log_list())
			else
				to_chat(user, span_notice("You swallow a gulp of [src]."))
			var/fraction = min(5/reagents.total_volume, 1)
			reagents.reaction(M, INGEST, fraction)
			addtimer(CALLBACK(reagents, /datum/reagents.proc/trans_to, M, 5), 5)
			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	if(!spillable)
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty!"))
			return

		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty and can't be refilled!"))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))

	else if(reagents.total_volume)
		if(user.a_intent == INTENT_HARM)
			user.visible_message(span_danger("[user] splashes the contents of [src] onto [target]!"), \
								span_notice("You splash the contents of [src] onto [target]."))
			reagents.reaction(target, TOUCH)
			reagents.clear_reagents()

/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, span_notice("You heat [name] with [I]!"))

	if(istype(I, /obj/item/reagent_containers/food/snacks/egg)) //breaking eggs
		var/obj/item/reagent_containers/food/snacks/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, span_notice("[src] is full."))
			else
				to_chat(user, span_notice("You break [E] in [src]."))
				E.reagents.trans_to(src, E.reagents.total_volume, transfered_by = user)
				qdel(E)
			return
	..()


/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	materials = list(/datum/material/glass=500)

/obj/item/reagent_containers/glass/beaker/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/glass/beaker/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/glass/beaker/update_icon()
	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 79)
				filling.icon_state = "[icon_state]75"
			if(80 to 90)
				filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/beaker/jar
	name = "honey jar"
	desc = "A jar for honey. It can hold up to 50 units of sweet delight."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vapour"

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	materials = list(/datum/material/glass=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)

/obj/item/reagent_containers/glass/beaker/plastic
	name = "x-large beaker"
	desc = "An extra-large beaker. Can hold up to 120 units."
	icon_state = "beakerwhite"
	materials = list(/datum/material/glass=2500, /datum/material/plastic=3000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120)

/obj/item/reagent_containers/glass/beaker/plastic/update_icon()
	icon_state = "beakerlarge" // hack to lets us reuse the large beaker reagent fill states
	..()
	icon_state = "beakerwhite"

/obj/item/reagent_containers/glass/beaker/meta
	name = "metamaterial beaker"
	desc = "A large beaker. Can hold up to 180 units."
	icon_state = "beakergold"
	materials = list(/datum/material/glass=2500, /datum/material/plastic=3000, /datum/material/gold=1000, /datum/material/titanium=1000)
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120,180)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	materials = list(/datum/material/iron=3000)
	reagent_flags = OPENCONTAINER | NO_REACT
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 30)

/obj/item/reagent_containers/glass/beaker/sulphuric
	list_reagents = list(/datum/reagent/toxin/acid = 50)

/obj/item/reagent_containers/glass/beaker/slime
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/reagent_containers/glass/beaker/large/styptic
	name = "styptic reserve tank"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 50)

/obj/item/reagent_containers/glass/beaker/large/silver_sulfadiazine
	name = "silver sulfadiazine reserve tank"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 50)

/obj/item/reagent_containers/glass/beaker/large/charcoal
	name = "charcoal reserve tank"
	list_reagents = list(/datum/reagent/medicine/charcoal = 50)

/obj/item/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/glass/beaker/synthflesh
	list_reagents = list(/datum/reagent/medicine/synthflesh = 50)

/obj/item/reagent_containers/glass/beaker/large/lemoline
	name = "lemoline reserve tank"
	list_reagents = list(/datum/reagent/lemoline = 100)

/obj/item/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'yogstation/icons/obj/janitor.dmi' //yogs - wasnt documented
	icon_state = "bucket"
	item_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	materials = list(/datum/material/iron=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 75, ACID = 50) //Weak melee protection, because you can wear it on your head
	slot_equipment_priority = list( \
		SLOT_BACK, SLOT_WEAR_ID,\
		SLOT_W_UNIFORM, SLOT_WEAR_SUIT,\
		SLOT_WEAR_MASK, SLOT_HEAD, SLOT_NECK,\
		SLOT_SHOES, SLOT_GLOVES,\
		SLOT_EARS, SLOT_GLASSES,\
		SLOT_BELT, SLOT_S_STORE,\
		SLOT_L_STORE, SLOT_R_STORE,\
		SLOT_GENERC_DEXTROUS_STORAGE
	)

/obj/item/reagent_containers/glass/bucket/wooden
	name = "wooden bucket"
	icon_state = "woodbucket"
	item_state = "woodbucket"
	materials = null
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 50)
	resistance_flags = FLAMMABLE

/obj/item/reagent_containers/glass/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("[src] is out of water!"))
		else
			reagents.trans_to(O, 5, transfered_by = user)
			to_chat(user, span_notice("You wet [O] in [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	else if(isprox(O)) //This works with wooden buckets for now. Somewhat unintended, but maybe someone will add sprites for it soon(TM)
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/cleanbot)
	else
		..()

/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if (slot == SLOT_HEAD)
		if(reagents.total_volume)
			to_chat(user, span_userdanger("[src]'s contents spill all over you!"))
			reagents.reaction(user, TOUCH)
			reagents.clear_reagents()
		reagents.flags = NONE

/obj/item/reagent_containers/glass/bucket/dropped(mob/user)
	. = ..()
	reagents.flags = initial(reagent_flags)

/obj/item/reagent_containers/glass/bucket/equip_to_best_slot(var/mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(SLOT_HEAD)
		slot_equipment_priority.Remove(SLOT_HEAD)
		. = ..()
		slot_equipment_priority.Insert(index, SLOT_HEAD)
		return
	return ..()

/obj/item/reagent_containers/glass/beaker/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list(/datum/reagent/water = 49.5, /datum/reagent/fluorine = 0.5)//see desc, don't think about it too hard
	materials = list(/datum/material/glass=0)
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/beaker/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/glass/beaker/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	materials = list(/datum/material/glass=0)
	list_reagents = list(/datum/reagent/water = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/glass/beaker/waterbottle/large/empty
	list_reagents = list()

/obj/item/pestle
	name = "pestle"
	desc = "An ancient, simple tool used in conjunction with a mortar to grind or juice items."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pestle"
	force = 7

/obj/item/reagent_containers/glass/mortar
	name = "mortar"
	desc = "A specially formed bowl of ancient design. It is possible to crush or juice items placed in it using a pestle; however the process, unlike modern methods, is slow and physically exhausting. Alt click to eject the item."
	icon_state = "mortar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 100
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	var/obj/item/grinded

/obj/item/reagent_containers/glass/mortar/AltClick(mob/user)
	if(grinded)
		grinded.forceMove(drop_location())
		grinded = null
		to_chat(user, "You eject the item inside.")

/obj/item/reagent_containers/glass/mortar/attackby(obj/item/I, mob/living/carbon/human/user)
	..()
	if(istype(I,/obj/item/pestle))
		if(grinded)
			if(user.getStaminaLoss() > 50)
				to_chat(user, span_danger("You are too tired to work!"))
				return
			to_chat(user, "You start grinding...")
			if((do_after(user, 2.5 SECONDS, src)) && grinded)
				user.adjustStaminaLoss(40)
				if(grinded.reagents) //food and pills
					grinded.reagents.trans_to(src, grinded.reagents.total_volume, transfered_by = user)
				if(grinded.juice_results) //prioritize juicing
					grinded.on_juice()
					reagents.add_reagent_list(grinded.juice_results)
					to_chat(user, "You juice [grinded] into a fine liquid.")
					QDEL_NULL(grinded)
					return
				grinded.on_grind()
				reagents.add_reagent_list(grinded.grind_results)
				to_chat(user, "You break [grinded] into powder.")
				QDEL_NULL(grinded)
				return
			return
		else
			to_chat(user, span_danger("There is nothing to grind!"))
			return
	if(grinded)
		to_chat(user, span_danger("There is something inside already!"))
		return
	if(I.juice_results || I.grind_results)
		I.forceMove(src)
		grinded = I
		return
	to_chat(user, span_danger("You can't grind this!"))

/obj/item/reagent_containers/glass/saline
	name = "saline canister"
	volume = 5000
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 5000)

/obj/item/reagent_containers/glass/mixbowl //chef's bowl
	name = "mixing bowl"
	desc = "A large bowl for mixing ingredients."
	icon = 'yogstation/icons/obj/food/containers.dmi'
	icon_state = "mixbowl"
	item_state = "mixbowl"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = NONE
	possible_transfer_amounts = list(10, 25, 50, 100)
	volume = 100
	materials = list(/datum/material/iron=1000)

/obj/item/reagent_containers/glass/mixbowl/on_reagent_change(changetype)
	..()
	update_icon()

/obj/item/reagent_containers/glass/mixbowl/update_icon()
	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('yogstation/icons/obj/reagentfillings.dmi', "[icon_state]11")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]0"
			if(10 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to INFINITY)
				filling.icon_state = "[icon_state]75"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/urn
	name = "urn"
	desc = "A tall vase used for storing cremated remains."
	obj_flags = UNIQUE_RENAME // Rename it to whoever you cremated
	icon_state = "urn_open"
	w_class = WEIGHT_CLASS_NORMAL // This is important! Don't just keep it in your box or something!
	resistance_flags = NONE // Shatters easily
	amount_per_transfer_from_this = 30 // Not very good at accurate reagent transfer and shouldn't be used for such
	possible_transfer_amounts = list(30)
	volume = 30
	materials = list(/datum/material/iron=0) // No free mats for you, chap
	var/spilled = FALSE // Is it currently spilled?
	var/locked = FALSE // Is it currently locked shut?

/// Calls on most non-table clicks, spills it
/obj/item/reagent_containers/glass/urn/afterattack()
	. = ..()
	if(spillable && !spilled)
		icon_state = "urn_spilled"
		spilled = TRUE
		amount_per_transfer_from_this = 0 // No reagent transfer allowed, it's spilled
		possible_transfer_amounts = list(0)
		reagents.clear_reagents()

/// Will not accept any reagents when spilled or locked
/obj/item/reagent_containers/glass/urn/is_refillable()
	if(spilled || locked)
		return FALSE
	else
		return reagents && (reagents.flags & REFILLABLE)

/// Using in hand will either upright a spilled urn or lock an open one
/obj/item/reagent_containers/glass/urn/attack_self(mob/user)
	src.add_fingerprint(user)
	if(locked) // If it's locked, we don't do anything with it
		return
	if(spilled) // If it's spilled over, we right it
		icon_state = "urn_open"
		spilled = FALSE
		to_chat(user, "<span class = 'notice'>You right [src].</span>")
		amount_per_transfer_from_this = 30
		possible_transfer_amounts = list(30)
		return
	locked = TRUE // If it's not locked or spilled, start locking it
	spillable = FALSE // Can't spill a closed container
	icon_state = "urn_closed"
	amount_per_transfer_from_this = 0 // No reagent transfer allowed, it's closed
	possible_transfer_amounts = list(0)
	to_chat(user, "<span class = 'notice'>You close the lid of [src] and lock it.</span>")