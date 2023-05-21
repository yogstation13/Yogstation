/datum/mutation/human/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	text_gain_indication = span_notice("You can hear your own voice echoing in your mind!")
	text_lose_indication = span_notice("You don't hear your mind echo anymore.")
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10
	energy_coeff = 1

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("Your throat is burning!")
	text_lose_indication = span_notice("Your throat is cooling down.")
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1
	conflicts = list(/datum/mutation/human/cryokinesis)

/datum/mutation/human/firebreath/modify()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/S = power
		S.strength = min(GET_MUTATION_POWER(src), S.strengthMax)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 450
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = 20
	projectile_type = /obj/item/projectile/magic/aoe/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "You build up heat in your mouth."
	deactive_msg = "You swallow the flame."
	var/strength = 1
	var/const/strengthMax = 3
	
/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,span_warning("Something in front of your mouth caught fire!"))
			return FALSE

/obj/effect/proc_holder/spell/aimed/firebreath/ready_projectile(obj/item/projectile/P, atom/target, mob/user, iteration)
	if(!istype(P, /obj/item/projectile/magic/aoe/fireball))
		return
	var/obj/item/projectile/magic/aoe/fireball/F = P
	F.exp_fire += (strength - 1) * 4	// +0, +2 if empowered

obj/effect/proc_holder/spell/aimed/firebreath/fire_projectile(mob/user)
	. = ..()
	message_admins("[ADMIN_LOOKUPFLW(user)] has shot firebreath at [ADMIN_VERBOSEJMP(user)]")

/obj/item/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 3

/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = span_notice("You feel a heavy, dull force just beyond the walls watching you.")
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/human/void/on_life()
	if(!isturf(owner.loc))
		return
	if(prob((0.5+((100-dna.stability)/20))) * GET_MUTATION_SYNCHRONIZER(src)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		owner.apply_status_effect(STATUS_EFFECT_VOIDED)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = FALSE
	antimagic_allowed = TRUE
	charge_max = 600
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = SPELL_INVOCATION_SAY
	action_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/living/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/living/user = usr)
	. = ..()
	user.apply_status_effect(STATUS_EFFECT_VOIDED)
