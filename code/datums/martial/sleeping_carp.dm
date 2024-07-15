/// The rate at which focus decays per second.
#define FOCUS_DECAY_RATE -5
/// Delay before focus starts decaying over time.
#define FOCUS_DECAY_COOLDOWN 2 SECONDS

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	no_guns = TRUE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help
	martial_traits = list(TRAIT_REDUCED_DAMAGE_SLOWDOWN, TRAIT_STRONG_GRABBER)
	/// Focus is built up by attacking and depletes over time or when taking damage.
	var/focus_level = 0
	/// Temporary immunity to focus decay over time.
	var/focus_decay_immunity = 0
	/// Image overlay when building up focus.
	var/image/focus_shield

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/user, make_temporary)
	. = ..()
	user.faction.Add("carp") // fish are friends, not food!
	RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(user, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	START_PROCESSING(SSfastprocess, src)
	focus_shield = new('icons/effects/effects.dmi', icon_state = "topaz-barrier")
	user.update_appearance(UPDATE_OVERLAYS)

/datum/martial_art/the_sleeping_carp/remove(mob/living/carbon/human/user)
	STOP_PROCESSING(SSfastprocess, src)
	UnregisterSignal(user, list(COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_MOB_APPLY_DAMAGE, COMSIG_MOB_CLICKON))
	adjust_focus(-focus_level) // remove space protection and update overlays
	user.faction.Remove("carp")
	QDEL_NULL(focus_shield)
	return ..()

/datum/martial_art/the_sleeping_carp/proc/on_click(mob/living/carbon/human/user, atom/target, params)
	SIGNAL_HANDLER
	if(user.pulling)
		return NONE
	if(world.time < user.next_move)
		return NONE
	if(user == target)
		return NONE
	if(!(user.mobility_flags & MOBILITY_USE))
		return NONE
	if(user.incapacitated())
		return NONE
	if(user.CanReach(target))
		return NONE
	var/list/modifiers = params2list(params)
	if(modifiers[RIGHT_CLICK])
		lunge(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

/datum/martial_art/the_sleeping_carp/proc/lunge(mob/living/carbon/human/user, atom/target)
	playsound(user, 'sound/weapons/punchmiss.ogg', 60, 1, -1)
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, MARTIALART_SLEEPINGCARP)
	user.AddComponent(/datum/component/after_image, 0.5 SECONDS, 0.5, TRUE)
	user.changeNext_move(CLICK_CD_MELEE * 2) // this gets reduced on a successful hit
	user.apply_status_effect(STATUS_EFFECT_DODGING)
	user.throw_at(target, 7, 3, user, TRUE, callback = CALLBACK(src, PROC_REF(end_lunge), user))

/datum/martial_art/the_sleeping_carp/proc/end_lunge(mob/living/carbon/human/user)
	user.remove_status_effect(STATUS_EFFECT_DODGING)
	var/datum/component/after_image = user.GetComponent(/datum/component/after_image)
	if(after_image)
		qdel(after_image)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, MARTIALART_SLEEPINGCARP)

/datum/martial_art/the_sleeping_carp/handle_throw(atom/hit_atom, mob/living/carbon/human/user, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		back_kick(user, hit_atom)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/process(delta_time)
	if(focus_decay_immunity > 0)
		focus_decay_immunity -= delta_time SECONDS
	else if(focus_level > 0)
		adjust_focus(FOCUS_DECAY_RATE * delta_time)

/datum/martial_art/the_sleeping_carp/proc/adjust_focus(amount = 0)
	if(amount > 0) // take some time before losing focus
		focus_decay_immunity = FOCUS_DECAY_COOLDOWN
		if(focus_level <= 0)
			ADD_TRAIT(martial_owner, TRAIT_RESISTLOWPRESSURE, MARTIALART_SLEEPINGCARP) // go hang out with space carp!
			ADD_TRAIT(martial_owner, TRAIT_RESISTCOLD, MARTIALART_SLEEPINGCARP)
	else if(focus_level > 0 && focus_level + amount <= 0)
		REMOVE_TRAIT(martial_owner, TRAIT_RESISTLOWPRESSURE, MARTIALART_SLEEPINGCARP)
		REMOVE_TRAIT(martial_owner, TRAIT_RESISTCOLD, MARTIALART_SLEEPINGCARP)
	focus_level = clamp(focus_level + amount, 0, 100)
	martial_owner.update_appearance(UPDATE_OVERLAYS)

/datum/martial_art/the_sleeping_carp/proc/on_update_overlays(atom/source, list/overlays)
	focus_shield.alpha = (1 - (1 - focus_level/100)**2) * 255
	overlays += focus_shield

/datum/martial_art/the_sleeping_carp/proc/on_apply_damage(mob/living/carbon/human/defender, damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	if(focus_level <= 0)
		return NONE
	if(blocked >= 100)
		return NONE
	if(damage <= 0)
		return NONE
	if(defender.incapacitated())
		return NONE
	var/effective_damage = damage * (damagetype == STAMINA ? 0.5 : 1) * (100 - blocked) / 100
	if(effective_damage > focus_level)
		var/effective_block = 100 * focus_level / effective_damage
		to_chat(defender, "Focus: [focus_level]") // remove this
		adjust_focus(-focus_level) // this needs to be set to zero before calling apply_damage again or it causes an infinite loop
		var/damage_taken = defender.apply_damage(damage, damagetype, def_zone, effective_block, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
		to_chat(defender, "Damage: [damage], Taken: [damage_taken], Armor: [blocked]%, Effective Block: [effective_block]%") // remove this
		defender.visible_message(span_danger("[src] deflects some of the incoming damage!"), span_userdanger("You deflect some of the incoming damage!"))
	else
		adjust_focus(-effective_damage)
		defender.visible_message(span_danger("[src] deflects the attack!"), span_userdanger("You deflect the attack!"))
	return COMPONENT_NO_APPLY_DAMAGE

/datum/martial_art/the_sleeping_carp/proc/on_bullet_act(mob/living/carbon/human/defender, obj/projectile/incoming, def_zone)
	if(!(defender.mobility_flags & MOBILITY_USE))
		return NONE
	if(defender.dna?.check_mutation(HULK))
		return NONE
	var/effective_damage = incoming.damage
	if(defender.status_flags & GODMODE) // you won't take damage anyway, deflect because it looks cool
		effective_damage = 0
	else
		if(incoming.damage_type == STAMINA)
			effective_damage *= 0.5
		effective_damage *= (100 - defender.getarmor(def_zone, incoming.armor_flag)) / 100
	if(effective_damage > focus_level) // can't block the full damage, no reflection
		return NONE
	if(!incoming.nodamage) // only lose focus if it was actually going to do real damage
		adjust_focus(-effective_damage)
	defender.visible_message(span_danger("[defender] deflects the projectile!"), span_userdanger("You deflect the projectile!"))
	playsound(defender, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
	incoming.firer = defender
	if(incoming.hitscan)
		incoming.store_hitscan_collision(incoming.trajectory.copy_to())
	incoming.setAngle(rand(0, 360))//SHING
	return BULLET_ACT_FORCE_PIERCE

/datum/martial_art/the_sleeping_carp/proc/wrist_wrench(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "wrist wrenched (Sleeping Carp)")
		if(A.pulling == D)
			A.stop_pulling()
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(span_warning("[A] grabs [D]'s wrist and wrenches it sideways!"), \
						  span_userdanger("[A] grabs your wrist and violently wrenches it to the side!"))
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		var/obj/item/bodypart/chosen_arm = D.get_active_hand()
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(A.get_punchdamagehigh() / 2, BRUTE, chosen_arm.body_zone, wound_bonus = CANT_WOUND)	//5 damage
		D.Immobilize(1 SECONDS)
		A.Immobilize(0.4 SECONDS)
		adjust_focus(10)
		return TRUE
	return basic_hit(A,D)

// it's called a back kick because your leg is moving opposite the direction your foot is pointing, hitting with the back of your heel
/datum/martial_art/the_sleeping_carp/proc/back_kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if((A.mobility_flags & MOBILITY_STAND) && (D.mobility_flags & MOBILITY_STAND))
		log_combat(A, D, "back kicked (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(
			span_warning("[A] spins around and kicks [D] in the head!"),
			span_userdanger("[A] spins around and kicks you in the jaw!"),
		)
		var/turf/target_turf = get_edge_target_turf(D, get_dir(A, D))
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.throw_at(target_turf, 2, 2, A, TRUE) // throw them back a few tiles
		D.apply_damage(A.get_punchdamagehigh() + 10, A.dna.species.attack_type, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)	//20 damage
		D.Knockdown(CLICK_CD_MELEE) // short knockdown
		A.changeNext_move(CLICK_CD_MELEE * 1.5) // heavy attack, longer cooldown
		A.emote("flip")
		adjust_focus(20)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/suplex(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.pulling == D)
		log_combat(A, D, "suplexed (Sleeping Carp)")
		var/turf/target_turf = get_step(get_turf(A), turn(get_dir(A, D), 180))
		if(target_turf.density)
			D.forceMove(get_turf(A))
		else
			D.forceMove(target_turf)
		D.Knockdown(1.5 SECONDS)
		D.apply_damage(A.get_punchdamagehigh() + focus_level / 5, A.dna.species.attack_type, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)	//10-30 damage
		D.visible_message(
			span_warning("[A] suplexes [D] into [target_turf]!"),
			span_userdanger("[A] suplexes you into [target_turf]!"),
		)
		playsound(target_turf, 'sound/effects/meteorimpact.ogg', 60, 1)
		playsound(A, 'sound/effects/gravhit.ogg', 20, 1)
		A.face_atom(D)
		A.changeNext_move(CLICK_CD_MELEE)
		adjust_focus(20)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/stomach_knee(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed() && A.pulling == D)
		A.stop_pulling()
		log_combat(A, D, "stomach kneed (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message(
			span_warning("[A] knees [D] in the stomach!"),
			span_userdanger("[A] winds you with a knee in the stomach!"),
		)
		D.emote("gasp")
		D.losebreath += 3
		D.Immobilize(0.5 SECONDS)
		D.apply_damage(30, OXY, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		adjust_focus(20)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/elbow_drop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if((A.mobility_flags & MOBILITY_STAND) && !(D.mobility_flags & MOBILITY_STAND))
		var/dunk_damage = A.get_punchdamagehigh() + focus_level // deal damage based on your focus level + punch damage, get dunked on
		adjust_focus(-focus_level) // spend all your focus on one big hit, you get some back later
		log_combat(A, D, "elbow dropped (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(
			span_warning("[A] elbow drops [D]!"),
			span_userdanger("[A] piledrives you with [A.p_their()] elbow!"),
		)
		if(D.stat)
			D.death() //FINISH HIM!
			adjust_focus(50)
		else
			adjust_focus(30)
		A.emote("flip")
		A.forceMove(get_turf(D))
		A.Immobilize(0.5 SECONDS)
		A.changeNext_move(CLICK_CD_MELEE * 2) // take some time to recover
		D.apply_damage(dunk_damage, A.dna.species.attack_type, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
		playsound(get_turf(D), 'sound/effects/wounds/crack2.ogg', 75, 1, -1) // ouch, that's gotta hurt
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return TRUE
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.pulling == D && D.stat != DEAD)
		wrist_wrench(A, D)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.stat == DEAD)
		return basic_hit(A, D)
	if(!(D.mobility_flags & MOBILITY_STAND))
		return elbow_drop(A, D)
	if(A.pulling == D)
		return suplex(A, D)
	return basic_hit(A, D)

/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.stat == DEAD)
		return FALSE
	if(A.pulling == D)
		return stomach_knee(A, D)
	else
		return back_kick(A, D)

/datum/martial_art/the_sleeping_carp/basic_hit(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	var/harm_damage = A.get_punchdamagehigh() + focus_level / 20 //10-15 damage
	D.visible_message(
		span_danger("[A] [atk_verb] [D]!"),
		span_userdanger("[A] [atk_verb] you!"),
	)
	D.apply_damage(harm_damage, A.dna.species.attack_type, wound_bonus = CANT_WOUND)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(D.getBruteLoss() > 90 && (D.mobility_flags & MOBILITY_STAND))
		var/datum/brain_trauma/mild/concussion/ouchie = new()
		D.gain_trauma(ouchie, TRAUMA_RESILIENCE_BASIC)
		D.visible_message(span_warning("[A] knocks [D] out cold with an uppercut!"), span_userdanger("[A] knocks you out cold!"))
		D.Unconscious(2 SECONDS) // short knockout, enough time for an elbow drop
		D.Knockdown(3 SECONDS)
	A.changeNext_move(CLICK_CD_MELEE * 0.75) // basic hits are faster
	log_combat(A, D, "[atk_verb] (Sleeping Carp)")
	if(D.stat != DEAD)
		adjust_focus(10)
	return TRUE

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

	to_chat(usr, "[span_notice("Focus")]: Landing hits builds up focus, which deflects incoming damage and increases the power of some attacks.")
	to_chat(usr, "[span_notice("Wrist Wrench")]: Grab twice. Forces opponent to drop item in hand and immobilizes for a short time.")
	to_chat(usr, "[span_notice("Flying Kick")]: Left click to perform a flying back kick, dealing heavy damage and sending you off balance for a moment.")
	to_chat(usr, "[span_notice("Suplex")]: Left click while grabbing. Decent damage scaling with focus, knocks opponent onto the ground.")
	to_chat(usr, "[span_notice("Stomach Knee")]: Right click while grabbing. Causes temporary suffocation.")
	to_chat(usr, "[span_notice("Elbow Drop")]: Left click a downed opponent. Deals damage based on your focus, instantly kills anyone in critical condition.")

	to_chat(usr, "<b><i>You will only deflect projectiles when you have enough focus to deflect all incoming damage.</i></b>")

/obj/item/melee/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK	
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	base_icon_state = "bostaff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'

/obj/item/melee/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 14, \
	)
	AddComponent(/datum/component/cleave_attack, arc_size=180, requires_wielded=TRUE)
	AddComponent(/datum/component/blocking, block_force = 25, block_flags = WEAPON_BLOCK_FLAGS|PROJECTILE_ATTACK|OMNIDIRECTIONAL_BLOCK|WIELD_TO_BLOCK)

/obj/item/melee/bostaff/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"

/obj/item/melee/bostaff/attack(mob/target, mob/living/user, params)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	var/datum/martial_art/the_sleeping_carp/carp = user.mind?.has_martialart(MARTIALART_SLEEPINGCARP)
	if(carp)
		carp.adjust_focus(15) // synergy!
	var/list/modifiers = params2list(params)
	if(HAS_TRAIT(src, TRAIT_WIELDED) && !(modifiers && modifiers[RIGHT_CLICK])) // right click to harm
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with the front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message(span_warning("[pick(fluffmessages)]"), \
							   span_userdanger("[pick(fluffmessages)]"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 75, 1, -1)
		SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, H, user)
		SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, H, user)
		H.lastattacker = user.real_name
		H.lastattackerckey = user.ckey

		user.do_attack_animation(H)

		log_combat(user, H, "Bo Staffed", src.name, "((DAMTYPE: STAMINA)")
		add_fingerprint(user)
		H.apply_damage(rand(28,33), STAMINA, BODY_ZONE_HEAD)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
									   span_userdanger("[user] knocks you unconscious!"))
				H.SetUnconscious(30 SECONDS)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()
