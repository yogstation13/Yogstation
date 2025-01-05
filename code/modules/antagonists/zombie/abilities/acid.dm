/*/obj/effect/proc_holder/zombie/acid
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	button_icon_state = "alien_acid"
	cooldown_time = 2.5 MINUTES

/obj/effect/proc_holder/zombie/acid/on_gain(mob/living/carbon/user)
	user.verbs.Add(/mob/living/carbon/proc/spitter_zombie_acid)

/obj/effect/proc_holder/zombie/acid/on_lose(mob/living/carbon/user)
	user.verbs.Remove(/mob/living/carbon/proc/spitter_zombie_acid)

/obj/effect/proc_holder/zombie/acid/proc/corrode(atom/target,mob/living/carbon/user = usr)
	if(target in oview(1, user))
		if(target.acid_act(200, 100))
			user.visible_message(span_alertalien("[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!"))
			return TRUE
		else
			to_chat(user, span_noticealien("You cannot dissolve this object."))


			return FALSE
	else
		to_chat(src, span_noticealien("[target] is too far away."))
		return FALSE


/obj/effect/proc_holder/zombie/acid/fire(mob/living/carbon/user)
	var/O = input("Select what to dissolve:", "Dissolve", null) as obj|turf in oview(1,user)
	if(!O || user.incapacitated())
		return FALSE
	if(corrode(O, user))
		return ..()


/mob/living/carbon/proc/spitter_zombie_acid(O as obj|turf in oview(1)) // right click menu verb ugh
	set name = "Corrosive Acid"

	if(!isinfected(usr))
		return
	var/mob/living/carbon/user = usr
	var/obj/effect/proc_holder/zombie/acid/A = locate() in user.actions
	if(!A)
		return

	if(!A.ready)
		to_chat(user, span_userdanger("Please wait. You will be able to use this ability in [(A.cooldown_ends - world.time) / 10] seconds"))
		return

	if(A.corrode(O, user))
		A.start_cooldown()
*/
