/datum/component/uplink/MakePurchase(mob/user, datum/uplink_item/U)
    var/canBuy = FALSE

    if(U.include_objectives.len)
        for(var/O in U.include_objectives)
            if(locate(O) in user.mind.objectives)
                canBuy = TRUE
                break
    else
        canBuy = TRUE

    if(canBuy && U.exclude_objectives.len)
        for(var/O in U.exclude_objectives)
            if(locate(O) in user.mind.objectives)
                canBuy = FALSE
                break

    if(canBuy)
        return ..()

    to_chat(user, "<span class='warning'>The Syndicate lacks resources to provide you with this item.</span>")
