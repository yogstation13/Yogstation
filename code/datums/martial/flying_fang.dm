#define CHOMP_COMBO "GH"
#define TAIL_COMBO_START "DD"
#define TAIL_COMBO "TD"


/datum/martial_art/flyingfang
	name = "Flying Fang"
	id = MARTIALART_FLYINGFANG
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/flyingfang_help
	///used to keep track of the pounce ability
	var/leaping = FALSE
	var/datum/action/innate/lizard_leap/linked_leap

/datum/martial_art/flyingfang/can_use(mob/living/carbon/human/H)
	return islizard(H)

/datum/martial_art/flyingfang/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak,TAIL_COMBO_START))
		streak = "T"
		Slam(A,D)
		return TRUE
	if(findtext(streak, TAIL_COMBO))
		streak = ""
		Slap(A,D)
		return TRUE
	if(findtext(streak, CHOMP_COMBO))
		streak = ""
		Chomp(A,D)
		return TRUE

///second attack of the tail slap combo, deals high stamina damage, low brute damage, and causes a short slowdown
/datum/martial_art/flyingfang/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 50)
	var/slam_staminadamage = A.dna.species.punchdamagehigh * 1.5 + 10	//25 damage
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	D.apply_damage(slam_staminadamage, STAMINA, selected_zone, armor_block)														
	D.apply_damage(A.dna.species.punchdamagehigh + 5, A.dna.species.attack_type, selected_zone, armor_block)	//15 damage
	D.visible_message(span_danger("[A] slams into [D], knocking them off balance!"), \
					  span_userdanger("[A] slams into you, knocking you off  balance!"))
	D.add_movespeed_modifier("tail slap", update=TRUE, priority=101, multiplicative_slowdown=0.9)
	addtimer(CALLBACK(D, /mob.proc/remove_movespeed_modifier, "tail slap"), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	log_combat(A, D, "slammed (Flying Fang)")

///last hit of the tail slap combo, causes a short stun or throws whatever blocks the attack
/datum/martial_art/flyingfang/proc/Slap(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	A.emote("spin")
	var/obj/item/organ/tail = A.getorganslot(ORGAN_SLOT_TAIL)
	if(!istype(tail, /obj/item/organ/tail/lizard))
		A.visible_message(span_danger("[A] spins around."), \
						  span_userdanger("You spin around like a doofus."))
		return
	playsound(get_turf(A), 'sound/weapons/slap.ogg', 50, TRUE, -1)
	for(var/obj/item/I in D.held_items)
		if(I.block_chance)
			D.visible_message(span_danger("[A] tail slaps [I] out of [D]'s hands!"), \
							 span_userdanger("[A] tail slaps your [I] out of your hands!"))
			D.dropItemToGround(I)
			var/atom/throw_target = get_edge_target_turf(D, get_dir(A, get_step_away(D, A)))
			I.safe_throw_at(throw_target, 5, 2)
			return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 50)
	var/slap_staminadamage = A.dna.species.punchdamagehigh * 1.5 + 10	//25 damage
	A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
	D.apply_damage(slap_staminadamage, STAMINA, selected_zone, armor_block)
	D.apply_damage(A.dna.species.punchdamagehigh, A.dna.species.attack_type, selected_zone, armor_block)	//10 damage
	D.Knockdown(5 SECONDS)
	D.Paralyze(2 SECONDS)
	D.visible_message(span_danger("[A] tail slaps [D]!"), \
					  span_userdanger("[A] tail slaps you!"))
	log_combat(A, D, "tail slapped (Flying Fang)")

/datum/martial_art/flyingfang/proc/remove_bonk(mob/living/carbon/human/D)
	REMOVE_TRAIT(D, TRAIT_POOR_AIM, "martial")

/datum/martial_art/flyingfang/proc/Chomp(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if((D.mobility_flags & MOBILITY_STAND))
		return harm_act(A,D)
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(BODY_ZONE_HEAD))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 30)
	var/chomp_damage = A.dna.species.punchdamagehigh * 2 + 10	//30 damage
	A.do_attack_animation(D, ATTACK_EFFECT_BITE)
	playsound(D, 'sound/weapons/bite.ogg', 50, TRUE, -1)
	D.apply_damage(chomp_damage, A.dna.species.attack_type, BODY_ZONE_HEAD, armor_block, sharpness = SHARP_EDGED)
	// D.bleed_rate += 10
	D.visible_message(span_danger("[A] takes a large bite out of [D]'s neck!"), \
					  span_userdanger("[A] takes a large bite out of your neck!"))
	if(D.health > 0)
		to_chat(A, span_boldwarning("You feel reinvigorated!"))
		A.heal_overall_damage(25, 25)
		A.adjustToxLoss(-8)
		A.adjustStaminaLoss(-50)
		A.blood_volume += 30
	A.Stun(1.5 SECONDS) //actually about 1 second due to the stun resist
	D.Stun(2 SECONDS)
	log_combat(A, D, "neck chomped (Flying Fang)")

//headbutt, deals moderate brute and stamina damage with an eye blur, causes poor aim for a few seconds to the target if they have no helmet on
/datum/martial_art/flyingfang/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	if(!can_use(A))
		return
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(BODY_ZONE_HEAD))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	var/disarm_damage = A.dna.species.punchdamagehigh / 2 	//5 damage
	A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
	playsound(D, 'sound/weapons/genhit1.ogg', 50, TRUE, -1)
	D.apply_damage(disarm_damage, STAMINA, BODY_ZONE_HEAD, armor_block)
	D.apply_damage(disarm_damage, A.dna.species.attack_type, BODY_ZONE_HEAD, armor_block)
	D.blur_eyes(4)
	if(!istype(D.head, /obj/item/clothing/head/helmet))
		ADD_TRAIT(D, TRAIT_POOR_AIM, "martial")
		addtimer(CALLBACK(src, .proc/remove_bonk, D), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	D.visible_message(span_danger("[A] headbutts [D]!"), \
					  span_userdanger("[A] headbutts you!"))
	log_combat(A, D, "headbutted (Flying Fang)")

/datum/martial_art/flyingfang/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE //nothing special here

/datum/martial_art/flyingfang/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 10)
	A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
	playsound(D, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	D.apply_damage(A.dna.species.punchdamagehigh + 2, A.dna.species.attack_type, selected_zone, armor_block, sharpness = SHARP_EDGED) //+2 unarmed damage and sharp
	var/atk_verb = pick("rends", "claws", "slices", "tears at")
	D.visible_message(span_danger("[A] [atk_verb] [D]!"), \
					  span_userdanger("[A] [atk_verb] you!"))
	return TRUE

/datum/action/innate/lizard_leap
	name = "Leap"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lizard_tackle"
	background_icon_state = "bg_default"
	desc = "Prepare to jump at a target, with a successful hit stunning them and preventing you from moving for a few seconds."
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	var/datum/martial_art/flyingfang/linked_martial

/datum/action/innate/lizard_leap/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/lizard_leap/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/lizard_leap/process()
	UpdateButtonIcon() //keep the button updated

/datum/action/innate/lizard_leap/IsAvailable()
	. = ..()
	if(linked_martial.leaping || !linked_martial.can_use(owner))
		return FALSE

/datum/action/innate/lizard_leap/Activate(silent)
	if(!silent)
		owner.visible_message(span_danger("[owner] prepares to pounce!"), "<b><i>You will now pounce as your next attack.</i></b>")
	owner.click_intercept = src
	active = TRUE
	background_icon_state = "bg_default_on"

/datum/action/innate/lizard_leap/Deactivate(silent)
	if(!silent)
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>You will no longer pounce on attack.</i></b>")
	owner.click_intercept = null
	active = FALSE
	background_icon_state = "bg_default"

/datum/action/innate/lizard_leap/proc/InterceptClickOn(mob/living/carbon/human/A, params, atom/target)
	if(linked_martial.leaping)
		return
	linked_martial.leaping = TRUE
	A.Knockdown(5 SECONDS)
	A.Immobilize(30 SECONDS) //prevents you from breaking out of your pounce
	A.throw_at(target, get_dist(A,target)+1, 1, A, FALSE, TRUE, callback = CALLBACK(src, .proc/leap_end, A))
	Deactivate()
	UpdateButtonIcon()

/datum/action/innate/lizard_leap/proc/leap_end(mob/living/carbon/human/A)
	A.SetImmobilized(1 SECONDS)
	linked_martial.leaping = FALSE
	UpdateButtonIcon()

/datum/martial_art/flyingfang/handle_throw(atom/hit_atom, mob/living/carbon/human/A)
	if(!leaping)
		return FALSE
	if(hit_atom)
		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			var/blocked = FALSE
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				if(H.check_shields(src, 0, "[A]", attack_type = LEAP_ATTACK))
					blocked = TRUE
			L.visible_message("<span class ='danger'>[A] pounces on [L]!</span>", "<span class ='userdanger'>[A] pounces on you!</span>")
			L.Paralyze(blocked ? 6 SECONDS : 0)
			L.Knockdown(10 SECONDS)
			L.Immobilize(6 SECONDS)
			A.SetKnockdown(0)
			A.SetImmobilized(10 SECONDS) //due to our stun resistance this is actually about 6.6 seconds
			sleep(0.2 SECONDS)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src,L)
		else if(hit_atom.density && !hit_atom.CanPass(A))
			A.visible_message("<span class ='danger'>[A] smashes into [hit_atom]!</span>", "<span class ='danger'>You smash into [hit_atom]!</span>")
			A.Paralyze(6 SECONDS, 1)
		if(leaping)
			leaping = FALSE
		linked_leap.UpdateButtonIcon()
		linked_leap.Deactivate(TRUE)
		return TRUE

/mob/living/carbon/human/proc/flyingfang_help()
	set name = "Recall Your Teachings"
	set desc = "You try to remember your training of Flying Fang."
	set category = "Flying Fang"
	to_chat(usr, "<b><i>You try to remember some of the basics of Flying Fang.</i></b>")

	to_chat(usr, span_notice("Your training has rendered you more resistant to pain, allowing you to keep fighting effectively for longer and reducing the effectiveness of stun and stamina weapons by about a third."))
	to_chat(usr, span_warning("However, the primitive instincts gained through this training prevent you from using guns, stun weapons, or armor."))
	to_chat(usr, span_notice("<b>All of your unarmed attacks deal increased brute damage with a small amount of armor piercing</b>"))
	
	to_chat(usr, "[span_notice("Disarm Intent")]: Headbutt your enemy, Deals minor stamina and brute damage, as well as causing eye blurriness. Prevents the target from using ranged weapons effectively for a few seconds if they are not wearing a helmet.")

	to_chat(usr, "[span_notice("Tail Slap")]: Disarm Disarm Disarm. High armor piercing attack that causes a short slow followed by a knockdown. Deals heavy stamina damage.")
	to_chat(usr, "[span_notice("Neck Bite")]: Grab Harm. Target must be prone. Stuns you and your target for a short period, dealing heavy brute damage and bleeding. If the target is not in crit, this attack will heal you.")
	to_chat(usr, "<spna class='notice'>Leap</span>: Action: Jump at a target, with a successful hit stunning them and preventing you from moving for a few seconds.")

/datum/martial_art/flyingfang/teach(mob/living/carbon/human/H,make_temporary=0)
	..()
	if(!linked_leap)
		linked_leap = new
		linked_leap.linked_martial = src
	linked_leap.Grant(H)
	ADD_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	ADD_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, "martial")
	ADD_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	H.physiology.stamina_mod *= 0.66
	H.physiology.stun_mod *= 0.66
	var/datum/species/S = H.dna?.species
	if(S)
		S.add_no_equip_slot(H, SLOT_WEAR_SUIT)

/datum/martial_art/flyingfang/on_remove(mob/living/carbon/human/H)
	..()
	linked_leap.Remove(H)
	REMOVE_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	REMOVE_TRAIT(H, TRAIT_REDUCED_DAMAGE_SLOWDOWN, "martial")
	REMOVE_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	H.physiology.stamina_mod /= 0.66
	H.physiology.stun_mod /= 0.66
	var/datum/species/S = H.dna?.species
	if(S)
		S.remove_no_equip_slot(H, SLOT_WEAR_SUIT)
