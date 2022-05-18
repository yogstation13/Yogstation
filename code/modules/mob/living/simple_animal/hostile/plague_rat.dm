/mob/living/simple_animal/hostile/plaguerat
	name = "rat"
	desc = "It's a large rodent, afflicted with both anger issues and a terrible disease."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Skree!","SKREEE!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("Hisses.")
	emote_see = list("runs in a circle.", "stands on its hind legs.")
	melee_damage_lower = 5 //stronk
	melee_damage_upper = 5
	obj_damage = 5
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 20
	health = 20
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/plagued = 1)
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC,MOB_BEAST)
	faction = list("rat")
	var/playstyle_string = "<span class='big bold'>You are a Plague Rat,</span></b> \
							Your goal is to spread The Plague as much as possible, by infecting anyone you can. \
							You can do this by licking their food, or by directly biting them. \
							You can also nibble on dead bodies to slightly heal yourself! \
							However, you are still very fragile! You're just are a small rat, after all.</b>"


/mob/living/simple_animal/hostile/plaguerat/AttackingTarget()
	..()
	var/mob/living/carbon/C = target
	if(isliving(С) && (С.stat != DEAD))          //It is for injecting plague reagent into people via biting them.
		if(С.reagents)
			var/obj/item/I = С.get_item_by_slot(SLOT_W_SUIT)
			if(!istype(I, /obj/item/clothing/suit/space/hardsuit) && !istype(I, /obj/item/clothing/suit/armor))
				С.reagents.add_reagent(/datum/reagent/plaguebacteria, 3)

	if(С.stat == DEAD)             //It is for biting dead bodies to heal.
		src.visible_message(span_warning("[src] starts biting into [С]!"),span_notice("You start eating [С]..."))
		if(do_mob(src, target, 3 SECONDS))
			to_chat(src, span_notice ("You finish eating [С]."))
			heal_bodypart_damage(5)
			С.adjustBruteLoss(15)
			return

	if (!isliving(target) && target.reagents && target.is_injectable(src, allowmobs = TRUE))   //It is for injecting plague reagent into food and reagent containers by licking them. Not to be confused with biting people.
		src.visible_message(span_warning("[src] starts licking [target]!"),span_notice("You start licking [target]..."))
		if (do_mob(src, target, 2 SECONDS))
			target.reagents.add_reagent(/datum/reagent/plaguebacteria,rand(1,2),no_react = TRUE)
			to_chat(src, span_notice("You finish licking [target]."))
			return

//Spawn Event

/datum/round_event_control/plaguerat
	name = "Spawn a Plague Rat"
	typepath = /datum/round_event/ghost_role/plaguerat
	weight = 6
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/ghost_role/plaguerat
	minimum_required = 1
	role_name = "plaguerat"

/datum/round_event/ghost_role/plaguerat/spawn_role()
	var/list/candidates = get_candidates(ROLE_SENTIENCE, null, ROLE_SENTIENCE)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.xeno_spawn)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/plaguerat/S = new /mob/living/simple_animal/hostile/plaguerat/(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Plague rat"
	player_mind.special_role = "Plague rat"
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a plague rat by an event.")
	log_game("[key_name(S)] was spawned as a plague rat by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
