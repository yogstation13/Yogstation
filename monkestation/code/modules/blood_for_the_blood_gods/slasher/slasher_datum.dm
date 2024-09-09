/datum/outfit/slasher
	name = "Slasher Outfit"
	suit = /obj/item/clothing/suit/apron/slasher
	uniform = /obj/item/clothing/under/color/random/slasher
	shoes = /obj/item/clothing/shoes/slasher_shoes
	mask = /obj/item/clothing/mask/gas/slasher

/datum/antagonist/slasher
	name = "\improper Slasher"
	show_in_antagpanel = TRUE
	roundend_category = "slashers"
	antagpanel_category = "Slasher"
	job_rank = ROLE_SLASHER
	antag_hud_name = "slasher"
	show_name_in_check_antagonists = TRUE
	hud_icon = 'monkestation/icons/mob/slasher.dmi'
	preview_outfit = /datum/outfit/slasher
	show_to_ghosts = TRUE

	///the linked machette that the slasher can summon even if destroyed and is unique to them
	var/obj/item/slasher_machette/linked_machette
	///rallys the amount of souls effects are based on this
	var/souls_sucked = 0
	///our cached brute_mod
	var/cached_brute_mod = 0
	/// the mob we are stalking
	var/mob/living/carbon/human/stalked_human
	/// how close we are in % to finishing stalking
	var/stalk_precent = 0
	///ALL Powers currently owned
	var/list/datum/action/cooldown/slasher/powers = list()

	///this is our team monitor
	var/datum/component/team_monitor/slasher_monitor
	///this is our tracker component
	var/datum/component/tracking_beacon
	var/monitor_key = "slasher_key"

	///weakref list of mobs and their fear
	var/list/fears = list()
	///weakref list of mobs and last fear attempt to stop fear maxxing
	var/list/fear_cooldowns = list()
	///weakref list of mobs and last fear stages
	var/list/fear_stages = list()
	///this is a list of all heartbeaters
	var/list/heartbeats = list()
	//this is a list of all statics
	var/list/mobs_with_fullscreens = list()
	///this is our list of refs over 100 fear
	var/list/total_fear = list()
	///this is our list of tracked people
	var/list/tracked = list()
	///this is our list of seers
	var/list/seers = list()

/datum/antagonist/slasher/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.overlay_fullscreen("slasher_prox", /atom/movable/screen/fullscreen/nearby, 1)

	monitor_key = "slasher_monitor_[current_mob.ckey]"
	tracking_beacon = current_mob.AddComponent(/datum/component/tracking_beacon, monitor_key, null, null, TRUE, "#f3d594")
	slasher_monitor = current_mob.AddComponent(/datum/component/team_monitor, monitor_key, null, tracking_beacon)
	slasher_monitor.show_hud(owner.current)

	ADD_TRAIT(current_mob, TRAIT_BATON_RESISTANCE, "slasher")
	ADD_TRAIT(current_mob, TRAIT_CLUMSY, "slasher")
	ADD_TRAIT(current_mob, TRAIT_DUMB, "slasher")
	ADD_TRAIT(current_mob, TRAIT_NODEATH, "slasher")
	ADD_TRAIT(current_mob, TRAIT_LIMBATTACHMENT, "slasher")
	ADD_TRAIT(current_mob, TRAIT_SLASHER, "slasher")

	var/mob/living/carbon/carbon = current_mob
	var/obj/item/organ/internal/eyes/shadow/shadow = new
	shadow.Insert(carbon, drop_if_replaced = FALSE)

	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(current_mob, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(item_pickup))
	RegisterSignal(current_mob, COMSIG_MOB_DROPPING_ITEM, PROC_REF(item_drop))
	RegisterSignal(current_mob, COMSIG_MOB_ITEM_ATTACK, PROC_REF(check_attack))

	///abilities galore
	for(var/datum/action/cooldown/slasher/listed_slasher as anything in subtypesof(/datum/action/cooldown/slasher))
		var/datum/action/cooldown/slasher/new_ability = new listed_slasher
		new_ability.Grant(current_mob)
		powers |= new_ability

	var/mob/living/carbon/human/human = current_mob
	if(istype(human))
		human.equipOutfit(/datum/outfit/slasher)
	cached_brute_mod = human.dna.species.brutemod


/datum/antagonist/slasher/on_removal()
	. = ..()
	owner.current.clear_fullscreen("slasher_prox", 15)
	owner.current.remove_traits(list(TRAIT_BATON_RESISTANCE, TRAIT_CLUMSY, TRAIT_NODEATH, TRAIT_DUMB, TRAIT_LIMBATTACHMENT), "slasher")
	for(var/datum/action/cooldown/slasher/listed_slasher as anything in powers)
		listed_slasher.Remove(owner.current)

/datum/antagonist/slasher/proc/LifeTick(mob/living/source, seconds_per_tick, times_fired)

	var/list/currently_beating = list()
	var/list/current_statics = list()
	for(var/datum/weakref/held as anything in fear_stages)
		var/stage = fear_stages[held]
		var/mob/living/carbon/human/human = held.resolve()

		if(stage >= 1)
			currently_beating |= held
			if(!(held in heartbeats))
				heartbeats |= held
				human.playsound_local(human, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)

		if(stage >= 2)
			current_statics |= held
			if(!(held in mobs_with_fullscreens))
				human.overlay_fullscreen("slasher_prox", /atom/movable/screen/fullscreen/nearby, 1)
				mobs_with_fullscreens |= held


	for(var/datum/weakref/held_ref as anything in (heartbeats - currently_beating))
		var/mob/living/carbon/human/human = held_ref.resolve()
		human.stop_sound_channel(CHANNEL_HEARTBEAT)
		heartbeats -= held_ref

	for(var/datum/weakref/held_ref as anything in (mobs_with_fullscreens - current_statics))
		var/mob/living/carbon/human/human = held_ref.resolve()
		human.clear_fullscreen("slasher_prox", 15)
		mobs_with_fullscreens -= held_ref

	if(stalked_human)
		for(var/mob/living/carbon/human in view(7, source))
			if(stalked_human != human)
				continue
			if(stalked_human.stat == DEAD)
				failed_stalking()
			stalk_precent += (1 / 1.8)
		if(stalk_precent >= 100)
			finish_stalking()

/datum/antagonist/slasher/proc/finish_stalking()
	to_chat(owner, span_boldwarning("You have finished spooking your victim, and have harvested part of their soul!"))
	if(linked_machette)
		linked_machette.force += 2.5
		linked_machette.throwforce += 2.5
	stalked_human = null

/datum/antagonist/slasher/proc/failed_stalking()
	to_chat(owner, span_boldwarning("You let your victim be taken before it was time!"))
	if(linked_machette)
		linked_machette.force -= 5
		linked_machette.throwforce -= 5
	stalked_human = null

/datum/antagonist/slasher/proc/check_attack(mob/living/attacking_person, mob/living/attacked_mob)
	var/obj/item/held_item = attacking_person.get_active_held_item()

	var/held_force = 3
	if(held_item)
		held_force = held_item.force

	increase_fear(attacked_mob, held_force / 3)

	for(var/i = 1 to (held_force / 3))
		attacked_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))

/datum/antagonist/slasher/proc/item_pickup(datum/input_source, obj/item/source)
	RegisterSignal(source, COMSIG_ITEM_DAMAGE_MULTIPLIER, PROC_REF(damage_multiplier))

/datum/antagonist/slasher/proc/item_drop(datum/input_source, obj/item/source)
	UnregisterSignal(source, COMSIG_ITEM_DAMAGE_MULTIPLIER)

/obj/item/var/last_multi = 1

/datum/antagonist/slasher/proc/damage_multiplier(obj/item/source, mob/living/attacked, def_zone)
	var/health_left = max(0, attacked.health) * 0.01

	attacked.cause_pain(def_zone, source.force)

	source.last_multi = health_left

	return TRUE

/datum/antagonist/slasher/proc/increase_fear(atom/movable/target, amount)
	var/datum/weakref/weak = WEAKREF(target)
	if(!(weak in fear_cooldowns))
		target.AddComponent(/datum/component/hovering_information, /datum/hover_data/slasher_fear, TRAIT_SLASHER)
		fear_cooldowns |= weak
		fear_cooldowns[weak] = 0

	if(fear_cooldowns[weak] > world.time + 10 SECONDS)
		return

	if(!(weak in fears))
		fears |= weak
	fears[weak] += amount

	fear_cooldowns[weak] = world.time
	fear_stage_check(weak)

/datum/antagonist/slasher/proc/reduce_fear_area(amount, area)
	for(var/mob/living/carbon/human/human in range(area, get_turf(owner)))
		var/datum/weakref/weak = WEAKREF(human)
		if(!(weak in fears))
			continue
		fears[weak] -= amount
		fears[weak] = max(fears[weak], 0)
		fear_stage_check(weak)

/datum/antagonist/slasher/proc/reduce_fear(atom/target, amount)
	var/datum/weakref/weak = WEAKREF(target)
	if(!(weak in fears))
		return
	fears[weak] -= amount
	fears[weak] = max(fears[weak], 0)
	fear_stage_check(weak)

/datum/antagonist/slasher/proc/fear_stage_check(datum/weakref/weak)
	var/fear_number = fears[weak]
	var/old_stage = fear_stages[weak]
	var/stage = 0
	switch(fear_number)
		if(0 to 25)
			stage = 0
		if(26 to 50)
			stage = 1
		if(51 to 75)
			stage = 2
		if(76 to 100)
			stage = 3
		else
			stage = 4

	if((weak in fear_stages))
		if(fear_stages[weak] == stage)
			return
	stage_change(weak, stage, old_stage)


/datum/antagonist/slasher/proc/stage_change(datum/weakref/weak, new_stage, last_stage)
	fear_stages[weak] = new_stage

	if(new_stage >= 3)
		try_add_tracker(weak)
	if(new_stage >= 4)
		try_add_seer(weak)


/datum/antagonist/slasher/proc/return_feared_people(range, value)
	var/list/mobs = list()
	for(var/datum/weakref/weak_ref as anything in fears)
		if(fears[weak_ref] < value)
			continue
		var/mob/living/mob = weak_ref.resolve()
		if(get_dist(owner.current, mob) > range)
			continue
		mobs += mob
	return mobs

/datum/antagonist/slasher/proc/try_add_tracker(datum/weakref/weak)
	if(weak in tracked)
		return
	tracked += weak

	var/mob/living/living = weak.resolve()

	var/datum/component/tracking_beacon/beacon = living.AddComponent(/datum/component/tracking_beacon, monitor_key, null, null, TRUE, "#f3d594")
	slasher_monitor.add_to_tracking_network(beacon)

	RegisterSignal(living, COMSIG_LIVING_TRACKER_REMOVED, PROC_REF(remove_tracker))

/datum/antagonist/slasher/proc/remove_tracker(mob/living/source, frequency)
	if(frequency != monitor_key)
		return

	tracked -= WEAKREF(source)
	slasher_monitor.update_all_directions()

/datum/antagonist/slasher/proc/try_add_seer(datum/weakref/weak)
	if(weak in seers)
		return
	seers += weak

	var/mob/living/living = weak.resolve()
	living.AddComponent(/datum/component/see_as_something, owner.current, "wendigo", 'icons/mob/simple/icemoon/64x64megafauna.dmi', "?????")

/datum/hover_data/slasher_fear/setup_data(atom/source, mob/enterer)
	if(!enterer.mind?.has_antag_datum(/datum/antagonist/slasher))
		return
	var/datum/antagonist/slasher/slasher = enterer.mind.has_antag_datum(/datum/antagonist/slasher)

	var/datum/weakref/weak = WEAKREF(source)
	if(!(weak in slasher.fear_stages))
		return
	var/fear_stage = slasher.fear_stages[weak]

	var/image/new_image = new
	new_image.icon = 'monkestation/code/modules/blood_for_the_blood_gods/icons/slasher_ui.dmi'
	new_image.pixel_x = 10
	new_image.plane = GAME_PLANE_UPPER
	switch(fear_stage)
		if(2)
			new_image.icon_state = "they_fear"
		if(3)
			new_image.icon_state = "they_see_no_evil"
		if(4)
			new_image.icon_state = "they_see"
		else
			new_image.icon_state = null

	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)
