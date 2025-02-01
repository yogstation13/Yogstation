#define SPACE_WIND_GOD_FIST_COMBO "HD"
#define CHAOS_REIGNS_COMBO "DH"
#define ONE_THOUSAND_FISTS_COMBO "HH"

#define TUNNEL_ARTS_TRAIT "sleeping_carp"
//god's sketchiest solution

/datum/martial_art/the_tunnel_arts
	name = "The Tunnel Arts"
	id = MARTIALART_TUNNELARTS
	allow_temp_override = FALSE
	help_verb = /mob/living/proc/tunnel_arts_help
	display_combos = TRUE
	/// Probability of successfully blocking attacks while on throw mode
	block_chance = 50
	/// List of traits applied to users of this martial art.
	var/static/list/tunnel_traits = list(
		TRAIT_HARDLY_WOUNDED,
		TRAIT_NOSOFTCRIT,
		TRAIT_BATON_RESISTANCE,
		TRAIT_PERFECT_ATTACKER,
		TRAIT_NOGUNS
	)

/datum/martial_art/the_tunnel_arts/teach(mob/living/new_holder)
	. = ..()
	new_holder.add_traits(tunnel_traits, TUNNEL_ARTS_TRAIT)
	RegisterSignal(new_holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	new_holder.faction |= FACTION_RAT //:D

/datum/martial_art/the_tunnel_arts/on_remove(mob/living/remove_from)
	remove_from.remove_traits(tunnel_traits, TUNNEL_ARTS_TRAIT)
	UnregisterSignal(remove_from, list(COMSIG_ATOM_ATTACKBY))
	remove_from.faction -= FACTION_RAT //:(
	return ..()

/datum/martial_art/the_tunnel_arts/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, SPACE_WIND_GOD_FIST_COMBO))
		reset_streak()
		return god_fist(attacker, defender)

	if(findtext(streak, CHAOS_REIGNS_COMBO))
		reset_streak()
		return chaos_punch(attacker, defender)

	if(findtext(streak, ONE_THOUSAND_FISTS_COMBO))
		reset_streak()
		return thousand_fists(attacker, defender)

	return FALSE

///Space Wind God Fist: Harm Disarm, stuns the target briefly and temporarily causing them to lose personal gravity.
/datum/martial_art/the_tunnel_arts/proc/god_fist(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] uppercuts [defender], sending [defender.p_them()] skyward!"),
		span_userdanger("[attacker] uppercuts you, sending you hurtling through the air!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		ignored_mobs = list(attacker),
	)
	to_chat(attacker, span_danger("You uppercut [defender]!"), type = MESSAGE_TYPE_COMBAT)
	playsound(defender, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "god fist (The Tunnel Arts))")
	defender.apply_damage(20, attacker.get_attack_type(), affecting)
	defender.emote("flip")
	defender.emote("spin")
	defender.apply_status_effect(/datum/status_effect/no_gravity)
	defender.Paralyze(1 SECONDS)
	return TRUE

///Chaos Reigns: Disarm Harm, Launches the target backwards, confuses them and causes the target to randomly lash out at others.
/datum/martial_art/the_tunnel_arts/proc/chaos_punch(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] slams [attacker.p_their()] palm into [defender]!"),
		span_userdanger("[attacker] palm strikes you, rattling you to your very core!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		ignored_mobs = list(attacker),
	)
	to_chat(attacker, span_danger("You palm strike [defender], corrupting [defender.p_their()] Chi energy!"), type = MESSAGE_TYPE_COMBAT)
	playsound(defender, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "god fist (The Tunnel Arts))")
	defender.apply_damage(30, attacker.get_attack_type(), affecting)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
	defender.throw_at(throw_target, 3, 4, attacker)
	defender.apply_status_effect(/datum/status_effect/amok/tunnel_madness)
	defender.adjust_confusion_up_to(5 SECONDS, 10 SECONDS)
	defender.adjust_dizzy_up_to(5 SECONDS, 10 SECONDS)
	return TRUE

///One Thousand Fists: Harm Harm, Delivers a lethal strike, and produces a duplicate of yourself to fight with you. Only works if the target is alive, and has a mind.
/datum/martial_art/the_tunnel_arts/proc/thousand_fists(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] punches [defender] with a rapid series of blows!"),
		span_userdanger("[attacker] rapidly punches you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		ignored_mobs = list(attacker),
	)
	to_chat(attacker, span_danger("You rapidly punch [defender]!"), type = MESSAGE_TYPE_COMBAT)

	// Borrows this trick from standard holoparsites
	for(var/sounds in 1 to 4)
		addtimer(CALLBACK(src, PROC_REF(do_attack_sound), defender.loc), sounds DECISECONDS, TIMER_DELETE_ME)

	log_combat(attacker, defender, "god fist (The Tunnel Arts))")
	defender.apply_damage(20, attacker.get_attack_type(), affecting)

	if(!defender.mind || defender.stat != CONSCIOUS || prob(50))
		return TRUE

	var/mob/living/simple_animal/hostile/illusion/khan_warrior/khan = new(attacker.loc)
	khan.faction = attacker.faction.Copy()
	khan.Copy_Parent(attacker, 100, attacker.health / 2.5, 12, 30)
	khan.GiveTarget(defender)
	attacker.visible_message(
		span_danger("[attacker] seems to duplicate before your very eyes!"),
		span_userdanger("[attacker] seems to duplicate before your eyes!"),
		span_hear("You hear a multitude of stamping feet!"),
		ignored_mobs = list(attacker),
	)
	to_chat(attacker, span_danger("You conjure an illusionary warrior to fight with you!"), type = MESSAGE_TYPE_COMBAT)
	return TRUE

/// Echo our punching sounds
/datum/martial_art/the_tunnel_arts/proc/do_attack_sound(atom/playing_from)
	playsound(playing_from, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

/datum/martial_art/the_tunnel_arts/grab_act(mob/living/attacker, mob/living/defender)
	if(!check_usability(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID

	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	log_combat(attacker, defender, "grabbed (The Tunnel Arts)")
	return MARTIAL_ATTACK_INVALID // normal grab

/datum/martial_art/the_tunnel_arts/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', 100)
			defender.visible_message(
				span_danger("[attacker] snaps the neck of [defender]!"),
				span_userdanger("Your neck is snapped by [attacker]!"),
				span_hear("You hear a sickening snap!"),
				ignored_mobs = attacker
			)
			to_chat(attacker, span_danger("In a swift motion, you snap the neck of [defender]!"), type = MESSAGE_TYPE_COMBAT)
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	log_combat(attacker, defender, "punched (The Tunnel Arts)")
	return MARTIAL_ATTACK_INVALID //normal punch

/datum/martial_art/the_tunnel_arts/disarm_act(mob/living/attacker, mob/living/defender)
	if(!check_usability(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	log_combat(attacker, defender, "disarmed (The Tunnel Arts)")
	return MARTIAL_ATTACK_INVALID // normal disarm

/datum/martial_art/the_tunnel_arts/proc/check_usability(mob/living/khan_user, check_intent = TRUE)
	if(check_intent && !(khan_user.istate & ISTATE_HARM))
		return FALSE
	if(khan_user.incapacitated(IGNORE_GRAB)) //NO STUN
		return FALSE
	if(!(khan_user.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return FALSE
	var/datum/dna/dna = khan_user.has_dna()
	if(dna?.check_mutation(/datum/mutation/human/hulk)) //NO HULK
		return FALSE
	if(!isturf(khan_user.loc)) //NO MOTHERFLIPPIN MECHS!
		return FALSE
	return TRUE

///Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/the_tunnel_arts/proc/on_attackby(mob/living/khan_user, obj/item/melee/touch_attack/touch_weapon, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(touch_weapon) || !check_usability(khan_user, check_intent = !touch_weapon.dangerous))
		return
	khan_user.visible_message(
		span_danger("[khan_user] carefully dodges [attacker]'s [touch_weapon]!"),
		span_userdanger("You take great care to remain untouched by [attacker]'s [touch_weapon]!"),
		ignored_mobs = list(attacker),
	)
	to_chat(attacker, span_userdanger("[khan_user] carefully dodges your [touch_weapon], remaining completely untouched!"), type = MESSAGE_TYPE_COMBAT)
	khan_user.balloon_alert(attacker, "miss!")
	attacker.changeNext_move(CLICK_CD_MELEE)
	playsound(khan_user, 'monkestation/sound/effects/miss.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	return COMPONENT_NO_AFTERATTACK

/// Verb added to humans who learn the tunnel arts.
/mob/living/proc/tunnel_arts_help()
	set name = "Remember the Arts"
	set desc = "Remember the martial techniques of Maint Khan, who brought to the Spinward Sector the knowledge of the Tunnel Arts."
	set category = "The Tunnel Arts"

	to_chat(src, "<b><i>You retreat inward and recall the teachings of the Tunnel Arts...</i></b>\n\
	[span_notice("One Thousand Fists")]: Punch Punch. Deal additional damage every second (consecutive) punch, and potentially conjure forth an illusionary Khan Warrior.\n\
	[span_notice("Chaos Reigns")]: Shove Punch. Launch your opponent away from you and corrupt their Chi energy, causing them to flail madly in their confused state!\n\
	[span_notice("Space Wind God Fist")]: Punch Shove. Send the target spinning helplessly through the air with this vicious uppercut.\n\
	<span class='notice'>While in throw mode (and not stunned, not a hulk, and not in a mech), you can block various attacks against you in melee with your bare hands!</span>")

/mob/living/simple_animal/hostile/illusion/khan_warrior
	speed = 0

#undef SPACE_WIND_GOD_FIST_COMBO
#undef CHAOS_REIGNS_COMBO
#undef ONE_THOUSAND_FISTS_COMBO
