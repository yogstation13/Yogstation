/datum/synth_os
	var/available_projects = list()
	var/completed_projects = list()
	var/running_projects = list()


/datum/synth_os/proc/switch_shell(mob/living/carbon/human/old_shell, mob/living/carbon/human/new_shell)
	for(var/datum/synth_project/running_project in running_projects)
		running_project.stop()
		running_project.synth = new_shell
		running_project.run_project()

/datum/synth_os/proc/tick()
