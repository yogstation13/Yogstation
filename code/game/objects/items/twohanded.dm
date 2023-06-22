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
	if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
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
		unwield(M)
		return

/obj/item/twohanded/equipped(mob/user, slot)
	..()
	if(!user.is_holding(src) && wielded)
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

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/twohanded/dualsaber
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "A more powerful version on the energy sword, it is more capable of blocking energy projectiles than its single bladed counterpart. 'At last we will have revenge' is carved on the side of the handle."
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
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	light_color = "#00ff00" //green
	light_on = FALSE
	wound_bonus = -10
	bare_wound_bonus = 20
	var/hacked = FALSE
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

/obj/item/twohanded/dualsaber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		var/new_color
		switch(saber_color)
			if("red")
				new_color = LIGHT_COLOR_RED
			if("green")
				new_color = LIGHT_COLOR_GREEN
			if("blue")
				new_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				new_color = LIGHT_COLOR_LAVENDER
		set_light_color(new_color)

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
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

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
		set_light_on(TRUE)

/obj/item/twohanded/dualsaber/unwield() //Specific unwield () to switch hitsounds.
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	..()
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/twohanded/dualsaber/process()
	if(wielded)
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/twohanded/dualsaber/IsReflect()
	if(wielded)
		return TRUE

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
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

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

/obj/item/twohanded/dualsaber/makeshift
	name = "makeshift double-bladed energy sword"
	desc = "Two energy swords taped crudely together. 'at last we finally get some revenge' is scribbled on the side with crayon."
	force_wielded = 27 //total of 30 to be equal to an esword, it's literally just two duct taped together

/obj/item/twohanded/dualsaber/makeshift/IsReflect()//only 50% chance to reflect, so it still has the cool effect, but not 100% chance
	if(prob(50))
		return ..()
	return FALSE

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
	slot_flags = ITEM_SLOT_BELT
	force = 14
	throwforce = 23
	force_wielded = 6

/obj/item/twohanded/pitchfork/demonic
	name = "demonic pitchfork"
	desc = "A red pitchfork, it looks like the work of the devil."
	force = 19
	throwforce = 24
	force_wielded = 6
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 6
	light_color = LIGHT_COLOR_RED

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

/*
 * Vxtvul Hammer
 */

/datum/action/item_action/charge_hammer
	name = "Charge the Blast Pads"

/datum/action/item_action/charge_hammer/Trigger()
	var/obj/item/twohanded/vxtvulhammer/vxtvulhammer = target
	if(istype(vxtvulhammer))
		vxtvulhammer.charge_hammer(owner)

/obj/item/twohanded/vxtvulhammer
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "vxtvul_hammer0-0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "Vxtvul Hammer"
	desc = "A relic sledgehammer with charge packs wired to two blast pads on its head. \
			While wielded in two hands, the user can charge a massive blow that will shatter construction and hurl bodies."
	force = 4 //It's heavy as hell
	force_wielded = 24
	armour_penetration = 50 //Designed for shattering walls in a single blow, I don't think it cares much about armor
	throwforce = 18
	attack_verb = list("attacked", "hit", "struck", "bludgeoned", "bashed", "smashed")
	block_chance = 30 //Only works in melee, but I bet your ass you could raise its handle to deflect a sword
	sharpness = SHARP_NONE //Blunt, breaks bones
	wound_bonus = -10
	bare_wound_bonus = 15
	max_integrity = 200
	resistance_flags = ACID_PROOF | FIRE_PROOF
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/effects/hammerhitbasic.ogg'
	slot_flags = ITEM_SLOT_BACK
	actions_types = list(/datum/action/item_action/charge_hammer)
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_HALOGEN
	light_range = 2
	light_power = 2
	var/datum/effect_system/spark_spread/spark_system //It's a surprise tool that'll help us later
	var/charging = FALSE
	var/supercharged = FALSE
	var/toy = FALSE

/obj/item/twohanded/vxtvulhammer/Initialize(mapload) //For the sparks when you begin to charge it
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	set_light_on(FALSE)

/obj/item/twohanded/vxtvulhammer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK || !wielded) //Doesn't work against ranged or if it's not wielded
		final_block_chance = 0 //Please show me how you can block a bullet with an industrial hammer I would LOVE to see it
	return ..()

/obj/item/twohanded/vxtvulhammer/Destroy() //Even though the hammer won't probably be destroyed, Ever™
	QDEL_NULL(spark_system)
	return ..()

/obj/item/twohanded/vxtvulhammer/update_icon()
	icon_state = "vxtvul_hammer[wielded]-[supercharged]"

/obj/item/twohanded/vxtvulhammer/examine(mob/living/carbon/user)
	. = ..()
	if(supercharged)
		. += "<b>Electric sparks</b> are bursting from the blast pads!"

/obj/item/twohanded/vxtvulhammer/unwield(mob/living/carbon/user)
	..()
	if(supercharged) //So you can't one-hand the charged hit
		to_chat(user, span_notice("Your hammer loses its power as you adjust your grip."))
		user.visible_message(span_warning("The sparks from [user]'s hammer suddenly stop!"))
		supercharge()
	if(charging) //So you can't one-hand while charging
		to_chat(user, span_notice("You flip the switch off as you adjust your grip."))
		user.visible_message(span_warning("[user] flicks the hammer off!"))
		charging = FALSE

/obj/item/twohanded/vxtvulhammer/attack(mob/living/carbon/human/target, mob/living/carbon/user) //This doesn't consider objects, only people
	if (charging) //So you can't attack while charging
		to_chat(user, span_notice("You flip the switch off before your attack."))
		user.visible_message(span_warning("[user] flicks the hammer off and raises it!"))
		charging = FALSE
	return ..()

/obj/item/twohanded/vxtvulhammer/AltClick(mob/living/carbon/user)
	charge_hammer(user)

/obj/item/twohanded/vxtvulhammer/proc/supercharge() //Proc to handle when it's charged for light + sprite + damage
	supercharged = !supercharged
	if(supercharged)
		set_light_on(TRUE) //Glows when charged
		if(!toy)
			force = initial(force) + (wielded ? force_wielded : 0) + 12 //12 additional damage for a total of 40 has to be a massively irritating check because of how force_wielded works
			armour_penetration = 100
	else
		set_light_on(FALSE)
		force = initial(force) + (wielded ? force_wielded : 0)
		armour_penetration = initial(armour_penetration)
	update_icon()

/obj/item/twohanded/vxtvulhammer/proc/charge_hammer(mob/living/carbon/user)
	if(!wielded)
		to_chat(user, span_warning("The hammer must be wielded in two hands in order to charge it!"))
		return
	if(supercharged)
		to_chat(user, span_warning("The hammer is already supercharged!"))
	else
		charging = TRUE
		to_chat(user, span_notice("You begin charging the weapon, concentration flowing into it..."))
		user.visible_message(span_warning("[user] flicks the hammer on, tilting [user.p_their()] head down as if in thought."))
		spark_system.start() //Generates sparks when you charge
		if(!do_mob(user, user, ispreternis(user)? 5 SECONDS : 6 SECONDS))
			if(!charging) //So no duplicate messages
				return
			to_chat(user, span_notice("You flip the switch off as you lose your focus."))
			user.visible_message(span_warning("[user]'s concentration breaks!"))
			charging = FALSE
		if(!charging) //No charging for you if you cheat
			return //Has to double-check return because attacking or one-handing won't actually proc !do_mob, so the channel will seem to continue despite the message that pops out, but this actually ensures that it won't charge despite attacking or one-handing
		to_chat(user, span_notice("You complete charging the weapon."))
		user.visible_message(span_warning("[user] looks up as [user.p_their()] hammer begins to crackle and hum!"))
		playsound(loc, 'sound/magic/lightningshock.ogg', 60, TRUE) //Mainly electric crack
		playsound(loc, 'sound/effects/magic.ogg', 40, TRUE) //Reverb undertone
		supercharge()
		charging = FALSE

/obj/item/twohanded/vxtvulhammer/afterattack(atom/target, mob/living/carbon/user, proximity) //Afterattack to properly be able to smack walls
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(target)) //So you don't just lose your supercharge if you miss and wack the floor. No I will NOT let people space with this thing
		return

	if(charging) //Needs a special snowflake check if you hit something that isn't a mob
		if(ismachinery(target) || isstructure(target) || ismecha(target))
			to_chat(user, span_notice("You flip the switch off after your blow."))
			user.visible_message(span_warning("[user] flicks the hammer off after striking [target]!"))
			charging = FALSE

	if(supercharged)
		var/turf/target_turf = get_turf(target) //Does the nice effects first so whatever happens to what's about to get clapped doesn't affect it
		var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
		K.color = color
		playsound(loc, 'sound/effects/powerhammerhit.ogg', 80, FALSE) //Mainly this sound
		playsound(loc, 'sound/effects/explosion3.ogg', 20, TRUE) //Bit of a reverb
		supercharge() //At start so it doesn't give an unintentional message if you hit yourself

		if(ismachinery(target) && !toy)
			var/obj/machinery/machine = target
			machine.take_damage(machine.max_integrity * 2) //Should destroy machines in one hit
			if(istype(target, /obj/machinery/door))
				for(var/obj/structure/door_assembly/door in target_turf) //Will destroy airlock assembly left behind, but drop the parts
					door.take_damage(door.max_integrity * 2)
			else
				for(var/obj/structure/frame/base in target_turf) //Will destroy machine or computer frame left behind, but drop the parts
					base.take_damage(base.max_integrity * 2)
				for(var/obj/structure/light_construct/light in target_turf) //Also light frames because why not
					light.take_damage(light.max_integrity * 2)
			user.visible_message(span_danger("The hammer thunders against the [target.name], demolishing it!"))

		else if(isstructure(target) && !toy)
			var/obj/structure/struct = target
			struct.take_damage(struct.max_integrity * 2) //Destroy structures in one hit too
			if(istype(target, /obj/structure/table))
				for(var/obj/structure/table_frame/platform in target_turf)
					platform.take_damage(platform.max_integrity * 2) //Destroys table frames left behind
			user.visible_message(span_danger("The hammer thunders against the [target.name], destroying it!"))

		else if(iswallturf(target) && !toy)
			var/turf/closed/wall/fort = target
			fort.dismantle_wall(1) //Deletes the wall but drop the materials, just like destroying a machine above
			user.visible_message(span_danger("The hammer thunders against the [target.name], shattering it!"))
			playsound(loc, 'sound/effects/meteorimpact.ogg', 50, TRUE) //Otherwise there's no sound for hitting the wall, since it's just dismantled

		else if(ismecha(target) && !toy)
			var/obj/mecha/mech = target
			mech.take_damage(mech.max_integrity/3) //A third of its max health is dealt as an untyped damage, in addition to the normal damage of the weapon (which has high AP)
			user.visible_message(span_danger("The hammer thunders as it massively dents the plating of the [target.name]!"))

		else if(isliving(target))
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			var/mob/living/victim = target
			if(toy)
				ADD_TRAIT(victim, TRAIT_IMPACTIMMUNE, "Toy Hammer")
				victim.safe_throw_at(throw_target, rand(1,2), 3, callback = CALLBACK(src, PROC_REF(afterimpact), victim))
			else
				victim.throw_at(throw_target, 15, 5) //Same distance as maxed out power fist with three extra force
				victim.Paralyze(2 SECONDS)
				user.visible_message(span_danger("The hammer thunders as it viscerally strikes [target.name]!"))
				to_chat(victim, span_userdanger("Agony sears through you as [user]'s blow cracks your body off its feet!"))
				victim.emote("scream")

/obj/item/twohanded/vxtvulhammer/proc/afterimpact(mob/living/victim)
	REMOVE_TRAIT(victim, TRAIT_IMPACTIMMUNE, "Toy Hammer")

/obj/item/twohanded/vxtvulhammer/pirate //Exact same but different text and sprites
	icon_state = "vxtvul_hammer_pirate0-0"
	name = "pirate Vxtvul Hammer"
	desc = "A relic sledgehammer with charge packs wired to two blast pads on its head. This one has been defaced by Syndicate pirates. \
			While wielded in two hands, the user can charge a massive blow that will shatter construction and hurl bodies."

/obj/item/twohanded/vxtvulhammer/pirate/update_icon()
	icon_state = "vxtvul_hammer_pirate[wielded]-[supercharged]"

/obj/item/twohanded/bigspoon
	name = "comically large spoon"
	desc = "For when you're only allowed one spoonful of something."
	icon = 'yogstation/icons/obj/kitchen.dmi'
	mob_overlay_icon = 'yogstation/icons/mob/clothing/back.dmi'
	icon_state = "bigspoon"
	item_state = "bigspoon0"
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/bigspoon_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/bigspoon_righthand.dmi'
	force = 2 //It's a big unwieldy for one hand
	force_wielded = 16 //cleaver is 15 and sharp, this at least gets to be on-par with a nullrod
	sharpness = SHARP_NONE //issa spoon
	armour_penetration = -50 //literally couldn't possibly be a worse weapon for hitting armour
	throwforce = 1 //it's terribly weighted, what do you expect?
	hitsound = 'sound/items/trayhit1.ogg'
	attack_verb = list("scooped", "bopped", "spooned", "wacked")
	block_chance = 30 //Only works in melee, but I bet your ass you could raise its handle to deflect a sword
	wound_bonus = -10
	bare_wound_bonus = -15
	materials = list(/datum/material/iron=18000)
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK

/obj/item/twohanded/bigspoon/update_icon()
	hitsound = wielded ? 'yogstation/sound/weapons/bat_hit.ogg' : 'sound/items/trayhit1.ogg' //big donk if wielded
	item_state = "bigspoon[wielded]" //i don't know why it's item_state rather than icon_state like every other wielded weapon
