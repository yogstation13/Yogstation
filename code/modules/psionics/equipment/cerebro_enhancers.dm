//Psi-boosting item (antag only)
/obj/item/clothing/head/helmet/space/psi_amp
	name = "cerebro-energetic enhancer"
	desc = "A matte-black, eyeless cerebro-energetic enhancement helmet. It uses highly sophisticated, and illegal, techniques to drill into your brain and install psi-infected AIs into the fluid cavities between your lobes."
	//actions_types = list(/datum/action/item_action/toggle_helmet_light)
	icon_state = "cerebro"

	var/operating = FALSE
	var/list/boosted_faculties
	var/boosted_rank = PSI_RANK_PARAMOUNT
	var/unboosted_rank = PSI_RANK_MASTER
	var/max_boosted_faculties = 3
	var/boosted_psipower = 120
	var/paramount_check = FALSE

/obj/item/clothing/head/helmet/space/psi_amp/Initialize()
	. = ..()
	verbs += /obj/item/clothing/head/helmet/space/psi_amp/proc/integrate

/obj/item/clothing/head/helmet/space/psi_amp/attack_self(mob/user)

	if(operating)
		return

	var/mob/living/carbon/human/H = loc
	if(istype(H) && H.head == src)
		integrate()
		return

	if(paramount_check && !H?.mind?.has_antag_datum(/datum/antagonist/paramount))
		to_chat(user, span_notice("You have no clue how to use this!"))

	var/choice = input("Select a brainboard to install or remove.","Psionic Amplifier") as null|anything in SSpsi.faculties_by_name
	if(!choice)
		return

	var/removed
	var/slots_left = max_boosted_faculties - LAZYLEN(boosted_faculties)
	var/datum/psionic_faculty/faculty = SSpsi.get_faculty(choice)
	if(faculty.id in boosted_faculties)
		LAZYREMOVE(boosted_faculties, faculty.id)
		removed = TRUE
	else
		if(slots_left <= 0)
			to_chat(user, span_warning("There are no slots left to install brainboards into."))
			return
		LAZYADD(boosted_faculties, faculty.id)
	UNSETEMPTY(boosted_faculties)

	slots_left = max_boosted_faculties - LAZYLEN(boosted_faculties)
	to_chat(user, span_notice("You [removed ? "remove" : "install"] the [choice] brainboard [removed ? "from" : "in"] \the [src]. There [slots_left!=1 ? "are" : "is"] [slots_left] slot\s left."))

/obj/item/clothing/head/helmet/space/psi_amp/AltClick(mob/user)
	. = ..()
	if(operating)
		deintegrate()
	else
		integrate()

/obj/item/clothing/head/helmet/space/psi_amp/proc/deintegrate()
	if(operating)
		return

	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return
	if(paramount_check && !H?.mind?.has_antag_datum(/datum/antagonist/paramount))
		to_chat(H, span_notice("You have no clue how to use this!"))


	to_chat(H, span_warning("You feel a strange tugging sensation as \the [src] begins removing the slave-minds from your brain..."))
	playsound(H, 'sound/weapons/circsawhit.ogg', 50, 1, -1)
	operating = TRUE

	sleep(80)

	if(H.psi) 
		H.psi.reset()

	to_chat(H, span_notice("\The [src] chimes quietly as it finishes removing the slave-minds from your brain."))

	REMOVE_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	operating = FALSE

	set_light(0)

/obj/item/clothing/head/helmet/space/psi_amp/Move()
	var/lastloc = loc
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = lastloc
		if(istype(H) && H.psi)
			H.psi.reset()
		H = loc
		if(!istype(H) || H.head != src)
			REMOVE_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)

/obj/item/clothing/head/helmet/space/psi_amp/proc/integrate()
	if(operating)
		return

	var/mob/living/carbon/human/H = loc

	if(!istype(H) || H.head != src)
		to_chat(usr, span_warning("\The [src] must be worn on your head in order to be activated."))
		return

	if(paramount_check && !H?.mind?.has_antag_datum(/datum/antagonist/paramount))
		to_chat(H, span_notice("You have no clue how to use this!"))
		return

	if(LAZYLEN(boosted_faculties) < max_boosted_faculties)
		to_chat(usr, span_notice("You still have [max_boosted_faculties - LAZYLEN(boosted_faculties)] facult[LAZYLEN(boosted_faculties) == 1 ? "y" : "ies"] to select. Use \the [src] in-hand to select them."))
		return

	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	operating = TRUE
	to_chat(H, span_warning("You feel a series of sharp pinpricks as \the [src] anaesthetises your scalp before drilling down into your brain."))
	playsound(H, 'sound/weapons/circsawhit.ogg', 50, 1, -1)

	sleep(80)

	for(var/faculty in list(PSI_COERCION, PSI_PSYCHOKINESIS, PSI_REDACTION, PSI_ENERGISTICS))
		if(faculty in boosted_faculties)
			H.set_psi_rank(faculty, boosted_rank, take_larger = TRUE, temporary = TRUE)
		else
			H.set_psi_rank(faculty, unboosted_rank, take_larger = TRUE, temporary = TRUE)
	if(H.psi)
		H.psi.max_stamina = boosted_psipower
		H.psi.set_stamina(H.psi.max_stamina)
		H.psi.update(force = TRUE)

	to_chat(H, span_notice("You experience a brief but powerful wave of deja vu as \the [src] finishes modifying your brain."))
	operating = FALSE
	H.update_action_buttons()

	set_light(0.5, 0.1, 3, 2, l_color = "#880000")

/obj/item/clothing/head/helmet/space/psi_amp/lesser
	max_boosted_faculties = 1
	boosted_rank = PSI_RANK_MASTER
	unboosted_rank = PSI_RANK_OPERANT
	boosted_psipower = 50

/obj/item/clothing/head/helmet/space/psi_amp/lesser/crown
	name = "psionic amplifier"
	desc = "A crown-of-thorns cerebro-energetic enhancer that interfaces directly with the brain, isolating and strengthening psionic signals. It kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	flags_inv = 0
	body_parts_covered = 0

/obj/item/clothing/head/helmet/space/psi_amp/paramount
	paramount_check = TRUE
