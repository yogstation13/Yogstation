/datum/team/hog_cult
	var/cult_objective/objective 

/datum/hog_objective
    var/name = "go fuck yourself"
    var/description = "go, and fuck yourself"
    var/datum/team/hog_cult/cult
    var/completed = FALSE

/datum/hog_objective/proc/check_completion()
    cult.can_ascend = completed
    return completed

/datum/hog_objective/proc/setup(var/datum/team/hog_cult/new_cult)
    cult = new_cult

/datum/hog_objective/sacrifice
    name = "Sacrificing"
    description = "You need to sacrifice X people, to be able to free your god and let him into the mortal plane."
    var/sacrifices_needed

/datum/hog_objective/sacrifice/setup(var/datum/team/hog_cult/new_cult)
    sacrifices_needed = rand(4,6)
    description = "You need to sacrifice [sacrifices_needed] people, to be able to free your god and let him into the mortal plane."
	. = ..()

/datum/hog_objective/sacrifice/check_completion()
    if(cult.sacrificed_people => sacrifices_needed)
        completed = TRUE
	. = ..()

/datum/hog_objective/people
    name = "Sacrificing"
    description = "You need to convert X people into your cult, to be able to free your god and let him into the mortal plane!"
    var/members_needed

    name = "Sacrificing"/setup(var/datum/team/hog_cult/new_cult)
    description = "You need to convert [members_needed] people into your cult, to be able to free your god and let him into the mortal plane!"
    members_needed = rand(10,15)
	. = ..()

    name = "Sacrificing"/check_completion()
    if(cult.members.len => members_needed)
        completed = TRUE
	. = ..()