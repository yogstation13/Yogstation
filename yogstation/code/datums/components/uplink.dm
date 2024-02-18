/datum/component/uplink/MakePurchase(mob/user, datum/uplink_item/U)
    var/canBuy = FALSE

    if(U.include_objectives.len)
        for(var/O in U.include_objectives)
            if(locate(O) in user.mind.get_all_objectives())
                canBuy = TRUE
                break
    else
        canBuy = TRUE

    if(canBuy && U.exclude_objectives.len)
        for(var/O in U.exclude_objectives)
            if(locate(O) in user.mind.get_all_objectives())
                canBuy = FALSE
                break

    if(canBuy)
        return ..()

    to_chat(user, span_warning("The Syndicate only permits [U.name][U.name[LAZYLEN(U.name)] != "s" ? "s" : ""] to specific agents. \
								Your mission does not require this equipment."))
