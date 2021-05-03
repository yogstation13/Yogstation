/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message("<span class='suicide'>[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!</span>")
		afterattack(user,user)
		return OXYLOSS
	else if (safety && (reagents.total_volume >= 1))
		user.visible_message("<span class='warning'>[user] puts the nozzle to [user.p_their()] mouth... The safety's still on!</span>")
		return SHAME
	else
		user.visible_message("<span class='warning'>[user] puts the nozzle to [user.p_their()] mouth... [src] is empty!</span>")
		return SHAME
