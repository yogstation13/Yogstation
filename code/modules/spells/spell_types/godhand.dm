/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charges = 1

/obj/item/melee/touch_attack/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	. = ..()
	user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound,50,1)
	charges--
	if(charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper disintegrating touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_notice("You can't get the words out!"))
		return
	var/mob/M = target
	do_sparks(4, FALSE, M.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message(span_warning("[target]'s [A] glows brightly as it wards off the spell!"))
		user.visible_message(span_warning("The feedback blows [user]'s arm off!"),span_userdanger("The spell bounces from [M]'s skin back into your arm!"))
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(SLOT_WEAR_SUIT)
	if(istype(suit))
		M.visible_message(span_danger("[M]'s [suit] explodes off of them into a puddle of gore!"))
		M.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(M.loc)
		return ..()
	M.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching yourself would also be bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_notice("You can't get the words out!"))
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, span_warning("The spell can't seem to affect [M]!"))
		to_chat(M, span_warning("You feel your flesh turn to stone for a moment, then revert back!"))
		..()
		return
	M.Stun(40)
	M.petrify()
	return ..()

/obj/item/melee/touch_attack/flagellate
	name = "\improper flagellating touch"
	desc = "I'd like to see them greytide me now."
	catchphrase = "RETRIBUTION!!"
	on_use_sound = 'sound/magic/wandodeath.ogg'
	icon_state = "flagellation"
	item_state = "hivehand"

/obj/item/melee/touch_attack/flagellate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //flagellating your own mind painfully wouldn't be THAT bad but still bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("You can't reach out!"))
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_notice("You can't get the words out!"))
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, span_warning("The spell can't seem to affect [M]!"))
		to_chat(M, span_warning("You feel faint energies trying to get into your head, before they suddenly vanish!"))
		..()
		return
	M.adjustBruteLoss(18) //same as nullrod, but with a large cooldown, so it should be fine
	M.blur_eyes(10)
	M.confused = max(M.confused, 6)
	M.visible_message(span_danger("[M] cringes in pain as they hold their head for a second!"))
	M.emote("scream")
	to_chat(M, span_warning("You feel an explosion of pain erupt in your mind!"))
	return ..()

/obj/item/melee/touch_attack/pacifism
    name = "\improper pacifism touch"
    desc = "Yes"
    catchphrase = "PAC'FY"
    on_use_sound = 'sound/magic/wandodeath.ogg'
    icon_state = "flagellation"
    item_state = "hivehand"
    color = "#FF0000"

/obj/item/melee/touch_attack/pacifism/afterattack(atom/target, mob/living/carbon/user, proximity)
    if(!proximity || target == user || !isliving(target) || !iscarbon(user))
        return
    var/mob/living/carbon/human/H = target
    if(!H)
        return
    if(H.anti_magic_check())
        return
    H.reagents.add_reagent(/datum/reagent/pax, 5)
    H.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 5)
    H.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)
    to_chat(H, span_notice("You feel calm..."))
    return ..()

/obj/item/melee/touch_attack/touchofdeath		//yogs start
	name = "\improper necrotic touch"
	desc = "What has a beginning but no end?"
	catchphrase = "DIM MAK!!"
	on_use_sound = 'sound/magic/wandodeath.ogg'
	icon_state = "touchofdeath"
	item_state = "touchofdeath"

/obj/item/melee/touch_attack/touchofdeath/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	if(!user.can_speak_vocal())
		to_chat(user, span_notice("You can't get the words out!"))
		return
	var/mob/living/M = target
	do_sparks(4, FALSE, M.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message(span_warning("[target]'s [A] glows brightly as it wards off the spell!"))
		user.visible_message(span_warning("[user]'s arm becomes a pale shade of grey and falls off!"),span_userdanger("The spell bounces from [M]'s skin back into your arm!"))
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(SLOT_WEAR_SUIT)
	if(istype(suit))
		M.visible_message(span_danger("[M]'s [suit] rots away into a pile of goo!"))
		M.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/decal/cleanable/molten_object(M.loc)
		return ..()
	M.adjustBruteLoss(max(200-(M.getOxyLoss() + M.getToxLoss() + M.getBruteLoss() + M.getFireLoss()),0))		
	M.death(FALSE)
	return ..()	//yogs end
