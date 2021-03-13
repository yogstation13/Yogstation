/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb = list("gored", "squished", "slapped", "digested")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.</span>"
	high_threshold_passed = "<span class='warning'>Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!</span>"
	high_threshold_cleared = "<span class='info'>The pain in your stomach dies down for now, but food still seems unappealing.</span>"
	low_threshold_cleared = "<span class='info'>The last bouts of pain in your stomach have died out.</span>"

	var/disgust_metabolism = 1

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/human/H = owner
	var/datum/reagent/Nutri

	..()
	if(istype(H))
		if(!(organ_flags & ORGAN_FAILING))
			H.dna.species.handle_digestion(H)
		handle_disgust(H)

	if(damage < low_threshold)
		return

	Nutri = locate(/datum/reagent/consumable/nutriment) in H.reagents.reagent_list

	if(Nutri)
		if(prob((damage/40) * Nutri.volume * Nutri.volume))
			H.vomit(damage)
			to_chat(H, "<span class='warning'>Your stomach reels in pain as you're incapable of holding down all that food!</span>")

	else if(Nutri && damage > high_threshold)
		if(prob((damage/10) * Nutri.volume * Nutri.volume))
			H.vomit(damage)
			to_chat(H, "<span class='warning'>Your stomach reels in pain as you're incapable of holding down all that food!</span>")

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H)
	if(H.disgust)
		var/pukeprob = 5 + 0.05 * H.disgust
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(prob(10))
				H.stuttering += 1
				H.confused += 2
			if(prob(10) && !H.stat)
				to_chat(H, "<span class='warning'>You feel kind of iffy...</span>")
			H.jitteriness = max(H.jitteriness - 3, 0)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(prob(pukeprob)) //iT hAndLeS mOrE ThaN PukInG
				H.confused += 2.5
				H.stuttering += 1
				H.vomit(10, 0, 1, 0, 1, 0)
			H.Dizzy(5)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(prob(25))
				H.blur_eyes(3) //We need to add more shit down here

		H.adjust_disgust(-0.5 * disgust_metabolism)
	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /obj/screen/alert/gross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /obj/screen/alert/verygross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /obj/screen/alert/disgusted)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
	..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "stomach-p"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."

/obj/item/organ/stomach/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	var/crystal_charge = ETHEREAL_CHARGE_FULL

/obj/item/organ/stomach/ethereal/on_life()
	..()
	adjust_charge(-ETHEREAL_CHARGE_FACTOR)

/obj/item/organ/stomach/ethereal/Insert(mob/living/carbon/M, special = 0)
	..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_electrocute)

/obj/item/organ/stomach/ethereal/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	..()

/obj/item/organ/stomach/ethereal/proc/charge(datum/source, amount, repairs)
	adjust_charge(amount / 70)

/obj/item/organ/stomach/ethereal/proc/on_electrocute(datum/source, shock_damage, siemens_coeff = 1, illusion = FALSE)
	if(illusion)
		return
	adjust_charge(shock_damage * siemens_coeff * 2)
	to_chat(owner, "<span class='notice'>You absorb some of the shock into your body!</span>")

/obj/item/organ/stomach/ethereal/proc/adjust_charge(amount)
	crystal_charge = clamp(crystal_charge + amount, ETHEREAL_CHARGE_NONE, ETHEREAL_CHARGE_FULL)
	
/obj/item/organ/stomach/cursed
	name = "cursed stomach"
	icon_state = "stomach-cursed"
	desc = "A stomach that used be a source of power of something incredibly vile. It seems to be beating."
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/stomach/cursed/ui_action_click() //Stomach that allows you to vomit at will, oh the humanity!
	if(HAS_TRAIT(owner, TRAIT_NOHUNGER))
		to_chat(owner, "<span class='notice'>You don't hunger, you can't vomit!</span>")
		return
	if(owner.IsParalyzed())
		to_chat(owner, "<span class='notice'>You can't bring yourself to vomit while stunned!</span>")
		return
	if(istype(owner.loc, /obj/effect/dummy/crawling))
		to_chat(owner, "<span class='notice'>You can't vomit while in vomitform!</span>") //no vomitghosts allowed
		return
	to_chat(owner, "<span class='notice'>You force yourself to vomit.</span>")
	owner.vomit(10, FALSE, TRUE, rand(0,4))  //BLEEEUUUGHHHH!!

/obj/item/organ/stomach/cursed/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth with disgust and tears into it with [user.p_their()] teeth!?</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] your mouth and unwillingly devour it!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 35, 1)
	if(user.GetComponent(/datum/component/crawl/vomit))
		to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
		qdel(src)
		return
	user.visible_message("<span class='warning'>[user] looks extremely sick!</span>", \
						 "<span class='userdanger'>You feel extremely weird... you have absorbed the demonic vomit-travelling powers?</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Are you gonna seriously gonna eat THAT?

/obj/item/organ/stomach/cursed/Insert(mob/living/carbon/M, special = 0)
	..()
	M.AddComponent(/datum/component/crawl/vomit)

/obj/item/organ/stomach/cursed/Remove(mob/living/carbon/M, special = 0)
	..()
	var/datum/component/crawl/vomit/B = M.GetComponent(/datum/component/crawl/vomit)
	if(B)
		B.RemoveComponent()
