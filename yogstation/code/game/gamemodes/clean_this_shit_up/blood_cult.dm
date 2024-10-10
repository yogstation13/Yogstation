//this is stuff used by antags that's stored on the base gamemode datum
//rework those antags to not need these
/datum/controller/subsystem/gamemode
	// blood cult
	var/list/datum/mind/cult = list()
	var/list/bloodstone_list = list()
	var/anchor_bloodstone
	var/anchor_time2kill = 5 MINUTES
	var/bloodstone_cooldown = FALSE

/datum/controller/subsystem/gamemode/proc/begin_bloodstone_phase()
	var/list/stone_spawns = GLOB.generic_event_spawns.Copy()
	var/list/bloodstone_areas = list()
	for(var/i = 0, i < 4, i++) //four bloodstones
		var/stone_spawn = pick_n_take(stone_spawns)
		if(!stone_spawn)
			stone_spawn = pick(GLOB.generic_event_spawns) // Fallback on all spawns
		var/spawnpoint = get_turf(stone_spawn)
		var/stone = new /obj/structure/destructible/cult/bloodstone(spawnpoint)
		notify_ghosts("Bloodcult has an object of interest: [stone]!", source=stone, action=NOTIFY_ORBIT, header="Praise the Geometer!")
		var/area/A = get_area(stone)
		bloodstone_areas.Add(A.map_name)

	priority_announce("Figments of an eldritch god are being pulled through the veil anomaly in [bloodstone_areas[1]], [bloodstone_areas[2]], [bloodstone_areas[3]], and [bloodstone_areas[4]]! Destroy any occult structures located in those areas!","Central Command Higher Dimensional Affairs")
	addtimer(CALLBACK(src, PROC_REF(increase_bloodstone_power)), 30 SECONDS)
	SSsecurity_level.set_level(SEC_LEVEL_GAMMA)

/datum/controller/subsystem/gamemode/proc/increase_bloodstone_power()
	if(!bloodstone_list.len) //check if we somehow ran out of bloodstones
		return
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		if(B.current_fullness == 9)
			create_anchor_bloodstone()
			return //We're done here
		else
			B.current_fullness++
		B.update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, PROC_REF(increase_bloodstone_power)), 30 SECONDS)

/datum/controller/subsystem/gamemode/proc/create_anchor_bloodstone()
	if(SSgamemode.anchor_bloodstone)
		return
	var/obj/structure/destructible/cult/bloodstone/anchor_target = bloodstone_list[1] //which bloodstone is the current cantidate for anchorship
	var/anchor_power = 0 //anchor will be faster if there are more stones
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		anchor_power++
		if(B.get_integrity() > anchor_target.get_integrity())
			anchor_target = B
	SSgamemode.anchor_bloodstone = anchor_target
	anchor_target.name = "anchor bloodstone"
	anchor_target.desc = "It pulses rhythmically with migraine-inducing light. Something is being reflected on every surface, something that isn't quite there..."
	anchor_target.anchor = TRUE
	anchor_target.modify_max_integrity(1200, can_break = FALSE)
	anchor_time2kill -= anchor_power * 1 MINUTES //one minute of bloodfuckery shaved off per surviving bloodstone.
	anchor_target.set_animate()
	var/area/A = get_area(anchor_target)
	addtimer(CALLBACK(anchor_target, TYPE_PROC_REF(/obj/structure/destructible/cult/bloodstone, summon)), anchor_time2kill)
	priority_announce("The anomaly has weakened the veil to a hazardous level in [A.map_name]! Destroy whatever is causing it before something gets through!","Central Command Higher Dimensional Affairs")

/datum/controller/subsystem/gamemode/proc/cult_loss_bloodstones()
	priority_announce("The veil anomaly appears to have been destroyed, shuttle locks have been lifted.","Central Command Higher Dimensional Affairs")
	bloodstone_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(disable_bloodstone_cooldown)), 5 MINUTES) //5 minutes
	for(var/datum/mind/M in cult)
		var/mob/living/cultist = M.current
		if(!cultist)
			continue
		cultist.playsound_local(cultist, 'sound/magic/demon_dies.ogg', 75, FALSE)
		if(isconstruct(cultist))
			to_chat(cultist, span_cultbold("You feel your form lose some of its density, becoming more fragile!"))
			cultist.maxHealth *= 0.75
			cultist.health *= 0.75
		else
			cultist.Stun(20)
			cultist.adjust_confusion(15 SECONDS)
		to_chat(cultist, span_narsiesmall("Your mind is flooded with pain as the last bloodstone is destroyed!"))

/datum/controller/subsystem/gamemode/proc/cult_loss_anchor()
	priority_announce("Whatever you did worked. Veil density has returned to a safe level. Shuttle locks lifted.","Central Command Higher Dimensional Affairs")
	bloodstone_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(disable_bloodstone_cooldown)), 7 MINUTES) //7 minutes
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		qdel(B)
		for(var/datum/mind/M in cult)
			var/mob/living/cultist = M.current
			if(!cultist)
				continue
			cultist.playsound_local(cultist, 'sound/effects/screech.ogg', 75, FALSE)
			if(isconstruct(cultist))
				to_chat(cultist, span_cultbold("You feel your form lose most of its density, becoming incredibly fragile!"))
				cultist.maxHealth *= 0.5
				cultist.health *= 0.5
			else
				cultist.Stun(4 SECONDS)
				cultist.adjust_confusion(1 MINUTES)
			to_chat(cultist, span_narsiesmall("You feel a bleakness as the destruction of the anchor cuts off your connection to Nar-Sie!"))

/datum/controller/subsystem/gamemode/proc/disable_bloodstone_cooldown()
	bloodstone_cooldown = FALSE
	for(var/datum/mind/M in cult)
		var/mob/living/L = M.current
		if(L)
			to_chat(M, span_narsiesmall("The veil has weakened enough for another attempt, prepare the summoning!"))
		if(isconstruct(L))
			L.maxHealth = initial(L.maxHealth)
			to_chat(L, span_cult("Your form regains its original durability!"))
	//send message to cultists saying they can do stuff again
