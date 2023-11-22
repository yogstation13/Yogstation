/datum/eldritch_knowledge/base_knock
	name = "A Locksmith's Secret"
	desc = "Opens up the Path of Knock to you. \
		Allows you to transmute a knife and a crowbar into a Key Blade. Additionally, your grasp will open up numerous locked things when used upon them."
	gain_text = "The Knock permits no seal and no isolation. It thrusts us gleefully out of the safety of ignorance."
	unlocked_transmutations = list(/datum/eldritch_transmutation/knock_knife)
	cost = 1
	route = PATH_KNOCK
	tier = TIER_PATH

/datum/eldritch_knowledge/base_knock/on_gain(mob/user)
	. = ..()

	var/datum/action/cooldown/spell/touch/mansus_grasp/knock_grasp = locate() in user.actions
	knock_grasp?.cooldown_time = 20 SECONDS
	var/obj/realknife = new /obj/item/melee/sickly_blade/knock
	user.put_in_hands(realknife)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	ADD_TRAIT(user, TRAIT_QUICKEST_CARRY, INNATE_TRAIT)
	
	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/knock/knock_jaunt = new(user)
	knock_jaunt.Grant(user)

/datum/eldritch_knowledge/base_ash/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_knock/proc/on_mansus_grasp(mob/living/source, atom/target)
	//SIGNAL_HANDLER - if this is uncommented the whole thing explodes like flesh grasp 

	if(isopenturf(target))//prevent use on tiles
		return COMPONENT_BLOCK_HAND_USE
	if(ismecha(target))
		var/obj/mecha/mecha = target
		mecha.dna_lock = null
		for(var/mob/living/occupant as anything in mecha.occupant)
			mecha.go_out()
	else if(istype(target,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		door.unbolt()
	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/computer = target
		computer.authenticated = TRUE
		computer.balloon_alert(source, "unlocked")

	var/turf/target_turf = get_turf(target)
	SEND_SIGNAL(target_turf, COMSIG_ATOM_MAGICALLY_UNLOCKED, src, source)
	playsound(target, 'sound/magic/hereticknock.ogg', 100, TRUE, -1)

/datum/eldritch_knowledge/key_ring
	name = "T1 - Key Keeper’s Burden"
	desc = "Allows you to transmute a wallet, an iron rod, and an ID card to create an Eldritch Card. \
		It functions the same as an ID Card, but attacking an ID card with it fuses them, causing it to gain the original's access. \
		You can use it in-hand to change its form. \
		Does not preserve the card used in the ritual.\
		Will also allow you to open portals at airlocks to travel between, with a maximum of two."
	gain_text = "Gateways shall open before me, my very will ensnaring reality."

	unlocked_transmutations = list(/datum/eldritch_transmutation/key_ring)
	cost = 1
	route = PATH_KNOCK
	tier = TIER_1

/datum/eldritch_knowledge/knock_mark
	name = "Grasp Mark - Mark of Knock"
	desc = "Your Mansus Grasp now applies the Mark of Knock. \
		Attack a marked person to bar them from all passages for the duration of the mark."
	gain_text = "Their requests for passage will remain unheeded."
	cost = 2
	route = PATH_KNOCK
	tier = TIER_MARK

/datum/eldritch_knowledge/knock_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/knock_mark/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/knock_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/knock)

/datum/eldritch_knowledge/spell/burglar_finesse
	name = "T2 - Burglar's Finesse"
	desc = "Grants you Burglar's Finesse, a single-target spell \
		that puts a random item from the victims backpack into your hand."
	gain_text = "Their trinkets will be mine, as will their lives in due time."
	spell_to_add = /datum/action/cooldown/spell/pointed/burglar_finesse
	cost = 1
	route = PATH_KNOCK
	tier = TIER_2

/datum/eldritch_knowledge/knock_blade_upgrade
	name = "Blade Upgrade - Opening Blade"
	desc = "Your blade will be able to pry open unlocked airlocks."
	gain_text = "The power of my patron courses through my blade, willing their very flesh to part."
	route = PATH_KNOCK
	tier = TIER_BLADE

/datum/eldritch_knowledge/knock_blade_upgrade/on_eldritch_blade(target,mob/user,proximity_flag,click_parameters)
	. = ..()

	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
			return

		if(A.locked)
			to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
			return
		if(A.welded)
			to_chat(user, span_warning("The airlock is welded shut, it won't budge!"))
			return

		if(A.hasPower())
			user.visible_message(span_warning("[user] jams their blade into the airlock and starts prying it open!"), span_warning("We start forcing the airlock open."), //yogs modified description
			span_italics("You hear a metal screeching sound."))
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, 1)
			if(!do_after(user, 6 SECONDS, A))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message(span_warning("[user] forces the airlock to open with their blade!"), span_warning("We force the airlock to open."), //yogs modified description
		span_italics("You hear a metal screeching sound."))
		A.open(2)

/datum/eldritch_knowledge/spell/freedom_forever
	name = "T3 - Freedom Forever"
	desc = "Grants you Freedom Forever, a spell \
		will cause reality to warp around you for a few seconds, confusing enemies and allies alike."
	gain_text = "Flesh opens, and blood spills. My master seeks sacrifice, and I shall appease."
	spell_to_add = /datum/action/cooldown/spell/spacetime_dist/eldritch
	cost = 1
	route = PATH_KNOCK
	tier = TIER_3

/datum/eldritch_knowledge/knock_final
	name = "Ascension Rite - Many secrets behind the Spider Door"
	desc = "The ascension ritual of the Path of Knock. \
		Bring 3 corpses to a transmutation rune to complete the ritual. \
		When completed, you gain damage resistance, and stun immunity \
		and in addition, create a tear to the Spider Door; \
		a tear in reality located at the site of this ritual. \
		Eldritch creatures will endlessly pour from this rift \
		who are bound to obey your instructions."
	gain_text = "With her knowledge, and what I had seen, I knew what to do. \
		I had to open the gates, with the holes in my foes as Ways! \
		Reality will soon be torn, the Spider Gate opened! WITNESS ME!"
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/knock_final)
	route = PATH_KNOCK
	tier = TIER_ASCEND
