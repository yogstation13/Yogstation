/*/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 0
	clothes_req = 0
	//If you couldn't cast this while phased, you'd have a problem
	phase_allowed = 1
	selection_type = "range"
	range = 1
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/phased = 0

/obj/effect/proc_holder/spell/bloodcrawl/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in range(range, get_turf(user)))
		if(target.can_bloodcrawl_in())
			perform(target)
			return
	revert_cast()
	to_chat(user, "<span class='warning'>There must be a nearby source of blood!</span>")

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(phased == 1)
			if(user.phasein(target))
				phased = 0
		else
			if(user.phaseout(target))
				phased = 1
		start_recharge()
		return
	revert_cast()
	to_chat(user, "<span class='warning'>You are unable to blood crawl!</span>")*/

/obj/effect/decal/cleanable/blood/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl)
		if(user.stat != CONSCIOUS)//people managed to hide in blood while knocked out
			return
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)


/obj/effect/decal/cleanable/trail_holder/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl && user.Adjacent(src))
		if(user.stat != CONSCIOUS)
			return
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/turf/CtrlClick(var/mob/living/user)
	if(!istype(user))
		return
	if(user.bloodcrawl)
		if(user.stat != CONSCIOUS)//no hiding in blood while KOed
			return
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
				if(user.holder)
					user.phasein(B)
					break
				else
					user.phaseout(B)
					break
	..()