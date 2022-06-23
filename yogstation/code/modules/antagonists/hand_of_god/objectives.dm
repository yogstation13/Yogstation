/datum/team/hog_cult
	var/cult_objective/objective 

/datum/hog_objective
    var/name = "go fuck yourself"
    var/description = "go, and fuck yourself"
    var/datum/team/hog_cult/cult
    var/completed = FALSE
    var/initialy = TRUE

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
    name = "Uprising"
    description = "You need to convert X people into your cult, to be able to free your god and let him into the mortal plane!"
    var/members_needed

/datum/hog_objective/people/setup(var/datum/team/hog_cult/new_cult)
    members_needed = rand(10,15)
    description = "You need to convert [members_needed] people into your cult, to be able to free your god and let him into the mortal plane!"
	. = ..()

/datum/hog_objective/people/check_completion()
    if(cult.members.len => members_needed)
        completed = TRUE
	. = ..()


/datum/hog_objective/holyland
    name = "Holy Land"
    description = "You need to construct and protect X shrines in different rooms, to be able to free your god and let him into the mortal plane!"
    var/shrines_needed

/datum/hog_objective/holyland/setup(var/datum/team/hog_cult/new_cult)
    shrines_needed = rand(6,9)
    description = "You need to construct and protect [shrines_needed] shrines in different rooms, to be able to free your god and let him into the mortal plane!"
	. = ..()

/datum/hog_objective/holyland/check_completion()
    var/we_have_shrines = 0
    for(var/obj/structure/destructible/hog_structure/shrine/S in cult.objects)
        if(!S)
            continue
        if(S.cult != cult)
            continue
        we_have_shrines += 1
    if(we_have_shrines => shrines_needed)
        completed = TRUE
	. = ..()