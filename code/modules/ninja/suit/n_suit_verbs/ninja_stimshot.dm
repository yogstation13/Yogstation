//Injects the user with a small amount of coagulant, perf, and saline glucose solution.
//Heals a very slight amount of damage while removing any slash wounds and slightly helping with bloodloss.
/obj/item/clothing/suit/space/space_ninja/proc/ninjastim()

	if(!ninjacost(0,N_STIM))
		var/mob/living/carbon/human/H = affecting
		H.reagents.add_reagent(/datum/reagent/medicine/coagulant, 5)
		H.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 10)
		H.reagents.add_reagent(/datum/reagent/medicine/perfluorodecalin, 5)
		s_shots--
		to_chat(H, "<span class='notice'>There are <B>[s_shots]</B> stim shots remaining.</span>")
		s_coold = 1
