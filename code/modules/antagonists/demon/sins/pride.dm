/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_mirror
	name = "Summon Mirror"
	desc = "Summon forth a temporary mirror of sin that will allow you and others to change anything they want about themselves."
	invocation = "Aren't I so amazing?"
	invocation_type = SPELL_INVOCATION_WHISPER
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/mirror/magic/lesser)
	summon_lifespan = 60 SECONDS
	range = 1
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "magic_mirror"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/touch/mend
	name = "Mend"
	desc = "Engulfs your arm in a healing powers. Striking someone with it will heal them a moderate amount. Can't target yourself."
	hand_path = /obj/item/melee/touch_attack/mend
	school = "evocation"
	charge_max = 120
	clothes_req = FALSE
	invocation = "Taste of Sin"
	invocation_type = SPELL_INVOCATION_WHISPER
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "fleshmend"
	action_background_icon_state = "bg_demon"

/obj/item/melee/touch_attack/mend
	name = "Mending Hand"
	desc = "A seemingly pleasant mass of mending energy, ready to heal."
	icon_state = "flagellation"
	item_state = "hivemind"
	catchphrase = "Bask in my aura."

/obj/item/melee/touch_attack/mend/afterattack(atom/target, mob/living/carbon/human/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, span_warning("[M] resists your pride!"))
		to_chat(M, span_warning("A deceptive feeling of pleasre dances around your mind before being suddenly dispelled."))
		..()
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	M.adjustBruteLoss(-20)
	M.adjustFireLoss(-20)
	M.visible_message(span_bold("[M] appears to flash colors of red, before seemingly appearing healthier!"))
	to_chat(M, span_warning("You feel a sinister feeling of soothing recovery."))
	return ..()

