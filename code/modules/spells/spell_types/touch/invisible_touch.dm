/datum/action/cooldown/spell/touch/invisible_touch
	name = "Invisible Touch"
	desc = "Touch somthing to make it disapear temporarily."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'// todo all sprites and such
	button_icon_state = "mime_speech"
	panel = "Mime"
	school = SCHOOL_MIME
	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	spell_max_level = 1
	var/list/things = list()
	var/list/blacklist = list (
        /obj/item/weapon/bombcore,
        /obj/item/weapon/reagent_containers/food/snacks/grown/cherry_bomb,
        /obj/item/weapon/grenade,
        /obj/machinery/nuclearbomb/selfdestruct,
        /obj/item/weapon/gun/,
        /obj/item/weapon/disk/nuclear,
        /obj/item/weapon/storage,
        /obj/structure/closet
        )

/datum/action/cooldown/spell/touch/invisible_touch/Destroy()
	for(var/obj/O in things)
		if(!O.alpha)
			reverttarget(O)
	..()

/datum/action/cooldown/spell/touch/invisible_touch/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	if(user.lying || user.handcuffed)
		return
	if(target in blacklist)
		user << "<span class='warning'>[target] is too dangerous to mess with!</span>"
		return
	if(iscarbon(target))
		if(target == user)
			if(user.job == "Mime")
				var/passes = 5
				while(passes > 0)
					if(!user)
						break
					passes--
					user.alpha = 0
					sleep(3)
					user.alpha = initial(user.alpha)
					sleep(2)
			else
				user << "<span class='warning'>You have to be a mime to use this trick!</span>"
		else
			user << "<span class='warning'>It doesn't work on other people!</span>"
	if(isobj(target))
		if(istype(target, /obj/structure/chair))
			target.visible_message("[target] [target.alpha == 0 ? "reappears" : "vanishes"]!</span>")
			if(target.alpha)
				target.alpha = 0
			else
				target.alpha = initial(target.alpha)
			if(!(target in things))// to be restored later
				things += target
			return
		if((target in things))
			user << "<span class='warning'>You can't use this on the same thing more than once!</span>"
			return
		if(!target.alpha)
			return
		things += target
		user << "<span class='warning'>You poke [target] extinguishing one of your charges.</span>"
		target.alpha = 0
		addtimer(src, "reverttarget",8 SECONDS, FALSE, target)

/datum/action/cooldown/spell/touch/invisible_touch/proc/reverttarget(atom/A)
	if(A)
		A.alpha = initial(A.alpha)
