/datum/brain_trauma/special/imaginary_friend/mrat
	name = "Epistemania"
	desc = "Patient suffers from a manic pursuit of knowlewdge."
	scan_desc = "epistemania"
	gain_text = "<span class='notice'>Requesting mentor rat...</span>"
	lose_text = "<span class='warning'>Mentor rat not found. Either your mentor rat left you or you didn't find one.</span>"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/special/imaginary_friend/mrat/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollMentorCandidatesForMob("Do you want to play as [owner]'s mentor rat?", ROLE_PAI, null, null, 75, friend, POLL_IGNORE_IMAGINARYFRIEND)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		friend.key = C.key
		friend_initialized = TRUE
		to_chat(owner, "<span class='notice'>You have acquired the mentor rat known as [friend.key], ask them any question you like.</span>")
	else
		qdel(src)

/mob/camera/imaginary_friend/mrat
	name = "Mentor Rat"
	real_name = "Mentor Rat"
	desc = "A mentor."

	var/datum/action/innate/mrat_leave/leave

/mob/camera/imaginary_friend/mrat/greet()
		to_chat(src, "<span class='notice'><b>You are the mentor rat of [owner]!</b></span>")
		to_chat(src, "<span class='notice'>Do not give [owner] any OOC information from your time as a ghost.</span>")
		to_chat(src, "<span class='notice'>Your job is to answer [owner]'s question(s) and you are given this form to assist in that.</span>")
		to_chat(src, "<span class='notice'>Don't be stupid with this or you will face the consequences.</span>")

/mob/camera/imaginary_friend/mrat/Initialize(mapload, _trauma)
	. = ..()

	trauma = _trauma
	owner = trauma.owner

	setup_friend()

	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)
	leave = new
	leave.Grant(src)


/mob/camera/imaginary_friend/mrat/setup_friend()
	real_name = src.ckey
	name = real_name
	human_image = icon('icons/mob/animal.dmi', icon_state = "mouse_gray")

/datum/action/innate/mrat_leave
	name = "Leave"
	desc = "Leave and return to your ghost form."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "beam_up"

/datum/action/innate/mrat_leave/Activate()
	var/mob/camera/imaginary_friend/I = owner
	qdel(I.trauma)
