//This is the base type for clockwork melee weapons.
/obj/item/clockwork/weapon
	name = "clockwork weapon"
	desc = "Weaponized brass. Whould've thunk it?"
	clockwork_desc = "This shouldn't exist. Report it to a coder."
	icon = 'icons/obj/clockwork_objects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	var/datum/action/innate/call_weapon/action //Some melee weapons use an action that lets you return and dismiss them

/obj/item/clockwork/weapon/Initialize(mapload, new_action)
	. = ..()
	if(new_action)
		action = new_action
		action.weapon = src

/obj/item/clockwork/weapon/attack_self(mob/user)
	if(!is_cyborg(user))
		return ..()
	var/mob/living/silicon/robot/robot_user = user
	for(var/i in 1 to 3) ///shitcode
		if(robot_user.held_items[i] && robot_user.held_items[i] == src)
			var/choice = input(user,"What weapon do you want to activate?", "Weapon") as anything in (list("ratvarian spear","brass battle-hammer","brass longsword") - initial(name))
			if(!choice)
				return
			var/obj/item/weapon_type
			switch(choice)
				if("ratvarian spear")
					weapon_type = /obj/item/clockwork/weapon/ratvarian_spear
				if("brass battle-hammer")
					weapon_type = /obj/item/clockwork/weapon/brass_battlehammer
				if("brass longsword")
					weapon_type = /obj/item/clockwork/weapon/brass_sword
			robot_user.unequip_module_from_slot(src, i)

			if(!weapon_type)
				return

			var/obj/item/weapon = new weapon_type (R.module)
			robot_user.module.ratvar_modules += weapon
			robot_user.module.add_module(weapon, FALSE, TRUE)
			robot_user.activate_module(weapon)