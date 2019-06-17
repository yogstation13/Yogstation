/obj/effect/dummy/crawling
	name = "THESE WOUNDS, THEY WILL NOT HEAL"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/crawling/relaymove(mob/user, direction)
	forceMove(get_step(src,direction))

/obj/effect/dummy/crawling/ex_act()
	return
/obj/effect/dummy/crawling/bullet_act()
	return
/obj/effect/dummy/crawling/singularity_act()
	return

/datum/component/crawl
	var/list/crawling_types //the types of objects we use to get in and out of crawling
	var/obj/effect/dummy/crawling/holder

	var/gain_message = "<span class='notice'>Make an issue on github stating what you were doing when this message appeared!</span>"
	var/loss_message = "<span class='notice'>Make an issue on github stating what you were doing when this message appeared!</span>"

/datum/component/crawl/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ALT_CLICK_ON, .proc/try_crawl)
	var/mob/living/M = parent
	on_gain(M)

/datum/component/crawl/proc/try_crawl(datum/source, atom/target)
	set waitfor = FALSE
	var/can_crawl = FALSE
	for(var/type in crawling_types)
		if(istype(target, type))
			can_crawl = TRUE
			break
	if(!can_crawl)
		return FALSE
	var/mob/living/M = parent
	if(M.incapacitated())
		return FALSE

	. = TRUE
	if(holder && can_stop_crawling(target, M))
		stop_crawling(target, M)
	else if(!istype(M.loc, /obj/effect/dummy/crawling) && can_start_crawling(target, M)) //no crawling while crawling
		start_crawling(target, M)

/datum/component/crawl/proc/can_start_crawling(atom/target, mob/living/user)
	if(!user.Adjacent(target))
		return FALSE
	return !user.notransform

/datum/component/crawl/proc/can_stop_crawling(atom/target, mob/living/user)
	return !user.notransform

/datum/component/crawl/proc/on_gain(mob/living/user)
	to_chat(user, gain_message)

/datum/component/crawl/proc/on_loss(mob/living/user)
	to_chat(user, loss_message)

/datum/component/crawl/proc/start_crawling(atom/target, mob/living/user)
	holder = new(get_turf(user))
	user.forceMove(holder)

/datum/component/crawl/proc/stop_crawling(atom/target, mob/living/user)
	user.forceMove(get_turf(target))
	qdel(holder)
	holder = null

/datum/component/crawl/RemoveComponent(del_holder=TRUE)
	var/mob/living/M = parent
	if(del_holder && holder)
		M.forceMove(get_turf(holder))
		qdel(holder)
	on_loss(M)
	return ..()

////////////BLOODCRAWL
/datum/component/crawl/blood
	crawling_types = list(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/xenoblood, /obj/effect/decal/cleanable/trail_holder)
	gain_message = "<span class='boldnotice'>You can now bloodcrawl! Alt-click blood or gibs to phase in and out.</span>"
	loss_message = "<span class='warning'>You can no longer bloodcrawl.</span>"

	var/kidnap = FALSE
	var/speed_boost = FALSE

/datum/component/crawl/blood/can_start_crawling(atom/target, mob/living/user)
	if(istype(target, /obj/effect/decal/cleanable/blood/footprints))
		var/obj/effect/decal/cleanable/blood/footprints/F = target
		if(F.blood_state != "blood")
			return FALSE
	if(!iscarbon(user))
		return ..()
	var/mob/living/carbon/C = user
	for(var/obj/item/I in C.held_items)
		to_chat(C, "<span class='warning'>You may not hold items while blood crawling!</span>")
		return FALSE
	return ..()

/datum/component/crawl/blood/start_crawling(atom/target, mob/living/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/bloodcrawl/B1 = new(C)
		var/obj/item/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()
		C.ExtinguishMob()
	var/pullee = user.pulling
	user.visible_message("<span class='warning'>[user] sinks into the pool of blood!</span>")
	playsound(get_turf(target), 'sound/magic/enter_blood.ogg', 100, 1, -1)
	..()

	if(!kidnap || !pullee || !isliving(pullee))
		return
	var/mob/living/victim = pullee
	if(victim.stat == CONSCIOUS)
		target.visible_message("<span class='warning'>[victim] kicks free of the blood pool just before entering it!</span>", null, "<span class='notice'>You hear splashing and struggling.</span>")
		return
	if(victim.reagents && victim.reagents.has_reagent("demonsblood"))
		target.visible_message("<span class='warning'>Something prevents [victim] from entering the pool!</span>", null, "<span class='notice'>You hear a splash and a thud.</span>")
		to_chat(user, "<span class='warning'>Some strange force is preventing you from pulling [victim] in!<span>")
		return
	victim.emote("scream")
	victim.forceMove(user)
	target.visible_message("<span class='warning'><b>[user] drags [victim] into the pool of blood!</b></span>", null, "<span class='notice'>You hear a splash.</span>")

	user.notransform = TRUE
	devour(victim, user, target)
	user.notransform = FALSE

/datum/component/crawl/blood/stop_crawling(atom/target, mob/living/user)
	target.visible_message("<span class='warning'>[target] starts to bubble...</span>")
	if(!do_after(user, 20, target = target))
		return
	if(!target)
		return
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		for(var/obj/item/bloodcrawl/BC in C)
			qdel(BC)
	..()
	user.visible_message("<span class='warning'><B>[user] rises out of the pool of blood!</B></span>")
	exit_blood_effect(target, user)
	if(speed_boost)
		if(istype(user, /mob/living/simple_animal))
			var/mob/living/simple_animal/SA = user
			SA.speed = 0
			addtimer(VARSET_CALLBACK(SA, speed, 1), 6 SECONDS)

/datum/component/crawl/blood/proc/devour(mob/living/victim, mob/living/user, atom/target)
	to_chat(user, "<span class='danger'>You begin to feast on [victim]. You can not move while you are doing this.</span>")
	var/sound
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/SD = user
		sound = SD.feast_sound
	else
		sound = 'sound/magic/demon_consume.ogg'
	for(var/i=1 to 3)
		playsound(get_turf(user), sound, 100, 1)
		sleep(30)
	if(!victim)
		to_chat(user, "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>")
		return

	if(victim.reagents && victim.reagents.has_reagent("devilskiss"))
		to_chat(user, "<span class='warning'><b>AAH! THEIR FLESH! IT BURNS!</b></span>")
		user.adjustBruteLoss(25) //I can't use adjustHealth() here because bloodcrawl affects /mob/living and adjustHealth() only affects simple mobs

		if(target)
			victim.forceMove(get_turf(target))
			victim.visible_message("<span class='warning'>[target] violently expels [victim]!</span>")
		else
			// Fuck it, just eject them, thanks to some split second cleaning
			victim.forceMove(get_turf(victim))
			victim.visible_message("<span class='warning'>[victim] appears from nowhere, covered in blood!</span>")
		exit_blood_effect(target, victim)
		return

	to_chat(user, "<span class='danger'>You devour [victim]. Your health is fully restored.</span>")
	user.revive(full_heal = 1)

	victim.adjustBruteLoss(1000)
	victim.death()
	swallow(victim)

/datum/component/crawl/blood/proc/swallow(mob/living/victim, mob/living/user)
	qdel(victim)

/datum/component/crawl/blood/proc/exit_blood_effect(atom/target, mob/living/user)
	playsound(get_turf(target), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	//Makes the mob have the color of the blood pool it came out of
	var/newcolor = rgb(149, 10, 10)
	if(istype(target, /obj/effect/decal/cleanable/xenoblood))
		newcolor = rgb(43, 186, 0)
	user.add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	// but only for a few seconds
	addtimer(CALLBACK(user, /atom/.proc/remove_atom_colour, TEMPORARY_COLOUR_PRIORITY, newcolor), 3 SECONDS)

/datum/component/crawl/blood/demonic
	kidnap = TRUE
	speed_boost = TRUE

/datum/component/crawl/blood/demonic/hilarious
	var/list/friends = list()

/datum/component/crawl/blood/demonic/hilarious/swallow(mob/living/victim, mob/living/user)
	friends += victim

////////////LOCKERCRAWL
/datum/component/crawl/locker
	crawling_types = list(/obj/structure/closet)
	gain_message = "<span class='boldnotice'>You can now lockercrawl! Alt-click a locker you are inside of to phase out, alt-click a closed locker to phase in.</span>"
	loss_message = "<span class='warning'>You can no longer lockercrawl.</span>"

/datum/component/crawl/locker/can_start_crawling(atom/target, mob/living/user)
	if(!(user in target.contents))
		target.AltClick(user) //toggle the lock if we aren't inside
		return FALSE
	var/obj/structure/closet/C = target
	if(C.opened)
		to_chat(user, "<span class='warning'>Close the locker first!</span>")
		return FALSE
	if(user.notransform)
		return FALSE
	return TRUE

/datum/component/crawl/locker/can_stop_crawling(atom/target, mob/living/user)
	var/obj/structure/closet/C = target
	if(C.opened)
		return FALSE
	var/mobs = 0
	for(var/mob/living/L in C)
		mobs++
	if(mobs >= C.mob_storage_capacity)
		to_chat(user, "<span class='warning'>This locker is full!</span>")
		return FALSE
	return ..()

/datum/component/crawl/locker/start_crawling(atom/target, mob/living/user)
	to_chat(user, "<span class='notice'>You close your eyes, plug your ears and start counting to three...</span>")
	target.visible_message("<span class='warning'>[target] starts shaking uncontrollably!</span")
	target.Shake(3, 3, 3 SECONDS * 5)
	if(!do_after(user, 3 SECONDS, target = target))
		return
	..()
	to_chat(user, "<span class='notice'>You open your eyes and find yourself in the locker dimension.</span>")
	user.reset_perspective()
	user.clear_fullscreen("remote_view")

/datum/component/crawl/locker/stop_crawling(atom/target, mob/living/user)
	target.visible_message("<span class='warning'>[target] starts shaking uncontrollably!</span")
	target.Shake(3, 3, 3 SECONDS * 5)
	if(!do_after(user, 3 SECONDS, target = target))
		return
	user.forceMove(target)
	qdel(holder)
	holder = null
	to_chat(user, "<span class='notice'>You are back in the material plane.</span>")
	user.reset_perspective()

/datum/component/crawl/meme
	var/thing = "meme"
	var/crawl_name

/datum/component/crawl/meme/Initialize()
	if(!crawl_name)
		crawl_name = thing
	gain_message = "<span class='boldnotice'>You can now [crawl_name]! Alt-click on [thing] to phase in and out.</span>"
	loss_message = "<span class='warning'>You can no longer [crawl_name].</span>"
	..()

/datum/component/crawl/meme/start_crawling(atom/target, mob/living/user)
	target.visible_message("<span class='warning'>[user] disappears into [target]!</span>")
	playsound(get_turf(target), 'sound/magic/enter_blood.ogg', 100, 1, -1)
	..()

/datum/component/crawl/meme/stop_crawling(atom/target, mob/living/user)
	target.visible_message("<span class='warning'>[user] rises from [target]!</span>")
	playsound(get_turf(target), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	..()

/datum/component/crawl/meme/food
	thing = "food"
	crawling_types = list(/obj/item/reagent_containers/food)

/datum/component/crawl/meme/trash
	thing = "trash"
	crawling_types = list(/obj/item/trash)

/datum/component/crawl/meme/animal
	thing = "animals"
	crawl_name = "animalcrawl"
	crawling_types = list(/mob/living/simple_animal)

/datum/component/crawl/meme/human
	thing = "people"
	crawl_name = "humancrawl"
	crawling_types = list(/mob/living/carbon/human)

/datum/component/crawl/meme/human/corpse
	thing = "dead and unconscious people"
	crawl_name = "corpsecrawl"
	crawling_types = list(/mob/living/carbon/human)

/datum/component/crawl/meme/human/corpse/can_start_crawling(atom/target, mob/living/user)
	var/mob/living/carbon/human/H = target
	if(H.stat < UNCONSCIOUS)
		return FALSE
	return ..()

/datum/component/crawl/meme/human/corpse/can_stop_crawling(atom/target, mob/living/user)
	var/mob/living/carbon/human/H = target
	if(H.stat < UNCONSCIOUS)
		return FALSE
	return ..()

/datum/component/crawl/meme/silicon
	thing = "silicons"
	crawl_name = "siliconcrawl"
	crawling_types = list(/mob/living/silicon)