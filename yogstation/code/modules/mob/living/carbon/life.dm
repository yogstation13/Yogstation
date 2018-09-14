/mob/living/carbon/handle_brain_damage()
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life()

/mob/living/carbon/handle_status_effects()
	. = ..()

	if (drunkenness > 20)
		var/mob/living/carbon/human/H = src

		if (istype(H))
			var/datum/component/waddling/W = H.GetComponent(/datum/component/waddling)

			if (!W)
				W = H.AddComponent(/datum/component/waddling)
				to_chat(src, "<span class='warning'>Walking straight feels very hard...</span>")
			
			// minimum of 1, max of 4
			var/waddle_multi = CLAMP(drunkenness / 25, 1, 4)

			W.waddle_min = -12 * waddle_multi
			W.waddle_max = 12 * waddle_multi
			W.z_change = 4 * waddle_multi / 2
	else
		var/has_waddle = locate(/datum/quirk/waddle) in roundstart_quirks
		
		if (!has_waddle)
			var/mob/living/carbon/human/H = src

			if (istype(H))
				var/datum/component/waddling/W = H.GetComponent(/datum/component/waddling)

				if (W)
					W.RemoveComponent()
					to_chat(src, "<span class='warning'>Walking doesn't seem so hard as you sober up.</span>")