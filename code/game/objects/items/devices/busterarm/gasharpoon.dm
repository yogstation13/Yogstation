/obj/item/clothing/gloves/gasharpoon
	name = "gasharpoon"
	desc = "A metal gauntlet with a harpoon attatched, powered by gasoline and traditionally used by space-whalers."
	///reminder to channge all this -- I changed it :)
	icon = 'icons/obj/traitor.dmi'
	icon_state = "gasharpoon"
	item_state = "gasharpoon"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("harpooned", "gouged", "pierced")
	force = 10
	throwforce = 10
	throw_range = 7
	strip_delay = 15 SECONDS
	cold_protection = HANDS
	heat_protection = HANDS
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/click_delay = 1.5
	COOLDOWN_DECLARE(harpoon_cd)

/obj/item/clothing/gloves/gasharpoon/examine(mob/user)
	. = ..()
	. += "Right click to fire the harpoon."

/obj/item/clothing/gloves/gasharpoon/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(power_harpoon))
		RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_click))

/obj/item/clothing/gloves/gasharpoon/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES)==src)
		UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
		UnregisterSignal(user, COMSIG_MOB_CLICKON)
	return ..()

/obj/item/clothing/gloves/gasharpoon/proc/on_click(mob/living/user, atom/target, params)
	if(!user.combat_mode || !isturf(user.loc))
		return NONE
	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[ALT_CLICK])
		return NONE
	if(!modifiers[RIGHT_CLICK])
		return NONE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("[src] is lethally chambered! You don't want to risk harming anyone..."))
		return COMSIG_MOB_CANCEL_CLICKON
	if(!synth_check(user, SYNTH_ORGANIC_HARM))
		return COMSIG_MOB_CANCEL_CLICKON
	if(!COOLDOWN_FINISHED(src, harpoon_cd))
		balloon_alert(user, "can't do that yet!")
		return COMSIG_MOB_CANCEL_CLICKON

	var/obj/projectile/wire/harpoon/harpoon_shot = new(get_turf(src))
	harpoon_shot.preparePixelProjectile(target, user, params)
	harpoon_shot.firer = user
	harpoon_shot.fire()
	playsound(src, 'sound/weapons/batonextend.ogg', 50, FALSE)
	COOLDOWN_START(src, harpoon_cd, 10 SECONDS)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/clothing/gloves/gasharpoon/proc/power_harpoon(mob/living/user, atom/movable/target)
	if(!user || !user.combat_mode || (!isliving(target) && !isobj(target)) || isitem(target))
		return NONE
	do_attack(user, target, force * 2)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1)
	target.visible_message(span_danger("[user]'s gasharpoon pierces through [target.name]!"))
	return COMPONENT_NO_ATTACK_HAND

/obj/item/clothing/gloves/gasharpoon/attack(mob/living/target, mob/living/user)
	power_harpoon(user, target)

/obj/item/clothing/gloves/gasharpoon/proc/do_attack(mob/living/user, atom/target, punch_force)
	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.apply_damage(punch_force, BRUTE, wound_bonus = 30)
	else if(isobj(target))
		var/obj/target_obj = target
		target_obj.take_damage(punch_force, BRUTE, MELEE, FALSE)
	user.do_attack_animation(target, ATTACK_EFFECT_SLASH)
	user.changeNext_move(CLICK_CD_MELEE * click_delay)
