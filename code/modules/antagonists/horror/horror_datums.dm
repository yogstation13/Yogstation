//ANTAG DATUMS
/datum/antagonist/horror
	name = "Horror"
	show_in_antagpanel = TRUE
	prevent_roundtype_conversion = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	var/datum/mind/summoner

/datum/antagonist/horror/on_gain()
	. = ..()
	give_objectives()
	if(ishorror(owner) && owner.current.mind)
		var/mob/living/simple_animal/horror/H = owner.current
		H.update_horror_hud()
		H.mind.store_memory("You become docile after contact with [H.weakness.name]. Avoid it.")

/datum/antagonist/horror/proc/give_objectives()
	if(summoner)
		var/datum/objective/newobjective = new
		newobjective.explanation_text = "Serve your summoner, [summoner.name]."
		newobjective.owner = owner
		newobjective.completed = TRUE
		objectives += newobjective
	else
		var/datum/objective/horrorascend/ascend = new
		ascend.owner = owner
		ascend.target_amount = rand(6, 10)
		objectives += ascend
		ascend.update_explanation_text()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/objective/horrorascend
	name = "consume souls"

/datum/objective/horrorascend/update_explanation_text()
	. = ..()
	explanation_text = "Consume [target_amount] souls."

/datum/objective/horrorascend/check_completion()
	var/mob/living/simple_animal/horror/H = owner.current
	if(istype(H) && H.consumed_souls > target_amount)
		return TRUE
	return FALSE

//SPAWNER
/obj/item/horrorspawner
	name = "suspicious pet carrier"
	desc = "It contains some sort of creature inside. You can see tentacles sticking out of it."
	icon = 'icons/obj/pet_carrier.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "pet_carrier"
	icon_state = "pet_carrier_occupied"
	var/used = FALSE
	var/weakness
	color = rgb(130, 105, 160)

/obj/item/horrorspawner/attack_self(mob/living/user)
	if(used)
		to_chat(user, "The pet carrier appears unresponsive.")
		return
	used = TRUE
	to_chat(user, "You're attempting to wake up the creature inside the box...")
	sleep(5 SECONDS)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the eldritch horror in service of [user.real_name]?", ROLE_HORROR, null, FALSE, 100)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/horror/H = new /mob/living/simple_animal/horror(get_turf(src))
		H.weakness = weakness
		H.key = C.key
		H.mind.enslave_mind_to_creator(user)
		H.mind.add_antag_datum(C)
		H.mind.memory += "You are <span class='purple'><b>[H.truename]</b></span>, an eldritch horror. Consume souls to evolve.<br>"
		var/datum/antagonist/horror/S = new
		S.summoner = user.mind
		S.antag_memory += "<b>[user.mind]</b> woke you from your eternal slumber. Aid them in their objectives as a token of gratitude.<br>"
		H.mind.add_antag_datum(S)
		log_game("[key_name(user)] has summoned [key_name(H)], an eldritch horror.")
		to_chat(user, "<span><b>[H.truename]</b> has awoken into your service!</span>")
		used = TRUE
		icon_state = "pet_carrier_open"
		sleep(5)
		var/obj/item/horrorsummonhorn/horn = new /obj/item/horrorsummonhorn(get_turf(src))
		horn.summoner = user.mind
		horn.horror = H
		to_chat(user, "<span class='notice'>A strange looking [horn] falls out of [src]!</span>")
	else
		to_chat(user, "The creatures looks at you with one of it's eyes before going back to slumber.")
		used = FALSE
		return

//Summoning horn
/obj/item/horrorsummonhorn
	name = "old horn"
	desc = "A very old horn. You feel an incredible urge to blow into it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "horn"
	icon_state = "horn"
	var/datum/mind/summoner
	var/mob/living/simple_animal/horror/horror
	var/cooldown

/obj/item/horrorsummonhorn/examine(mob/user)
	. = ..()
	if(user.mind == summoner)
		to_chat(user, "<span class='velvet'>Blowing into this horn will recall the horror back to you. Be wary, the horn is loud, and may attract <B>unwanted</B> attention.<span>")

/obj/item/horrorsummonhorn/attack_self(mob/living/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>Take a breath before you blow [src] again.</span>")
		return
	to_chat(user, "<span class='notice'>You take a deep breath and prepare to blow into [src]...</span>")
	if(do_mob(user, src, 100))
		if(cooldown > world.time)
			return
		cooldown = world.time + 5 SECONDS
		to_chat(src, "<span class='notice'>You blow the horn...</span>")
		playsound(loc, "sound/items/airhorn.ogg", 100, 1, 30)
		var/turf/summonplace = get_turf(src)
		sleep(5 SECONDS)
		if(prob(20)) //yeah you're summoning an eldritch horror allright
			new /obj/effect/temp_visual/summon(summonplace)
			sleep(10)
			var/type = pick(typesof(/mob/living/simple_animal/hostile/abomination))
			var/mob/R = new type(summonplace)
			playsound(summonplace, "sound/effects/phasein.ogg", 30)
			summonplace.visible_message("<span class='danger'>[R] emerges!</span>")
		else
			if(!horror || horror.stat == DEAD)
				summonplace.visible_message("<span class='danger'>But nothing responds to the call!</span>")
			else
				new /obj/effect/temp_visual/summon(summonplace)
				sleep(10)
				horror.leave_victim()
				horror.forceMove(summonplace)
				playsound(summonplace, "sound/effects/phasein.ogg", 30)
				summonplace.visible_message("<span class='notice'>[horror] appears out of nowhere!</span>")
				if(user.mind != summoner)
					sleep(2 SECONDS)
					playsound(summonplace, "sound/effects/glassbr2.ogg", 30, 1)
					to_chat(user, "<span class='danger'>[src] breaks!</span>")
					qdel(src)

/obj/item/horrorsummonhorn/suicide_act(mob/living/user)  //"I am the prettiest unicorn that ever was!" ~Spy 2013
	user.visible_message("<span class='suicide'>[user] stabs [user.p_their()] forehead with [src]!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/paper/crumpled/horrorweakness
	name = "scruffed note"
	infolang = /datum/language/aphasia //his previous owner got brought to madness, luckily curator can translate

/obj/item/horrortentacle
	name = "tentacle"
	desc = "A long, slimy, arm-like appendage."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "horrortentacle"
	item_state = "tentacle"
	lefthand_file = 'icons/mob/inhands/antag/horror_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/horror_righthand.dmi'
	resistance_flags = ACID_PROOF
	force = 17
	item_flags = ABSTRACT | DROPDEL
	reach = 2
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/horrortentacle/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/horrortentacle/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='velvet bold'>Functions:<span>")
	to_chat(user, "<span class='velvet'><b>All attacks work up to 2 tiles away.</b></span>")
	to_chat(user, "<span class='velvet'><b>Help intent:</b> Usual help function of an arm.</span>")
	to_chat(user, "<span class='velvet'><b>Disarm intent:</b> Whips the tentacle, disarming your opponent.</span>")
	to_chat(user, "<span class='velvet'><b>Grab intent:</b> Instant aggressive grab on an opponent. Can also throw them!</span>")
	to_chat(user, "<span class='velvet'><b>Harm intent:</b> Whips the tentacle, damaging your opponent.</span>")
	to_chat(user, "<span class='velvet'>Also functions to pry open unbolted airlocks.</span>")

/obj/item/horrortentacle/attack(atom/target, mob/living/user)
	if(isliving(target))
		user.Beam(target,"purpletentacle",time=5)
		var/mob/living/L = target
		switch(user.a_intent)
			if(INTENT_HELP)
				L.attack_hand(user)
				return
			if(INTENT_GRAB)
				if(L != user)
					L.grabbedby(user)
					L.grippedby(user, instant = TRUE)
					L.Knockdown(30)
				return
			if(INTENT_DISARM)
				if(iscarbon(L))
					var/mob/living/carbon/C = L
					var/obj/item/I = C.get_active_held_item()
					if(I)
						if(C.dropItemToGround(I))
							playsound(loc, "sound/weapons/whipgrab.ogg", 30)
							target.visible_message("<span class='danger'>[I] is whipped out of [C]'s hand by [user]!</span>","<span class='userdanger'>A tentacle whips [I] out of your hand!</span>")
							return
						else
							to_chat(user, "<span class='danger'>You can't seem to pry [I] off [C]'s hands!</span>")
							return
					else
						C.attack_hand(user)
						return
	. = ..()

/obj/item/horrortentacle/afterattack(atom/target, mob/user, proximity)
	if(isliving(user.pulling) && user.pulling != target)
		var/mob/living/H = user.pulling
		user.visible_message("<span class='warning'>[user] throws [H] with [user.p_their()] [src]!</span>", "<span class='warning'>You throw [H] with [src].</span>")
		H.throw_at(target, 8, 2)
		H.Knockdown(30)
		return
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower())
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>", "<span class='warning'>You start forcing the airlock open.</span>",
			"<span class='italics'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
			if(!do_after(user, 150, target = A)) //tentacle 50% worse than an armblade
				return
		user.visible_message("<span class='warning'>[user] forces the airlock to open with [user.p_their()] [src]!</span>", "<span class='warning'>You force the airlock to open.</span>",
		"<span class='italics'>You hear a metal screeching sound.</span>")
		A.open(2)
		return
	. = ..()

/obj/item/horrortentacle/suicide_act(mob/user) //funnily enough, this will never be called, since horror stops suicide
	user.visible_message("<span class='suicide'>[src] coils itself around [user] tightly gripping [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

//Pinpointer
/obj/screen/alert/status_effect/agent_pinpointer/horror
	name = "Soul locator"
	desc = "Find your target soul."

/datum/status_effect/agent_pinpointer/horror
	id = "horror_pinpointer"
	minimum_range = 0
	range_fuzz_factor = 0
	tick_interval = 20
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/horror

/datum/status_effect/agent_pinpointer/horror/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/horror/point_to_target()
	if(!ishorror(owner))
		return
	return ..()



//ABILITIES

/datum/action/innate/horror
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_horror.dmi'
	var/id //The ability's ID, for giving, taking and such
	var/blacklisted = FALSE //If the ability can't be mutated
	var/soul_price = 0 //How much souls the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/chemical_cost = 0 //How much chemicals the ability costs to use
	var/mob/living/simple_animal/horror/B //Horror holding the ability
	var/category  //category for when the ability is active, "horror" is for creature, "infest" is during infestation, "controlling" is when a horror is controlling a body

/datum/action/innate/horror/New(Target, horror)
	B = horror
	..()

/datum/action/innate/horror/mutate
	name = "Mutate"
	id = "mutate"
	desc = "Use consumed souls to mutate your abilities."
	button_icon_state = "mutate"
	blacklisted = TRUE
	category = list("horror","infest")

/datum/action/innate/horror/mutate/Activate()
	to_chat(usr, "<span class='velvet bold'>You focus on mutating your body...</span>")
	B.ui_interact(usr)
	return TRUE

/datum/action/innate/horror/seek_soul
	name = "Seek target soul"
	id = "seek_soul"
	desc = "Search for a soul weak enough for you to consume."
	button_icon_state = "seek_soul"
	blacklisted = TRUE
	category = list("horror","infest")

/datum/action/innate/horror/seek_soul/Activate()
	B.SearchTarget()

/datum/action/innate/horror/consume_soul
	name = "Consume soul"
	id = "consume_soul"
	desc = "Consume your target's soul."
	button_icon_state = "consume_soul"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/consume_soul/Activate()
	B.ConsumeSoul()

/datum/action/innate/horror/talk_to_host
	name = "Converse with Host"
	id = "talk_to_host"
	desc = "Send a silent message to your host."
	button_icon_state = "talk_to_host"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/talk_to_host/Activate()
	B.Communicate()

/datum/action/innate/horror/infest_host
	name = "Infest"
	id = "infest"
	desc = "Infest a suitable humanoid host."
	button_icon_state = "infest"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/infest_host/Activate()
	B.infect_victim()

/datum/action/innate/horror/toggle_hide
	name = "Toggle Hide"
	id = "toggle_hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "horror_hiding_false"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/toggle_hide/Activate()
	B.hide()
	button_icon_state = "horror_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/horror/talk_to_horror
	name = "Converse with Horror"
	id = "talk_to_horror"
	desc = "Communicate mentally with your horror."
	button_icon_state = "talk_to_horror"
	blacklisted = TRUE

/datum/action/innate/horror/talk_to_horror/Activate()
	var/mob/living/O = owner
	O.horror_comm()

/datum/action/innate/horror/talk_to_brain
	name = "Converse with Trapped Mind"
	id = "talk_to_brain"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "talk_to_trapped_mind"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/talk_to_brain/Activate()
	B.victim.trapped_mind_comm()

/datum/action/innate/horror/take_control
	name = "Assume Control"
	id = "take_control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "horror_brain"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/take_control/Activate()
	B.bond_brain()

/datum/action/innate/horror/give_back_control
	name = "Release Control"
	id = "release_control"
	desc = "Release control of your host's body."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/give_back_control/Activate()
	B.victim.release_control()

/datum/action/innate/horror/leave_body
	name = "Release Host"
	id = "leave_body"
	desc = "Slither out of your host."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/leave_body/Activate()
	B.release_victim()

/datum/action/innate/horror/make_chems
	name = "Secrete chemicals"
	id = "make_chems"
	desc = "Push some chemicals into your host's bloodstream."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "minidispenser"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/make_chems/Activate()
	B.secrete_chemicals()

/datum/action/innate/horror/freeze_victim
	name = "Knockdown victim"
	id = "freeze_victim"
	desc = "Use your tentacle to trip a victim, stunning for a short duration."
	button_icon_state = "trip"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/freeze_victim/Activate()
	B.freeze_victim()
	UpdateButtonIcon()
	addtimer(CALLBACK(src, .proc/UpdateButtonIcon), 150)

/datum/action/innate/horror/freeze_victim/IsAvailable()
	if(world.time - B.used_freeze < 150)
		return FALSE
	else
		return ..()

//non-default abilities, can be mutated

/datum/action/innate/horror/tentacle
	name = "Grow Tentacle"
	id = "tentacle"
	desc = "Makes your host grow a tentacle in their arm. Costs 50 chemicals to activate."
	button_icon_state = "tentacle"
	category = list("infest", "control")
	soul_price = 2

/datum/action/innate/horror/tentacle/IsAvailable()
	if(!active && !B.has_chemicals(50))
		return FALSE
	return ..()

/datum/action/innate/horror/tentacle/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/horror/tentacle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/horror/tentacle/process()
	..()
	active = locate(/obj/item/horrortentacle) in B.victim
	UpdateButtonIcon()


/datum/action/innate/horror/tentacle/Activate()
	B.use_chemicals(50)
	B.victim.visible_message("<span class='warning'>[B.victim]'s arm contorts into tentacles!</span>", "<span class='notice'>Your arm transforms into a giant tentacle. Examine it to see possible uses.</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>You transform [B.victim]'s arm into a tentacle!</span>")
	var/obj/item/horrortentacle/T = new
	B.victim.put_in_hands(T)
	return TRUE

/datum/action/innate/horror/tentacle/Deactivate()
	B.victim.visible_message("<span class='warning'>[B.victim]'s tentacle transforms back!</span>", "<span class='notice'>Your tentacle disappears!</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>You transform [B.victim]'s arm back.</span>")
	for(var/obj/item/horrortentacle/T in B.victim)
		qdel(T)
	return TRUE

/datum/action/innate/horror/jumpstart_host
	name = "Revive Host"
	id = "jumpstart_host"
	desc = "Bring your host back to life."
	button_icon_state = "revive"
	category = list("infest")
	soul_price = 2

/datum/action/innate/horror/jumpstart_host/Activate()
	B.jumpstart()

/datum/action/innate/horror/view_memory
	name = "View Memory"
	id = "view_memory"
	desc = "Read recent memory of the host you're inside of."
	button_icon_state = "view_memory"
	category = list("infest")
	soul_price = 1

/datum/action/innate/horror/view_memory/Activate()
	B.view_memory()

/datum/action/innate/horror/chameleon
	name = "Chameleon Skin"
	id = "chameleon"
	desc = "Adjust your skin color to blend into environment. Costs 5 chemicals per tick, also stopping chemical regeneration while active. Attacking stops the invisibility completely."
	button_icon_state = "horror_sneak_false"
	category = list("horror")
	soul_price = 1

/datum/action/innate/horror/chameleon/Activate()
	B.go_invisible()
	button_icon_state = "horror_sneak_[B.invisible ? "true" : "false"]"
	UpdateButtonIcon()

//UPGRADES
/datum/horror_upgrade
	var/name = "horror upgrade"
	var/desc = "This is an upgrade."
	var/id
	var/soul_price = 0 //How much souls an upgrade costs to buy
	var/mob/living/simple_animal/horror/B //Horror holding the upgrades

/datum/horror_upgrade/proc/unlock()
	if(!B)
		return
	apply_effects()
	qdel(src)
	return TRUE

/datum/horror_upgrade/New(owner)
	..()
	B = owner

/datum/horror_upgrade/proc/apply_effects()
	return

//Upgrades the stun ability
/datum/horror_upgrade/paralysis
	name = "Electrocharged tentacle"
	id = "paralysis"
	desc = "Empowers your tentacle knockdown ability by giving it extra charge, knocking your victim down unconcious."
	soul_price = 3

/datum/horror_upgrade/paralysis/apply_effects()
	var/datum/action/innate/horror/A = B.has_ability("freeze_victim")
	if(A)
		A.name = "Paralyze Victim"
		A.desc = "Shock a victim with an electrically charged tentacle."
		A.button_icon_state = "paralyze"
		B.update_action_buttons()

//Increases chemical regeneration rate by 2
/datum/horror_upgrade/chemical_regen
	name = "Efficient chemical glands"
	id = "chem_regen"
	desc = "Your chemical glands work more efficiently. Unlocking this increases your chemical regeneration."
	soul_price = 2

/datum/horror_upgrade/chemical_regen/apply_effects()
	B.chem_regen_rate += 2

//Lets horror regenerate chemicals outside of a host
/datum/horror_upgrade/nohost_regen
	name = "Independent chemical glands"
	id = "nohost_regen"
	desc = "Your chemical glands become less parasitic and let you regenerate chemicals on their own without need for a host."
	soul_price = 2

//Lets horror regenerate health
/datum/horror_upgrade/regen
	name = "Regenerative skin"
	id = "regen"
	desc = "Your skin adapts to sustained damage and slowly regenerates itself, healing your wounds over time."
	soul_price = 1

//Triples horror's health pool
/datum/horror_upgrade/hp_up
	name = "Rhino skin"  //Horror can....roll?
	id = "hp_up"
	desc = "Your skin becomes hard as rock, greatly increasing your maximum health - and odds of survival outside of host."
	soul_price = 2

/datum/horror_upgrade/hp_up/apply_effects()
	B.health = round(min(B.maxHealth,B.health * 3))
	B.maxHealth = round(B.maxHealth * 3)

//Makes horror almost invisible for a short time after leaving a host
/datum/horror_upgrade/invisibility
	name = "Reflective fluids"
	id = "invisible_exit"
	desc = "You build up reflective solution inside host's brain. Upon exiting a host, you're briefly covered in it, rendering you near invisible for a few seconds. This mutation also makes the host unable to notice you exiting it directly."
	soul_price = 2

//Increases melee damage to 20
/datum/horror_upgrade/dmg_up
	name = "Sharpened teeth"
	id = "dmg_up"
	desc = "Your teeth become sharp blades, this mutation increases your melee damage."
	soul_price = 2

/datum/horror_upgrade/dmg_up/apply_effects()
	B.attacktext = "crushes"
	B.attack_sound = 'sound/weapons/pierce_slow.ogg' //chunky
	B.melee_damage_lower += 10
	B.melee_damage_upper += 10

//Expands the reagent selection horror can make
/datum/horror_upgrade/upgraded_chems
	name = "Advanced reagent synthesis"
	id = "upgraded_chems"
	desc = "Lets you synthetize adrenaline, salicyclic acid, oxandrolone, pentetic acid and rezadone into your host."
	soul_price = 2

/datum/horror_upgrade/upgraded_chems/apply_effects()
	B.horror_chems += list(/datum/horror_chem/adrenaline,/datum/horror_chem/sal_acid,/datum/horror_chem/oxandrolone,/datum/horror_chem/pen_acid,/datum/horror_chem/rezadone)

//faster mind control
/datum/horror_upgrade/fast_control
	name = "Precise probosci"
	id = "fast_control"
	desc = "Your probosci become more precise, allowing you to take control over your host's brain noticably faster."
	soul_price = 2

//makes it longer for host to snap out of mind control
/datum/horror_upgrade/deep_control
	name = "Insulated probosci"
	id = "deep_control"
	desc = "Your probosci become insulated, protecting them from neural shocks. This makes it harder for the host to regain control over their body."
	soul_price = 2


//TRAPPED MIND - when horror takes control over your body, you become a mute trapped mind
/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"
	var/datum/action/innate/resist_control/R
	var/mob/living/simple_animal/horror/H

/mob/living/captive_brain/Initialize(mapload, gen=1)
	..()
	R = new
	R.Grant(src)

/mob/living/captive_brain/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(ishorror(loc))
		message = sanitize(message)
		if(!message)
			return
		log_say("[key_name(src)] : [message]")
		if(stat == 2)
			return say_dead(message)

		to_chat(src, "<i><span class='alien'>You whisper silently, \"[message]\"</span></i>")
		to_chat(H.victim, "<i><span class='alien'>The captive mind of [src] whispers, \"[message]\"</span></i>")

		for (var/mob/M in GLOB.player_list)
			if(isnewplayer(M))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				to_chat(M, "<i>Thought-speech, <b>[src]</b> -> <b>[H.truename]:</b> [message]</i>")

/mob/living/captive_brain/emote(act, m_type = null, message = null, intentional = FALSE)
	return

/datum/action/innate/resist_control
	name = "Resist control"
	desc = "Try to take back control over your brain. A strong nerve impulse should do it."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_horror.dmi'
	button_icon_state = "resist_control"

/datum/action/innate/resist_control/Activate()
	var/mob/living/captive_brain/B = owner
	if(B)
		B.try_resist()

/mob/living/captive_brain/resist()
	try_resist()

/mob/living/captive_brain/proc/try_resist()
	var/delay = rand(50,150)
	if(H.horrorupgrades["deep_control"])
		delay += rand(50,150)
	to_chat(src, "<span class='danger'>You begin doggedly resisting the parasite's control.</span>")
	to_chat(H.victim, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")
	addtimer(CALLBACK(src, .proc/return_control), delay)

/mob/living/captive_brain/proc/return_control()
    if(!H || !H.controlling)
        return
    to_chat(src, "<span class='userdanger'>With an immense exertion of will, you regain control of your body!</span>")
    to_chat(H.victim, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")
    H.detatch()