#define HYPO_INJECT "Inject"
#define HYPO_SPRAY "Spray"
#define HYPO_DRAW "Draw"

/obj/item/reagent_containers/autoinjector
	name = "autoinjector"
	desc = "A sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "old_hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list()
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	var/inject_sound = 'sound/items/autoinjector.ogg'
	var/ignore_flags = 0
	var/infinite = FALSE

/obj/item/reagent_containers/autoinjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/autoinjector/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	if(!iscarbon(M))
		return

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to inject", src, "([contained])")

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		to_chat(M, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You inject [M] with [src]."))
		playsound(src, pick(inject_sound), 25)

		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
// yogs start -Adds viruslist stuff
			var/viruslist = ""
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name
				if(istype(R, /datum/reagent/blood))
					var/datum/reagent/blood/RR = R
					for(var/datum/disease/D in RR.data["viruses"])
						viruslist += " [D.name]"
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/DD = D
							viruslist += " \[ symptoms: "
							for(var/datum/symptom/S in DD.symptoms)
								viruslist += "[S.name] "
							viruslist += "\]"
// yogs end
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)

			to_chat(user, span_notice("[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src]."))

			log_combat(user, M, "injected", src, "([contained])")
// yogs start - makes logs if viruslist
			if(viruslist)
				investigate_log("[user.real_name] ([user.ckey]) injected [M.real_name] ([M.ckey]) with [viruslist]", INVESTIGATE_VIROLOGY)
				log_game("[user.real_name] ([user.ckey]) injected [M.real_name] ([M.ckey]) with [viruslist]")
// yogs end

/obj/item/reagent_containers/autoinjector/combat
	name = "combat stimulant autoinjector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "old_combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/autoinjector/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with experimental medical compounds for rapid healing."
	volume = 100
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/autoinjector/magillitis
	name = "experimental autoinjector"
	desc = "A modified air-needle autoinjector with a small single-use reservoir. It contains an experimental serum."
	icon_state = "old_combat_hypo"
	volume = 5
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/magillitis = 5)

//MediPens

/obj/item/reagent_containers/autoinjector/medipen
	name = "epinephrine medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge. Contains a powerful preservative that can delay decomposition when applied to a dead body."
	icon_state = "medipen"
	item_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 12
	volume = 12
	ignore_flags = 1 //so you can medipen through hardsuits
	reagent_flags = DRAWABLE
	flags_1 = null
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/coagulant = 2)
	custom_price = 40

/obj/item/reagent_containers/autoinjector/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to choke on \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/autoinjector/medipen/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	..()
	if(!iscyborg(user))
		reagents.maximum_volume = 0 //Makes them useless afterwards
		reagents.flags = NONE
	update_icon()
	addtimer(CALLBACK(src, .proc/cyborg_recharge, user), 80)

/obj/item/reagent_containers/autoinjector/medipen/proc/cyborg_recharge(mob/living/silicon/robot/user)
	if(!reagents.total_volume && iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.use(100))
			reagents.add_reagent_list(list_reagents)
			update_icon()

/obj/item/reagent_containers/autoinjector/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/autoinjector/medipen/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += span_notice("It is currently loaded.")
	else
		. += span_notice("It is spent.")

/obj/item/reagent_containers/autoinjector/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/consumable/coffee = 10)

/obj/item/reagent_containers/autoinjector/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list(/datum/reagent/medicine/stimulants = 10, /datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/autoinjector/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	list_reagents = list(/datum/reagent/medicine/morphine = 10)

/obj/item/reagent_containers/autoinjector/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "stimpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list(/datum/reagent/medicine/atropine = 10, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/perfluorodecalin = 15, /datum/reagent/medicine/spaceacillin = 20)

/obj/item/reagent_containers/autoinjector/medipen/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. WARNING: Do not inject more than one pen in quick succession."
	icon_state = "stimpen"
	volume = 57
	amount_per_transfer_from_this = 57
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/tricordrazine = 15, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/lavaland_extract = 2, /datum/reagent/medicine/omnizine = 5)

/obj/item/reagent_containers/autoinjector/medipen/species_mutator
	name = "species mutator medipen"
	desc = "Embark on a whirlwind tour of racial insensitivity by \
		literally appropriating other races."
	volume = 1
	amount_per_transfer_from_this = 1
	list_reagents = list(/datum/reagent/toxin/mutagen = 1)

/obj/item/reagent_containers/autoinjector/combat/heresypurge
	name = "holy water autoinjector"
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with 5 doses of a holy water mixture."
	volume = 250
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
	amount_per_transfer_from_this = 50

/obj/item/reagent_containers/autoinjector/medipen/atropine
	name = "atropine autoinjector"
	desc = "A rapid way to save a person from a critical injury state!"
	list_reagents = list(/datum/reagent/medicine/atropine = 10)

/obj/item/reagent_containers/autoinjector/medipen/pumpup
	name = "maintanance pump-up"
	desc = "A ghetto looking autoinjector filled with a cheap adrenaline shot... Great for shrugging off the effects of stunbatons."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/pumpup = 15)
	icon_state = "maintenance"

/obj/item/reagent_containers/autoinjector/medipen/ekit
	name = "emergency first-aid autoinjector"
	desc = "An epinephrine medipen with extra coagulant and antibiotics to help stabilize bad cuts and burns."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/medicine/spaceacillin = 0.5)

/obj/item/reagent_containers/autoinjector/medipen/blood_loss
	name = "hypovolemic-response autoinjector"
	desc = "A medipen designed to stabilize and rapidly reverse severe bloodloss."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/iron = 3.5, /datum/reagent/medicine/salglu_solution = 4)

/*/obj/item/reagent_containers/autoinjector/medipen/snail
	name = "snail shot"
	desc = "All-purpose snail medicine! Do not use on non-snails!"
	list_reagents = list(/datum/reagent/snail = 10)
	icon_state = "snail" */ //yogs we removed snail people cause we are bad people who hate fun

//A vial-loaded hypospray. Cartridge-based!
/obj/item/hypospray
	name = "hypospray"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "hypo"
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A new development from DeForest Medical, this hypospray takes 15-unit vials as the drug supply for easy swapping."
	w_class = WEIGHT_CLASS_SMALL
	/// Determines what attacking someone with this hypospray does
	var/mode = HYPO_INJECT
	/// If the hypospray allows injecting multiple times while still injecting. Initial value determines if this hypospray prevents that, actual value is if the hypospray is currently injecting someone.
	var/antispam = FALSE
	/// The amount to transfer from the hypospray
	var/transfer_amount = 5
	/// The different amounts for *transfer_amount* that this hypospray has available
	var/list/possible_transfer_amounts = list(5)

	//  Container Vars  //
	/// The currently inserted container
	var/obj/item/reagent_containers/container
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial)
	var/max_container_size = WEIGHT_CLASS_TINY

	//  Wait Time Vars  //
	var/inject_wait = 2 SECONDS
	var/inject_self = 1 SECONDS
	var/spray_wait = 2 SECONDS
	var/spray_self = 1 SECONDS

	//  Misc Vars  //
	var/quickload = FALSE
	var/penetrates = FALSE
	var/can_remove_container = TRUE

	//	Sound Vars	//
	/// The sound that plays when you insert a vial into the hypospray
	var/load_sound = 'sound/weapons/autoguninsert.ogg'
	/// The sound that plays when you eject a vial from the hypospray
	var/eject_sound = 'sound/weapons/empty.ogg'
	/// The sound that plays when you someone with the hypospray
	var/inject_sound = 'sound/items/hypospray.ogg'
	/// The sound that plays when you spray someone with the hypospray
	var/spray_sound = 'sound/effects/spray2.ogg'
	/// The sound that plays when you draw from someone with the hypospray
	var/draw_sound = 'sound/items/autoinjector.ogg'

/obj/item/hypospray/Initialize()
	. = ..()
	if(ispath(container))
		container = new container
	antispam = FALSE
	update_icon()

/obj/item/hypospray/update_icon()
	..()
	cut_overlays()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	if(container?.reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state]-10")

		var/percent = round((container.reagents.total_volume / container.volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[icon_state]-10"
			if(10 to 29)
				filling.icon_state = "[icon_state]25"
			if(30 to 49)
				filling.icon_state = "[icon_state]50"
			if(50 to 69)
				filling.icon_state = "[icon_state]75"
			if(70 to INFINITY)
				filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(container.reagents.reagent_list)
		add_overlay(filling)
	return

/obj/item/hypospray/examine(mob/user)
	. = ..()
	if(!initial(antispam))
		. += span_notice("[src] has a rapispray needle, allowing for spraying multiple patients at once.")
	if(quickload)
		. += span_notice("[src] has a quickloading mechanism, allowing tactical reloads by using a container on it.")
	if(penetrates)
		. += span_notice("[src] has a diamond tipped needle, allowing it to pierce thick clothing.")
	if(container)
		. += span_notice("[container] has [container.reagents.total_volume]u remaining.")
	else
		. += span_notice("It has no container loaded in.")
	. += span_notice("[src] is set to [mode] contents on application.")

/obj/item/hypospray/proc/unload_hypo(mob/user)
	if(container)
		container.forceMove(user.loc)
		user.put_in_hands(container)
		to_chat(user, span_notice("You remove [container] from [src]."))
		container = null
		update_icon()
		playsound(loc, pick(eject_sound), 50, 1)
	else
		to_chat(user, span_notice("This hypo isn't loaded!"))
		return

/obj/item/hypospray/attackby(obj/item/I, mob/living/user)
	if((istype(I, /obj/item/reagent_containers/glass/bottle/vial) && container != null))
		if(!quickload)
			to_chat(user, span_warning("[src] can not hold more than one container!"))
			return FALSE
		unload_hypo(user)
	if(I.w_class <= max_container_size)
		var/obj/item/reagent_containers/glass/bottle/vial/V = I
		if(!is_type_in_list(V, allowed_containers))
			to_chat(user, span_notice("[src] doesn't accept this type of container."))
			return FALSE
		if(!user.transferItemToLoc(V,src))
			return FALSE
		container = V
		user.visible_message(span_notice("[user] has loaded [container] into [src]."),span_notice("You have loaded [container] into [src]."))
		update_icon()
		playsound(loc, pick(load_sound), 35, 1)
		return TRUE
	else
		to_chat(user, span_notice("This doesn't fit in [src]."))
		return FALSE

/obj/item/hypospray/AltClick(mob/user)
	. = ..()
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == transfer_amount)
				if(i<possible_transfer_amounts.len)
					transfer_amount = possible_transfer_amounts[i+1]
				else
					transfer_amount = possible_transfer_amounts[1]
				to_chat(user, span_notice("[src]'s transfer amount is now [transfer_amount] units."))
				return

/obj/item/hypospray/proc/switch_modes(mob/user)
	switch(mode)
		if(HYPO_SPRAY)
			mode = HYPO_INJECT
			to_chat(user, span_notice("[src] is now set to inject contents on application."))
		if(HYPO_INJECT)
			mode = HYPO_SPRAY
			to_chat(user, span_notice("[src] is now set to spray contents on application."))

/obj/item/hypospray/attack(obj/item/I, mob/user, params)
	return

/obj/item/hypospray/attack_hand(mob/user)
	if(can_remove_container && loc == user && user.is_holding(src) && container)
		unload_hypo(user)
		return
	return ..()

/obj/item/hypospray/CtrlClick(mob/user)
	if(can_remove_container && loc == user && user.is_holding(src) && container)
		unload_hypo(user)
		return
	return ..()

/obj/item/hypospray/afterattack(atom/target, mob/user, proximity)
	if(!container || !proximity || (antispam && initial(antispam)))
		return
	antispam = TRUE
	switch(mode)
		if(HYPO_INJECT)
			inject(target, user)
		if(HYPO_SPRAY)
			spray(target, user)
		if(HYPO_DRAW)
			draw(target, user)
	antispam = FALSE
	update_icon()

/obj/item/hypospray/proc/inject(mob/living/carbon/target, mob/user)
	//Initial Checks/Logging
	if(!container.reagents.total_volume)
		to_chat(user, span_notice("[container] is empty!"))
		return

	var/mob/living/carbon/C = target
	if(istype(C) && C.can_inject(user, 1))
		if(ishuman(C))
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
			if(!affecting)
				to_chat(user, span_warning("The limb is missing!"))
				return
			if(affecting.status != BODYPART_ORGANIC)
				to_chat(user, span_notice("Medicine won't work on a robotic limb!"))
				return

		log_combat(user, C, "attemped to spray", src, addition = "which had [container.reagents.log_list()]")

		//Pre messages
		to_chat(C, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You begin to inject [C] with [src]."))

		//Checks
		if(!do_mob(user, C, (C == user) ? inject_self : inject_wait))
			return
		if((!penetrates && !C.can_inject(user, 1)) || !container?.reagents?.total_volume || C.reagents.total_volume >= C.reagents.maximum_volume)
			return

		//Post Messages/sounds
		C.visible_message(span_danger("[user] injects [C] with [src]!"), span_userdanger("[user] injects you with [src]!"))
		playsound(loc, pick(inject_sound), 25)

		//Logging
		var/contained = container.reagents.log_list()
		user.log_message("applied [src] to  [C == user ? "themselves" : C ] ([contained]).", INDIVIDUAL_ATTACK_LOG)
		if(C != user)
			log_attack("[user.name] ([user.ckey]) applied [src] to [C.name] ([C.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [mode])")
	else
		if(!target.is_injectable(user))
			to_chat(user, span_warning("You cannot directly fill [target]!"))
			return
	
	//The actual reagent transfer
	var/fraction = min(transfer_amount/container.reagents.total_volume, 1)
	container.reagents.reaction(C, INJECT, fraction)
	container.reagents.trans_to(C, transfer_amount, transfered_by = user)
	to_chat(user, span_notice("[transfer_amount] unit\s injected. [container] now contains [container.reagents.total_volume] unit\s."))

/obj/item/hypospray/proc/spray(mob/living/carbon/target, mob/user)
	//Initial Checks/Logging
	if(!container.reagents.total_volume)
		to_chat(user, span_notice("[container] is empty!"))
		return
	var/mob/living/carbon/C = target
	if(istype(C) && C.can_inject(user, 1))
		if(ishuman(C))
			var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
			if(!affecting)
				to_chat(user, span_warning("The limb is missing!"))
				return
			if(affecting.status != BODYPART_ORGANIC)
				to_chat(user, span_notice("Medicine won't work on a robotic limb!"))
				return

		log_combat(user, C, "attemped to spray", src, addition = "which had [container.reagents.log_list()]")

		//Pre messages
		to_chat(user, span_notice("You begin to spray [C] with [src]."))

		//Checks Again
		if(!do_mob(user, C, (C == user) ? spray_self : spray_wait))
			return
		if(!C.can_inject(user, 1) || C.reagents.total_volume >= C.reagents.maximum_volume)
			return

		//Post Messages / Sound
		C.visible_message(span_danger("[user] sprays [C] with [src]!"), span_userdanger("[user] sprays you with [src]!"))
		playsound(loc, pick(spray_sound), 25)

		//Logging
		var/contained = container.reagents.log_list()
		user.log_message("applied [src] to  [C == user ? "themselves" : C ] ([contained]).", INDIVIDUAL_ATTACK_LOG)
		if(C != user)
			log_attack("[user.name] ([user.ckey]) applied [src] to [C.name] ([C.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [mode])")
	else
		if(!target.is_injectable(user))
			to_chat(user, span_warning("You cannot directly fill [target]!"))
			return

	//The actual reagent transfer
	var/fraction = min(transfer_amount/container.reagents.total_volume, 1)
	container.reagents.reaction(target, PATCH, fraction)
	container.reagents.trans_to(target, transfer_amount, transfered_by = user)
	to_chat(user, span_notice("[transfer_amount] unit\s sprayed. [container] now contains [container.reagents.total_volume] unit\s."))

/obj/item/hypospray/proc/draw(atom/target, mob/user)
	if(container.reagents.total_volume >= container.reagents.maximum_volume)
		to_chat(user, span_notice("[container] is full."))
		return
	var/transfered_amount = 0
	//Drawing from a mob
	var/mob/living/L = target
	if(istype(L)) 
		transfered_amount = container.reagents.maximum_volume - container.reagents.total_volume
		if(target != user)
			target.visible_message(span_danger("[user] is trying to take a blood sample from [target]!"), \
							span_userdanger("[user] is trying to take a blood sample from [target]!"))
			if(!do_mob(user, target))
				return
			if(container.reagents.total_volume >= container.reagents.maximum_volume)
				return
		if(L.transfer_blood_to(container, transfered_amount))
			user.visible_message("[user] takes a blood sample from [L].")
		else
			to_chat(user, span_warning("You are unable to draw any blood from [L]!"))

	//If not mob
	else 
		if(!target?.reagents?.total_volume)
			to_chat(user, span_warning("[target] is empty!"))
			return

		if(!target.is_drawable(user))
			to_chat(user, span_warning("You cannot directly remove reagents from [target]!"))
			return

		transfered_amount = target.reagents.trans_to(container, transfer_amount, transfered_by = user)

	playsound(loc, pick(draw_sound), 25)
	to_chat(user, span_notice("[transfered_amount] unit\s drawn. [container] now contains [container.reagents.total_volume] unit\s."))

/obj/item/hypospray/attack_self(mob/user)
	if(loc != user)
		return
	switch_modes(user)

/obj/item/hypospray/deluxe
	name = "hypospray deluxe"
	desc = "The Deluxe Hypospray can take larger-size vials. It also acts faster and delivers more reagents per spray."
	icon_state = "hypo_deluxe"
	max_container_size = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(1, 5)
	inject_wait = 0 SECONDS
	inject_self = 0 SECONDS
	spray_wait = 0.5 SECONDS
	spray_self = 0.5 SECONDS

/obj/item/hypospray/deluxe/switch_modes(mob/user)
	switch(mode)
		if(HYPO_DRAW)
			mode = HYPO_INJECT
			to_chat(user, span_notice("[src] is now set to inject contents on application."))
		if(HYPO_INJECT)
			mode = HYPO_SPRAY
			to_chat(user, span_notice("[src] is now set to spray contents on application."))
		if(HYPO_SPRAY)
			mode = HYPO_DRAW
			to_chat(user, span_notice("[src] is now set to draw on application."))

/obj/item/hypospray/deluxe/cmo
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	cryo_preserve = TRUE

/obj/item/hypospray/deluxe/debug
	name = "debug hypospray"
	desc = "A highly advanced hypospray that uses bluespace magic to instantly inject people with reagents."
	allowed_containers = list(/obj/item/reagent_containers)
	container = /obj/item/reagent_containers/glass/bottle/adminordrazine
	max_container_size = WEIGHT_CLASS_TINY
	quickload = TRUE
	penetrates = TRUE
	possible_transfer_amounts = list(0.1, 1, 5, 10, 15, 20, 30, 50, 100)
	spray_wait = 0 SECONDS
	spray_self = 0 SECONDS
  
/obj/item/hypospray/combat
	name = "combat hypospray"
	desc = "A combat-ready deluxe hypospray that acts almost instantly."
	icon_state = "hypo_syndie"
	allowed_containers = list(/obj/item/reagent_containers/glass/bottle)
	container = /obj/item/reagent_containers/glass/bottle/vial/large/combat
	max_container_size = WEIGHT_CLASS_SMALL
	inject_wait = 0 SECONDS
	inject_self = 0 SECONDS
	spray_wait = 0 SECONDS
	spray_self = 0 SECONDS
	quickload = TRUE
	penetrates = TRUE

/obj/item/hypospray/qmc
	name = "QMC hypospray"
	desc = "A modified, well used quick-mix capital combat hypospray designed to treat those on the field with hardsuits."
	icon_state = "hypo_qmc"
	quickload = TRUE
	penetrates = TRUE

/obj/item/hypospray/syringe
	name = "autosyringe"
	desc = "A precurser to the modern day hyposprays commonly used for its compatability with hypospray vials."
	icon_state = "autosyringe"
	inject_wait = 3 SECONDS
	inject_self = 0 SECONDS

/obj/item/hypospray/syringe/switch_modes(mob/user)
	switch(mode)
		if(HYPO_DRAW)
			mode = HYPO_INJECT
			to_chat(user, span_notice("[src] is now set to inject contents on application."))
		if(HYPO_INJECT)
			mode = HYPO_DRAW
			to_chat(user, span_notice("[src] is now set to draw on application."))

#undef HYPO_INJECT
#undef HYPO_SPRAY
#undef HYPO_DRAW
