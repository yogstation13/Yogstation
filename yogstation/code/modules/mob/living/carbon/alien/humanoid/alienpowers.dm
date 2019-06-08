/obj/effect/proc_holder/alien/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	plasma_cost = 0
	action_icon_state = "alien_barf"

/obj/effect/proc_holder/alien/regurgitate/fire(mob/living/carbon/user)
	if(user.stomach_contents.len)
		for(var/atom/movable/A in user.stomach_contents)
			user.stomach_contents.Remove(A)
			A.forceMove(user.drop_location())
			if(isliving(A))
				var/mob/M = A
				M.reset_perspective()
		user.visible_message("<span class='alertealien'>[user] hurls out the contents of their stomach!</span>")
