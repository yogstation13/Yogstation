#define VINE_SNATCH_COMBO "DD"

#define STRANGLE_COMBO "GGG"
#define PRE_STRANGLE_COMBO "GG"

#define SPLINTER_COMBO "HHH"
#define PRE_SPLINTER_COMBO "HH"

/datum/martial_art/gardern_warfare
	name = "Garden Warfare" //I feel like that I deserve a bullet into my head for this names
	id = MARTIALART_GARDENWARFARE
	block_chance = 50
	help_verb =  /mob/living/carbon/human/proc/gardern_warfare_help
	var/datum/action/vine_snatch/vine_snatch = new /datum/action/vine_snatch()
	var/current_combo

/datum/martial_art/gardern_warfare/can_use(mob/living/carbon/human/H)
	return ispodperson(H)

/datum/martial_art/gardern_warfare/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		vine_snatch.Grant(H)
		H.dna.species.speedmod = 0

/datum/martial_art/gardern_warfare/on_remove(mob/living/carbon/human/H)
	vine_snatch.Remove(H)
	H.dna.species.speedmod = initial(H.dna.species.speedmod)

/datum/martial_art/gardern_warfare/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(current_combo && current_combo != SPLINTER_COMBO)
		streak = ""
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/gardern_warfare/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	if(current_combo && current_combo !=  VINE_SNATCH_COMBO)
		streak = ""
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/gardern_warfare/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) 
		if(current_combo && current_combo !=  STRANGLE_COMBO)
			streak = ""
		add_to_streak("G",D)
		if(check_streak(A,D))
			return TRUE
	return FALSE

/datum/martial_art/gardern_warfare/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, VINE_SNATCH_COMBO))
		current_combo = VINE_SNATCH_COMBO
		vine_mark(A,D)
		return FALSE
	if(findtext(streak, PRE_STRANGLE_COMBO))
		current_combo = STRANGLE_COMBO
		strangle(A,D)
		return FALSE  ///Zamn
	if(findtext(streak, PRE_SPLINTER_COMBO))
		current_combo = SPLINTER_COMBO
		splinter_stab(A,D)
		return TRUE

/datum/martial_art/gardern_warfare/proc/vine_mark(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_notice("You mark [D] with a vine mark. Using vine snatch now will pull an item from their active hands to you, or knokdown them and pull them to you."))
	to_chat(D, span_danger("[A] marks you!"))
	vine_snatch.marked_dude = D
	vine_snatch.last_time_marked = world.time
	streak = ""

/datum/martial_art/gardern_warfare/proc/strangle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, STRANGLE_COMBO))
		streak = ""
		ADD_TRAIT(D, TRAIT_MUTE, "martial")
		block_chance = 25
		final_strangle(A,D)
		block_chance = initial(block_chance)
		REMOVE_TRAIT(D, TRAIT_MUTE, "martial")
		streak = ""
	else 
		D.visible_message(span_danger("[A] wraps a vine around [D]'s throat!"), \
					span_userdanger("[A] wraps a vine around your throat!"))
		log_combat(A, D, "pre-strangles(Garden Warfare)")		

		D.Stun(1 SECONDS)
		D.adjustOxyLoss(10)

/datum/martial_art/gardern_warfare/proc/splinter_stab(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, SPLINTER_COMBO))
		A.do_attack_animation(D, ATTACK_EFFECT_SLASH)
		playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, TRUE, -1)
		D.visible_message(span_danger("[A] impales [D]!"), \
					span_userdanger("[A] impales you!"))
		log_combat(A, D, "impales(Garden Warfare)")		

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
		var/armor_block = D.run_armor_check(affecting, MELEE, 30)

		D.apply_damage(20, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED)

		var/list/arms = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
		var/arm_zone = pick(arms)
		arms -= arm_zone
		var/obj/item/bodypart/affecting_arm = A.get_bodypart(ran_zone(arm_zone))
		if(!affecting_arm)
			affecting_arm = A.get_bodypart(ran_zone(pick(arms)))
		var/arm_armor_block = A.run_armor_check(affecting_arm, MELEE, 5)

		A.apply_damage(5, BRUTE, arm_zone, arm_armor_block) 	

		var/obj/item/splinter = new /obj/item/splinter(D)
		D.embed_object(splinter, affecting, FALSE, FALSE, TRUE)
		streak = ""
	else
		A.do_attack_animation(D, ATTACK_EFFECT_SLASH)
		playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, TRUE, -1)
		D.visible_message(span_danger("[A] stabs [D]!"), \
					span_userdanger("[A] stabs you!"))
		log_combat(A, D, "stabs(Garden Warfare)")		

		var/selected_zone = A.zone_selected
		var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(selected_zone))
		var/armor_block = D.run_armor_check(affecting, MELEE, 30)

		D.apply_damage(15, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 	

/datum/martial_art/gardern_warfare/proc/final_strangle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_strangle(A, D))
		return
	if(!do_mob(A, D, 1 SECONDS))
		return
	if(!can_strangle(A, D))
		return
	D.adjustOxyLoss(10)
	if(prob(35))
		to_chat(D, span_danger("You can't breath!"))
	final_strangle(A,D)

/datum/martial_art/gardern_warfare/proc/can_strangle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!A.pulling)
		return FALSE
	if(!(A.pulling == D))
		return FALSE
	if(A.stat == DEAD || A.stat == UNCONSCIOUS)
		return FALSE
	if(D.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/vine_snatch
	name = "Vine Snatch - using it while having a target, recently marked with a vine mark in the range of 2 tiles will pull an item in their active hands to you, or pull and knockdown them.."
	icon_icon = 'icons/obj/changeling.dmi'
	button_icon_state = "tentacle"
	var/mob/living/carbon/human/marked_dude = null
	var/last_time_marked = 0

/datum/action/vine_snatch/New()
	. = ..()
	last_time_marked = world.time

/datum/action/vine_snatch/Trigger()
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if(!marked_dude)
		to_chat(owner, span_warning("You can't use [name] while not having anyone marked."))
		return
	if(world.time > last_time_marked + 3 SECONDS)
		to_chat(owner, span_warning("Your mark has expired, you can't use [name]."))
		return
	if(get_dist(get_turf(owner),get_turf(marked_dude)) > 2)
		to_chat(owner, span_warning("Your target needs to be in a range of two titles, to be able to use [name]."))
		return
	to_chat(owner, span_notice("You throw a vine into [marked_dude]!"))
	var/obj/item/I = marked_dude.get_active_held_item()
	if(I && !HAS_TRAIT(I, TRAIT_NODROP))
		marked_dude.visible_message(span_warning("[owner] hits [marked_dude] with a vine, pulling [I] out of their hands!"), \
							span_userdanger("[owner] hits you with a vine, pulling [I] out of your hands!"))     
		if(I && marked_dude.temporarilyRemoveItemFromInventory(I))
			I.forceMove(get_turf(owner))
	else
		marked_dude.throw_at(get_step_towards(owner, marked_dude), 7, 2) 
		marked_dude.visible_message(span_warning("[owner] hits [marked_dude] with a vine, knocking them down and pulling them to themselfes!"), \
							span_userdanger("[owner] hits you with a vine, pulling you to themselfs!"))  
		marked_dude.Knockdown(3 SECONDS)
	marked_dude = null
				
/obj/item/splinter
	name = "splinter"
	desc = "It's sharp!"
	throwforce = 3
	sharpness = SHARP_EDGED
	embedding = list("embedded_pain_multiplier" = 3, "embed_chance" = 100, "embedded_fall_chance" = 0)
	var/passive_damage = 3

/obj/item/splinter/on_embed_removal(mob/living/carbon/human/embedde)
	qdel(src)
	. = ..()

/obj/item/splinter/embed_tick(mob/living/carbon/human/embedde, obj/item/bodypart/part)
	part.receive_damage(passive_damage, wound_bonus=-30, sharpness = TRUE)

/datum/martial_art/gardern_warfare/handle_counter(mob/living/carbon/human/user, mob/living/carbon/human/attacker)
	if(!can_use(user))
		return
	if(!user.in_throw_mode)
		return
	user.do_attack_animation(attacker, ATTACK_EFFECT_SLASH)
	playsound(get_turf(attacker), 'sound/weapons/slash.ogg', 50, TRUE, -1)
	attacker.visible_message(span_danger("[user] stabs [attacker]!"), \
				span_userdanger("[user] stabs you!"))
	log_combat(user, attacker, "counterattacks(Garden Warfare)")		

	var/selected_zone = user.zone_selected
	var/obj/item/bodypart/affecting = attacker.get_bodypart(ran_zone(selected_zone))
	var/armor_block = attacker.run_armor_check(affecting, MELEE, 0)

	attacker.apply_damage(10, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 	

	var/obj/item/splinter = new /obj/item/splinter(attacker)
	attacker.embed_object(splinter, affecting, FALSE, FALSE, TRUE)
	streak = ""	

/mob/living/carbon/human/proc/gardern_warfare_help()
	set name = "Remember the basics"
	set desc = "You try to remember some basic actions from the garden warfare art."
	set category = "Garden Warfare"
	to_chat(usr, "<b><i>You try to remember some basic actions from the garden warfare art.</i></b>")

	to_chat(usr, "[span_notice("Vine snatch")]: Disarm Disarm. Finishning this combo will mark the victim with a vine mark, allowing you to drag them or an item in their active hand by using ["Vine Snatch"] ability. The mark lasts only 3 seconds.")
	to_chat(usr, "[span_notice("Strangle")]: Grab Grab Grab. The second grab will deal 10 oxyloss damage to the target, and finishing the combo will upgrade your grab, making it mute the target and deal 10 oxyloss damage per second.")
	to_chat(usr, "[span_notice("Splinter stab")]: Harm harm Harm. The second attack will deal increased damage with 30 armor penetration, and finishing the combo will deal 20 damage with 30 armor penetration, while also embedding a splinter into the targets limb.")

	to_chat(usr, span_notice("Additionaly, you have a passive 50% block chance(25% if strangling someone), and having throw mode on will allow you to counterattack attackers, dealing them 10 damage and embedding a splinter into them."))
