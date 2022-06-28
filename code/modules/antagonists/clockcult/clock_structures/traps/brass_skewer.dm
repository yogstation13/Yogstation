//Non-servants standing over this will get spikes through the feet, immobilizing them until they're freed.
/obj/structure/destructible/clockwork/trap/brass_skewer
	name = "brass skewer"
	desc = "A deadly brass spike, cleverly concealed in the floor. You think you should be safe if you disarm whatever's meant to set it off."
	clockwork_desc = "A barbaric but undeniably effective weapon: a spear through the chest. It immobilizes anyone unlucky enough to step on it and keeps them in place until they get help.."
	icon_state = "brass_skewer"
	break_message = span_warning("The skewer snaps in two!")
	max_integrity = 40
	density = FALSE
	can_buckle = TRUE
	buckle_prevents_pull = TRUE
	buckle_lying = FALSE
	var/wiggle_wiggle
	var/mutable_appearance/impale_overlay //This is applied to any mob impaled so that they visibly have the skewer coming through their chest

/obj/structure/destructible/clockwork/trap/brass_skewer/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/clockwork/trap/brass_skewer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(buckled_mobs && LAZYLEN(buckled_mobs))
		var/mob/living/L = buckled_mobs[1]
		if(iscarbon(L))
			L.Paralyze(100)
			L.visible_message(span_warning("[L] is maimed as the skewer shatters while still in [L.p_their()] body!"))
			L.adjustBruteLoss(15)
		unbuckle_mob(L)
	return ..()

/obj/structure/destructible/clockwork/trap/brass_skewer/process()
	if(density)
		if(buckled_mobs && LAZYLEN(buckled_mobs))
			var/mob/living/spitroast = buckled_mobs[1]
			spitroast.adjustBruteLoss(0.1)

/obj/structure/destructible/clockwork/trap/attackby(obj/item/I, mob/living/user, params)
	if(buckled_mobs && (user in buckled_mobs))
		to_chat(user, span_warning("You can't reach!"))
		return
	..()

/obj/structure/destructible/clockwork/trap/brass_skewer/bullet_act(obj/item/projectile/P)
	if(buckled_mobs && LAZYLEN(buckled_mobs))
		var/mob/living/L = buckled_mobs[1]
		return L.bullet_act(P)
	return ..()

/obj/structure/destructible/clockwork/trap/brass_skewer/activate()
	if(density)
		return
	var/mob/living/squirrel = locate() in get_turf(src)
	if(squirrel)
		if(iscyborg(squirrel))
			if(!squirrel.stat)
				squirrel.visible_message(span_boldwarning("A massive brass spike erupts from the ground, rending [squirrel]'s chassis but shattering into pieces!"), \
				span_userdanger("A massive brass spike rips through your chassis and bursts into shrapnel in your casing!"))
				squirrel.adjustBruteLoss(50)
				squirrel.Stun(20)
				addtimer(CALLBACK(src, .proc/take_damage, max_integrity), 1)
		else
			squirrel.visible_message(span_boldwarning("A massive brass spike erupts from the ground, impaling [squirrel]!"), \
			span_userdanger("A massive brass spike rams through your chest, hoisting you into the air!"))
			squirrel.emote("scream")
			playsound(squirrel, 'sound/effects/splat.ogg', 50, TRUE)
			playsound(squirrel, 'sound/misc/desceration-03.ogg', 50, TRUE)
			squirrel.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			squirrel.Stun(20)
		buckle_mob(squirrel, TRUE)
	else
		visible_message(span_danger("A massive brass spike erupts from the ground!"))
	playsound(src, 'sound/machines/clockcult/brass_skewer.ogg', 75, FALSE)
	icon_state = "[initial(icon_state)]_extended"
	density = TRUE //Skewers are one-use only
	desc = "A vicious brass spike protruding from the ground like a stala[pick("gm", "ct")]ite. It makes you sick to look at." //is stalagmite the ground one? or the ceiling one? who can ever remember?

/obj/structure/destructible/clockwork/trap/brass_skewer/user_buckle_mob()
	return

/obj/structure/destructible/clockwork/trap/brass_skewer/post_buckle_mob(mob/living/L)
	if(L in buckled_mobs)
		L.pixel_y = 3
		impale_overlay = mutable_appearance('icons/obj/clockwork_objects.dmi', "brass_skewer_pokeybit", ABOVE_MOB_LAYER)
		add_overlay(impale_overlay)
	else
		L.pixel_y = initial(L.pixel_y)
		L.cut_overlay(impale_overlay)

/obj/structure/destructible/clockwork/trap/brass_skewer/user_unbuckle_mob(mob/living/skewee, mob/living/user)
	if(user == skewee)
		if(wiggle_wiggle)
			return
		user.visible_message(span_warning("[user] starts wriggling off of [src]!"), \
		span_danger("You start agonizingly working your way off of [src]..."))
		wiggle_wiggle = TRUE
		if(!do_after(user, 30 SECONDS, user))
			user.visible_message(span_warning("[user] slides back down [src]!"))
			user.emote("scream")
			user.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
			playsound(user, 'sound/misc/desceration-03.ogg', 50, TRUE)
			wiggle_wiggle = FALSE
			return
		wiggle_wiggle = FALSE
	else
		user.visible_message(span_danger("[user] starts tenderly lifting [skewee] off of [src]..."), \
		span_danger("You start tenderly lifting [skewee] off of [src]..."))
		if(!do_after(user, 6 SECONDS, skewee))
			skewee.visible_message(span_warning("[skewee] painfully slides back down [src]."))
			skewee.emote("moan")
			return
	skewee.visible_message(span_danger("[skewee] comes free of [src] with a squelching pop!"), \
	span_boldannounce("You come free of [src]!"))
	skewee.Paralyze(30)
	playsound(skewee, 'sound/misc/desceration-03.ogg', 50, TRUE)
	unbuckle_mob(skewee)
