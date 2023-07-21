/// Singleton representing a category of jobs forming a department.
/// NOTICE: This is NOT fully implemented everywhere. Currently only used in: Preferences menu
/datum/job_department
	/// Department as displayed on different menus.
	var/department_name = DEPARTMENT_UNASSIGNED
	/// Bitflags associated to the specific department.
	var/department_bitflags = NONE
	/// Typepath of the job datum leading this department.
	var/datum/job/department_head = null
	/// Experience granted by playing in a job of this department.
	var/department_experience_type = null
	/// The order in which this department appears on menus, in relation to other departments.
	var/display_order = 0
	/// The header color to be displayed in the ban panel, classes defined in banpanel.css
	var/label_class = "undefineddepartment"
	/// The color used in TGUI or similar menus.
	var/ui_color = "#9689db"
	/// Job singleton datums associated to this department. Populated on job initialization.
	var/list/department_jobs = list()


/// Handles adding jobs to the department and setting up the job bitflags.
/datum/job_department/proc/add_job(datum/job/job)
	department_jobs += job
	job.departments_bitflags |= department_bitflags

/// A special assistant only department, primarily for use by the preferences menu
/datum/job_department/assistant
	department_name = DEPARTMENT_ASSISTANT
	department_bitflags = DEPARTMENT_BITFLAG_ASSISTANT
	// Don't add department_head! Assistants names should not be in bold.

/// A special captain only department, for use by the preferences menu
/datum/job_department/captain
	department_name = DEPARTMENT_CAPTAIN
	department_bitflags = DEPARTMENT_BITFLAG_CAPTAIN
	department_head = /datum/job/captain

/datum/job_department/command
	department_name = DEPARTMENT_COMMAND
	department_bitflags = DEPARTMENT_BITFLAG_COMMAND
	department_head = /datum/job/captain
	department_experience_type = EXP_TYPE_COMMAND
	display_order = 1
	label_class = "command"
	ui_color = "#ccccff"


/datum/job_department/security
	department_name = DEPARTMENT_SECURITY
	department_bitflags = DEPARTMENT_BITFLAG_SECURITY
	department_head = /datum/job/hos
	department_experience_type = EXP_TYPE_SECURITY
	display_order = 2
	label_class = "security"
	ui_color = "#ffbbbb"


/datum/job_department/engineering
	department_name = DEPARTMENT_ENGINEERING
	department_bitflags = DEPARTMENT_BITFLAG_ENGINEERING
	department_head = /datum/job/chief_engineer
	department_experience_type = EXP_TYPE_ENGINEERING
	display_order = 3
	label_class = "engineering"
	ui_color = "#ffeeaa"


/datum/job_department/medical
	department_name = DEPARTMENT_MEDICAL
	department_bitflags = DEPARTMENT_BITFLAG_MEDICAL
	department_head = /datum/job/cmo
	department_experience_type = EXP_TYPE_MEDICAL
	display_order = 4
	label_class = "medical"
	ui_color = "#c1e1ec"


/datum/job_department/science
	department_name = DEPARTMENT_SCIENCE
	department_bitflags = DEPARTMENT_BITFLAG_SCIENCE
	department_head = /datum/job/rd
	department_experience_type = EXP_TYPE_SCIENCE
	display_order = 5
	label_class = "science"
	ui_color = "#ffddff"


/datum/job_department/cargo
	department_name = DEPARTMENT_CARGO
	department_bitflags = DEPARTMENT_BITFLAG_CARGO
	department_head = /datum/job/qm
	department_experience_type = EXP_TYPE_SUPPLY
	display_order = 6
	label_class = "supply"
	ui_color = "#d7b088"


/datum/job_department/service
	department_name = DEPARTMENT_SERVICE
	department_bitflags = DEPARTMENT_BITFLAG_SERVICE
	department_head = /datum/job/hop
	department_experience_type = EXP_TYPE_SERVICE
	display_order = 7
	label_class = "service"
	ui_color = "#ddddff"


/datum/job_department/silicon
	department_name = DEPARTMENT_SILICON
	department_bitflags = DEPARTMENT_BITFLAG_SILICON
	department_head = /datum/job/ai
	department_experience_type = EXP_TYPE_SILICON
	display_order = 8
	label_class = "silicon"
	ui_color = "#ccffcc"


/// Catch-all department for undefined jobs.
/datum/job_department/undefined
	display_order = 10
