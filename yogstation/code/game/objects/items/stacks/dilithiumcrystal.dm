//Dilithium crystals, used in atmospherics to lower the required temperature for fusion, by grinding into a matter and reacting to form a gas.
/obj/item/stack/ore/dilithium_crystal
	name = "dilithium crystal"
	desc = "A glowing dilithium crystal. It looks very delicate."
	icon = 'yogstation/icons/obj/telescience.dmi'
	icon_state = "dilithium_crystal"
	singular_name = "dilithium crystal"
	w_class = WEIGHT_CLASS_TINY
	points = 50
	grind_results = list(/datum/reagent/dilithium = 20)

/obj/item/stack/ore/dilithium_crystal/Initialize()
	. = ..()
	pixel_x = rand(-5, 5) // Cloned over from bluespace crystals. I guess to make their spawning a bit more scattered?
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/dilithium_crystal/attack_self(mob/user) // Currently has no effect, besides crushing one of the crystals into dust.
	user.visible_message("<span class='warning'>[user] crushes [src]!</span>", "<span class='danger'>You crush [src]!</span>")
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)
	use(1)
