//Ocular warden: Low-damage, low-range turret. Deals constant damage to whoever it makes eye contact with.
/obj/structure/destructible/clockwork/ocular_warden
	name = "ocular warden"
	desc = "A large brass eye with tendrils trailing below it and a wide red iris."
	clockwork_desc = "A fragile turret which will automatically attack nearby unrestrained non-Servants that can see it."
	icon_state = "ocular_warden"
	unanchored_icon = "ocular_warden_unwrenched"
	max_integrity = 25
	construction_value = 15
	layer = WALL_OBJ_LAYER
	break_message = span_warning("The warden's eye gives a glare of utter hate before falling dark!")
	debris = list(/obj/item/clockwork/component/belligerent_eye/blind_eye = 1)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/damage_per_tick = 12 //yogs: increased damage to make up for slower attack speed
	var/sight_range = 3
	var/atom/movable/target
	var/list/idle_messages = list(" sulkily glares around.", " lazily drifts from side to side.", " looks around for something to burn.", " slowly turns in circles.")
	var/time_between_shots = 4 //yogs: slower attack speed
	var/last_process = 0 //see above

/obj/structure/destructible/clockwork/ocular_warden/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/clockwork/ocular_warden/examine(mob/user)
	. = ..()
	. += span_brass("[target ? "<b>It's fixated on [target]!</b>" : "Its gaze is wandering aimlessly."]")

/obj/structure/destructible/clockwork/ocular_warden/hulk_damage()
	return 25

/obj/structure/destructible/clockwork/ocular_warden/can_be_unfasten_wrench(mob/user, silent)
	if(!anchored)
		for(var/obj/structure/destructible/clockwork/ocular_warden/W in orange(OCULAR_WARDEN_EXCLUSION_RANGE, src))
			if(W.anchored)
				if(!silent)
					to_chat(user, span_neovgre("You sense another ocular warden too near this location. Activating this one this close would cause them to fight."))
				return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/structure/destructible/clockwork/ocular_warden/ratvar_act()
	..()
	if(GLOB.ratvar_awakens)
		damage_per_tick = 40 //yogs: increased damage to make up for slower attack speed
		sight_range = 6
	else
		damage_per_tick = initial(damage_per_tick)
		sight_range = initial(sight_range)

/obj/structure/destructible/clockwork/ocular_warden/process()
	if(!anchored)
		lose_target()
		return
	var/list/validtargets = acquire_nearby_targets()
	if(target)
		if(!(target in validtargets))
			lose_target()
		else //yogs start: slows warden attack speed so it doesn't stop people from moving
			if(last_process + time_between_shots < world.time)
				if(isliving(target))
					var/mob/living/L = target
					if(!L.anti_magic_check(chargecost = 0))
						if(isrevenant(L))
							var/mob/living/simple_animal/revenant/R = L
							if(R.revealed)
								R.unreveal_time += 2
							else
								R.reveal(10)
						if(prob(50))
							L.playsound_local(null,'sound/machines/clockcult/ocularwarden-dot1.ogg',75 * get_efficiency_mod(),1)
						else
							L.playsound_local(null,'sound/machines/clockcult/ocularwarden-dot2.ogg',75 * get_efficiency_mod(),1)
						L.adjustFireLoss((!iscultist(L) ? damage_per_tick : damage_per_tick * 2) * get_efficiency_mod()) //Nar-Sian cultists take additional damage
						Beam(L, icon_state = "warden_beam", time = 10)		//yogs: gives a beam
						last_process = world.time
						if(GLOB.ratvar_awakens && L)
							L.adjust_fire_stacks(damage_per_tick)
							L.IgniteMob()
				else if(ismecha(target))
					var/obj/mecha/M = target
					Beam(M, icon_state = "warden_beam", time = 10)		//yogs: gives a beam
					M.take_damage(damage_per_tick * get_efficiency_mod(), BURN, MELEE, 1, get_dir(src, M))
					last_process = world.time //yogs end

			new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(target))

			setDir(get_dir(get_turf(src), get_turf(target)))
	if(!target)
		if(validtargets.len)
			target = pick(validtargets)
			playsound(src,'sound/machines/clockcult/ocularwarden-target.ogg',50,1)
			visible_message(span_warning("[src] swivels to face [target]!"))
			if(isliving(target))
				var/mob/living/L = target
				to_chat(L, "[span_neovgre("\"I SEE YOU!\"")]\n[span_userdanger("[src]'s gaze [GLOB.ratvar_awakens ? "melts you alive" : "burns you"]!")]")
			else if(ismecha(target))
				var/obj/mecha/M = target
				to_chat(M.occupant, span_neovgre("\"I SEE YOU!\"") )
		else if(prob(0.5)) //Extremely low chance because of how fast the subsystem it uses processes
			if(prob(50))
				visible_message(span_notice("[src][pick(idle_messages)]"))
			else
				setDir(pick(GLOB.cardinals))//Random rotation

/obj/structure/destructible/clockwork/ocular_warden/proc/acquire_nearby_targets()
	. = list()
	for(var/mob/living/L in viewers(sight_range, src)) //Doesn't attack the blind
		var/obj/item/storage/book/bible/B = L.bible_check()
		if(B)
			if(!(B.resistance_flags & ON_FIRE))
				to_chat(L, span_warning("Your [B.name] bursts into flames!"))
			for(var/obj/item/storage/book/bible/BI in L.GetAllContents())
				if(!(BI.resistance_flags & ON_FIRE))
					BI.fire_act()
			continue
		if(is_servant_of_ratvar(L) || (HAS_TRAIT(L, TRAIT_BLIND)) || L.anti_magic_check(TRUE, TRUE))
			continue
		if(L.stat || L.IsStun() || L.IsParalyzed()) //yogs: changes mobility flag to IsStun so people have to taze themselves to ignore warden attacks
			continue
		if(isslime(L)) //Ocular wardens heal slimes
			continue
		if (iscarbon(L))
			var/mob/living/carbon/c = L
			if (istype(c.handcuffed,/obj/item/restraints/handcuffs/clockwork))
				continue
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L
			if(("ratvar" in H.faction) || (!H.mind && ("neutral" in H.faction)))
				continue
			if(ismegafauna(H) || (H.status_flags & GODMODE) || (!H.mind && H.AIStatus == AI_OFF))
				continue
		else if(isrevenant(L))
			var/mob/living/simple_animal/revenant/R = L
			if(R.stasis) //Don't target any revenants that are respawning
				continue
		else if(!L.mind)
			continue
		. += L
	var/list/viewcache = list()
	for(var/N in GLOB.mechas_list)
		var/obj/mecha/M = N
		if(get_dist(M, src) <= sight_range && M.occupant && !is_servant_of_ratvar(M.occupant))
			if(!length(viewcache))
				for (var/obj/Z in view(sight_range, src))
					viewcache += Z
			if (M in viewcache)
				. += M

/obj/structure/destructible/clockwork/ocular_warden/proc/lose_target()
	if(!target)
		return 0
	target = null
	visible_message(span_warning("[src] settles and seems almost disappointed."))
	return 1

/obj/structure/destructible/clockwork/ocular_warden/get_efficiency_mod()
	if(GLOB.ratvar_awakens)
		return 2
	. = 1
	if(target)
		for(var/turf/T in getline(src, target))
			if(T.density)
				. -= 0.1
				continue
			for(var/obj/structure/O in T)
				if(O != src && O.density)
					. -= 0.1
					break
		. -= (get_dist(src, target) * 0.05)
		. = max(., 0.1) //The lowest damage a warden can do is 10% of its normal amount (0.25 by default)
