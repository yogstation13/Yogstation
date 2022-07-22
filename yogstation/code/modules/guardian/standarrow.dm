/obj/item/stand_arrow
	name = "mysterious arrow"
	desc = "An ancient arrow. You feel poking yourself, or someone else with it would have... <span class='holoparasite'>unpredictable</span> results."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "standarrow"
	item_state = "standarrow"
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_POINTY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/kill_chance = 50 // people will still chuck these at the nearest security officer anyways, so who cares
	var/in_use = FALSE
	var/uses = 3
	var/users = list()
	var/arrowtype = "magic"
	var/can_requiem = TRUE

/obj/item/stand_arrow/Initialize()
	. = ..()
	GLOB.poi_list += src

/obj/item/stand_arrow/Destroy()
	. = ..()
	GLOB.poi_list -= src

/obj/item/stand_arrow/attack(mob/living/M, mob/living/user)
	if (in_use || !M.client)
		return
	if (!iscarbon(M) && !isguardian(M))
		to_chat(span_italics(span_warning("You can't stab [M], it won't work!")))
		return
	if (M.stat == DEAD)
		to_chat(span_italics(span_warning("You can't stab [M], they're already dead!")))
		return
	var/mob/living/carbon/H = M
	var/mob/living/simple_animal/hostile/guardian/G = M
	user.visible_message(span_warning("[user] prepares to stab [H] with [src]!"), span_notice("You raise [src] into the air."))
	if (do_mob(user, H, 5 SECONDS, uninterruptible=FALSE))
		if (LAZYLEN(H.hasparasites()) || (H.mind && H.mind.has_antag_datum(/datum/antagonist/changeling)) || (isguardian(M) && (users[G] || G.requiem || G.transforming || !can_requiem)))
			H.visible_message(span_holoparasite("[src] rejects [H]!"))
			return
		in_use = TRUE
		log_combat(user, H, "stabbed with stand arrow")
		H.visible_message(span_holoparasite("[src] embeds itself into [H], and begins to glow!"))
		user.dropItemToGround(src, TRUE)
		forceMove(H)
		if (iscarbon(M))
			addtimer(CALLBACK(src, .proc/judge, H), 15 SECONDS)
		else if (isguardian(M))
			INVOKE_ASYNC(src, .proc/requiem, M)

	if (!uses)
		visible_message(span_warning("[src] falls apart!"))
		qdel(src)

/obj/item/stand_arrow/proc/judge(mob/living/carbon/victim)
	if (prob(kill_chance))
		victim.visible_message(span_bolddanger("[victim] stares ahead, eyes full of fear, before collapsing lifelessly into ash, [src] falling out..."))
		log_game("[key_name(victim)] was killed by a stand arrow.")
		forceMove(victim.drop_location())
		victim.adjustCloneLoss(500)
		victim.dust(TRUE)
		in_use = FALSE
	else
		INVOKE_ASYNC(src, .proc/generate_stand, victim)

/obj/item/stand_arrow/proc/requiem(mob/living/simple_animal/hostile/guardian/G)
	G.range = 255
	G.transforming = TRUE
	G.visible_message(span_holoparasite("[G] begins to melt!"))
	to_chat(G, span_holoparasite("This power... You can't handle it! RUN AWAY!"))
	log_game("[key_name(G)] was stabbed by a stand arrow, it is now becoming requiem.")
	var/i = 0
	var/flicker = TRUE
	while(i < 10)
		i++
		G.set_light(4, 10, rgb(rand(1, 127), rand(1, 127), rand(1, 127)))
		var/a = flicker ? 127 : 255
		flicker = !flicker
		animate(G, alpha = a, time = 5 SECONDS)
		sleep(5 SECONDS)
	G.stats.Unapply(G)
	G.requiem = TRUE
	G.name = "[G.name] Requiem"
	G.real_name = "[G.real_name] Requiem"
	G.mind.name = "[G.mind.name] Requiem"
	G.stats.damage = min(G.stats.damage + rand(1,3), 5)
	G.stats.defense = min(G.stats.defense + rand(1,3), 5)
	G.stats.speed = min(G.stats.speed + rand(1,3), 5)
	G.stats.potential = min(G.stats.potential + rand(1,3), 5)
	G.stats.range = min(G.stats.range + rand(1,3), 5)
	for (var/T in subtypesof(/datum/guardian_ability/minor))
		G.stats.TakeMinorAbility(T)
	QDEL_NULL(G.stats.ability)
	var/requiem_ability = pick(subtypesof(/datum/guardian_ability/major/special))
	G.stats.ability = new requiem_ability
	G.stats.Apply(G)
	if (G.berserk)
		G.stats.ability.Berserk()
		log_game("[key_name(G)] went berserk (Damage [level_to_grade(G.stats.damage)], Defense [level_to_grade(G.stats.defense)], Speed [level_to_grade(G.stats.speed)], Potential [level_to_grade(G.stats.potential)], Range [level_to_grade(G.stats.range)], [G.stats.ability.name])")
	else
		log_game("[key_name(G)] became requiem (Damage [level_to_grade(G.stats.damage)], Defense [level_to_grade(G.stats.defense)], Speed [level_to_grade(G.stats.speed)], Potential [level_to_grade(G.stats.potential)], Range [level_to_grade(G.stats.range)], [G.stats.ability.name])")
		var/datum/antagonist/guardian/S = G.mind.has_antag_datum(/datum/antagonist/guardian)
		if (S)
			S.name = "Requiem Guardian"
	G.transforming = FALSE
	G.Recall(TRUE)
	G.visible_message(span_holoparasite("[src] is absorbed into [G]!"))
	qdel(src)


/obj/item/stand_arrow/proc/generate_stand(mob/living/carbon/human/H)
	var/points = 15
	var/list/categories = list("Damage", "Defense", "Speed", "Potential", "Range") // will be shuffled every iteration
	var/list/majors = subtypesof(/datum/guardian_ability/major) - typesof(/datum/guardian_ability/major/special)
	var/list/major_weighted = list()
	for (var/M in majors)
		var/datum/guardian_ability/major/major = new M
		major_weighted[major] = major.arrow_weight
	var/datum/guardian_ability/major/major_ability = pickweight(major_weighted)
	var/datum/guardian_stats/stats = new
	stats.ability = major_ability
	stats.ability.master_stats = stats
	points -= major_ability.cost
	while(points > 0)
		if (!categories.len)
			break
		shuffle_inplace(categories)
		var/cat = pick(categories)
		points--
		switch(cat)
			if ("Damage")
				stats.damage++
				if (stats.damage >= 5)
					categories -= "Damage"
			if ("Defense")
				stats.defense++
				if (stats.defense >= 5)
					categories -= "Defense"
			if ("Speed")
				stats.speed++
				if (stats.speed >= 5)
					categories -= "Speed"
			if ("Potential")
				stats.potential++
				if (stats.potential >= 5)
					categories -= "Potential"
			if ("Range")
				stats.range++
				if (stats.range >= 5)
					categories -= "Range"
	INVOKE_ASYNC(src, .proc/get_stand, H, stats)

/obj/item/stand_arrow/proc/get_stand(mob/living/carbon/H, datum/guardian_stats/stats)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the Guardian Spirit of [H.real_name]?", ROLE_HOLOPARASITE, null, FALSE, 100, POLL_IGNORE_HOLOPARASITE)
	if (LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/hostile/guardian/G = new(H, arrowtype)
		G.summoner = H.mind
		G.key = C.key
		G.mind.enslave_mind_to_creator(H)
		G.RegisterSignal(H, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
		var/datum/antagonist/guardian/S = new
		S.stats = stats
		S.summoner = H.mind
		G.mind.add_antag_datum(S)
		G.stats = stats
		G.stats.Apply(G)
		G.show_detail()
		users[G] = TRUE
		log_game("[key_name(H)] has summoned [key_name(G)], a holoparasite, via the stand arrow.")
		to_chat(H, span_holoparasite("<font color=\"[G.namedatum.color]\"><b>[G.real_name]</b></font> has been summoned!"))
		add_verb(H, list(/mob/living/proc/guardian_comm, /mob/living/proc/guardian_recall, /mob/living/proc/guardian_reset))
		uses--
		in_use = FALSE
		H.visible_message(span_bolddanger("[src] falls out of [H]!"))
		forceMove(H.drop_location())
		if (!uses)
			visible_message(span_warning("[src] falls apart!"))
			qdel(src)
	else
		addtimer(CALLBACK(src, .proc/get_stand, H, stats), 90 SECONDS) // lmao

/obj/item/stand_arrow/examine(mob/user)
	. = ..()
	if (isobserver(user))
		. += span_notice("The arrow has a [span_bold("[kill_chance]%")] chance of killing the user.")
