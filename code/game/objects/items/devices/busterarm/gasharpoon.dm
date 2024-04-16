/obj/item/clothing/gloves/gasharpoon
	name = "gas-harpoon"
	desc = "A metal gauntlet with a harpoon attatched, powered by gasoline and traditionally used by space-whalers."
	///reminder to channge all this -- I changed it :)
	icon = 'icons/obj/traitor.dmi'
	icon_state = "gasharpoon"
	item_state = "gasharpoon"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("harpooned", "hooked", "gouged", "pierced")
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


/obj/item/clothing/gloves/gasharpoon/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(power_harpoon))
		var/datum/action/cooldown/buster/megabuster/megaharpoon/l/harpoon = new(user)
		harpoon.Grant(user)

/obj/item/clothing/gloves/gasharpoon/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES)==src)
		UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
		var/datum/action/cooldown/buster/megabuster/megaharpoon/l/harpoon = locate(/datum/action/cooldown/buster/megabuster/megaharpoon/l) in user.actions
		if(harpoon)
			harpoon.Remove(user)
	return ..()


/obj/item/clothing/gloves/gasharpoon/proc/power_harpoon(mob/living/user, atom/movable/target)
	if(!user || user.a_intent!=INTENT_HARM || (!isliving(target) && !isobj(target)) || isitem(target))
		return
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
