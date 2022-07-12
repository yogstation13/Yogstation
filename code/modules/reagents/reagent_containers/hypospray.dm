#define HYPO_SPRAY (1<<0)
#define HYPO_INJECT (1<<1)

#define WAIT_SPRAY 25
#define WAIT_INJECT 25
#define SELF_SPRAY 15
#define SELF_INJECT 15

#define DELUXE_WAIT_SPRAY 5
#define DELUXE_WAIT_INJECT 0
#define DELUXE_SELF_SPRAY 5
#define DELUXE_SELF_INJECT 0

#define COMBAT_WAIT_SPRAY 0
#define COMBAT_WAIT_INJECT 0
#define COMBAT_SELF_SPRAY 0
#define COMBAT_SELF_INJECT 0

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
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

/obj/item/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/hypospray/attack(mob/living/M, mob/user)
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
/obj/item/reagent_containers/hypospray/CMO
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	cryo_preserve = TRUE

/obj/item/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with experimental medical compounds for rapid healing."
	volume = 100
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/hypospray/magillitis
	name = "experimental autoinjector"
	desc = "A modified air-needle autoinjector with a small single-use reservoir. It contains an experimental serum."
	icon_state = "combat_hypo"
	volume = 5
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/magillitis = 5)

//MediPens

/obj/item/reagent_containers/hypospray/medipen
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

/obj/item/reagent_containers/hypospray/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to choke on \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/hypospray/medipen/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return
	..()
	if(!iscyborg(user))
		reagents.maximum_volume = 0 //Makes them useless afterwards
		reagents.flags = NONE
	update_icon()
	addtimer(CALLBACK(src, .proc/cyborg_recharge, user), 80)

/obj/item/reagent_containers/hypospray/medipen/proc/cyborg_recharge(mob/living/silicon/robot/user)
	if(!reagents.total_volume && iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell.use(100))
			reagents.add_reagent_list(list_reagents)
			update_icon()

/obj/item/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/hypospray/medipen/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += span_notice("It is currently loaded.")
	else
		. += span_notice("It is spent.")

/obj/item/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/consumable/coffee = 10)

/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list(/datum/reagent/medicine/stimulants = 10, /datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/hypospray/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	list_reagents = list(/datum/reagent/medicine/morphine = 10)

/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "stimpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list(/datum/reagent/medicine/atropine = 10, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/perfluorodecalin = 15, /datum/reagent/medicine/spaceacillin = 20)

/obj/item/reagent_containers/hypospray/medipen/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. WARNING: Do not inject more than one pen in quick succession."
	icon_state = "stimpen"
	volume = 57
	amount_per_transfer_from_this = 57
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/tricordrazine = 15, /datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/lavaland_extract = 2, /datum/reagent/medicine/omnizine = 5)

/obj/item/reagent_containers/hypospray/medipen/species_mutator
	name = "species mutator medipen"
	desc = "Embark on a whirlwind tour of racial insensitivity by \
		literally appropriating other races."
	volume = 1
	amount_per_transfer_from_this = 1
	list_reagents = list(/datum/reagent/toxin/mutagen = 1)

/obj/item/reagent_containers/hypospray/combat/heresypurge
	name = "holy water autoinjector"
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with 5 doses of a holy water mixture."
	volume = 250
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
	amount_per_transfer_from_this = 50

/obj/item/reagent_containers/hypospray/medipen/atropine
	name = "atropine autoinjector"
	desc = "A rapid way to save a person from a critical injury state!"
	list_reagents = list(/datum/reagent/medicine/atropine = 10)

/obj/item/reagent_containers/hypospray/medipen/pumpup
	name = "maintanance pump-up"
	desc = "A ghetto looking autoinjector filled with a cheap adrenaline shot... Great for shrugging off the effects of stunbatons."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/pumpup = 15)
	icon_state = "maintenance"

/obj/item/reagent_containers/hypospray/medipen/ekit
	name = "emergency first-aid autoinjector"
	desc = "An epinephrine medipen with extra coagulant and antibiotics to help stabilize bad cuts and burns."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/medicine/spaceacillin = 0.5)

/obj/item/reagent_containers/hypospray/medipen/blood_loss
	name = "hypovolemic-response autoinjector"
	desc = "A medipen designed to stabilize and rapidly reverse severe bloodloss."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/iron = 3.5, /datum/reagent/medicine/salglu_solution = 4)

/*/obj/item/reagent_containers/hypospray/medipen/snail
	name = "snail shot"
	desc = "All-purpose snail medicine! Do not use on non-snails!"
	list_reagents = list(/datum/reagent/snail = 10)
	icon_state = "snail" */ //yogs we removed snail people cause we are bad people who hate fun

//A vial-loaded hypospray. Cartridge-based!
/obj/item/hypospray
	name = "hypospray"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "hypo"
	desc = "A new development from DeForest Medical, this hypospray takes 15-unit vials as the drug supply for easy swapping."
	w_class = WEIGHT_CLASS_SMALL
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial)
	var/max_container_size = WEIGHT_CLASS_TINY
	var/mode = HYPO_INJECT
	var/obj/item/reagent_containers/glass/bottle/vial/vial
	var/transfer_amount = 5
	var/list/possible_transfer_amounts = list(5)
	var/inject_wait = WAIT_INJECT
	var/spray_wait = WAIT_SPRAY
	var/spray_self = SELF_SPRAY
	var/inject_self = SELF_INJECT
	var/quickload = FALSE
	var/penetrates = FALSE
	var/can_remove_vials = TRUE

	//	Sound Vars	//
	var/load_sound = 'sound/weapons/autoguninsert.ogg'
	var/eject_sound = 'sound/weapons/empty.ogg'
	var/preinject_sound = 'sound/items/autoinjector.ogg'
	var/postinject_sound = 'sound/items/hypospray.ogg'
	var/prespray_sound = 'sound/items/autoinjector.ogg'
	var/postspray_sound = 'sound/effects/spray2.ogg'

/obj/item/hypospray/Initialize()
	. = ..()
	if(ispath(vial))
		vial = new vial
	update_icon()

/obj/item/hypospray/update_icon()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	return

/obj/item/hypospray/examine(mob/user)
	. = ..()
	if(vial)
		. += "[vial] has [vial.reagents.total_volume]u remaining."
	else
		. += "It has no vial loaded in."
	. += "[src] is set to [mode ? "Inject" : "Spray"] contents on application."

/obj/item/hypospray/proc/unload_hypo(mob/user)
	if(vial)
		vial.forceMove(user.loc)
		user.put_in_hands(vial)
		to_chat(user, span_notice("You remove [vial] from [src]."))
		vial = null
		update_icon()
		playsound(loc, pick(eject_sound), 50, 1)
	else
		to_chat(user, span_notice("This hypo isn't loaded!"))
		return

/obj/item/hypospray/attackby(obj/item/I, mob/living/user)
	if((istype(I, /obj/item/reagent_containers/glass/bottle/vial) && vial != null))
		if(!quickload)
			to_chat(user, span_warning("[src] can not hold more than one vial!"))
			return FALSE
		unload_hypo(vial, user)
	if(I.w_class <= max_container_size)
		var/obj/item/reagent_containers/glass/bottle/vial/V = I
		if(!is_type_in_list(V, allowed_containers))
			to_chat(user, span_notice("[src] doesn't accept this type of vial."))
			return FALSE
		if(!user.transferItemToLoc(V,src))
			return FALSE
		vial = V
		user.visible_message(span_notice("[user] has loaded a vial into [src]."),span_notice("You have loaded [vial] into [src]."))
		update_icon()
		playsound(loc, pick(load_sound), 35, 1)
		return TRUE
	else
		to_chat(user, span_notice("This doesn't fit in [src]."))
		return FALSE

/obj/item/hypospray/AltClick(mob/user)
	. = ..()
	if(loc != user)
		return
	switch(mode)
		if(HYPO_SPRAY)
			mode = HYPO_INJECT
			to_chat(user, "[src] is now set to inject contents on application.")
		if(HYPO_INJECT)
			mode = HYPO_SPRAY
			to_chat(user, "[src] is now set to spray contents on application.")

/obj/item/hypospray/attack(obj/item/I, mob/user, params)
	return

/obj/item/hypospray/attack_hand(mob/user)
	if(can_remove_vials && loc == user && user.is_holding(src) && vial)
		unload_hypo(user)
		return
	return ..()

/obj/item/hypospray/afterattack(atom/target, mob/user, proximity)
	if(!vial || !proximity)
		return

	var/mob/living/carbon/C = target
	if(!istype(C))
		return

	if(!penetrates && !C.can_inject(user, 1)) //This check appears another four times, since otherwise the penetrating sprays will break in do_mob.
		return

	if(ishuman(C))
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, span_warning("The limb is missing!"))
			return
		if(affecting.status != BODYPART_ORGANIC)
			to_chat(user, span_notice("Medicine won't work on a robotic limb!"))
			return

	log_combat(user, C, "attemped to inject", src, addition = "which had [vial.reagents.log_list()]")
	//Always log attemped injections for admins
	if(!vial)
		to_chat(user, span_notice("[src] doesn't work here!"))
		return

	switch(mode)
		if(HYPO_INJECT)
			inject(C, user)
		if(HYPO_SPRAY)
			spray(C, user)

/obj/item/hypospray/proc/inject(mob/living/carbon/target, mob/user)
	//Pre messages/sound
	to_chat(target, span_warning("You feel a tiny prick!"))
	to_chat(user, span_notice("You begin to inject [target] with [src]."))
	playsound(src, pick(preinject_sound), 25)

	//Checks
	if(!do_mob(user, target, (target == user) ? inject_self : inject_wait))
		return
	if((!penetrates && !target.can_inject(user, 1)) || !vial?.reagents?.total_volume || target.reagents.total_volume >= target.reagents.maximum_volume)
		return

	//Post Messages/sounds
	target.visible_message(span_danger("[user] injects [target] with [src]!"), span_userdanger("[user] injects you with [src]!"))
	playsound(loc, pick(postinject_sound), 25)

	//Logging
	var/contained = vial.reagents.log_list()
	user.log_message("applied [src] to  [target == user ? "themselves" : target ] ([contained]).", INDIVIDUAL_ATTACK_LOG)
	if(target != user)
		log_attack("[user.name] ([user.ckey]) applied [src] to [target.name] ([target.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [mode])")
		
	
	//The actual reagent transfer
	var/fraction = min(transfer_amount/vial.reagents.total_volume, 1)
	vial.reagents.reaction(target, INJECT, fraction)
	vial.reagents.trans_to(target, transfer_amount, transfered_by = user)
	to_chat(user, span_notice("[transfer_amount] unit\s injected. [vial] now contains [vial.reagents.total_volume] unit\s."))

/obj/item/hypospray/proc/spray(mob/living/carbon/target, mob/user)
	//Pre messages/sound
	to_chat(user, span_notice("You begin to spray [target] with [src]."))
	playsound(src, pick(prespray_sound), 25)

	//Checks
	if(!do_mob(user, target, (target == user) ? spray_self : spray_wait))
		return
	if(!target.can_inject(user, 1) || !vial?.reagents?.total_volume || target.reagents.total_volume >= target.reagents.maximum_volume)
		return

	//Post Messages/sounds
	target.visible_message(span_danger("[user] sprays [target] with [src]!"), span_userdanger("[user] sprays you with [src]!"))
	playsound(loc, pick(postspray_sound), 25)

	//Logging
	var/contained = vial.reagents.log_list()
	user.log_message("applied [src] to  [target == user ? "themselves" : target ] ([contained]).", INDIVIDUAL_ATTACK_LOG)
	if(target != user)
		log_attack("[user.name] ([user.ckey]) applied [src] to [target.name] ([target.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [mode])")

	//The actual reagent transfer
	var/fraction = min(transfer_amount/vial.reagents.total_volume, 1)
	vial.reagents.reaction(target, PATCH, fraction)
	vial.reagents.trans_to(target, transfer_amount, transfered_by = user)
	to_chat(user, span_notice("[transfer_amount] unit\s sprayed. [vial] now contains [vial.reagents.total_volume] unit\s."))

/obj/item/hypospray/attack_self(mob/user)
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

/obj/item/hypospray/verb/modes()
	set name = "Toggle Application Mode"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	switch(mode)
		if(HYPO_SPRAY)
			mode = HYPO_INJECT
			to_chat(M, "[src] is now set to inject contents on application.")
		if(HYPO_INJECT)
			mode = HYPO_SPRAY
			to_chat(M, "[src] is now set to spray contents on application.")

/obj/item/hypospray/deluxe
	name = "hypospray deluxe"
	desc = "The Deluxe Hypospray can take larger-size vials. It also acts faster and delivers more reagents per spray."
	icon_state = "hypo_deluxe"
	max_container_size = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(1, 5)
	inject_wait = DELUXE_WAIT_INJECT
	spray_wait = DELUXE_WAIT_SPRAY
	spray_self = DELUXE_SELF_SPRAY
	inject_self = DELUXE_SELF_INJECT

/obj/item/hypospray/deluxe/cmo
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/hypospray/combat
	name = "combat hypospray"
	desc = "A combat-ready deluxe hypospray that acts almost instantly. It can be tactically reloaded by using a vial on it."
	icon_state = "combat_hypo"
	allowed_containers = list(/obj/item/reagent_containers/glass/bottle)
	vial = /obj/item/reagent_containers/glass/bottle/combat
	max_container_size = WEIGHT_CLASS_SMALL
	inject_wait = COMBAT_WAIT_INJECT
	spray_wait = COMBAT_WAIT_SPRAY
	spray_self = COMBAT_SELF_SPRAY
	inject_self = COMBAT_SELF_INJECT
	quickload = TRUE
	penetrates = TRUE

#undef HYPO_SPRAY
#undef HYPO_INJECT
#undef WAIT_SPRAY
#undef WAIT_INJECT
#undef SELF_SPRAY
#undef SELF_INJECT
#undef DELUXE_WAIT_SPRAY
#undef DELUXE_WAIT_INJECT
#undef DELUXE_SELF_SPRAY
#undef DELUXE_SELF_INJECT
#undef COMBAT_WAIT_SPRAY
#undef COMBAT_WAIT_INJECT
#undef COMBAT_SELF_SPRAY
#undef COMBAT_SELF_INJECT
