/datum/disease/honkrot
	form = "Disease"
	name = "Brain Honk"
	max_stages = 5
	spread_text = "HONK"
	cure_text = "Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "Honk"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5 //Get honked
	desc = "A funny disease, that forces it's victims to act like clowns."
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE
  var/honkshot = 0

/datum/disease/honkrot/stage_act()
	..()
	switch(stage)
    if(1)
      if(prob(20))
				to_chat(affected_mob, span_danger("You feel HONK!"))
        playsound(source, 'sound/items/bikehorn.ogg', 50, TRUE) //Henk
		if(2)
      if(prob(25))
				to_chat(affected_mob, span_danger("You feel HONK!"))
        playsound(source, 'sound/items/bikehorn.ogg', 50, TRUE)
      if(prob(15))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/honkpax = 5))
    if(3)
      if(prob(25))
				to_chat(affected_mob, span_danger("You feel HONK!"))
        playsound(source, 'sound/items/bikehorn.ogg', 50, TRUE)
      if(prob(20))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/honkpax = 5))
		if(4)
      if(prob(25))
				to_chat(affected_mob, span_danger("You feel HONK!"))
        playsound(source, 'sound/items/bikehorn.ogg', 55, TRUE)
      if(prob(20))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/honkpax = 6))
				to_chat(affected_mob, span_danger("You feel clumsy!"))
      if(prob(5))
  
		if(5)
			if(prob(10))

			if(prob(15))

				to_chat(affected_mob, span_danger("You feel hot!"))
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel very weak!"))
	
			if(prob(6))
				to_chat(affected_mob, span_danger("Your lungs feel full of fluid! You're unable to breathe!"))

	return

/datum/disease/honkrot/proc/FirePie()
  var/list/honkdudes = list()
  for(var/mob/living/carbon/human/target in view_or_range(7, affected_mob, "view"))
    if(affected_mob == target)
      continue
    honkdudes += target
  if(!honkdudes)
    honkshot += 15
    return 
  var/prey = pick(honkdudes)
  var/obj/item/reagent_containers/food/snacks/pie/cream/honkpie = new /obj/item/reagent_containers/food/snacks/pie/cream(get_turf(affected_mob))
  honkpie.throw_at(get_turf(prey), 10, 2)
