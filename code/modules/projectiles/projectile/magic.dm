/obj/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	armor_flag = MAGIC
	var/tile_dropoff = 0
	var/tile_dropoff_s = 0
	/// determines what type of antimagic can block the spell projectile
	var/antimagic_flags = MAGIC_RESISTANCE
	/// determines the drain cost on the antimagic item
	var/antimagic_charge_cost = 1

/obj/projectile/magic/prehit(atom/target)
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.can_block_magic(antimagic_flags, antimagic_charge_cost))
			visible_message(span_warning("[src] fizzles on contact with [victim]!"))
			qdel(src)
			return FALSE

	if(istype(target, /obj/machinery/hydroponics)) // even plants can block antimagic
		var/obj/machinery/hydroponics/plant_tray = target
		if(!plant_tray.myseed)
			return
		if(LAZYFIND(plant_tray.myseed.reagents_add, /datum/reagent/water/holywater))
			visible_message(span_warning("[src] fizzles on contact with [plant_tray]!"))
			qdel(src)
			return FALSE
	return ..()

/obj/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"

/obj/projectile/magic/death/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.death(0)

/obj/projectile/magic/spellcard
	name = "enchanted card"
	desc = "A piece of paper enchanted to give it extreme durability and stiffness, along with a very hot burn to anyone unfortunate enough to get hit by a charged one."
	icon_state = "spellcard"
	damage_type = BURN
	damage = 2
	nodamage = FALSE
	antimagic_charge_cost = 0 // since the cards gets spammed like a shotgun

/obj/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = TRUE

/obj/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(isliving(target))
		if(target.hellbound)
			return BULLET_ACT_BLOCK
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.regenerate_limbs()
			C.regenerate_organs()
		if(target.revive(full_heal = 1))
			target.grab_ghost(force = TRUE) // even suicides
			to_chat(target, span_notice("You rise with a start, you're alive!!!"))
		else if(target.stat != DEAD)
			to_chat(target, span_notice("You feel great!"))

/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc && !isobserver(stuff))
			if(do_teleport(stuff, stuff, 10, channel = TELEPORT_CHANNEL_MAGIC))
				teleammount++
				var/smoke_range = max(round(4 - teleammount), 0)
				var/datum/effect_system/fluid_spread/smoke/smoke = new
				smoke.set_up(smoke_range, location = stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
				smoke.start()

/obj/projectile/magic/safety
	name = "bolt of safety"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE

/obj/projectile/magic/safety/on_hit(atom/target)
	. = ..()
	if(isturf(target))
		return BULLET_ACT_HIT

	var/turf/origin_turf = get_turf(target)
	var/turf/destination_turf = find_safe_turf()

	if(do_teleport(target, destination_turf, channel=TELEPORT_CHANNEL_MAGIC))
		for(var/t in list(origin_turf, destination_turf))
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(0, location = t)
			smoke.start()

/obj/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/list/door_types = list(/obj/structure/mineral_door/wood, /obj/structure/mineral_door/iron, /obj/structure/mineral_door/silver, /obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium, /obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/plasma, /obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/machinery/door))
		open_door(target)
	else
		var/turf/T = get_turf(target)
		if(isclosedturf(T) && !isindestructiblewall(T))
			CreateDoor(T)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	D.Open()

/obj/projectile/magic/door/proc/open_door(obj/machinery/door/D)
	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/change/on_hit(atom/change)
	. = ..()
	wabbajack(change)
	qdel(src)

/proc/wabbajack(mob/living/M, randomize)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags) || HAS_TRAIT(M, TRAIT_SPECIESLOCK))
		return

	M.notransform = TRUE
	M.mobility_flags = NONE
	M.icon = null
	M.cut_overlays()
	M.invisibility = INVISIBILITY_ABSTRACT

	var/list/contents = M.contents.Copy()

	if(iscyborg(M))
		var/mob/living/silicon/robot/Robot = M
		if(Robot.mmi)
			qdel(Robot.mmi)
		Robot.notify_ai(NEW_BORG)
	else
		for(var/obj/item/W in contents)
			if(!M.dropItemToGround(W))
				qdel(W)

	var/mob/living/new_mob

	if(!randomize)
		randomize = pick("monkey","robot","slime","xeno","humanoid","animal")
	switch(randomize)
		if("monkey")
			new_mob = new /mob/living/carbon/monkey(M.loc)

		if("robot")
			var/robot = pick(200;/mob/living/silicon/robot,
							/mob/living/silicon/robot/modules/syndicate,
							/mob/living/silicon/robot/modules/syndicate/medical,
							/mob/living/silicon/robot/modules/syndicate/saboteur,
							200;/mob/living/simple_animal/drone/polymorphed)
			new_mob = new robot(M.loc)
			if(issilicon(new_mob))
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.lawupdate = FALSE
				Robot.connected_ai = null
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				Robot.clear_inherent_laws(0)
				Robot.clear_zeroth_law(0)

		if("slime")
			new_mob = new /mob/living/simple_animal/slime/random(M.loc)

		if("xeno")
			var/Xe
			if(M.ckey)
				Xe = pick(/mob/living/carbon/alien/humanoid/hunter,/mob/living/carbon/alien/humanoid/sentinel)
			else
				Xe = pick(/mob/living/carbon/alien/humanoid/hunter,/mob/living/simple_animal/hostile/alien/sentinel)
			new_mob = new Xe(M.loc)

		if("animal")
			var/path = pick(/mob/living/simple_animal/hostile/carp,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/carp/eyeball,
							/mob/living/simple_animal/hostile/eldritch/raw_prophet,
							/mob/living/simple_animal/hostile/statue,
							/mob/living/simple_animal/hostile/retaliate/bat,
							/mob/living/simple_animal/hostile/retaliate/goat,
							/mob/living/simple_animal/hostile/retaliate/goat/clown,
							/mob/living/simple_animal/hostile/retaliate/clown/mutant/blob,
							/mob/living/simple_animal/hostile/retaliate/clown/clownhulk,
							/mob/living/simple_animal/hostile/killertomato,
							/mob/living/simple_animal/hostile/poison/giant_spider,
							/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
							/mob/living/simple_animal/hostile/blob/blobbernaut/independent,
							/mob/living/simple_animal/hostile/carp/ranged,
							/mob/living/simple_animal/hostile/carp/ranged/chaos,
							/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
							/mob/living/simple_animal/hostile/asteroid/goliath/beast,
							/mob/living/simple_animal/hostile/headcrab,
							/mob/living/simple_animal/hostile/morph,
							/mob/living/simple_animal/hostile/stickman,
							/mob/living/simple_animal/hostile/stickman/dog,
							/mob/living/simple_animal/hostile/megafauna/dragon/lesser,
							/mob/living/simple_animal/hostile/gorilla,
							/mob/living/simple_animal/hostile/lightgeist/healing,
							/mob/living/simple_animal/parrot,
							/mob/living/simple_animal/pet/dog/corgi,
							/mob/living/simple_animal/crab,
							/mob/living/simple_animal/pet/dog/pug,
							/mob/living/simple_animal/pet/cat,
							/mob/living/simple_animal/pet/cat/space,
							/mob/living/simple_animal/chocobo,
							/mob/living/simple_animal/cow,
							/mob/living/simple_animal/hostile/lizard,
							/mob/living/simple_animal/pet/fox,
							/mob/living/simple_animal/pet/catslug,
							/mob/living/simple_animal/pet/cat/cak,
							/mob/living/simple_animal/chick)
			new_mob = new path(M.loc)

		if("humanoid")
			new_mob = new /mob/living/carbon/human(M.loc)

			if(prob(50))
				var/list/chooseable_races = list()
				for(var/speciestype in subtypesof(/datum/species))
					var/datum/species/S = speciestype
					if(initial(S.changesource_flags) & WABBAJACK)
						chooseable_races += speciestype

				if(chooseable_races.len)
					new_mob.set_species(pick(chooseable_races))

			var/mob/living/carbon/human/H = new_mob
			H.randomize_human_appearance(~(RANDOMIZE_SPECIES))
			H.update_body()
			H.update_hair()
			H.update_body_parts()
			H.dna.update_dna_identity()

	if(!new_mob)
		return

	// Some forms can still wear some items
	for(var/obj/item/W in contents)
		new_mob.equip_to_appropriate_slot(W)

	M.log_message("became [new_mob.real_name]", LOG_ATTACK, color="orange")

	new_mob.a_intent = INTENT_HARM

	M.wabbajack_act(new_mob)

	to_chat(new_mob, span_warning("Your form morphs into that of a [randomize]."))

	var/poly_msg = get_policy(POLICY_POLYMORPH)
	if(poly_msg)
		to_chat(new_mob, poly_msg)

	M.transfer_observers_to(new_mob)

	qdel(M)
	return new_mob

/obj/projectile/magic/cheese
	name = "bolt of cheese"
	icon_state = "cheese"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/cheese/on_hit(mob/living/M)
	. = ..()
	cheeseify(M, FALSE)

/proc/cheeseify(mob/living/M, forced = FALSE)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags))
		return
	if(istype(M, /mob/living/simple_animal/cheese))
		M.revive()
		return
	var/mob/living/simple_animal/cheese/B = new(M.loc)
	if(!B)
		return
	M.dropItemToGround(M.get_active_held_item())
	M.dropItemToGround(M.get_inactive_held_item())
	B.temporary = !forced
	B.stored_mob = M
	M.forceMove(B)	
	M.log_message("became [B.real_name]", LOG_ATTACK, color="orange")
	B.desc = "What appears to be [M.real_name] reformed into a wheel of delicious parmesan..."
	B.name = "[M.name] Parmesan"
	B.real_name = "[M.name] Parmesan"
	B.set_stat(CONSCIOUS)
	B.a_intent = INTENT_HARM
	if(M.mind)
		M.mind.transfer_to(B)
	else
		B.key = M.key
	var/poly_msg = get_policy(POLICY_POLYMORPH)
	if(poly_msg)
		to_chat(B, poly_msg)
	M.transfer_observers_to(B)
	to_chat(B, "<span class='big bold'>You are a cheesewheel!</span><b> You're a harmless wheel of parmesan that is remarkably tasty. Careful of people that want to eat you.</b>")
	return B

/obj/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/animate/on_hit(atom/target, blocked = FALSE)
	target.animate_atom_living(firer)
	..()

/atom/proc/animate_atom_living(mob/living/owner = null)
	if((isitem(src) || isstructure(src)) && !is_type_in_list(src, GLOB.protected_objects))
		if(istype(src, /obj/structure/statue/petrified))
			var/obj/structure/statue/petrified/P = src
			if(P.petrified_mob)
				var/mob/living/L = P.petrified_mob
				var/mob/living/simple_animal/hostile/statue/S = new(P.loc, owner)
				S.name = "statue of [L.name]"
				if(owner)
					S.faction = list("[REF(owner)]")
				S.icon = P.icon
				S.icon_state = P.icon_state
				S.copy_overlays(P, TRUE)
				S.color = P.color
				S.atom_colours = P.atom_colours.Copy()
				if(L.mind)
					L.mind.transfer_to(S)
					if(owner)
						to_chat(S, span_userdanger("You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [owner], your creator."))
				P.forceMove(S)
				return
		else
			var/obj/O = src
			if(istype(O, /obj/item/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(loc, src, owner)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(loc, src, owner)

	else if(istype(src, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = src
		if(owner)
			C.ChangeOwner(owner)

/obj/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 20
	damage_type = BURN
	armor_flag = MAGIC
	dismemberment = 50
	nodamage = FALSE

/obj/projectile/magic/spellblade/weak
	damage = 15
	dismemberment = 20
	
/obj/projectile/magic/spellblade/beesword
	name = "stinger"
	icon_state = "bee"
	damage = 1
	damage_type = BRUTE
	dismemberment = 0
	
/obj/projectile/magic/spellblade/beesword/on_hit(atom/target, blocked = FALSE)
	..()
	if(ishuman(target))
		target.reagents.add_reagent(/datum/reagent/toxin/venom, 2)

/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 40
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 20
	armor_flag = MAGIC 
	hitsound = 'sound/weapons/barragespellhit.ogg'

/obj/projectile/magic/locker
	name = "locker bolt"
	icon_state = "locker"
	nodamage = TRUE
	armor_flag = MAGIC
	var/weld = TRUE
	var/created = FALSE //prevents creation of more then one locker if it has multiple hits
	var/locker_suck = TRUE

/obj/projectile/magic/locker/prehit(atom/A)
	if(ismob(A) && locker_suck)
		var/mob/M = A
		if(M.anchored)
			return ..()
		M.forceMove(src)
		return FALSE
	return ..()

/obj/projectile/magic/locker/on_hit(target)
	if(created)
		return ..()
	var/obj/structure/closet/decay/C = new(get_turf(src))
	if(LAZYLEN(contents))
		for(var/atom/movable/AM in contents)
			C.insert(AM)
		C.welded = weld
		C.update_appearance(UPDATE_ICON)
	created = TRUE
	return ..()

/obj/projectile/magic/locker/Destroy()
	locker_suck = FALSE
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	. = ..()

/obj/structure/closet/decay
	breakout_time = 600
	icon_welded = null
	var/magic_icon = "cursed"
	var/weakened_icon = "decursed"
	var/auto_destroy = TRUE

/obj/structure/closet/decay/Initialize(mapload)
	. = ..()
	if(auto_destroy)
		addtimer(CALLBACK(src, PROC_REF(bust_open)), 5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(magicly_lock)), 5)

/obj/structure/closet/decay/proc/magicly_lock()
	if(!welded)
		return
	icon_state = magic_icon
	update_appearance(UPDATE_ICON)

/obj/structure/closet/decay/after_weld(weld_state)
	if(weld_state)
		unmagify()

/obj/structure/closet/decay/proc/decay()
	animate(src, alpha = 0, time = 3 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 3 SECONDS)

/obj/structure/closet/decay/open(mob/living/user)
	. = ..()
	if(.)
		if(icon_state == magic_icon) //check if we used the magic icon at all before giving it the lesser magic icon
			unmagify()
		else
			addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/structure/closet/decay/proc/unmagify()
	icon_state = weakened_icon
	update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)
	icon_welded = "welded"

/obj/projectile/magic/flying
	name = "bolt of flying"
	icon_state = "flight"

/obj/projectile/magic/flying/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		var/atom/throw_target = get_edge_target_turf(L, angle2dir(Angle))
		L.throw_at(throw_target, 200, 4)

/obj/projectile/magic/bounty
	name = "bolt of bounty"
	icon_state = "bounty"

/obj/projectile/magic/bounty/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(STATUS_EFFECT_BOUNTY, firer)

/obj/projectile/magic/antimagic
	name = "bolt of antimagic"
	icon_state = "antimagic"

/obj/projectile/magic/antimagic/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.apply_status_effect(STATUS_EFFECT_ANTIMAGIC)

/obj/projectile/magic/fetch
	name = "bolt of fetching"
	icon_state = "fetch"

/obj/projectile/magic/fetch/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic() || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		var/atom/throw_target = get_edge_target_turf(L, get_dir(L, firer))
		L.throw_at(throw_target, 200, 4)

/obj/projectile/magic/sapping
	name = "bolt of sapping"
	icon_state = "sapping"

/obj/projectile/magic/sapping/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, REF(src), /datum/mood_event/sapped)

/obj/projectile/magic/necropotence
	name = "bolt of necropotence"
	icon_state = "necropotence"

/obj/projectile/magic/necropotence/on_hit(target)
	. = ..()
	if(!isliving(target))
		return

	// Performs a soul tap on living targets hit.
	// Takes away max health, but refreshes their spell cooldowns (if any)
	var/datum/action/cooldown/spell/tap/tap = new(src)
	if(tap.is_valid_target(target))
		tap.cast(target)

	qdel(tap)

/obj/projectile/magic/wipe
	name = "bolt of possession"
	icon_state = "wipe"

/obj/projectile/magic/wipe/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		for(var/x in M.get_traumas())//checks to see if the victim is already going through possession
			if(istype(x, /datum/brain_trauma/special/imaginary_friend/trapped_owner))
				M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
				return BULLET_ACT_BLOCK
		to_chat(M, span_warning("Your mind has been opened to possession!"))
		possession_test(M)
		return BULLET_ACT_HIT

/obj/projectile/magic/wipe/proc/possession_test(mob/living/carbon/target)
	var/datum/brain_trauma/special/imaginary_friend/trapped_owner/trauma = target.gain_trauma(/datum/brain_trauma/special/imaginary_friend/trapped_owner)
	var/poll_message = "Do you want to play as [target.real_name]?"
	if(target.mind)
		poll_message = "[poll_message] Job:[target.mind.assigned_role]."
	if(target.mind && target.mind.special_role)
		poll_message = "[poll_message] Status:[target.mind.special_role]."
	else if(target.mind)
		var/datum/antagonist/A = target.mind.has_antag_datum(/datum/antagonist/)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
	var/list/mob/dead/observer/candidates = pollCandidatesForMob(poll_message, ROLE_PAI, null, FALSE, 10 SECONDS, target)
	if(target.stat == DEAD)//boo.
		return
	if(LAZYLEN(candidates))
		var/mob/dead/observer/ghost = pick(candidates)
		to_chat(target, span_boldnotice("You have been noticed by a ghost and it has possessed you!"))
		var/oldkey = target.key
		target.ghostize(FALSE)
		target.key = ghost.key
		trauma.friend.key = oldkey
		trauma.friend.reset_perspective(null)
		trauma.friend.Show()
		trauma.friend_initialized = TRUE
	else
		to_chat(target, span_notice("Your mind has managed to go unnoticed in the spirit world."))
		qdel(trauma)

/// Gives magic projectiles an area of effect radius that will bump into any nearby mobs
/obj/projectile/magic/aoe
	damage = 0

	/// The AOE radius that the projectile will trigger on people.
	var/trigger_range = 1
	/// Whether our projectile will only be able to hit the original target / clicked on atom
	var/can_only_hit_target = FALSE

	/// Whether our projectile leaves a trail behind it  as it moves.
	var/trail = FALSE
	/// The duration of the trail before deleting.
	var/trail_lifespan = 0 SECONDS
	/// The icon the trail uses.
	var/trail_icon = 'icons/obj/wizard.dmi'
	/// The icon state the trail uses.
	var/trail_icon_state = "trail"


/obj/projectile/magic/aoe/Range()
	if(trigger_range >= 1)
		for(var/mob/living/nearby_guy in range(trigger_range, get_turf(src)))
			if(nearby_guy.stat == DEAD)
				continue
			if(nearby_guy == firer)
				continue
			// Bump handles anti-magic checks for us, conveniently.
			return Bump(nearby_guy)

	return ..()

/obj/projectile/magic/aoe/can_hit_target(atom/target, list/passthrough, direct_target = FALSE, ignore_loc = FALSE)
	if(can_only_hit_target && target != original)
		return FALSE
	return ..()

/obj/projectile/magic/aoe/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(trail)
		create_trail()

/// Creates and handles the trail that follows the projectile.
/obj/projectile/magic/aoe/proc/create_trail()
	if(!trajectory)
		return

	var/datum/point/vector/previous = trajectory.return_vector_after_increments(1, -1)
	var/obj/effect/overlay/trail = new /obj/effect/overlay(previous.return_turf())
	trail.pixel_x = previous.return_px()
	trail.pixel_y = previous.return_py()
	trail.icon = trail_icon
	trail.icon_state = trail_icon_state
	//might be changed to temp overlay
	trail.set_density(FALSE)
	trail.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	QDEL_IN(trail, trail_lifespan)

/obj/projectile/magic/aoe/lightning
	name = "lightning bolt"
	icon_state = "tesla_projectile"	//Better sprites are REALLY needed and appreciated!~
	damage = 25
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3
	armor_flag = MAGIC

	/// The power of the zap itself when it electrocutes someone
	var/zap_power = 2e4
	/// The range of the zap itself when it electrocutes someone
	var/zap_range = 15
	/// The flags of the zap itself when it electrocutes someone
	var/zap_flags = TESLA_MOB_DAMAGE | TESLA_MOB_STUN | TESLA_OBJ_DAMAGE
	/// A reference to the chain beam between the caster and the projectile
	var/datum/beam/chain

/obj/projectile/magic/aoe/lightning/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]")
	return ..()

/obj/projectile/magic/aoe/lightning/on_hit(target)
	. = ..()
	tesla_zap(source = src, zap_range = zap_range, power = zap_power, tesla_flags = zap_flags)

/obj/projectile/magic/aoe/lightning/Destroy()
	QDEL_NULL(chain)
	return ..()

/obj/projectile/magic/aoe/lightning/eldritch
	name = "otherwordly power"
	icon_state = "tesla_projectile"	
	damage = 25
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3
	armor_flag = MAGIC

	zap_power = 9000
	zap_range = 7
	zap_flags = TESLA_MOB_STUN | TESLA_OBJ_DAMAGE

/obj/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = FALSE

	/// Heavy explosion range of the fireball
	var/exp_heavy = 0
	/// Light explosion range of the fireball
	var/exp_light = 2
	/// Fire radius of the fireball
	var/exp_fire = 2
	/// Flash radius of the fireball
	var/exp_flash = 3

/obj/projectile/magic/fireball/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		// between this 10 burn, the 10 brute, the explosion brute, and the onfire burn,
		// you are at about 65 damage if you stop drop and roll immediately
		mob_target.take_overall_damage(burn = 10)

	var/turf/target_turf = get_turf(target)

	explosion(
		target_turf,
		devastation_range = -1,
		heavy_impact_range = exp_heavy,
		light_impact_range = exp_light,
		flame_range = exp_fire,
		flash_range = exp_flash,
		adminlog = FALSE,
	)

/obj/projectile/magic/fireball/eldritch
	name = "bolt of soul fire"
	icon_state = "fireball"

	damage = 10
	damage_type = BURN
	nodamage = FALSE

	/// Heavy explosion range of the fireball
	exp_heavy = 0
	/// Light explosion range of the fireball
	exp_light = 0
	/// Fire radius of the fireball
	exp_fire = 2
	/// Flash radius of the fireball
	exp_flash = 0

/obj/projectile/magic/aoe/magic_missile
	name = "magic missile"
	icon_state = "magicm"
	range = 20
	speed = 5
	trigger_range = 0
	can_only_hit_target = TRUE
	nodamage = FALSE
	paralyze = 6 SECONDS
	hitsound = 'sound/magic/mm_hit.ogg'

	trail = TRUE
	trail_lifespan = 0.5 SECONDS
	trail_icon_state = "magicmd"

/obj/projectile/magic/aoe/magic_missile/lesser
	color = "red" //Looks more culty this way
	range = 10

/obj/projectile/magic/aoe/juggernaut
	name = "Gauntlet Echo"
	icon_state = "cultfist"
	alpha = 180
	damage = 30
	damage_type = BRUTE
	knockdown = 50
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	ignored_factions = list("cult")
	range = 15
	speed = 7

/obj/projectile/heretic_assault
	name ="mindbolt"
	icon_state= "chronobolt"
	damage = 30
	armour_penetration = 100
	speed = 1
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	range = 5

/obj/projectile/magic/spell/juggernaut/on_hit(atom/target, blocked)
	. = ..()
	var/turf/target_turf = get_turf(src)
	playsound(target_turf, 'sound/weapons/resonator_blast.ogg', 100, FALSE)
	new /obj/effect/temp_visual/cult/sac(target_turf)
	for(var/obj/adjacent_object in range(1, src))
		if(!adjacent_object.density)
			continue
		if(istype(adjacent_object, /obj/structure/destructible/cult))
			continue

		adjacent_object.take_damage(90, BRUTE, MELEE, 0)
		new /obj/effect/temp_visual/cult/turf/floor(get_turf(adjacent_object))

/obj/projectile/magic/fireball/infernal
	name = "infernal fireball"
	exp_heavy = -1
	exp_light = -1
	exp_flash = 4
	exp_fire= 5

/obj/projectile/magic/fireball/infernal/on_hit(target)
	. = ..()
	var/turf/T = get_turf(target)
	for(var/i=0, i<50, i+=10)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), T, -1, exp_heavy, exp_light, exp_flash, FALSE, FALSE, exp_fire), i)

//still magic related, but a different path

/obj/projectile/temp/chill
	name = "bolt of chills"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	armour_penetration = 100
	temperature = 50
	armor_flag = MAGIC


/obj/projectile/temp/runic_icycle
	name = "Icicle"
	icon_state = "runic_icycle"
	damage = 6
	armor_flag = MAGIC
	temperature = 80

/obj/projectile/temp/runic_icycle/on_hit(target)
	.=..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.adjustBruteLoss(5)

/obj/projectile/magic/runic_tentacle
	name = "Tentacle"
	icon_state = "tentacle_end"
	damage = 6
	armor_flag = MAGIC


/obj/projectile/magic/runic_tentacle/on_hit(target)
	if(ismob(target))
		new /obj/effect/temp_visual/goliath_tentacle/original(target)
	.=..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.Paralyze(30)
		X.visible_message(span_warning("Tentacle wraps around [target]!"))
		X.adjustBruteLoss(6)
		new /obj/effect/temp_visual/goliath_tentacle/original(target)

/obj/projectile/magic/runic_heal
	name = "Runic Heal"
	icon_state = "runic_heal"
	armor_flag = MAGIC
	nodamage = TRUE
/obj/projectile/magic/runic_heal/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.adjustBruteLoss(-10)
		X.adjustFireLoss(-10)
		X.adjustToxLoss(-10)
		X.adjustOxyLoss(-10)
		X.adjustCloneLoss(-10)
		var/mob/living/carbon/Y = firer
		Y.adjustBruteLoss(-10)
		Y.adjustFireLoss(-10)
		Y.adjustToxLoss(-10)
		Y.adjustOxyLoss(-10)
		Y.adjustCloneLoss(-10)



/obj/projectile/magic/runic_fire
	name = "Runic Fire"
	icon_state = "lava"
	armor_flag = MAGIC
	nodamage = FALSE

/obj/projectile/magic/runic_fire/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.adjust_fire_stacks(2)
		X.ignite_mob()


/obj/projectile/magic/runic_honk
	name = "Runic Peel"
	icon_state = "runic_honk"
	armor_flag = MAGIC
	range = 200
	movement_type = FLYING
	reflectable = REFLECT_NORMAL
	ricochet_chance = 100
	ricochets_max = 66

/obj/projectile/magic/runic_honk/on_hit(target)
	. = ..()
	var/mob/X = target
	if(istype(X))
		X.slip(75, X.loc, GALOSHES_DONT_HELP|SLIDE, 0, FALSE)


/obj/projectile/magic/runic_bomb
	name = "Runic Bomb"
	icon_state = "runic_bomb"
	armor_flag = MAGIC
	range = 10
	speed = 4
	var/boom = 1

/obj/projectile/magic/runic_bomb/on_hit(target)
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		ADD_TRAIT(X, TRAIT_NODISMEMBER, type)
		ADD_TRAIT(X, TRAIT_SLEEPIMMUNE, type)
		ADD_TRAIT(X, TRAIT_STUNIMMUNE, type)
		spawn(5)
			REMOVE_TRAIT(X, TRAIT_NODISMEMBER, type)
			REMOVE_TRAIT(X, TRAIT_SLEEPIMMUNE, type)
			REMOVE_TRAIT(X, TRAIT_STUNIMMUNE, type)
			X.adjustBruteLoss(-120)
	if(ismob(target))
		var/mob/M = target
		explosion(M, -1, 0, boom, 0, 0)

/obj/projectile/magic/runic_toxin
	name = "Runic Toxin"
	icon_state = "syringeproj"
	armor_flag = MAGIC
	damage = 1
	damage_type = BRUTE
	nodamage = FALSE
	eyeblur = 10

/obj/projectile/magic/runic_toxin/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		if(prob(25))
			X.reagents.add_reagent(/datum/reagent/toxin, 10)
		else
			if(prob(25))
				X.reagents.add_reagent(/datum/reagent/toxin/amatoxin, 10)
			else
				if(prob(50))
					X.reagents.add_reagent(/datum/reagent/toxin/fentanyl, 10)
				else
					if(prob(5))
						X.reagents.add_reagent(/datum/reagent/drug/methamphetamine, 20)
					else
						X.reagents.add_reagent(/datum/reagent/toxin/plasma, 10)


/obj/projectile/magic/runic_death
	name = "Runic Death"
	icon_state = "antimagic"
	armor_flag = MAGIC
	impact_effect_type = /obj/effect/temp_visual/dir_setting/bloodsplatter

/obj/projectile/magic/runic_death/on_hit(mob/living/target)
	. = ..()
	if(iszombie(target))
		target.gib()
	if(isskeleton(target))
		target.gib()
	if(isvampire(target))
		target.adjustBruteLoss(40)


/obj/projectile/magic/shotgun/slug
	name = "Shotgun slug"
	icon_state = "bullet"
	damage = 10
	armor_flag = MAGIC

/obj/projectile/magic/shotgun/slug/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.adjustBruteLoss(10)

/obj/projectile/magic/incediary_slug
	name = "Incendiary shotgun slug"
	icon_state = "bullet"
	damage = 5
	armor_flag = MAGIC


/obj/projectile/magic/incediary_slug/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		X.adjust_fire_stacks(1)
		X.ignite_mob()
		X.adjustBruteLoss(5)

/obj/projectile/magic/runic_mutation
	name = "Runic Mutation"
	icon_state = "toxin"
	armor_flag = MAGIC
	irradiate = 12

/obj/projectile/magic/runic_mutation/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/X = target
		if(prob(66))
			X.easy_random_mutate(NEGATIVE)
		else
			X.easy_random_mutate(MINOR_NEGATIVE)


/obj/projectile/magic/runic_resizement
	name = "Runic Resizement"
	armor_flag = MAGIC
	icon_state = "cursehand1"


/obj/projectile/magic/runic_resizement/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/X = target
		var/newsize1 = 0.5
		var/newsize2 = 0.75
		var/newsize3 = 1
		var/newsize4 = 1.25
		var/newsize5 = 1.50
		var/reresize = pick(newsize1, newsize2, newsize3, newsize4, newsize5)
		X.resize = reresize
		X.update_transform()
		sleep(10 SECONDS)
		if(reresize == 0.5)
			reresize = 2
			X.resize = reresize
			X.update_transform()
		else
			if(reresize == 0.75)
				reresize = 1.3333334
				X.resize = reresize
				X.update_transform()
			else
				if(reresize == 1)
					return
				else
					if(reresize == 1.25)
						reresize = 0.8
						X.resize = reresize
						X.update_transform()
					else
						if(reresize == 1.5)
							reresize = 0.66666667
							X.resize = reresize
							X.update_transform()
		.=..()

/obj/projectile/magic/ion //magic version of ion rifle bullets
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion
	var/ion_severity = EMP_HEAVY //Heavy EMP effect that doesn't spread to adjacent tiles
	var/ion_range = 3

/obj/projectile/magic/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, ion_severity, ion_range)
	return BULLET_ACT_HIT
