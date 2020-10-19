/datum/component/daniel/Initialize()
    if(!isobj(parent))
        return COMPONENT_INCOMPATIBLE

    RegisterSignal(parent, COMSIG_ATOM_POINTED_AT, .proc/damn)

/datum/component/daniel/proc/damn(datum/source, mob/user)
    spawn(10)
        user.say("DAMN DANIEL!")