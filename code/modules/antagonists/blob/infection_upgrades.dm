/datum/infection_upgrade
	var/id = "test"
	var/name = "TEST"
	var/desc = "Contact an admin"
	var/cost = 0
	var/bought = FALSE

/datum/infection_upgrade/proc/onPurchase(/mob/camera/blob/infection)
	return FALSE


/datum/infection_upgrade
	id = "ballistic_gel"
	name = "Ballistic Gel"
	desc = "Gives +10% resistance to brute damage"
	cost = 1

/datum/infection_upgrade/onPurchase()
	if(bought)
		return
	if(infection.biopoints >= cost)
		infection.biopoints -= cost
		infection.brute_resistance += 0.1
		bought = TRUE
		return TRUE
	return FALSE