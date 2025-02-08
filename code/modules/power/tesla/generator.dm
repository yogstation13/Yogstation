/obj/machinery/the_singularitygen/tesla
	name = "energy ball generator"
	desc = "Makes the wardenclyffe look like a child's plaything when shot with a particle accelerator."
	icon = 'icons/obj/tesla_engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/singularity/energy_ball

/obj/machinery/the_singularitygen/tesla/tesla_act(source, power, zap_range, tesla_flags, list/shocked_targets)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		energy += power
