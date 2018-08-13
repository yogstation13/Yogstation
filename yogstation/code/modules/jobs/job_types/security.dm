/datum/job/hos/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	var/datum/martial_art/cqc/seccqc = new
	seccqc.teach(H)
	to_chat(H, "<span class='bold info'><font size='2'>In the academy not only did you essentially get abused, but you've gained a life skill, the art of Close Quarters Combat.</span></font>")

/datum/job/warden/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	var/datum/martial_art/krav_maga/brigdefense = new
	brigdefense.teach(H)
	to_chat(H, "<span class='bold info'><font size='2'>During your strict training to become a mall cop, they gave you some sort of nanites and a promotion. You know the arts of Krav Maga.</span></font>")

/datum/job/officer/after_spawn(mob/living/carbon/human/H, mob/M)
	var/art = pickweight("Flip" = 10,"Block" = 30,"Punch" = 30,"Headbutt" = 20,"Grab" = 20,"Disarm" = 25)
	var/description = ""
	switch(art)
		if("Block")
			var/datum/martial_art/sec/blocker/martialart = new
			description = martialart.desc
			martialart.teach(H)

		if("Punch")
			var/datum/martial_art/sec/puncher/martialart = new
			description = martialart.desc
			martialart.teach(H)


		if("Headbutt")
			var/datum/martial_art/sec/headbutter/martialart = new
			description = martialart.desc
			martialart.teach(H)


		if("Grab")
			var/datum/martial_art/sec/grabber/martialart = new
			description = martialart.desc
			martialart.teach(H)


		if("Disarm")
			var/datum/martial_art/sec/disarmer/martialart = new
			description = martialart.desc
			martialart.teach(H)


		if("Flip")
			var/datum/martial_art/sec/flipper/martialart = new
			description = martialart.desc
			martialart.teach(H)

	to_chat(M, "<span class='bold info'><font size='2'[description]</span></font>")
	..()