// Ensures that any existing characters are only using valid job titles.
//
// As a note, this will apply to ANY invalid job titles, even if they were once valid in the past.
/datum/preferences/proc/monkestation_sanitize_alt_job_titles(list/save_data)
	var/list/old_alt_job_titles = save_data["alt_job_titles"]
	var/list/new_alt_job_titles = list()
	for(var/job_name in old_alt_job_titles)
		var/alt_title = old_alt_job_titles[job_name]
		var/datum/job/job = SSjob.GetJob(job_name)

		if(isnull(job))
			continue

		if(!(alt_title in job.alt_titles))
			continue

		// Allows the job title into the new list.
		new_alt_job_titles[job_name] = alt_title
	save_data["alt_job_titles"] = new_alt_job_titles
