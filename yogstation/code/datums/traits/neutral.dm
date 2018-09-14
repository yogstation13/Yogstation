/* Yogstation Neutral Traits */
/datum/quirk/monochromatic
	name = "Monochromacy"
	desc = "You suffer from full colorblindness, and perceive nearly the entire world in blacks and whites."
	value = 0
	medical_record_text = "Patient is afflicted with almost complete color blindness."

/datum/quirk/monochromatic/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/monochromatic/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		if(H.mind.assigned_role == "Detective")
			to_chat(quirk_holder, "<span class='boldannounce'>Mmm. Nothing's ever clear on this station. It's all shades of gray...</span>")
			quirk_holder.playsound_local(quirk_holder, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/quirk/monochromatic/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.remove_client_colour(/datum/client_colour/monochrome)

/datum/quirk/greyscale_vision
	name = "Old School Vision"
	desc = "Did you get stuck in an old video recorder? You can only see in black and white!"
	value = 0
	gain_text = "<span class='notice'>...Huh? You can't see colour anymore!</span>"
	lose_text = "<span class='notice'>You can see colour again!</span>"

/datum/quirk/greyscale_vision/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.add_client_colour(/datum/client_colour/greyscale)

/datum/quirk/greyscale_vision/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.remove_client_colour(/datum/client_colour/greyscale)

/datum/quirk/inverted_vision
	name = "Inverted Colour Vision"
	desc = "You see red and blue colours as reversed."
	value = 0
	gain_text = "<span class='notice'>You feel like you're seeing colours differently.</span>"
	lose_text = "<span class='notice'>You feel like you're seeing colours normally again.</span>"

/datum/quirk/inverted_vision/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.add_client_colour(/datum/client_colour/inverted)

/datum/quirk/inverted_vision/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		H.remove_client_colour(/datum/client_colour/inverted)

/datum/quirk/waddle
	name = "Waddle"
	desc = "You have an extra bounce in your step."
	value = 0
	gain_text = "<span class='notice'>The world starts to bob as you move.</span>"
	lose_text = "<span class='notice'>The world no longer bobs as you move.</span>"

/datum/quirk/waddle/add()
	var/mob/living/carbon/human/H = quirk_holder
	if (H)
		H.AddComponent(/datum/component/waddling)

/datum/quirk/waddle/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if (H)
		var/datum/component/waddling/W = H.GetComponent(/datum/component/waddling)
		if (W)
			W.RemoveComponent()