/datum/hog_god_interaction //Shit for god interacting with hith guys
	var/name = "Do nothing"
	var/description = "Literaly, do nothing. It doesn't do ANYTHING. ANYTHING."
	var/cost = 0
	var/when_recharged //Timers are for weak
	var/cooldown = 0 
	var/is_targeted = FALSE
	

/datum/hog_god_interaction/proc/on_called(var/mob/camera/hog_god/user)
	if(when_recharged > world.time)
		to_chat(user,span_danger("The action is on coldown!"))
		return FALSE		
	var/confirm = alert(user, "[description] It will cost [cost] energy.", "Confirm action", "Yes", "No")
	if(confirm == "No")
		return FALSE
	if(cost > user.cult.energy)
		if(prob(2))
			to_chat(user,span_danger("There is not enough minerals!")) ///Funny references
		else
			to_chat(user,span_warning("You don't have enough energy to use this!"))
		return FALSE
	return TRUE

/datum/hog_god_interaction/proc/on_use(var/mob/camera/hog_god/user) ///Calling this proc is made in attack_god()
	when_recharged = world.time + cooldown
	user.cult.change_energy_amount(-cost)

/datum/hog_god_interaction/proc/on_targeting(var/mob/camera/hog_god/user, var/atom/target) ///Same as on_use but for targeted ones
	when_recharged = world.time + cooldown
	user.cult.change_energy_amount(-cost)

/datum/hog_god_interaction/structure
	var/obj/structure/destructible/hog_structure/owner

/datum/hog_god_interaction/targeted
	is_targeted = TRUE
	



	

	
