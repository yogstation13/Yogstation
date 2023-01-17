/obj/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "\improper Durand"
	icon_state = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 35, LASER = 15, ENERGY = 0, BOMB = 20, BIO = 100, RAD = 50, FIRE = 100, ACID = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 35
	wreckage = /obj/structure/mecha_wreckage/durand

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defence_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defence_action.Remove(user)

