/obj/item/extinguisher/suicide_act(mob/living/carbon/user)
	if (!safety && (reagents.total_volume >= 1))
		user.visible_message(span_suicide("[user] puts the nozzle to [user.p_their()] mouth. It looks like [user.p_theyre()] trying to extinguish the spark of life!"))
		afterattack(user,user)
		return OXYLOSS
	else if (safety && (reagents.total_volume >= 1))
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... The safety's still on!"))
		return SHAME
	else
		user.visible_message(span_warning("[user] puts the nozzle to [user.p_their()] mouth... [src] is empty!"))
		return SHAME
