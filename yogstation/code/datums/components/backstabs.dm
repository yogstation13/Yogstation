/datum/component/backstabs
	var/backstab_multiplier = 2 // 2x damage by default

/datum/component/backstabs/Initialize(mult)
	backstab_multiplier = mult
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/component/backstabs/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	// No bypassing pacifism nerd
	if(source.force > 0 && HAS_TRAIT(user, TRAIT_PACIFISM) && (source.damtype != STAMINA))
		return
	// Same calculation that kinetic crusher uses
	var/backstab_dir = get_dir(user, target)
	// No backstabbing people if they're already in crit
	if(!target.stat && (user.dir & backstab_dir) && (target.dir & backstab_dir))
		var/multi = backstab_multiplier - 1
		var/dmg = source.force * multi
		if(dmg) // Truthy because backstabs can heal lol
			target.apply_damage(dmg, source.damtype, BODY_ZONE_CHEST, 0, source.wound_bonus*multi, source.bare_wound_bonus*multi, source.sharpness*multi)
			log_combat(user, target, "scored a backstab", source.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(source.damtype)])")
			if(iscarbon(target))
				target.emote("scream") // SPY AROUND HERE
