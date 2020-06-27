/obj/item/weapon/implant/bombcollar
	name = "collar console implant"
	desc = "You die with me."
	origin_tech = "programming=5;biotech=3;bluespace=3"
	var/list/linkedCollars = list()
	var/info
	var/list/boundCollars = list()

/obj/item/weapon/implant/bombcollar/activate(mob/user as mob)
	switch(alert("Select an option.","Bomb Collar Control","Status","Bind","Exit"))
		if("Status")
			imp_in << "<span class='notice'><b>Bomb Collar Status Report:</b></span>"
			for(var/obj/item/clothing/head/bombCollar/C in linkedCollars)
				var/turf/T = get_turf(C)
				imp_in << "<b>[C]:</b> [iscarbon(C.loc) ? "Worn by [C.loc], " : ""][get_area(C)], [T.loc.x], [T.loc.y], [C.locked ? "<span class='boldannounce'>Locked</span>" : "<font color='green'><b>Unlocked</b></font>"]"
			return
		if("Bind")
			var/choice = input(user, "Select collar to bind.", "Binding Control") in linkedCollars
			var/obj/item/clothing/head/bombCollar/collarToBind = choice
			if(!collarToBind)
				return
			if(!iscarbon(collarToBind.loc))
				imp_in << "<span class='warning'>That collar isn't being held or worn by anyone.</span>"
				return
			var/mob/living/carbon/C = collarToBind.loc
			if(C.head != collarToBind)
				imp_in << "<span class='warning'>That collar isn't around someone's neck.</span>"
				return
			for(var/obj/item/clothing/head/bombCollar in boundCollars)
				boundCollars -= collarToBind
				imp_in << "You unbind [collarToBind] to you, once you die, they wont."
				message_admins("[imp_in] unbound [collarToBind]")
				return

			boundCollars += collarToBind
			imp_in << "You bind [collarToBind] to you, once you die, they die with you."
			message_admins("[collarToBind] has been been bound to [imp_in], if [imp_in] dies, so does [collarToBind]")
			return
		if("Exit")
			return

/obj/item/weapon/implant/bombcollar/trigger(emote)
	if(emote == "deathgasp")
		alluha_ackbar()

/obj/item/weapon/implant/bombcollar/proc/alluha_ackbar(mob/source) //I'm not great with names
	for(var/obj/item/clothing/head/bombCollar/C in boundCollars)
		C.detonate()
		message_admins("[C] detonated due to the death of an implantee")

/obj/item/weapon/implanter/bombcollar
	name = "implanter (collar console)"

/obj/item/weapon/implanter/bombcollar/New()
	imp = new /obj/item/weapon/implant/bombcollar(src)
	..()

/obj/item/weapon/implantcase/bombcollar
	name = "implant case - 'Collar Console'"
	desc = "A glass case containing an implant version of the collar detonator."

/obj/item/weapon/implantcase/bombcollar/New()
	imp = new /obj/item/weapon/implant/bombcollar(src)
	..()