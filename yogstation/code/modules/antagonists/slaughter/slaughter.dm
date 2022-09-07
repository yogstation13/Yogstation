/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	sound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 15 // reduced from 30 to 15 with wounds since they get big buffs to slicing wounds
	melee_damage_upper = 15
	wound_bonus = -10
	bare_wound_bonus = 0
	sharpness = SHARP_EDGED
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/playstyle_string = "<span class='big bold'>You are a slaughter demon,</span><B> a terrible creature from another realm. You have a single desire: To kill.  \
							Alt-click blood pools to travel through them, appearing and disappearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. \
							You gain strength the more attacks you land on live humanoids, though this resets when you return to the blood zone. You can also \
							launch a devastating slam attack with ctrl+shift+click, capable of smashing bones in one strike.</B>"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart/demon)
	del_on_ = 1
	message = "screams in anger as it collapses into a puddle of viscera!"
	/// How long it takes for the alt-click slam attack to come off cooldown
	var/slam_cooldown_time = 45 SECONDS
	/// The actual instance var for the cooldown
	var/slam_cooldown = 0
	/// How many times we have hit humanoid targets since we last bloodcrawled, scaling wounding power
	var/current_hitstreak = 0
	/// How much both our wound_bonus and bare_wound_bonus go up per hitstreak hit
	var/wound_bonus_per_hit = 5
	/// How much our wound_bonus hitstreak bonus caps at (peak demonry)
	var/wound_bonus_hitstreak_max = 12

/mob/living/simple_animal/slaughter/Initialize()
	..()
	var/datum/component/crawl/blood/demonic/bloodcrawl = AddComponent(/datum/component/crawl/blood/demonic)
	if(bloodcrawl && istype(loc, /obj/effect/dummy/crawling))
		bloodcrawl.holder = loc

/mob/living/simple_animal/slaughter/CtrlShiftClickOn(atom/A)
	if(!isliving(A))
		return ..()
	if(!Adjacent(A))
		to_chat(src, span_warning("You are too far away to use your slam attack on [A]!"))
		return
	if(slam_cooldown + slam_cooldown_time > world.time)
		to_chat(src, span_warning("Your slam ability is still on cooldown!"))
		return

	face_atom(A)
	var/mob/living/victim = A
	victim.take_bodypart_damage(brute=20, wound_bonus=wound_bonus) // don't worry, there's more punishment when they hit something
	visible_message(span_danger("[src] slams into [victim] with monstrous strength!"), span_danger("You slam into [victim] with monstrous strength!"), ignored_mobs=victim)
	to_chat(victim, span_userdanger("[src] slams into you with monstrous strength, sending you flying like a ragdoll!"))
	var/turf/yeet_target = get_edge_target_turf(victim, dir)
	victim.throw_at(yeet_target, 10, 5, src)
	slam_cooldown = world.time
	log_combat(src, victim, "slaughter slammed")

/mob/living/simple_animal/slaughter/UnarmedAttack(atom/A, proximity)
	if(iscarbon(A))
		var/mob/living/carbon/target = A
		if(target.stat != DEAD && target.mind && current_hitstreak < wound_bonus_hitstreak_max)
			current_hitstreak++
			wound_bonus += wound_bonus_per_hit
			bare_wound_bonus += wound_bonus_per_hit

	return ..()


/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon_state = "innards"

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/heart/demon/update_icon()
	return //always beating visually

/obj/item/organ/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"), \
						 span_danger("An unnatural hunger consumes you. You raise [src] your mouth and devour it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
	if(user.GetComponent(/datum/component/crawl/blood))
		to_chat(user, span_warning("...and you don't feel any different."))
		qdel(src)
		return
	user.visible_message(span_warning("[user]'s eyes flare a deep crimson!"), \
						 span_userdanger("You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/heart/demon/Insert(mob/living/carbon/M, special = 0)
	..()
	M.AddComponent(/datum/component/crawl/blood)

/obj/item/organ/heart/demon/Remove(mob/living/carbon/M, special = 0)
	..()
	var/datum/component/crawl/blood/B = M.GetComponent(/datum/component/crawl/blood)
	if(B)
		B.RemoveComponent()

/obj/item/organ/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles","titters","chuckles")
	emote_hear = list("guffaws","laughs")
	response_help  = "hugs"
	attacktext = "wildly tickles"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	message = "fades out, as all of its friends are released from its \
		prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	playstyle_string = "<span class='big bold'>You are a laughter \
	demon,</span><B> a wonderful creature from another realm. You have a single \
	desire: <span class='clown'>To hug and tickle.</span><BR>\
	Alt-click blood pools to travel \
	through them, appearing and disappearing from the station at will. \
	Pulling a dead or unconscious mob while you enter a pool will pull \
	them in with you, allowing you to hug them and regain your health.<BR> \
	You move quickly upon leaving a pool of blood, but the material world \
	will soon sap your strength and leave you sluggish.\
	You gain strength the more attacks you land on live humanoids, though this resets when you return to the blood zone. You can also \
	launch a devastating slam attack with ctrl+shift+click, capable of smashing bones in one strike.<BR>\
	What makes you a little sad is that people seem to die when you tickle \
	them; but don't worry! When you die, everyone you hugged will be \
	released and fully healed, because in the end it's just a jape, \
	sibling!</B>"

/mob/living/simple_animal/slaughter/laughter/Initialize()
	..()
	var/datum/component/crawl/blood/demonic/scary = GetComponent(/datum/component/crawl/blood/demonic)
	if(scary)
		scary.RemoveComponent(del_holder=FALSE)
	var/datum/component/crawl/blood/demonic/hilarious/bloodcrawl = AddComponent(/datum/component/crawl/blood/demonic/hilarious)
	if(bloodcrawl && istype(loc, /obj/effect/dummy/crawling))
		bloodcrawl.holder = loc

/mob/living/simple_animal/slaughter/laughter/Destroy()
	release_friends()
	. = ..()

/mob/living/simple_animal/slaughter/laughter/ex_act(severity)
	switch(severity)
		if(1)
			()
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/slaughter/laughter/proc/release_friends()
	var/datum/component/crawl/blood/demonic/hilarious/bloodcrawl = GetComponent(/datum/component/crawl/blood/demonic/hilarious)
	if(!bloodcrawl || !bloodcrawl.friends)
		return
	for(var/mob/living/M in bloodcrawl.friends)
		if(!M)
			continue
		var/turf/T = find_safe_turf()
		if(!T)
			T = get_turf(src)
		M.forceMove(T)
		if(M.revive(full_heal = TRUE, admin_revive = TRUE))
			M.grab_ghost(force = TRUE)
			playsound(T, feast_sound, 50, 1, -1)
			to_chat(M, span_clown("You leave [src]'s warm embrace, and feel ready to take on the world.")) //Why the fuck was there a random tab in this message?

/mob/living/simple_animal/slaughter/laughter/bloodcrawl_swallow(var/mob/living/victim)
	var/datum/component/crawl/blood/demonic/hilarious/bloodcrawl = GetComponent(/datum/component/crawl/blood/demonic/hilarious)
	if(!bloodcrawl || !bloodcrawl.friends)
		victim.forceMove(get_turf(victim))
		victim.exit_blood_effect()
		victim.visible_message("[victim] falls out of the air, covered in blood, looking highly confused. And dead.")
		return
	bloodcrawl.friends += victim
