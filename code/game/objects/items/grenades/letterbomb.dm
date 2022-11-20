/obj/item/mail/explosive
	var/assigned = FALSE //whether or not the details of the mail have been added
	var/letterbomb = /obj/item/grenade/mailbomb()

/obj/item/mail/explosive/Initialize(mapload)
	. = ..()
	
	var/atom/movable/target_atom = new letterbomb(src)
	body.log_message("[key_name(body)] received [target_atom.name] in the mail ([target_good])", LOG_GAME)

/obj/item/mail/explosive/attack_self(mob/user)
	if(!assigned)
		/*
		what department are they in?
		ACCOUNT_CIV = COLOR_WHITE,
		ACCOUNT_ENG = COLOR_PALE_ORANGE,
		ACCOUNT_SCI = COLOR_PALE_PURPLE_GRAY,
		ACCOUNT_MED = COLOR_PALE_BLUE_GRAY,
		ACCOUNT_SRV = COLOR_PALE_GREEN_GRAY,
		ACCOUNT_CAR = COLOR_BEIGE,
		ACCOUNT_SEC = COLOR_PALE_RED_GRAY,
		color = 
		*/
		assigned = TRUE
	else
		. = ..()
	
/obj/item/grenade/mailbomb
	name = "improvised pipebomb"
	desc = "A weak, improvised explosive with a mousetrap attached. For all your mailbombing needs."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "pipebomb"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	active = 0
	display_timer = 0
	det_time = 1 SECONDS //better throw it quickly

/obj/item/grenade/mailbomb/Initialize()
	. = ..()
	if(ishuman(src.loc))
		to_chat(src.loc, span_userdanger("Oh fuck!"))
		preprime(src, FALSE, FALSE)	
		return TRUE	//good luck~
	else
		visible_message(span_warning("[src] starts beeping!"))
		preprime(finder, FALSE, FALSE)	
		return FALSE

/obj/item/grenade/mailbomb/prime()
	update_mob()
	explosion(src.loc,-1,1,4)	// small explosion
	qdel(src)
