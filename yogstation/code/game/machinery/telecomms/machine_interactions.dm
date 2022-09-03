/obj/machinery/telecomms/get_multitool(mob/user) // Proc override, to improve compatibility with holotools and other silly multitool-like devices
    if(isAI(user))
        var/mob/living/silicon/ai/U = user
        return U.aiMulti
    if(iscyborg(user) && in_range(user,src)) // I couldn't tell you why this has a range requirement, that's just what was in the original code.
        var/obj/held_thing = user.get_active_held_item()
        if(istype(held_thing,/obj/item/multitool))
            return held_thing
        else
            return
    var/obj/item/multitool/held_thing = user.is_holding_tool_quality(TOOL_MULTITOOL)
    if(istype(held_thing))
        return held_thing
    return
