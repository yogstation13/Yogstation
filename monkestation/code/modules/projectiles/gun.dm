/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_FEEBLE) && recoil && !tk_firing(user))
		feeble_quirk_recoil(user, get_dir(user, pbtarget), TRUE)
