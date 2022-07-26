//////////////////////////////////////////
//                                      //
//          LIFEFORCE TRADE             //
//                                      //
//////////////////////////////////////////

/datum/status_effect/lifeforce_trade
	id = "lifeforce_trade"
	duration = 15 SECONDS
	alert_type = null
	tick_interval = 1.2 SECONDS
	var/mob/living/carbon/trader

/datum/status_effect/lifeforce_trade/on_creation(mob/living/new_owner, mob/living/carbon/trading_dude)
	trader = trading_dude
	. = ..()

/datum/status_effect/lifeforce_trade/on_apply()
	to_chat(owner, span_warning("You feel getting linked with [trader]..."))
	return ..()

/datum/status_effect/lifeforce_trade/tick()
	var/what_do_we_do
	var/knockdowned = owner.AmountKnockdown()
	if(knockdowned)
		owner.SetKnockdown(0, TRUE, TRUE)
		trader.AdjustKnockdown(knockdowned*0.65)
		what_do_we_do = "arise"
	var/immobilized = owner.AmountImmobilized()
	if(immobilized)
		owner.SetImmobilized(0, TRUE, TRUE)
		trader.AdjustImmobilized(immobilized*0.65)
		what_do_we_do = "move again"
	var/paralyzed = owner.AmountParalyzed()
	if(paralyzed)
		owner.SetParalyzed(0, TRUE, TRUE)
		trader.AdjustParalyzed(paralyzed*0.65)
		what_do_we_do = "move again"
	var/unconsinius = owner.AmountUnconscious()
	if(unconsinius)
		owner.SetUnconscious(0, TRUE, TRUE)
		trader.AdjustUnconscious(unconsinius*0.65)
		what_do_we_do = "return to consciousness"
	var/sleepin = owner.AmountSleeping()
	if(sleepin)
		owner.SetSleeping(0, TRUE, TRUE)
		trader.AdjustSleeping(sleepin*0.65)
		what_do_we_do = "awake"
	var/stun = owner.AmountStun()
	if(stun)
		owner.SetStun(0, TRUE, TRUE)
		trader.AdjustStun(stun*0.65)
		what_do_we_do = "move again"
	if(what_do_we_do)
		to_chat(owner, span_warning("You feel new energy entering your body. You [what_do_we_do]."))
		to_chat(trader, span_warning("You feel your energy leaving your body, as you sacrifice it to [owner]."))

//////////////////////////////////////////
//                                      //
//              BERSERKER               //
//                                      //
//////////////////////////////////////////

/datum/status_effect/berserker
	id = "berserker"
	duration = 20 SECONDS
	alert_type = /obj/screen/alert/status_effect/berserker
	var/tools = FALSE

/obj/screen/alert/status_effect/berserker
	name = "Berserker"
	desc = "<span class='cult'>FIGHT OR DIE</span>"
	icon_state = "regenerative_core"

/datum/status_effect/berserker/on_apply()
	var/mob/living/carbon/C = owner
	playsound(owner, 'sound/effects/wounds/blood3.ogg', 50, 1)
	to_chat(owner, span_warning("You feel the bloodlust seeping into your mind."))
	ADD_TRAIT(owner, TRAIT_MUTE, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_DEAF, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, STATUS_EFFECT_TRAIT)
	ADD_TRAIT(owner, TRAIT_NO_SPELLS, STATUS_EFFECT_TRAIT)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	if(C.IsAdvancedToolUser())
		tools = TRUE
		ADD_TRAIT(owner, TRAIT_MONKEYLIKE, STATUS_EFFECT_TRAIT)
	return ..()

/datum/status_effect/berserker/on_remove()
	to_chat(owner, span_warning("You feel your humanity returning back."))
	REMOVE_TRAIT(owner, TRAIT_MUTE, STATUS_EFFECT_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_DEAF, STATUS_EFFECT_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_REDUCED_DAMAGE_SLOWDOWN, STATUS_EFFECT_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, STATUS_EFFECT_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_NO_SPELLS, STATUS_EFFECT_TRAIT)
	if(tools)
		REMOVE_TRAIT(owner, TRAIT_MONKEYLIKE, STATUS_EFFECT_TRAIT)
		tools = FALSE
	owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)
	return ..()


/datum/status_effect/berserker/tick()
	var/mob/living/carbon/C = owner
	if(!C)
		return
	C.AdjustAllImmobility(-60, FALSE)
	C.adjustStaminaLoss(-30*REM, 0)

//////////////////////////////////////////
//                                      //
//            BLADE EFFECT              //
//                                      //
//////////////////////////////////////////

/datum/status_effect/hog_blade_effect
	id = "hog_blade_effect_idk"
	duration = 20 SECONDS
	var/apply_message = "fuck you"
	var/remove_message = "you fuck"

/datum/status_effect/hog_blade_effect/on_apply()
	RegisterSignal(owner, COMSIG_ATTACK_HOG_BLADE, .proc/blade_effect)
	to_chat(owner, span_notice(apply_message))
	return ..()


/datum/status_effect/hog_blade_effect/on_remove()
	UnregisterSignal(owner, COMSIG_ATTACK_HOG_BLADE)
	to_chat(owner, span_warning(remove_message))
	return ..()

/datum/status_effect/hog_blade_effect/proc/blade_effect(mob/living/source, obj/item/weapon, mob/target)  ///Do nothing IDK
	return

/datum/status_effect/hog_blade_effect/lifesteal
	id = "hog_lifesteal"
	duration = 20 SECONDS
	apply_message = "You enchant yourself, making your blade attacks steal life from your enemies"
	remove_message = "The lifesteal effect has faded, you no longer steal life with your attacks."

/datum/status_effect/hog_blade_effect/lifesteal/blade_effect(mob/living/source, obj/item/weapon, mob/target)
	source.heal_overall_damage(5, 5)