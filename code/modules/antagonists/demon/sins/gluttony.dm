/obj/effect/proc_holder/spell/targeted/forcewall/gluttony
	name = "Gluttonous Wall"
	desc = "Create a magical barrier that only allows fat people to pass through."
	school = "transmutation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "INDULGE"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "blob"
	action_background_icon_state = "bg_demon"
	range = -1
	include_user = TRUE
	cooldown_min = 50 //12 deciseconds reduction per rank
	wall_type = /obj/effect/gluttony/timed

/obj/effect/proc_holder/spell/targeted/shapeshift/demon/gluttony //emergency get out of jail card, but better. It also eats everything.
	name = "Gluttony Demon Form"
	desc = "Take on your true demon form. This form is strong but very obvious and especially weak to holy influence. \
	Also, note that damage taken in this form can transform into your normal body. Heal by attacking living creatures before transforming back if gravely wounded! \
	Your unique form as a demon of gluttony also allows you to eat corpses to heal yourself."
	shapeshift_type = /mob/living/simple_animal/lesserdemon/gluttony

/mob/living/simple_animal/lesserdemon/gluttony //capable of devouring corpses for health
	name = "gluttonous demon"
	real_name = "gluttonous demon"
	icon_state = "lesserdaemon_gluttony"
	icon_living = "lesserdaemon_gluttony"

/mob/living/simple_animal/lesserdemon/gluttony/UnarmedAttack(mob/living/L)
	if(isliving(L)) //Eat Corpses to regen health
		if(L.stat == DEAD)
			if(do_after(src, 3 SECONDS, L))
				devour(L)
			return
	return ..()

/mob/living/simple_animal/lesserdemon/gluttony/proc/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		span_danger("[src] devours [L]!"),
		span_userdanger("You feast on [L], restoring your health!"))
	adjustBruteLoss(-50)
	L.gib()
	return TRUE

/obj/effect/gluttony/timed
	///Time in deciseconds before it deletes itself.
	var/timeleft = 150

/obj/effect/gluttony/timed/Initialize()
	. = ..()
	if(timeleft)
		QDEL_IN(src, timeleft)
