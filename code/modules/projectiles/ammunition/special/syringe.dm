/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "A high-power spring that throws syringes."
	projectile_type = /obj/projectile/bullet/reusable/dart/syringe
	firing_effect_type = null

/obj/item/ammo_casing/syringegun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/syringe))
		var/obj/item/gun/syringe/SG = loc
		var/obj/projectile/bullet/reusable/dart/D = BB
		if(!SG.syringes.len)
			return

		var/obj/item/reagent_containers/syringe/S = SG.syringes[1]

		S.reagents.trans_to(BB, S.reagents.total_volume, transfered_by = user)
		D.add_dart(S, S.proj_piercing)
		SG.syringes.Remove(S)
	..()

/obj/item/ammo_casing/chemgun
	name = "dart synthesiser"
	desc = "A high-power spring, linked to an energy-based dart synthesiser."
	projectile_type = /obj/projectile/bullet/reusable/dart
	firing_effect_type = null

/obj/item/ammo_casing/chemgun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/chem))
		var/obj/item/gun/chem/CG = loc
		if(CG.syringes_left <= 0)
			return
		var/obj/projectile/bullet/reusable/dart/D = BB
		var/obj/item/reagent_containers/syringe/dart/temp/new_dart = new(D)

		CG.reagents.trans_to(new_dart, 15, transfered_by = user)
		D.add_dart(new_dart)
		CG.syringes_left--
	..()

/obj/item/ammo_casing/dnainjector
	name = "rigged syringe gun spring"
	desc = "A high-power spring that throws DNA injectors."
	projectile_type = /obj/projectile/bullet/dnainjector
	firing_effect_type = null

/obj/item/ammo_casing/dnainjector/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/syringe/dna))
		var/obj/item/gun/syringe/dna/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/dnainjector/S = popleft(SG.syringes)
		var/obj/projectile/bullet/dnainjector/D = BB
		S.forceMove(D)
		D.injector = S
	..()

/obj/item/ammo_casing/blowgun
	name = "blow gun spring"
	desc = "A low-power spring that throws syringes a short distance." // how does a blowgun have a spring
	projectile_type = /obj/projectile/bullet/reusable/dart/syringe/blowgun
	firing_effect_type = null

/obj/item/ammo_casing/blowgun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/syringe/blowgun))
		var/obj/item/gun/syringe/BG = loc
		var/obj/projectile/bullet/reusable/dart/D = BB
		if(!BG.syringes.len)
			return

		var/obj/item/reagent_containers/syringe/S = BG.syringes[1]

		S.reagents.trans_to(BB, S.reagents.total_volume, transfered_by = user)
		D.add_dart(S, S.proj_piercing)
		BG.syringes.Remove(S)
	..()
