/obj/effect/proc_holder/spell/targeted/shapeshift/demon/gluttony //emergency get out of jail card, but better. It also eats everything.
	name = "Gluttony Demon Form"
	desc = "Take on your true demon form. This form is strong but very obvious, and especially weak to holy influence. \
	Also note that damage taken in this form can transform into your normal body. Heal by attacking living creatures before transforming back if gravely wounded! \
	Your unique form as a demon of gluttony also allows you to eat just about any item/corpse by clicking on it."
	shapeshift_type = /mob/living/simple_animal/lesserdemon/gluttony

/mob/living/simple_animal/lesserdemon/gluttony //capable of devouring pretty much anything.
	name = "gluttonous demon"
	real_name = "gluttonous demon"
	melee_damage_lower = 26
	melee_damage_upper = 26

/mob/living/simple_animal/lesserdemon/gluttony/death(gibbed)
	barf_contents()
	..()

/mob/living/simple_animal/lesserdemon/gluttony/proc/barf_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/lesserdemon/gluttony/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/lesserdemon/gluttony/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		visible_message(span_warning("[src] swallows [A] whole!"))
		A.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/lesserdemon/gluttony/UnarmedAttack(mob/living/L, obj/item/I)
	if(isliving(L)) //Eat Corpses to regen health
		if(L.stat == DEAD)
			if(do_after(src, 3 SECONDS, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
	else if(isitem(L)) //Eat items just to be annoying
		if(!I.anchored)
			if(do_after(src, 2 SECONDS, target = I))
				eat(I)
			return
	return ..()
