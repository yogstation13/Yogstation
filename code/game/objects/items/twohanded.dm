/* Two-handed Weapons
 * Contains:
 * 		Twohanded
 *		Fireaxe
 *		Double-Bladed Energy Swords
 *		Spears
 *		CHAINSAWS
 *		Bone Axe and Spear
 */

/*##################################################################
##################### TWO HANDED WEAPONS BE HERE~ -Agouri :3 ########
####################################################################*/

//Rewrote TwoHanded weapons stuff and put it all here. Just copypasta fireaxe to make new ones ~Carn
//This rewrite means we don't have two variables for EVERY item which are used only by a few weapons.
//It also tidies stuff up elsewhere.




/*
 * Twohanded
 */
/obj/item/twohanded
	/// Is the item currently wielded with two hands
	var/wielded = FALSE
	/// How much additonal force to give
	var/force_wielded = 0
	/// Sound made when you wield it
	var/wieldsound = null
	/// Sound made when you unwield it
	var/unwieldsound = null
	/// stat list for wielded/unwielded, switches with weapon_stats when wielding or unwielding
	var/list/wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)

/obj/item/twohanded/proc/unwield(mob/living/carbon/user, show_message = TRUE)
	if(!wielded || !user)
		return
	wielded = FALSE
	force -= force_wielded
	var/sf = findtext(name, " (Wielded)", -10)//10 == length(" (Wielded)")
	if(sf)
		name = copytext(name, 1, sf)
	else //something wrong
		name = "[initial(name)]"
	update_icon()
	if(user.get_item_by_slot(SLOT_BACK) == src)
		user.update_inv_back()
	else
		user.update_inv_hands()
	if(show_message)
		if(iscyborg(user))
			to_chat(user, span_notice("You free up your module."))
		else
			to_chat(user, span_notice("You are now carrying [src] with one hand."))
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/twohanded/offhand/O = user.get_inactive_held_item()
	if(O && istype(O))
		O.unwield()
	var/list/stats = weapon_stats
	weapon_stats = wielded_stats
	wielded_stats = stats
	return

/obj/item/twohanded/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(ismonkey(user))
		to_chat(user, span_warning("It's too heavy for you to wield fully."))
		return
	if(user.get_inactive_held_item())
		to_chat(user, span_warning("You need your other hand to be empty!"))
		return
	var/obj/item/twohanded/offhand/O = new(user) // Reserve other hand
	// Cyborgs are snowflakes hand wise
	if(iscyborg(user))
		user.put_in_inactive_hand(O)
	else
		if(!user.put_in_inactive_hand(O))
			to_chat(user, span_notice("You try to wield it... but it seems you're missing the matching arm.")) // should be better text but dunno what
			return
	wielded = TRUE
	if(force_wielded)
		force += force_wielded
	name = "[name] (Wielded)"
	update_icon()
	if(iscyborg(user))
		to_chat(user, span_notice("You dedicate your module to [src]."))
	else
		to_chat(user, span_notice("You grab [src] with both hands."))
	if (wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/list/stats = weapon_stats
	weapon_stats = wielded_stats
	wielded_stats = stats
	O.name = "[name] - offhand"
	O.desc = "Your second grip on [src]."
	O.wielded = TRUE
	return

/obj/item/twohanded/dropped(mob/user)
	. = ..()
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(!wielded)
		return
	unwield(user)

/obj/item/twohanded/update_icon()
	return

/obj/item/twohanded/attack_self(mob/user)
	. = ..()
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)

/obj/item/twohanded/equip_to_best_slot(mob/M)
	if(..())
		if(istype(src, /obj/item/twohanded/required))
			return // unwield forces twohanded-required items to be dropped.
		unwield(M)
		return

/obj/item/twohanded/equipped(mob/user, slot)
	..()
	if(!user.is_holding(src) && wielded && !istype(src, /obj/item/twohanded/required))
		unwield(user)

///////////OFFHAND///////////////
/obj/item/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/twohanded/offhand/Destroy()
	wielded = FALSE
	return ..()

/obj/item/twohanded/offhand/dropped(mob/living/user, show_message = TRUE) //Only utilized by dismemberment since you can't normally switch to the offhand to drop it.
	SHOULD_CALL_PARENT(FALSE)
	var/obj/I = user.get_active_held_item()
	if(I && istype(I, /obj/item/twohanded))
		var/obj/item/twohanded/thw = I
		thw.unwield(user, show_message)
		if(istype(thw, /obj/item/twohanded/required))
			user.dropItemToGround(thw)
	if(!QDELETED(src))
		qdel(src)

/obj/item/twohanded/offhand/unwield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		qdel(src)

/obj/item/twohanded/offhand/wield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		qdel(src)

/obj/item/twohanded/offhand/attack_self(mob/living/carbon/user)		//You should never be able to do this in standard use of two handed items. This is a backup for lingering offhands.
	var/obj/item/twohanded/O = user.get_inactive_held_item()
	if (istype(O) && !istype(O, /obj/item/twohanded/offhand/))		//If you have a proper item in your other hand that the offhand is for, do nothing. This should never happen.
		return
	if (QDELETED(src))
		return
	qdel(src)																//If it's another offhand, or literally anything else, qdel. If I knew how to add logging messages I'd put one here.

///////////Two hand required objects///////////////
//This is for objects that require two hands to even pick up
/obj/item/twohanded/required
	w_class = WEIGHT_CLASS_HUGE

/obj/item/twohanded/required/attack_self()
	return

/obj/item/twohanded/required/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(wielded && !slot_flags)
		if(!disable_warning)
			to_chat(M, span_warning("[src] is too cumbersome to carry with anything but your hands!"))
		return 0
	return ..()

/obj/item/twohanded/required/attack_hand(mob/user)//Can't even pick it up without both hands empty
	var/obj/item/twohanded/required/H = user.get_inactive_held_item()
	if(get_dist(src,user) > 1)
		return
	if(H != null)
		to_chat(user, span_notice("[src] is too cumbersome to carry in one hand!"))
		return
	if(loc != user)
		wield(user)
	. = ..()

/obj/item/twohanded/required/equipped(mob/user, slot)
	..()
	var/slotbit = slotdefine2slotbit(slot)
	if(slot_flags & slotbit)
		var/datum/O = user.is_holding_item_of_type(/obj/item/twohanded/offhand)
		if(!O || QDELETED(O))
			return
		qdel(O)
		return
	if(slot == SLOT_HANDS)
		wield(user)
	else
		unwield(user)

/obj/item/twohanded/required/dropped(mob/living/user, show_message = TRUE)
	unwield(user, show_message)
	..()

/obj/item/twohanded/required/wield(mob/living/carbon/user)
	..()
	if(!wielded)
		user.dropItemToGround(src)

/obj/item/twohanded/required/unwield(mob/living/carbon/user, show_message = TRUE)
	if(!wielded)
		return
	if(show_message)
		to_chat(user, span_notice("You drop [src]."))
	..(user, FALSE)

/*
 * Fireaxe
 */
/obj/item/twohanded/fireaxe  // DEM AXES MAN, marker -Agouri
	icon = 'icons/obj/tools.dmi'
	icon_state = "fireaxe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 19
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20

/obj/item/twohanded/fireaxe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound) //axes are not known for being precision butchering tools

/obj/item/twohanded/fireaxe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "fireaxe[wielded]"
	return

/obj/item/twohanded/fireaxe/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/twohanded/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window))
			var/obj/structure/window/W = A
			W.take_damage(W.max_integrity*2, BRUTE, MELEE, 0)
		else if(istype(A, /obj/structure/grille))
			var/obj/structure/grille/G = A
			G.take_damage(G.max_integrity*2, BRUTE, MELEE, 0)

/*
 * Metal Hydrogen Axe
 */
/obj/item/twohanded/fireaxe/metal_h2_axe  // Blatant imitation of the fireaxe, but made out of metallic hydrogen
	icon_state = "metalh2_axe0"
	name = "metallic hydrogen axe"
	desc = "A large, menacing axe made of an unknown substance that the most elder atmosians call Metallic Hydrogen. Truly an otherwordly weapon."
	force_wielded = 18

/obj/item/twohanded/fireaxe/metal_h2_axe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "metalh2_axe[wielded]"
	return

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/twohanded/dualsaber
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	force_wielded = 31
	wieldsound = 'sound/weapons/saberon.ogg'
	unwieldsound = 'sound/weapons/saberoff.ogg'
	hitsound = "swing_hit"
	armour_penetration = 35
	var/saber_color = "green"
	light_color = "#00ff00"//green
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	wound_bonus = -10
	bare_wound_bonus = 20
	var/hacked = FALSE
	var/brightness_on = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	var/list/possible_colors = list("red", "blue", "green", "purple")

/obj/item/twohanded/dualsaber/suicide_act(mob/living/carbon/user)
	if(wielded)
		user.visible_message(span_suicide("[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!"))

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL	//this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(0.3 SECONDS)
			else
				user.visible_message(span_suicide("[user] panics and starts choking to death!"))
				return OXYLOSS


	else
		user.visible_message(span_suicide("[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!"))
	return BRUTELOSS

/obj/item/twohanded/dualsaber/Initialize()
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		switch(saber_color)
			if("red")
				light_color = LIGHT_COLOR_RED
			if("green")
				light_color = LIGHT_COLOR_GREEN
			if("blue")
				light_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				light_color = LIGHT_COLOR_LAVENDER

/obj/item/twohanded/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/twohanded/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[saber_color][wielded]"
	else
		icon_state = "dualsaber0"
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_TYPE_BLOOD)

/obj/item/twohanded/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna())
		if(user.dna.check_mutation(HULK) || user.dna.check_mutation(ACTIVE_HULK))
			to_chat(user, span_warning("You grip the blade too hard and accidentally close it!"))
			unwield()
			return
	..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && (wielded) && prob(40))
		impale(user)
		return
	if((wielded) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/twohanded/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.emote("flip")
		sleep(0.1 SECONDS)

/obj/item/twohanded/dualsaber/proc/impale(mob/living/user)
	to_chat(user, span_warning("You twirl around a bit before losing your balance and impaling yourself on [src]."))
	if (force_wielded)
		user.take_bodypart_damage(20,25,check_armor = TRUE)
	else
		user.adjustStaminaLoss(25)

/obj/item/twohanded/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return 0

/obj/item/twohanded/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(wielded)
		to_chat(user, span_warning("You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!"))
		return 1

/obj/item/twohanded/dualsaber/wield(mob/living/carbon/M) //Specific wield () hulk checks due to reflection chance for balance issues and switches hitsounds.
	if(M.has_dna())
		if(M.dna.check_mutation(HULK) || M.dna.check_mutation(ACTIVE_HULK))
			to_chat(M, span_warning("You lack the grace to wield this!"))
			return
	..()
	if(wielded)
		sharpness = SHARP_EDGED
		w_class = w_class_on
		hitsound = 'sound/weapons/blade1.ogg'
		START_PROCESSING(SSobj, src)
		set_light(brightness_on)

/obj/item/twohanded/dualsaber/unwield() //Specific unwield () to switch hitsounds.
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	..()
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light(0)

/obj/item/twohanded/dualsaber/process()
	if(wielded)
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/twohanded/dualsaber/IsReflect()
	if(wielded)
		return 1

/obj/item/twohanded/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/transforming/energy, mostly
	if(!wielded)
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/twohanded/dualsaber/green
	possible_colors = list("green")

/obj/item/twohanded/dualsaber/red
	possible_colors = list("red")

/obj/item/twohanded/dualsaber/blue
	possible_colors = list("blue")

/obj/item/twohanded/dualsaber/purple
	possible_colors = list("purple")

/obj/item/twohanded/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, span_warning("2XRNBW_ENGAGE"))
			saber_color = "rainbow"
			update_icon()
		else
			to_chat(user, span_warning("It's starting to look like a triple rainbow - no, nevermind."))
	else
		return ..()

//spears
/obj/item/twohanded/spear
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 2, DAMAGE_HIGH = 5)
	wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 2, DAMAGE_HIGH = 5)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 8
	throwforce = 20
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 3)
	armour_penetration = 10
	materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	break_message = "%SRC's cable binding suddenly snaps"
	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"
	wound_bonus = -15
	bare_wound_bonus = 15

/obj/item/twohanded/spear/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.

/obj/item/twohanded/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/twohanded/spear/Initialize()
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/twohanded/spear/update_icon()
	icon_state = "[icon_prefix][wielded]"

/obj/item/twohanded/spear/deconstruct() //we drop our rod and maybe the glass shard used
	new /obj/item/stack/rods(get_turf(src))
	if(!prob(20)) //20% chance to save our spearhead
		break_message += " and its head smashes into pieces!"
		return ..()
	var/spearhead = icon_prefix == "spear_plasma" ? /obj/item/shard/plasma : /obj/item/shard //be honest we have this stored  //we do NOT have this stored
	new spearhead(get_turf(src))
	break_message += "!"
	..()

/obj/item/twohanded/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if (istype(tip, /obj/item/shard/plasma))
		force_wielded += 1
		force += 1
		throwforce += 1
		righthand_file = 'yogstation/icons/mob/inhands/weapons/polearms_righthand.dmi' //yogs
		mob_overlay_icon = 'yogstation/icons/mob/clothing/back.dmi' //yogs
		icon_prefix = "spearplasma"
	update_icon()
	qdel(tip)
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/twohanded/spear/explosive/lance = new /obj/item/twohanded/spear/explosive(src.loc, G)
		lance.force_wielded = force_wielded
		lance.force = force
		lance.throwforce = throwforce
		lance.icon_prefix = icon_prefix
		parts_list -= G
		qdel(src)
	..()


/obj/item/twohanded/spear/explosive
	name = "explosive lance"
	var/obj/item/grenade/explosive = null

/obj/item/twohanded/spear/explosive/Initialize(mapload, obj/item/grenade/G)
	. = ..()
	if (!G)
		G = new /obj/item/grenade/iedcasing() //For admin-spawned explosive lances
	G.forceMove(src)
	explosive = G
	desc = "A makeshift spear with [G] attached to it"
	update_icon()

/obj/item/twohanded/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.prime()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/twohanded/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/twohanded/spear/explosive/update_icon()
	icon_state = "spearbomb[wielded]"

/obj/item/twohanded/spear/explosive/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		..()
		if(istype(user) && loc == user)
			var/input = stripped_input(user,"What do you want your war cry to be? You will shout it when you hit someone in melee.", ,"", 50)
			if(input)
				src.war_cry = input

/obj/item/twohanded/spear/explosive/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded)
		user.say("[war_cry]", forced="spear warcry")
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)

// CHAINSAW
/obj/item/twohanded/required/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon = 'icons/obj/tools.dmi'
	icon_state = "chainsaw_off"
	var/icon_name = "chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	var/force_on = 24
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	materials = list(/datum/material/iron=13000)
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = "swing_hit"
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/startchainsaw)
	var/on = FALSE

/obj/item/twohanded/required/chainsaw/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 100, 0, 'sound/weapons/chainsawhit.ogg', TRUE)

/obj/item/twohanded/required/chainsaw/suicide_act(mob/living/carbon/user)
	if(on)
		user.visible_message(span_suicide("[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/weapons/chainsawhit.ogg', 100, 1)
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			myhead.dismember()
	else
		user.visible_message(span_suicide("[user] smashes [src] into [user.p_their()] neck, destroying [user.p_their()] esophagus! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/weapons/genhit1.ogg', 100, 1)
	return(BRUTELOSS)

/obj/item/twohanded/required/chainsaw/attack_self(mob/user)
	on = !on
	to_chat(user, "As you pull the starting cord dangling from [src], [on ? "it begins to whirr." : "the chain stops moving."]")
	force = on ? force_on : initial(force)
	throwforce = on ? force_on : initial(force)
	icon_state = "[icon_name]_[on ? "on" : "off"]"
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on

	if(on)
		hitsound = 'sound/weapons/chainsawhit.ogg'
	else
		hitsound = "swing_hit"

	if(src == user.get_active_held_item()) //update inhands
		user.update_inv_hands()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/twohanded/required/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = span_warning("VRRRRRRR!!!")
	armour_penetration = 100
	force_on = 30

/obj/item/twohanded/required/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message(span_danger("Ranged attacks just make [owner] angrier!"))
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
		return 1
	return 0

/obj/item/twohanded/required/chainsaw/demon
	name = "demon chainsaw"
	desc = "Show me your dreams."
	icon_state = "demon_off"
	force_on = 30
	icon_name = "demon"

/obj/item/twohanded/required/chainsaw/demon/Initialize()
	. = ..()
	AddComponent(/datum/component/lifesteal, 30)

//GREY TIDE
/obj/item/twohanded/spear/grey_tide
	icon_state = "spearglass0"
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force = 15
	force_wielded = 10
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	throwforce = 20
	throw_speed = 4
	attack_verb = list("gored")

/obj/item/twohanded/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.faction |= "greytide([REF(user)])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

/obj/item/twohanded/pitchfork
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	force_wielded = 8
	attack_verb = list("attacked", "impaled", "pierced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

/obj/item/twohanded/pitchfork/trident
	icon_state = "trident"
	name = "trident"
	desc = "A trident recovered from the ruins of atlantis"
	force = 14
	throwforce = 23
	force_wielded = 6

/obj/item/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_wielded = 6

/obj/item/twohanded/pitchfork/demonic/Initialize()
	. = ..()
	set_light(3,6,LIGHT_COLOR_RED)

/obj/item/twohanded/pitchfork/demonic/greater
	force = 24
	throwforce = 50
	force_wielded = 10

/obj/item/twohanded/pitchfork/demonic/ascended
	force = 100
	throwforce = 100
	force_wielded = 500000 // Kills you DEAD.

/obj/item/twohanded/pitchfork/update_icon()
	icon_state = "pitchfork[wielded]"

/obj/item/twohanded/pitchfork/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] impales [user.p_them()]self in [user.p_their()] abdomen with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/twohanded/pitchfork/demonic/pickup(mob/living/user)
	. = ..()
	if(isliving(user) && user.mind && user.owns_soul() && !is_devil(user))
		var/mob/living/U = user
		U.visible_message(span_warning("As [U] picks [src] up, [U]'s arms briefly catch fire."), \
			span_warning("\"As you pick up [src] your arms ignite, reminding you of all your past sins.\""))
		if(ishuman(U))
			var/mob/living/carbon/human/H = U
			H.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		else
			U.adjustFireLoss(rand(force/2,force))

/obj/item/twohanded/pitchfork/demonic/attack(mob/target, mob/living/carbon/human/user)
	if(user.mind && user.owns_soul() && !is_devil(user))
		to_chat(user, "<span class ='warning'>[src] burns in your hands.</span>")
		user.apply_damage(rand(force/2, force), BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	..()

/obj/item/twohanded/pitchfork/demonic/ascended/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !wielded)
		return
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		user.visible_message(span_danger("[user] blasts \the [target] with \the [src]!"))
		playsound(target, 'sound/magic/disintegrate.ogg', 100, 1)
		W.break_wall()
		W.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return

//HF blade

/obj/item/twohanded/vibro_weapon
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "vibro sword"
	desc = "A potent weapon capable of cutting through nearly anything. Wielding it in two hands will allow you to deflect gunfire."
	force = 20
	force_wielded = 20
	armour_penetration = 100
	block_chance = 40
	throwforce = 20
	throw_speed = 4
	sharpness = SHARP_EDGED
	attack_verb = list("cut", "sliced", "diced")
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/twohanded/vibro_weapon/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 20, 105)

/obj/item/twohanded/vibro_weapon/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		final_block_chance *= 2
	if(wielded || attack_type != PROJECTILE_ATTACK)
		if(prob(final_block_chance))
			if(attack_type == PROJECTILE_ATTACK)
				owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
				playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
				return 1
			else
				owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
				return 1
	return 0

/obj/item/twohanded/vibro_weapon/update_icon()
	icon_state = "hfrequency[wielded]"

/*
 * Bone Axe
 */
/obj/item/twohanded/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 18

/obj/item/twohanded/fireaxe/boneaxe/update_icon()
	icon_state = "bone_axe[wielded]"

/*
 * Bone Spear
 */
/obj/item/twohanded/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "bone_spear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 11
	max_integrity = 100
	weapon_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0, ENCUMBRANCE_TIME = 0, REACH = 1, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 9					//I have no idea how to balance
	throwforce = 22
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 3)
	armour_penetration = 15				//Enhanced armor piercing
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED

/obj/item/twohanded/bonespear/update_icon()
	icon_state = "bone_spear[wielded]"

/obj/item/twohanded/bonespear/chitinspear //like a mix of a bone spear and bone axe, but more like a bone spear. And better.
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "chitin_spear0"
	name = "chitin spear"
	desc = "A well constructed spear with a sharpened edge akin to a naginata, making it equally great for slicing and throwing."
	force = 13
	force_wielded = 10
	throwforce = 25
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored", "sliced", "ripped", "cut")

/obj/item/twohanded/bonespear/chitinspear/update_icon()
	icon_state = "chitin_spear[wielded]"

/obj/item/twohanded/binoculars
	name = "binoculars"
	desc = "Used for long-distance surveillance."
	icon = 'icons/obj/tools.dmi'
	item_state = "binoculars"
	icon_state = "binoculars"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/mob/listeningTo
	var/zoom_out_amt = 6
	var/zoom_amt = 10

/obj/item/twohanded/binoculars/Destroy()
	listeningTo = null
	return ..()

/obj/item/twohanded/binoculars/wield(mob/user)
	. = ..()
	if(!wielded)
		return
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/unwield)
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, .proc/rotate)
	listeningTo = user
	user.visible_message("[user] holds [src] up to [user.p_their()] eyes.","You hold [src] up to your eyes.")
	item_state = "binoculars_wielded"
	user.regenerate_icons()
	user.client.view_size.zoomOut(zoom_out_amt, zoom_amt, user.dir)

/obj/item/twohanded/binoculars/unwield(mob/user)
	. = ..()
	UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_ATOM_DIR_CHANGE)
	listeningTo = null
	item_state = "binoculars"
	user.regenerate_icons()
	user.client.view_size.zoomIn()

/obj/item/twohanded/binoculars/proc/rotate(atom/thing, old_dir, new_dir)
	if(ismob(thing))
		var/mob/lad = thing
		lad.regenerate_icons()
		lad.client.view_size.zoomOut(zoom_out_amt, zoom_amt, new_dir)

/obj/item/twohanded/bamboospear
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "bamboo_spear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_wielded = 8
	throwforce = 22
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 2)
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = SHARP_EDGED

/obj/item/twohanded/bamboospear/update_icon()
	icon_state = "bamboo_spear[wielded]"

// Baseball Bats
/obj/item/twohanded/required/baseball_bat
	name = "baseball bat"
	desc = "A traditional tool for a game of Baseball. Modern wood isn't very strong, try not to crack the bat!"
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 12
	wound_bonus = -5
	throwforce = 8
	attack_verb = list("beat", "smacked")
	sharpness = SHARP_NONE
	w_class = WEIGHT_CLASS_HUGE
	var/homerun_ready = 0
	var/homerun_able = 0
	var/flimsy = TRUE //spesswood? only used for knockback check now

/obj/item/twohanded/required/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = 1
	durability = 10


/obj/item/twohanded/required/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		..()
		return
	if(homerun_ready)
		to_chat(user, span_notice("You're already ready to do a home run!"))
		return
	to_chat(user, span_warning("You begin gathering strength..."))
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, 1)
	if(do_after(user, 9 SECONDS, src))
		to_chat(user, span_userdanger("You gather power! Time for a home run!"))
		homerun_ready = 1
	..()

/obj/item/twohanded/required/baseball_bat/attack(mob/living/target, mob/living/user)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(target == user)
		return
	if(homerun_ready)
		user.visible_message(span_userdanger("It's a home run!"))
		target.throw_at(throw_target, rand(8,10), 14, user)
		SSexplosions.medturf += throw_target
		playsound(get_turf(src), 'sound/weapons/homerun.ogg', 100, 1)
		homerun_ready = 0
		return
	else if(!flimsy && !target.anchored)
		var/whack_speed = (prob(60) ? 1 : 4)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)

/obj/item/twohanded/required/baseball_bat/metal_bat
	name = "titanium baseball bat"
	desc = "This bat is made of titanium, it feels light yet strong."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	hitsound = 'yogstation/sound/weapons/bat_hit.ogg'
	force = 15
	throwforce = 12
	flimsy = FALSE
	wound_bonus = 5
	w_class = WEIGHT_CLASS_HUGE
