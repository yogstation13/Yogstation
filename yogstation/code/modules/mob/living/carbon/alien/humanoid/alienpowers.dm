/datum/action/cooldown/alien/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach."
	plasma_cost = 0
	button_icon_state = "alien_barf"

/datum/action/cooldown/alien/regurgitate/Activate(mob/living/carbon/user)
	if(user.stomach_contents.len)
		for(var/atom/movable/A in user.stomach_contents)
			user.stomach_contents.Remove(A)
			A.forceMove(user.drop_location())
			if(isliving(A))
				var/mob/M = A
				M.reset_perspective()
		user.visible_message(span_alertealien("[user] hurls out the contents of their stomach!"))
