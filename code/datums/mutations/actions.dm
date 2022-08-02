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


/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("Smells begin to make more sense...")
	text_lose_indication = span_notice("Your sense of smell goes back to normal.")
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	synchronizer_coeff = 1
	var/reek = 200

/datum/mutation/human/olfaction/modify()
	if(power)
		var/obj/effect/proc_holder/spell/targeted/olfaction/S = power
		S.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 100
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	var/sensitivity = 1

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	//can we sniff? is there miasma in the air?
	var/datum/gas_mixture/air = user.loc.return_air()
	if(air.get_moles(/datum/gas/miasma) >= 0.1)
		user.adjust_disgust(sensitivity * 45)
		to_chat(user, span_warning("With your overly sensitive nose, you get a whiff of stench and feel sick! Try moving to a cleaner area!"))
		return

	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		for(var/mob/living/carbon/C in GLOB.carbon_list)
			if(prints[md5(C.dna.uni_identity)])
				possible |= C
		if(!length(possible))
			to_chat(user,span_warning("Despite your best efforts, there are no scents to be found on [sniffed]..."))
			return
		tracking_target = input(user, "Choose a scent to remember.", "Scent Tracking") as null|anything in possible
		if(!tracking_target)
			if(!old_target)
				to_chat(user,span_warning("You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was."))
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,span_notice("You pick up the scent of [tracking_target]. The hunt begins."))
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,span_warning("You're not holding anything to smell, and you haven't smelled anything you can track. You smell your skin instead; it's kinda salty."))
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,span_warning("You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug."))
		return
	if(tracking_target == user)
		to_chat(user,span_warning("You smell out the trail to yourself. Yep, it's you."))
		return
	var/turf/pos = get_turf(tracking_target)
	if(usr.z < pos.z)
		to_chat(user,span_warning("The trail leads... way up above you? Huh. They must be really, really far away."))
		return
	else if(usr.z > pos.z)
		to_chat(user,span_warning("The trail leads... way down below you? Huh. They must be really, really far away."))
		return
	var/direction_text = "[dir2text(get_dir(usr, pos))]"
	if(direction_text)
		to_chat(user,span_notice("You consider [tracking_target]'s scent. The trail leads <b>[direction_text].</b>"))

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
	
/datum/mutation/human/firebreath/modify()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/S = power
		S.strength = min(GET_MUTATION_POWER(src), S.strengthMax)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	charge_max = 600
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
	F.exp_light = strength-1
	F.exp_fire += strength

obj/effect/proc_holder/spell/aimed/firebreath/fire_projectile(mob/user)
	. = ..()
	message_admins("[ADMIN_LOOKUPFLW(user)] has shot firebreath at [ADMIN_VERBOSEJMP(user)]")

/obj/item/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4

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
	invocation_type = "shout"
	action_icon = 'icons/mob/actions/actions_humble.dmi'
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/living/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/void/cast(mob/living/user = usr)
	. = ..()
	user.apply_status_effect(STATUS_EFFECT_VOIDED)
