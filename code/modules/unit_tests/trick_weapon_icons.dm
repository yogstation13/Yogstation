/// Makes sure all trick weapons have valid icons.
/datum/unit_test/trick_weapon_icons

/datum/unit_test/trick_weapon_icons/Run()
	for(var/obj/item/melee/trick_weapon/trick_weapon as anything in subtypesof(/obj/item/melee/trick_weapon))
		var/icon = trick_weapon::icon
		var/lh_icon = trick_weapon::lefthand_file
		var/rh_icon = trick_weapon::righthand_file
		var/icon_state = trick_weapon::icon_state
		var/base_icon_state = trick_weapon::base_icon_state
		var/active_icon_state = "[base_icon_state]_active"
		// make sure the icon states are set
		TEST_ASSERT(base_icon_state, "[trick_weapon] does not have a base_icon_state")
		TEST_ASSERT_EQUAL(icon_state, base_icon_state, "[trick_weapon] has a different base_icon_state ([base_icon_state]) and icon_state ([icon_state]) specified")
		// make sure base obj icons exist
		TEST_ASSERT(icon_exists(icon, base_icon_state), "[trick_weapon] has a non-existent base icon ([base_icon_state] in [icon])")
		TEST_ASSERT(icon_exists(icon, active_icon_state), "[trick_weapon] has a non-existent active icon ([active_icon_state] in [icon])")
		// make sure lefthand held icons exist
		TEST_ASSERT(icon_exists(lh_icon, base_icon_state), "[trick_weapon] has a non-existent base lefthand held icon ([base_icon_state] in [lh_icon])")
		TEST_ASSERT(icon_exists(lh_icon, active_icon_state), "[trick_weapon] has a non-existent active lefthand held icon ([active_icon_state] in [lh_icon])")
		// make sure righthand held icons exist
		TEST_ASSERT(icon_exists(rh_icon, base_icon_state), "[trick_weapon] has a non-existent base righthand held icon ([base_icon_state] in [rh_icon])")
		TEST_ASSERT(icon_exists(rh_icon, active_icon_state), "[trick_weapon] has a non-existent active righthand held icon ([active_icon_state] in [rh_icon])")

