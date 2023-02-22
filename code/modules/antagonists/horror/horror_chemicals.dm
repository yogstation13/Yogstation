/mob/living/simple_animal/horror/Topic(href, href_list, hsrc)
	if(href_list["horror_use_chem"])
		locate(href_list["src"])
		if(!istype(src, /mob/living/simple_animal/horror))
			return

		var/topic_chem = href_list["horror_use_chem"]
		var/datum/horror_chem/C

		for(var/datum in typesof(/datum/horror_chem))
			var/datum/horror_chem/test = new datum()
			if(test.chemname == topic_chem)
				C = test
				break

		if(!istype(C, /datum/horror_chem))
			return

		if(!C || !victim || controlling || !src || stat)
			return

		if(!istype(C, /datum/horror_chem))
			return

		if(chemicals < C.chemuse)
			to_chat(src, span_boldnotice("You need [C.chemuse] chemicals stored to use this chemical!"))
			return

		to_chat(src, span_danger("You squirt a measure of [C.chemname] from your reservoirs into [victim]'s bloodstream."))
		victim.reagents.add_reagent(C.R, C.quantity)
		chemicals -= C.chemuse
		log_game("[src]/([src.ckey]) has injected [C.chemname] into their host [victim]/([victim.ckey])")

		src << output(chemicals, "ViewHorror\ref[src]Chems.browser:update_chemicals")

	..()

/datum/horror_chem
	var/chemname
	var/chem_desc = "This is a chemical"
	var/datum/reagent/R
	var/chemuse = 30
	var/quantity = 10

/datum/horror_chem/epinephrine
	chemname = "epinephrine"
	R = /datum/reagent/medicine/epinephrine
	chem_desc = "Stabilizes critical condition and slowly restores oxygen damage."

/datum/horror_chem/mannitol
	chemname = "mannitol"
	R = /datum/reagent/medicine/mannitol
	chem_desc = "Heals brain damage."

/datum/horror_chem/bicaridine
	chemname = "bicaridine"
	R = /datum/reagent/medicine/bicaridine
	chem_desc = "Heals brute damage."

/datum/horror_chem/kelotane
	chemname = "kelotane"
	R = /datum/reagent/medicine/kelotane
	chem_desc = "Heals burn damage."

/datum/horror_chem/charcoal
	chemname = "charcoal"
	R = /datum/reagent/medicine/charcoal
	chem_desc = "Slowly heals toxin damage, while also slowly removing any other chemicals."

/datum/horror_chem/adrenaline
	chemname = "adrenaline"
	R = /datum/reagent/medicine/changelingadrenaline
	chemuse = 100
	chem_desc = "Stimulates the brain, shrugging off effect of stuns while regenerating stamina."

/datum/horror_chem/rezadone
	chemname = "rezadone"
	R = /datum/reagent/medicine/rezadone
	chemuse = 50
	chem_desc = "Heals cellular damage."

/datum/horror_chem/pen_acid
	chemname = "pentetic acid"
	R = /datum/reagent/medicine/pen_acid
	chemuse = 50
	chem_desc = "Reduces massive amounts of radiation and toxin damage while purging other chemicals from the body."

/datum/horror_chem/sal_acid
	chemname = "salicyclic acid"
	R = /datum/reagent/medicine/sal_acid
	chem_desc = "Stimulates the healing of severe bruises. Rapidly heals severe bruising and slowly heals minor ones."

/datum/horror_chem/oxandrolone
	chemname = "oxandrolone"
	R = /datum/reagent/medicine/oxandrolone
	chem_desc = "Stimulates the healing of severe burns. Rapidly heals severe burns and slowly heals minor ones."