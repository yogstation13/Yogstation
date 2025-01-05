/*
 * Gang Boss Pens
 */
/obj/item/pen/gang
	var/cooldown

/obj/item/pen/gang/attack(mob/living/M, mob/user, stealth = TRUE)
	if(!istype(M))
		return
	if(!ishuman(M) || !ishuman(user) || M.stat == DEAD)
		return ..()
	var/datum/antagonist/gang/boss/L = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
	if(!L)
		return ..()
	if(!..())
		return
	if(cooldown)
		to_chat(user, span_warning("[src] needs more time to recharge before it can be used."))
		return
	if(!M.client || !M.mind)
		to_chat(user, span_warning("A braindead gangster is an useless gangster!"))
		return
	var/datum/team/gang/gang = L.gang
	if(!add_gangster(user, gang, M.mind))
		return
	cooldown = TRUE
	icon_state = "pen_blink"
	var/cooldown_time = 600/gang.leaders.len
	addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown_time)

/obj/item/pen/gang/proc/cooldown()
	cooldown = FALSE
	icon_state = "pen"
	var/mob/M = loc
	if(istype(M))
		to_chat(M, span_notice("[icon2html(src, M)] [src] vibrates softly. It is ready to be used again."))

/obj/item/pen/gang/proc/add_gangster(mob/user, datum/team/gang/gang, datum/mind/gangster_mind, check = TRUE) // Basically a wrapper to add_antag_datum.
	var/datum/antagonist/dudegang = gangster_mind.has_antag_datum(/datum/antagonist/gang)
	if(dudegang)
		if(dudegang == gang)
			to_chat(user, span_danger("This mind is already controlled by your gang!"))
			return
		to_chat(user, span_danger("This mind is already controlled by someone else!"))
		return
	if(check && HAS_TRAIT(gangster_mind.current, TRAIT_MINDSHIELD)) //Check to see if the potential gangster is implanted
		to_chat(user, span_danger("This mind is too strong to control!"))
		return
	var/mob/living/carbon/human/H = gangster_mind.current // we are sure the dude's human cause it's checked in attack()
	H.silent = max(H.silent, 5)
	H.Knockdown(100)
	if(is_banned_from(gangster_mind.current.ckey, ROLE_GANG))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/game_mode, replace_jobbaned_player), gangster_mind.current, ROLE_GANG, ROLE_GANG) // will gangster_mind point to the new dude's mind? dunno honestly, i hope it does
	gangster_mind.add_antag_datum(/datum/antagonist/gang, gang)
	return TRUE
