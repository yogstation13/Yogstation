/datum/guardian_ability
	var/name = "ERROR"
	var/desc = "You should not see this!"
	var/cost = 0
	var/spell_type
	var/obj/effect/proc_holder/spell/spell
	var/list/action_types = list()
	var/list/actions = list()
	var/datum/guardian_stats/master_stats
	var/mob/living/simple_animal/hostile/guardian/guardian
	var/arrow_weight = 1

/datum/guardian_ability/Destroy()
	. = ..()
	if (!QDELETED(guardian))
		Remove()

// note -- all guardian abilities should be able to have Apply() ran multiple times with no problems.
/datum/guardian_ability/proc/Apply()
	if(spell_type && !spell)
		spell = new spell_type
	if(spell && !(spell in guardian.mob_spell_list))
		guardian.AddSpell(spell)
	for (var/action_type in action_types)
		var/datum/action/action = new action_type
		action.Grant(guardian)
		actions += action

/datum/guardian_ability/proc/Remove()
	if (spell)
		guardian.RemoveSpell(spell)
	for (var/A in actions)
		var/datum/action/action = A
		action.Remove(guardian)

/datum/guardian_ability/proc/CanBuy()
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

/datum/guardian_ability/proc/StatusTab()
	SHOULD_CALL_PARENT(TRUE)
	return list()

// major abilities have a mode usually
/datum/guardian_ability/major
	var/has_mode = FALSE
	var/mode = FALSE
	var/recall_mode = FALSE
	var/mode_on_msg = ""
	var/mode_off_msg = ""

/datum/guardian_ability/major/proc/Attack(atom/target)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/RangedAttack(atom/target)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/AfterAttack(atom/target)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/Manifest()
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/Recall()
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/Mode()
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/Health(amount)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/AltClickOn(atom/A)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/CtrlClickOn(atom/A)
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/proc/Berserk()
	SHOULD_CALL_PARENT(FALSE)

/datum/guardian_ability/major/special

// minor ability stub
/datum/guardian_ability/minor

/datum/action/guardian
	icon_icon = 'icons/mob/actions_guardian.dmi'
	background_icon_state = null

/datum/action/guardian/Trigger()
	. = ..()
	if (!.)
		return
	var/mob/living/simple_animal/hostile/guardian/user = owner
	if (QDELETED(user) || !istype(user))
		stack_trace("called Trigger on [type] without a valid user")
		return
	on_use(user)

/datum/action/guardian/proc/on_use(mob/living/simple_animal/hostile/guardian/user)
	SHOULD_CALL_PARENT(FALSE)
