/datum/component/backstabs
	var/backstab_multiplier = 2 // 2x damage by default
	var/stored_ap = 0
	var/cooldown_time = 0 SECONDS
	COOLDOWN_DECLARE(backstab_cooldown)

/datum/component/backstabs/Initialize(mult, cooldown)
	backstab_multiplier = mult
	cooldown_time = cooldown
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(pre_attack))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/backstabs/proc/can_backstab(obj/item/source, atom/target, mob/living/user)
	if(!isliving(target))
		return FALSE
	if(!COOLDOWN_FINISHED(src, backstab_cooldown))
		return
	var/mob/living/living_target = target
	// No bypassing pacifism nerd
	if(source.force > 0 && HAS_TRAIT(user, TRAIT_PACIFISM) && (source.damtype != STAMINA))
		return FALSE
	if(source.force > 0 && is_synth(user))
		return FALSE
	// Same calculation that kinetic crusher uses
	var/backstab_dir = get_dir(user, living_target)
	// No backstabbing people if they're already in crit
	if(living_target.stat || !(user.dir & backstab_dir) || !(living_target.dir & backstab_dir))
		return FALSE
	return TRUE

/datum/component/backstabs/proc/pre_attack(obj/item/source, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(!can_backstab(source, target, user))
		return
	stored_ap = source.armour_penetration
	source.armour_penetration = 100

/datum/component/backstabs/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	// SIGNAL_HANDLER // screaming doesn't sleep!!
	if(!can_backstab(source, target, user))
		return
	var/multi = backstab_multiplier - 1
	var/dmg = source.force * multi
	if(dmg) // Truthy because backstabs can heal lol
		target.apply_damage(dmg, source.damtype, BODY_ZONE_CHEST, 0, source.wound_bonus*multi, source.bare_wound_bonus*multi, source.sharpness*multi)
		log_combat(user, target, "scored a backstab", source.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(source.damtype)])")
		if(iscarbon(target))
			// extra safe to ensure no sleeping
			var/datum/emote/living/scream/scream_emote = new
			scream_emote.run_emote(scream_emote) // SPY AROUND HERE
	source.armour_penetration = stored_ap
	if(cooldown_time > 0)
		COOLDOWN_START(src, backstab_cooldown, cooldown_time)
