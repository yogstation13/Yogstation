#define PENANCE_LIFE "Lose your life ()"
#define PENANCE_SOUL "Lose your soul ()"
#define PENANCE_LIMB "Lose a limb ()"
#define PENANCE_SKELETON "Lose your flesh ()"
#define PENANCE_TRAUMA_ADV "Lose your mind ()"
#define PENANCE_TRAUMA_BASIC "Lose your mind ()"


/obj/effect/eldritch
	name = "Generic rune"
	desc = "Weird combination of shapes and symbols etched into the floor itself. The indentation is filled with thick black tar-like fluid."
	anchored = TRUE
	icon_state = ""
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE

/obj/effect/eldritch/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	try_activate(user)

/obj/effect/eldritch/proc/try_activate(mob/living/user)
	if(!IS_HERETIC(user))
		return
	if(!is_in_use)
		INVOKE_ASYNC(src, .proc/activate , user)

/obj/effect/eldritch/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I,/obj/item/nullrod))
		qdel(src)

/obj/effect/eldritch/proc/activate(mob/living/user)
	is_in_use = TRUE
	// Have fun trying to read this proc.
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/transmutations = cultie.get_all_transmutations()
	var/list/atoms_in_range = list()

	for(var/A in range(1, src))
		var/atom/atom_in_range = A
		if(istype(atom_in_range,/area))
			continue
		if(istype(atom_in_range,/turf)) // we dont want turfs
			continue
		if(istype(atom_in_range,/mob/living))
			var/mob/living/living_in_range = atom_in_range
			if(living_in_range.stat != DEAD || living_in_range == user) // we only accept corpses, no living beings allowed.
				continue
		atoms_in_range += atom_in_range
	for(var/X in transmutations)
		var/datum/eldritch_transmutation/current_eldritch_transmutation = X

		//has to be done so that we can freely edit the local_required_atoms without fucking up the eldritch knowledge
		var/list/local_required_atoms = list()

		if(!current_eldritch_transmutation.required_atoms || current_eldritch_transmutation.required_atoms.len == 0)
			continue

		local_required_atoms += current_eldritch_transmutation.required_atoms

		var/list/selected_atoms = list()

		if(!current_eldritch_transmutation.recipe_snowflake_check(atoms_in_range,drop_location(),selected_atoms))
			continue

		for(var/LR in local_required_atoms)
			var/list/local_required_atom_list = LR

			for(var/LAIR in atoms_in_range)
				var/atom/local_atom_in_range = LAIR
				if(is_type_in_list(local_atom_in_range,local_required_atom_list))
					selected_atoms |= local_atom_in_range
					local_required_atoms -= list(local_required_atom_list)

		if(length(local_required_atoms) > 0)
			continue

		flick("[icon_state]_active",src)
		playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE)
		//we are doing this since some on_finished_recipe subtract the atoms from selected_atoms making them invisible permanently.
		var/list/atoms_to_disappear = selected_atoms.Copy()
		for(var/to_disappear in atoms_to_disappear)
			var/atom/atom_to_disappear = to_disappear
			//temporary so we dont have to deal with the bs of someone picking those up when they may be deleted
			atom_to_disappear.invisibility = INVISIBILITY_ABSTRACT
		if(current_eldritch_transmutation.on_finished_recipe(user,selected_atoms,loc))
			current_eldritch_transmutation.cleanup_atoms(selected_atoms)
		is_in_use = FALSE

		for(var/to_appear in atoms_to_disappear)
			var/atom/atom_to_appear = to_appear
			//we need to reappear the item just in case the ritual didnt consume everything... or something.
			atom_to_appear.invisibility = initial(atom_to_appear.invisibility)

		return
	is_in_use = FALSE
	to_chat(user,span_warning("Your ritual failed! You used either wrong components or are missing something important!"))

/obj/effect/eldritch/big
	name = "Transmutation rune"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "eldritch_rune1"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32

/**
  * #Reality smash tracker
  *
  * Stupid fucking list holder, DONT create new ones, it will break the game, this is automnatically created whenever eldritch cultists are created.
  *
  * Tracks relevant data, generates relevant data, useful tool
  */
/datum/reality_smash_tracker
	///list of tracked reality smashes
	var/list/smashes = list()
	///List of mobs with ability to see the smashes
	var/list/targets = list()

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("/datum/reality_smash_tracker was deleted. Heretics will no longer be able to access any influences. Fix it or call coder support (whatever that means)")
	QDEL_LIST(smashes)
	targets.Cut()
	return ..()

/**
  * Automatically fixes the target and smash network
  *
  * Fixes any issues caused by late Generate() calls or exchanging clients
  */
/datum/reality_smash_tracker/proc/ReworkNetwork()
	listclearnulls(smashes)
	for(var/mind in targets)
		if(isnull(mind))
			stack_trace("A null somehow landed in the reality smash tracker's list of minds")
			continue
		for(var/X in smashes)
			var/obj/effect/reality_smash/reality_smash = X
			reality_smash.AddMind(mind)

/**
  * Generates a set amount of reality smashes based on the N value
  *
  * Automatically creates more reality smashes
  */
/datum/reality_smash_tracker/proc/Generate(mob/caller)
	if(istype(caller))
		targets += caller
	var/targ_len = length(targets)
	var/smash_len = length(smashes)
	var/number = max(targ_len * (4-(targ_len-1)) - smash_len,1)

	for(var/i in 0 to number)
		var/turf/chosen_location = find_safe_turf(extended_safety_checks = TRUE)
		//we also dont want them close to each other, at least 1 tile of seperation
		var/obj/effect/reality_smash/current_fracture = locate() in range(1, chosen_location)
		var/obj/effect/broken_illusion/current_burnt_fracture = locate() in range(1, chosen_location)
		var/obj/structure/window/windowsxp = locate() in range(1, chosen_location)
		if(current_fracture || current_burnt_fracture || windowsxp.fulltile) //we dont want to spawn
			continue
		new /obj/effect/reality_smash(chosen_location)
	ReworkNetwork()

/**
  * Adds a mind to the list of people that can see reality smashes
  *
  * Use this whenever you want to add someone to the list
  */
/datum/reality_smash_tracker/proc/AddMind(datum/mind/ecultist)
	RegisterSignal(ecultist.current, COMSIG_MOB_LOGIN, .proc/ReworkNetwork)
	targets |= ecultist
	Generate()
	for(var/obj/effect/reality_smash/R in smashes)
		R.AddMind(ecultist)


/**
  * Removes a mind from the list of people that can see reality smashes
  *
  * Use this whenever you want to remove someone from that list
  */
/datum/reality_smash_tracker/proc/RemoveMind(datum/mind/ecultist)
	UnregisterSignal(ecultist.current, COMSIG_MOB_LOGIN)
	targets -= ecultist
	for(var/obj/effect/reality_smash/R in smashes)
		R.RemoveMind(ecultist)

/obj/effect/broken_illusion
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/broken_illusion/attack_hand(mob/living/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/human_user = user
	if(IS_HERETIC(human_user))
		to_chat(human_user,span_boldwarning("You know better than to tempt forces out of your control!"))
	else
		var/obj/item/bodypart/arm = human_user.get_active_hand()
		if(prob(25))
			to_chat(human_user,span_userdanger("As you reach into [src], you feel something latch onto it and tear it off of you!"))
			arm.dismember()
			qdel(arm)
		else
			to_chat(human_user,span_danger("You pull your hand away from the hole as the eldritch energy flails trying to catch onto the existance itself!"))

/obj/effect/broken_illusion/attack_tk(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(IS_HERETIC(human_user))
		to_chat(human_user,span_boldwarning("You know better than to tempt forces out of your control!"))
	else
		//a very elaborate way to suicide
		var/throwtarget
		for(var/i in 1 to 20)
			human_user.SetStun(INFINITY) //:^^^^^^^^^^)
			throwtarget = get_edge_target_turf(src, pick(GLOB.alldirs))
			human_user.safe_throw_at(throwtarget, rand(1,20), 1, src, force = MOVE_FORCE_OVERPOWERING , quickstart = TRUE)
			human_user.Shake(rand(-100,100), rand(-100,100), 110) //oh we are TOTALLY stacking these //turns out we are not in fact stacking these
			to_chat(user, span_userdanger("[pick("I- I- I-", "NO-", "IT HURTS-", "GETOUTOFMYHEADGETOUTOFMY-", "<i>POD-</i>","<i>COVE-</i>", "AAAAAAAAA-")]"))
			sleep(1.1) //Spooky flavor message spam
		to_chat(user, span_cultbold("That was a really bad idea..."))
		human_user.ghostize()
		var/obj/item/bodypart/head/head = locate() in human_user.bodyparts
		if(head)
			head.dismember()
			qdel(head)
		else
			human_user.gib()

		var/datum/effect_system/reagents_explosion/explosion = new()
		explosion.set_up(1, get_turf(human_user), 1, 0)
		explosion.start()

/obj/effect/broken_illusion/examine(mob/user)
	if(!IS_HERETIC(user) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		to_chat(human_user,span_warning("You get a headache even trying to look at this!"))
		human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN,10)
	. = ..()

/obj/effect/reality_smash
	name = "/improper reality smash"
	icon = 'icons/effects/eldritch.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///we cannot use icon_state bc we are invisible, this is the same thing but can be not v isible
	var/image_state = "reality_smash"
	///who can see this
	var/list/minds = list()
	///tracker image
	var/image/img
	///who has already used this influence
	var/list/siphoners = list()

/obj/effect/reality_smash/Initialize()
	. = ..()
	GLOB.reality_smash_track.smashes += src
	img = image(icon, src, "reality_smash", OBJ_LAYER)
	generate_name()

/obj/effect/reality_smash/Destroy()
	GLOB.reality_smash_track.smashes -= src
	on_destroy()
	return ..()

/obj/effect/reality_smash/proc/on_destroy()
	for(var/ecultist in minds)
		var/datum/mind/cultist = ecultist
		if(cultist.current?.client)
			cultist.current.client.images -= img
		//clear the list
		minds -= cultist
	img = null
	new /obj/effect/broken_illusion(drop_location())

///makes someone able to see this
/obj/effect/reality_smash/proc/AddMind(datum/mind/ecultist)
	minds |= ecultist
	if(ecultist.current.client)
		ecultist.current.client.images |= img

///makes someone not able to see this
/obj/effect/reality_smash/proc/RemoveMind(datum/mind/ecultist)
	minds -= ecultist
	if(ecultist.current.client)
		ecultist.current.client.images -= img

///Generates random name
/obj/effect/reality_smash/proc/generate_name()
	var/static/list/prefix = list("Omniscient","Thundering","Enlightening","Intrusive","Rejectful","Atomized","Subtle","Rising","Lowering","Fleeting","Towering","Blissful","Arrogant","Threatening","Peaceful","Aggressive")
	var/static/list/postfix = list("Flaw","Presence","Crack","Heat","Cold","Memory","Reminder","Breeze","Grasp","Sight","Whisper","Flow","Touch","Veil","Thought","Imperfection","Blemish","Blush")

	name = pick(prefix) + " " + pick(postfix)


/*
 *
 * brazil effects/status effect
 * used to create a "fun and intuitive gameplay" for people who get sacrificed by heretics
 * and by that i mean they get to lose stuff
 *
 */

/datum/status_effect/brazil_penance
	id = "brazil_penance"
	alert_type = /obj/screen/alert/status_effect/brazil_penance
	///counts how close to escaping brazil the owner is
	var/penance_left = 15
	///sacrifices made to reduce penance_left, each is applied when leaving
	var/list/penance_sources = list()
	var/list/unspooked_limbs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)

/datum/status_effect/brazil_penance/on_apply()
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(1, get_turf(owner))
	S.start()
	owner.revive(full_heal = TRUE) //this totally won't be used to bypass stuff(tm)
	owner.regenerate_organs()
	owner.regenerate_limbs()
	owner.grab_ghost()
	to_chat(owner, "<span class='revenbignotice'>You find yourself floating in a strange, unfamiliar void. Are you dead? ... no ... that feels different... Maybe there's a way out?</span>")
	for(var/i in GLOB.brazil_reception)
		if(locate(/mob) in get_turf(i)) //there are actually 64 total spots at brazil to get teleported to so if this gets filled (unlikely) they just get returned as a failsafe
			continue
		owner.forceMove(get_turf(i))
		return TRUE

/datum/status_effect/brazil_penance/tick()
	if(!penance_left)
		if(apply_effects())
			qdel(src)
		return
	if(get_area(owner) != /area/brazil)
		dust(owner)

/datum/status_effect/brazil_penance/proc/apply_effects()
	. = TRUE
	var/mob/living/carbon/human/H = owner
	for(var/p in penance_sources)
		while(penance_sources[p])
			switch(P)
				if(PENANCE_LIFE)
					owner.blood_volume = 0
					owner.death()
				if(PENANCE_SOUL)
					owner.mind.hellbound = TRUE
				if(PENANCE_LIMB)
					var/obj/item/bodypart/BP
					while(!BP)
						if(!LAZYLEN(unspooked_limbs)) //this shouoldn't occur but i dont trust people
							return FALSE
						var/target_zone = pick_n_take(unspooked_limbs)
						BP = C.get_bodypart(target_zone)
					BP.dismember(BURN)
				if(PENANCE_SKELETON)
					var/obj/item/bodypart/BP
					while(!BP || BP.species_id == "skeleton")
						if(!LAZYLEN(unspooked_limbs))
							return FALSE
						var/target_zone = pick_n_take(unspooked_limbs)
						BP = C.get_bodypart(target_zone)
					var/obj/item/bodypart/replacement_part = new BP.type
					replacement_part.max_damage = 15
					replacement_part.species_id = "skeleton"
					replacement_part.original_owner = "inside"
					replacement_part.replace_limb(owner)
				if(PENANCE_TRAUMA_ADV)
					H.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
				if(PENANCE_TRAUMA_BASIC)
					H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
			penance_sources[p] --
			sleep(2)

/obj/effect/penance_giver
	name = "code ing"
	desc = "it takes your soul, and other stuff potentially"
	var/list/penance_given = list(PENANCE_LIFE, PENANCE_SOUL, PENANCE_LIMB, PENANCE_SKELETON, PENANCE_TRAUMA_ADV, PENANCE_TRAUMA_BASIC)

/obj/effect/penance_giver/attack_hand(mob/user)
	input("What will you offer?", "Lose") as null|anything in penance_given

#undef PENANCE_LIFE
#undef PENANCE_SOUL
#undef PENANCE_LIMB
#undef PENANCE_SKELETON
#undef PENANCE_TRAUMA_ADV
#undef PENANCE_TRAUMA_BASIC