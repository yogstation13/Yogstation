/obj/item/sentient_disease_injector
	name = "\improper CVS recipient injector"
	desc = "It doesn't look like it prints receipts."

	var/uses = 3

	var/obj/item/reagent_containers/glass/bottle/vial/stored_vial

/obj/item/sentient_disease_injector/examine(mob/user)
	. = ..()
	if(stored_vial)
		. += span_notice("It has a [stored_vial] inserted.")
	if(uses > 0)
		. += span_notice("The charge meter indicates it has [uses] [uses == 1 ? "use" : "uses"] remaining.")
	else
		. += span_notice("The charge meter indicates it is spent..")

/obj/item/sentient_disease_injector/attackby(obj/item/I, mob/user, params)

	if(!istype(I,/obj/item/reagent_containers))
		return ..() //Something else.

	if(stored_vial) //Already exists.
		to_chat(user, span_warning("There is already \a [stored_vial] inside."))
		return

	if(!istype(I, /obj/item/reagent_containers/glass/bottle/vial))
		to_chat(user, span_warning("\The [stored_vial] won't fit inside."))
		return

	var/datum/reagent/R = I.reagents.get_master_reagent()

	if(!R)
		to_chat(user, span_warning("\The [I] is empty!"))
		return

	if(!length(R.data["viruses"]))
		to_chat(user, span_warning("\The [src] can't seem to detect any viruses inside \the [I]..."))
		return

	stored_vial = I
	stored_vial.forceMove(src)

	to_chat(user, span_notice("You insert \the [I] into \the [src]."))

	return TRUE

/obj/item/sentient_disease_injector/attack_self(mob/user)

	if(!stored_vial)
		return

	stored_vial.forceMove(user.loc)
	user.put_in_hands(stored_vial)
	to_chat(user, span_notice("You eject \the [stored_vial] from \the [src]."))
	stored_vial = null

	return TRUE

/obj/item/sentient_disease_injector/attack(obj/item/I, mob/user, params)
	return //Prevents damage.

/obj/item/sentient_disease_injector/afterattack(atom/target, mob/user, proximity)

	if(!proximity || !istype(target,/mob/living/carbon))
		return ..()

	if(uses <= 0)
		to_chat(user, span_warning("\The [src] is spent!"))
		return

	var/mob/living/carbon/C = target

	if(!C.can_inject(user, 1, user.zone_selected, TRUE))
		to_chat(user, span_warning("You can't seem to inject \the [C] that way!"))

	if(ishuman(C))
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, span_warning("\The [src] can't inject a missing limb!"))
			return
		if(affecting.status != BODYPART_ORGANIC)
			to_chat(user, span_warning("\The [src] won't work on a robotic limb!"))
			return

	to_chat(user, span_notice("You stealthily inject \the [C] with \the [src]."))

	uses -= 1

	for(var/k in C.diseases) //Cure all existing diseases
		var/datum/disease/D = k
		D.cure(add_resistance = FALSE)

	if(stored_vial && stored_vial.reagents.total_volume) //If there is a stored vial, inject.
		var/list/injected = list()
		for(var/k in stored_vial.reagents)
			var/datum/reagent/R = k
			injected += R.name
		log_combat(user, C, "attempted to inject", src, "([english_list(injected)])")
		stored_vial.reagents.reaction(C, INJECT, 1)
		stored_vial.reagents.trans_to(C, stored_vial.reagents.total_volume, transfered_by = user)
	else
		log_combat(user, C, "attempted to inject", src)

	if(length(C.diseases))
		INVOKE_ASYNC(src, .proc/create_sentient_virus, target, user)

	return TRUE

/obj/item/sentient_disease_injector/Destroy()
	QDEL_NULL(stored_vial)
	. = ..()

/obj/item/sentient_disease_injector/proc/create_sentient_virus(mob/living/carbon/target,mob/user)

	var/list/candidates = pollGhostCandidates("Do you wish to be considered for the special role of 'custom sentient disease'?", ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return FALSE //No candidates.

	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/mob/camera/disease/virus = new/mob/camera/disease(get_turf(target))
	virus.key = selected.key
	message_admins("[ADMIN_LOOKUPFLW(virus)] has been made into a sentient disease by [ADMIN_LOOKUPFLW(usr)]'s [src].")
	log_game("[key_name(virus)] was spawned as a sentient disease by [ADMIN_LOOKUPFLW(usr)]'s [src].")
	//Mix and cure all existing diseases.
	for(var/k in target.diseases)
		var/datum/disease/D = k
		if(D == virus)
			continue
		virus.disease_template.Mix(D)
		D.cure(add_resistance = FALSE)

	return virus.force_infect(target)


