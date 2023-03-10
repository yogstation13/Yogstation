/obj/item/melee/transforming
	sharpness = SHARP_EDGED
	bare_wound_bonus = 20
	var/active = FALSE
	var/force_on = 30 //force when active
	var/faction_bonus_force = 0 //Bonus force dealt against certain factions
	var/throwforce_on = 20
	var/icon_state_on = "axe1"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/list/attack_verb_off = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_SMALL
	var/bonus_active = FALSE //If the faction damage bonus is active
	var/list/nemesis_factions //Any mob with a faction that exists in this list will take bonus damage/effects
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/clumsy_check = TRUE
	var/extend_sound = 'sound/weapons/saberon.ogg'
	var/retract_sound = 'sound/weapons/saberoff.ogg'

/obj/item/melee/transforming/Initialize()
	. = ..()
	if(active)
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
	else
		if(attack_verb_off.len)
			attack_verb = attack_verb_off
	if(is_sharp())
		AddComponent(/datum/component/butchering, 50, 100, 0, hitsound, !active)

/obj/item/melee/transforming/attack_self(mob/living/carbon/user)
	if(transform_weapon(user))
		clumsy_transform_effect(user)

/obj/item/melee/transforming/attack(mob/living/target, mob/living/carbon/human/user)
	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/F in target.faction)
			if(F in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force

/obj/item/melee/transforming/proc/transform_weapon(mob/living/user, supress_message_text)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = hitsound_on
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		icon_state = icon_state_on
		w_class = w_class_on
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_off.len)
			attack_verb = attack_verb_off
		icon_state = initial(icon_state)
		w_class = initial(w_class)
	if(is_sharp())
		var/datum/component/butchering/BT = LoadComponent(/datum/component/butchering)
		BT.butchering_enabled = TRUE
	else
		var/datum/component/butchering/BT = GetComponent(/datum/component/butchering)
		if(BT)
			BT.butchering_enabled = FALSE
	transform_messages(user, supress_message_text)
	add_fingerprint(user)
	return TRUE

/obj/item/melee/transforming/proc/nemesis_effects(mob/living/user, mob/living/target)
	return

/obj/item/melee/transforming/proc/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? extend_sound : retract_sound, 35, 1)  //changed it from 50% volume to 35% because deafness
	if(!supress_message_text)
		to_chat(user, span_notice("[src] [active ? "is now active":"can now be concealed"]."))

/obj/item/melee/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [src], like a doofus!"))
		user.take_bodypart_damage(5,5)

/// Security lethal melee weapon, stats inspired by combat knife and energy sword
/// Legally distinct from /obj/item/twohanded/vibro_weapon
/obj/item/melee/transforming/vib_blade
	name = "vibration blade"
	desc = "A blade with an edge that vibrates rapidly, enabling it to easily cut through armor and flesh alike."
	hitsound = "swing_hit"
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "hfrequency0"
	icon_state_on = "hfrequency0_ext"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 0
	force_on = 20
	throwforce = 0
	throwforce_on = 10
	wound_bonus = -10
	bare_wound_bonus = 0
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	attack_verb_off = list("tapped", "poked")
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	armour_penetration = 25
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = "#40ceff" // badass sheen
	light_on = FALSE
	extend_sound = 'sound/weapons/batonextend.ogg'
	retract_sound = 'sound/weapons/batonextend.ogg'

/obj/item/melee/transforming/vib_blade/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(.)
		set_light_on(active)

/obj/item/melee/transforming/vibroblade/suicide_act(mob/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/vib_blade/ignition_effect(atom/A, mob/user)
	if(!active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [C.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)
