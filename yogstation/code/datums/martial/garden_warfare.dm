#define STRANGLE_COMBO "GGG"
#define PRE_STRANGLE_COMBO "GG"

#define SPLINTER_COMBO "HHH"
#define PRE_SPLINTER_COMBO "HH"

//Important note: podpeople have a max punch damage of 8, damage values take this into account

/datum/martial_art/gardern_warfare
	name = "Garden Warfare" //I feel like that I deserve a bullet into my head for this names
	id = MARTIALART_GARDENWARFARE
	block_chance = 75
	help_verb =  /mob/living/carbon/human/proc/gardern_warfare_help
	var/datum/action/vine_snatch/vine_snatch
	var/current_combo
	var/old_grab_state = null

/datum/martial_art/gardern_warfare/can_use(mob/living/carbon/human/H)
	return ispodperson(H)

/datum/martial_art/gardern_warfare/teach(mob/living/carbon/human/H, make_temporary=0)
	if(..())
		vine_snatch = new(H)
		vine_snatch.Grant(H)
		H.dna.species.speedmod = 0

/datum/martial_art/gardern_warfare/on_remove(mob/living/carbon/human/H)
	vine_snatch.Remove(H)
	QDEL_NULL(vine_snatch)
	H.dna.species.speedmod = initial(H.dna.species.speedmod)

/datum/martial_art/gardern_warfare/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(current_combo && current_combo != SPLINTER_COMBO)
		current_combo = null
		streak = ""
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/gardern_warfare/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE
	vine_mark(A,D)
	return FALSE

/datum/martial_art/gardern_warfare/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && (can_use(A))) 
		if(current_combo && current_combo !=  STRANGLE_COMBO)
			current_combo = null
			streak = ""
		add_to_streak("G",D)
		old_grab_state = A.grab_state
		if(old_grab_state < GRAB_AGGRESSIVE)
			D.grabbedby(A, 1)
		if(old_grab_state == GRAB_PASSIVE)
			A.setGrabState(GRAB_AGGRESSIVE) //Instant agressive grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively (garden warfare)")
			D.visible_message(span_warning("[A] grabs [D] with a swarm of vines!"), \
								span_userdanger("[A] wraps a swarm of vines around you!"))
		check_streak(A,D)
		return TRUE
	else
		return FALSE

/datum/martial_art/gardern_warfare/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, PRE_STRANGLE_COMBO))
		current_combo = STRANGLE_COMBO
		strangle(A,D)
		return FALSE  ///Zamn
	if(findtext(streak, PRE_SPLINTER_COMBO))
		current_combo = SPLINTER_COMBO
		splinter_stab(A,D)
		return TRUE

/datum/martial_art/gardern_warfare/proc/vine_mark(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_notice("You mark [D] with a vine mark. Using vine snatch now will pull an item from their active hands to you, or knockdown them and pull them to you."))
	to_chat(D, span_danger("[A] marks you!"))
	vine_snatch.marked_dude = D
	vine_snatch.last_time_marked = world.time
	streak = ""

/datum/martial_art/gardern_warfare/proc/strangle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, STRANGLE_COMBO))
		streak = ""
		ADD_TRAIT(D, TRAIT_MUTE, "martial")
		block_chance = 35
		final_strangle(A,D)
		block_chance = initial(block_chance)
		REMOVE_TRAIT(D, TRAIT_MUTE, "martial")
		streak = ""
	else 
		D.visible_message(span_danger("[A] wraps a vine around [D]'s throat!"), \
					span_userdanger("[A] wraps a vine around your throat!"))
		log_combat(A, D, "pre-strangles(Garden Warfare)")		
		D.Immobilize((A.get_punchdamagehigh() / 4) SECONDS)	//2 Seconds
		D.adjustOxyLoss(A.get_punchdamagehigh() + 2)	//10 oxyloss

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

		D.apply_damage((A.get_punchdamagehigh() * 1.5 + 8), BRUTE, selected_zone, armor_block, sharpness = SHARP_POINTY)	//20 damage
		D.Stun((A.get_punchdamagehigh() / 8) SECONDS)	//1 second

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

		D.apply_damage(A.get_punchdamagehigh() + 7, BRUTE, selected_zone, armor_block, sharpness = SHARP_POINTY) 	//15 damage

/datum/martial_art/gardern_warfare/proc/final_strangle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_strangle(A, D))
		return
	if(!do_after(A, 1 SECONDS, D))
		return
	if(!can_strangle(A, D))
		return
	D.adjustOxyLoss(5)
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
	name = "Vine Snatch - using it while having a target, recently marked with a vine mark in the range of 2 tiles will pull an item in their active hands to you, or pull and knockdown them."
	button_icon = 'icons/obj/changeling.dmi'
	button_icon_state = "tentacle"
	var/mob/living/carbon/human/marked_dude = null
	var/last_time_marked = 0
	var/range = 3

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
	if(world.time > last_time_marked + 5 SECONDS)
		to_chat(owner, span_warning("Your mark has expired, you can't use [name]."))
		return
	if(get_dist(get_turf(owner),get_turf(marked_dude)) > range)
		to_chat(owner, span_warning("Your target needs to be in a range of [range] titles, to be able to use [name]."))
		return
	to_chat(owner, span_notice("You throw a vine into [marked_dude]!"))
	owner.Beam(marked_dude, "vine", time= 10, maxdistance = range)
	var/obj/item/I = marked_dude.get_active_held_item()
	if(I && !HAS_TRAIT(I, TRAIT_NODROP))
		marked_dude.visible_message(span_warning("[owner] grabs at [marked_dude] with a vine, pulling [I] out of their hands!"), \
							span_userdanger("[owner] grabs at you with a vine, pulling [I] out of your hands!"))     
		if(I && marked_dude.temporarilyRemoveItemFromInventory(I))
			I.forceMove(get_turf(owner))
	else
		marked_dude.throw_at(get_step_towards(owner, marked_dude), 7, 2) 
		marked_dude.visible_message(span_warning("[owner] grabs [marked_dude] with a vine, knocking them down and pulling them closer!"), \
							span_userdanger("[owner] grabs you with a vine, pulling you closer!"))  
		marked_dude.Knockdown(3 SECONDS)
	marked_dude = null
				
/obj/item/splinter
	name = "splinter"
	desc = "It's sharp!"
	throwforce = 3
	sharpness = SHARP_EDGED
	embedding = list("embedded_pain_multiplier" = 3, "embed_chance" = 100, "embedded_fall_chance" = 0, "embedded_unsafe_removal_pain_multiplier" = 12)

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

	attacker.apply_damage(user.get_punchdamagehigh() + 2, BRUTE, selected_zone, armor_block, sharpness = SHARP_EDGED) 	//10 damage

	var/obj/item/splinter = new /obj/item/splinter(attacker)
	attacker.embed_object(splinter, affecting, FALSE, FALSE, TRUE)
	streak = ""	

/mob/living/carbon/human/proc/gardern_warfare_help()
	set name = "Remember the basics"
	set desc = "You try to remember some basic actions from the garden warfare art."
	set category = "Garden Warfare"
	to_chat(usr, "<b><i>You try to remember some basic actions from the garden warfare art.</i></b>")

	to_chat(usr, "[span_notice("Vine snatch")]: Your disarms mark the victim with a vine mark, allowing you to drag them or an item in their active hand by using ["Vine Snatch"] ability. The mark lasts only 5 seconds.")
	to_chat(usr, "[span_notice("Strangle")]: Grab Grab Grab. The second grab will deal 10 oxygen damage to the target, and finishing the combo will upgrade your grab, making it mute the target and deal 5 oxygen damage per second.")
	to_chat(usr, "[span_notice("Splinter stab")]: Harm harm Harm. The second attack will deal increased damage with 30 armor penetration, and finishing the combo will deal 20 damage with 30 armor penetration, while also embedding a splinter into the targets limb.")

	to_chat(usr, span_notice("Additionally, if you have throw mode on you have a 75% block chance (35% if strangling someone) and can counter-attack, dealing 10 damage and embedding a splinter into the attacker."))
