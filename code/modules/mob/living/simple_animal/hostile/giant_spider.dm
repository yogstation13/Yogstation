#define SPIDER_IDLE 0
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

/mob/living/simple_animal/hostile/poison
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin/acid

/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_vis_effect = ATTACK_EFFECT_BITE
	faction = list("spiders")
	pass_flags = PASSTABLE
	move_to_delay = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	unique_name = 1
	gold_core_spawnable = HOSTILE_SPAWN

	footstep_type = FOOTSTEP_MOB_CLAW
	var/busy = SPIDER_IDLE
	var/playable_spider = FALSE
	var/directive = "" //Message passed down to children, to relay the creator's orders

/mob/living/simple_animal/hostile/poison/giant_spider/Initialize(mapload)
	. = ..()
	var/datum/action/innate/spider/lay_web/webbing = new(src)
	webbing.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost) && playable_spider && !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	..()
	if(directive)
		to_chat(src, span_spider("Your mother left you a directive! Follow it at all costs."))
		to_chat(src, span_spider("<b>[directive]</b>"))
		if(mind)
			mind.store_memory(span_spider("<b>[directive]</b>"))

/mob/living/simple_animal/hostile/poison/giant_spider/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_spider(user)

/mob/living/simple_animal/hostile/poison/giant_spider/proc/humanize_spider(mob/user)
	if(key || !playable_spider || stat)//Someone is in it, it's dead, or the fun police are shutting it down
		return 0
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src || QDELETED(src))
		return 1
	if(key)
		to_chat(user, span_notice("Someone else already took this spider."))
		return 1
	key = user.key
	return 1

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/spider = 2, /obj/item/reagent_containers/food/snacks/spiderleg = 8, /obj/item/reagent_containers/food/snacks/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 4
	poison_type = /datum/reagent/toxin/staminatoxin
	var/atom/movable/cocoon_target
	var/fed = 0
	var/static/list/consumed_mobs = list() //the tags of mobs that have been consumed by nurse spiders to lay eggs
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/datahud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	datahud.show_to(src)

	var/datum/action/cooldown/wrap/wrapping = new(src)
	wrapping.Grant(src)

	var/datum/action/innate/spider/lay_eggs/make_eggs = new(src)
	make_eggs.Grant(src)

	var/datum/action/innate/spider/set_directive/give_orders = new(src)
	give_orders.Grant(src)

	var/datum/action/innate/spider/comm/not_hivemind_talk = new(src)
	not_hivemind_talk.Grant(src)

//broodmothers are the queen of the spiders, can send messages to all them and web faster. That rare round where you get a queen spider and turn your 'for honor' players into 'r6siege' players will be a fun one.
/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife
	name = "broodmother"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 40
	health = 40
	gold_core_spawnable = HOSTILE_SPAWN //yogs xenobio spiders best spiders

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/Initialize(mapload)
	. = ..()
	var/datum/action/innate/spider/comm/letmetalkpls = new(src)
	letmetalkpls.Grant(src)

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 10
	move_to_delay = 5

//recluses are the rare variant of the hunter, no IMMEDIATE damage but so much poison medical care will be needed fast.
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper
	name = "void recluse"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 1
	poison_per_bite = 12
	move_to_delay = 4
	poison_type = /datum/reagent/toxin/venom //all in venom, glass cannon. you bite 5 times and they are DEFINITELY dead, but 40 health and you are extremely obvious. Ambush, maybe?
	speed = 1
	gold_core_spawnable = NO_SPAWN

//tarantulas are really tanky, regenerating (maybe), hulky monster but are also extremely slow, so.
/mob/living/simple_animal/hostile/poison/giant_spider/tarantula
	name = "tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 300 // woah nelly
	health = 300
	melee_damage_lower = 35
	melee_damage_upper = 40
	poison_per_bite = 0
	move_to_delay = 8
	speed = 7
	status_flags = NONE
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = NO_SPAWN
	var/slowed_by_webs = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/tarantula/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(slowed_by_webs)
		if(!(locate(/obj/structure/spider/stickyweb) in loc))
			remove_movespeed_modifier(MOVESPEED_ID_TARANTULA_WEB)
			slowed_by_webs = FALSE
	else if(locate(/obj/structure/spider/stickyweb) in loc)
		add_movespeed_modifier(MOVESPEED_ID_TARANTULA_WEB, priority=100, multiplicative_slowdown=3)
		slowed_by_webs = TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/ice //spiders dont usually like tempatures of 140 kelvin who knew
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/ice
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice
	name = "giant ice spider"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_action()
	if(!..()) //AIStatus is off
		return 0
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(!busy && prob(1))
			stop_automated_movement = 1
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = 0
				walk(src,0)
		return 1

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = FALSE
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_action()
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return

			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				for(var/datum/action/innate/spider/lay_web/lay_web in actions)
					lay_web.Activate()
			else
				//third, lay an egg cluster there
				if(fed)
					for(var/datum/action/innate/spider/lay_eggs/lay_eggs in actions)
						lay_eggs.Activate()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)

						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				cocoon()

	else
		busy = SPIDER_IDLE
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/cocoon()
	if(stat != DEAD && cocoon_target && !cocoon_target.anchored)
		if(cocoon_target == src)
			to_chat(src, span_warning("You can't wrap yourself!"))
			return
		if(istype(cocoon_target, /mob/living/simple_animal/hostile/poison/giant_spider))
			to_chat(src, span_warning("You can't wrap other spiders!"))
			return
		if(!Adjacent(cocoon_target))
			to_chat(src, span_warning("You can't reach [cocoon_target]!"))
			return
		if(busy == SPINNING_COCOON)
			to_chat(src, span_warning("You're already spinning a cocoon!"))
			return //we're already doing this, don't cancel out or anything
		busy = SPINNING_COCOON
		visible_message(span_notice("[src] begins to secrete a sticky substance around [cocoon_target]."),span_notice("You begin wrapping [cocoon_target] into a cocoon."))
		stop_automated_movement = TRUE
		walk(src,0)
		if(do_after(src, 5 SECONDS, cocoon_target))
			if(busy == SPINNING_COCOON)
				log_admin("[src] spun a cocoon around [cocoon_target]")
				var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
				if(isliving(cocoon_target))
					var/mob/living/L = cocoon_target
					if(L.blood_volume && (L.stat != DEAD || !consumed_mobs[L.tag])) //if they're not dead, you can consume them anyway
						consumed_mobs[L.tag] = TRUE
						fed++
						for(var/datum/action/innate/spider/lay_eggs/lay_eggs in actions)
							lay_eggs.build_all_button_icons(TRUE)
						visible_message(span_danger("[src] sticks a proboscis into [L] and sucks a viscous substance out."),span_notice("You suck the nutriment out of [L], feeding you enough to lay a cluster of eggs."))
						L.death() //you just ate them, they're dead.
					else
						to_chat(src, span_warning("[L] cannot sate your hunger!"))
				cocoon_target.forceMove(C)

				if(cocoon_target.density || ismob(cocoon_target))
					C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	busy = SPIDER_IDLE
	stop_automated_movement = FALSE

/datum/action/innate/spider
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/spider/lay_web // Todo: Unify this with the genetics power
	name = "Spin Web"
	desc = "Spin a web to slow down potential prey."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
		return FALSE

	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner
	var/obj/structure/spider/stickyweb/web = locate() in get_turf(spider)
	if(web) //&& !spider.web_sealer) //if(web && (!spider.web_sealer || istype(web, /obj/structure/spider/stickyweb/sealed)))
		to_chat(owner, span_warning("There's already a web here!"))
		return FALSE

	if(!isturf(spider.loc))
		return FALSE

	return TRUE

/datum/action/innate/spider/lay_web/Activate()
	var/turf/spider_turf = get_turf(owner)
	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner
	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	if(web)
		spider.visible_message(
			span_notice("[spider] begins to pack more webbing onto the web."),
			span_notice("You begin to seal the web."),
		)
	else
		to_chat(spider, span_warning("You're already doing something else!"))
		spider.visible_message(
			span_notice("[spider] begins to secrete a sticky substance."),
			span_notice("You begin to lay a web."),
		)

	spider.stop_automated_movement = TRUE

	if(do_after(spider, 4 SECONDS, target = spider_turf))
		if(spider.loc == spider_turf)
			if(web)
				qdel(web)
//				new /obj/structure/spider/stickyweb/sealed(spider_turf)
			new /obj/structure/spider/stickyweb(spider_turf)

	spider.stop_automated_movement = FALSE

/datum/action/cooldown/wrap
	name = "Wrap"
	desc = "Wrap something or someone in a cocoon. If it's a human or similar species, \
		you'll also consume them, allowing you to lay enriched eggs."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "wrap_0"
	check_flags = AB_CHECK_CONSCIOUS
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/wrap_target.dmi'
	/// The time it takes to wrap something.
	var/wrap_time = 5 SECONDS

/datum/action/cooldown/wrap/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(owner.incapacitated())
		return FALSE
	return TRUE

/datum/action/cooldown/wrap/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B>"))
	button_icon_state = "wrap_0"
	build_all_button_icons()

/datum/action/cooldown/wrap/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You no longer prepare to wrap something in a cocoon."))
	button_icon_state = "wrap_1"
	build_all_button_icons()

/datum/action/cooldown/wrap/Activate(atom/to_wrap)
	if(!owner.Adjacent(to_wrap))
		owner.balloon_alert(owner, "must be closer!")
		return FALSE

	if(!ismob(to_wrap) && !isobj(to_wrap))
		return FALSE

	if(to_wrap == owner)
		return FALSE

	if(istype(to_wrap, /mob/living/simple_animal/hostile/poison/giant_spider))
		owner.balloon_alert(owner, "can't wrap spiders!")
		return FALSE

	var/atom/movable/target_movable = to_wrap
	if(target_movable.anchored)
		return FALSE

	StartCooldown(wrap_time)
	INVOKE_ASYNC(src, PROC_REF(cocoon), to_wrap)
	return TRUE

/datum/action/cooldown/wrap/proc/cocoon(atom/movable/to_wrap)
	owner.visible_message(
		span_notice("[owner] begins to secrete a sticky substance around [to_wrap]."),
		span_notice("You begin wrapping [to_wrap] into a cocoon."),
	)

	var/mob/living/simple_animal/animal_owner = owner
	if(istype(animal_owner))
		animal_owner.stop_automated_movement = TRUE

	if(do_after(owner, wrap_time, target = to_wrap))
		var/obj/structure/spider/cocoon/casing = new(to_wrap.loc)
		if(isliving(to_wrap))
			var/mob/living/living_wrapped = to_wrap
			// if they're not dead, you can consume them anyway
			if(ishuman(living_wrapped) && (living_wrapped.stat != DEAD || !HAS_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED)))
				living_wrapped.death() //you just ate them, they're dead.
			else
				to_chat(owner, span_warning("[living_wrapped] cannot sate your hunger!"))

		to_wrap.forceMove(casing)
		if(to_wrap.density || ismob(to_wrap))
			casing.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")

	if(istype(animal_owner))
		animal_owner.stop_automated_movement = TRUE

/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into more spiders. You must wrap a living being to do this."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
	///How long it takes for a broodmother to lay eggs.
	var/egg_lay_time = 15 SECONDS
	///The type of egg we create
	//var/egg_type = /obj/effect/mob_spawn/ghost_role/spider

/datum/action/innate/spider/lay_eggs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
		return FALSE
	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
	if(eggs)
		to_chat(owner, span_warning("There is already a cluster of eggs here!"))
		return FALSE

	return TRUE

/datum/action/innate/spider/lay_eggs/Activate()
	owner.visible_message(
		span_notice("[owner] begins to lay a cluster of eggs."),
		span_notice("You begin to lay a cluster of eggs."),
	)

	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner
	spider.stop_automated_movement = TRUE

	if(do_after(owner, egg_lay_time, target = get_turf(owner)))
		var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
		if(!eggs || !isturf(spider.loc))
			var/obj/structure/spider/eggcluster/new_eggs = new /obj/structure/spider/eggcluster(get_turf(spider))
			new_eggs.directive = spider.directive
			new_eggs.faction = spider.faction
			build_all_button_icons(TRUE)

	spider.stop_automated_movement = FALSE

/datum/action/innate/spider/set_directive
	name = "Set Directive"
	desc = "Set a directive for your children to follow."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/IsAvailable(feedback = FALSE)
	return ..() && istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider)

/datum/action/innate/spider/set_directive/Activate()
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/spider = owner

	spider.directive = tgui_input_text(spider, "Enter the new directive", "Create directive", "[spider.directive]")
	if(isnull(spider.directive) || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = FALSE))
		return FALSE

	message_admins("[ADMIN_LOOKUPFLW(owner)] set its directive to: '[spider.directive]'.")
	log_game("[key_name(owner)] set its directive to: '[spider.directive]'.")
	return TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	. = ..()
	GLOB.spidermobs[src] = TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/datum/action/innate/spider/comm
	name = "Command"
	desc = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable(feedback = FALSE)
	return ..() && istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife)

/datum/action/innate/spider/comm/Trigger()
	var/input = tgui_input_text(owner, "Input a command for your legions to follow.", "Command")
	if(!input || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = FALSE))
		return FALSE

	spider_command(owner, input)
	return TRUE

/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message
	my_message = span_spider("<b>Command from [user]:</b> [message]")
	for(var/mob/living/simple_animal/hostile/poison/giant_spider/spider as anything in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag = "spider command")

/mob/living/simple_animal/hostile/poison/giant_spider/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(20)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)

#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
