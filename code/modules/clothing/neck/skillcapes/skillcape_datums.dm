/datum/skillcape
	var/name = ""
	var/minutes = 18000
	var/job
	var/special = FALSE // If true, exempt from the max cape
	var/capetype = "" // goes along with special, for the switch statement.
	var/path = /obj/item/clothing/neck/skillcape
	var/id

/datum/skillcape/trimmed
	name = "trimmed cape of skill"
	minutes = 30000
	path = /obj/item/clothing/neck/skillcape/trimmed


/datum/skillcape/maximum
	name = "cape of the absolute pinnacle of beings"
	special = TRUE
	capetype = "max"
	path = /obj/item/clothing/neck/skillcape/maximum
	id = "max"

/datum/skillcape/captain
	name = "cape of the captain"
	job = "Captain"
	path = /obj/item/clothing/neck/skillcape/captain
	id = "cap"

/datum/skillcape/trimmed/captain
	name = "cape of the grand commander"  
	job = "Captain"
	path = /obj/item/clothing/neck/skillcape/trimmed/captain
	id = "cap_trimmed"

/datum/skillcape/hop
	name = "cape of the head of personel"
	job = "Head of Personnel"
	path = /obj/item/clothing/neck/skillcape/hop
	id = "hop"

/datum/skillcape/trimmed/hop
	name = "cape of the grand torchbearer"
	job = "Head of Personnel"
	path = /obj/item/clothing/neck/skillcape/trimmed/hop
	id = "hop_trimmed"

/datum/skillcape/hos
	name = "cape of the head of security"
	job = "Head of Security"
	path = /obj/item/clothing/neck/skillcape/hos
	id = "hos"

/datum/skillcape/trimmed/hos
	name = "cape of the grand executor"
	job = "Head of Security"
	path = /obj/item/clothing/neck/skillcape/trimmed/hos
	id = "hos_trimmed"

/datum/skillcape/chiefengineer
	name = "cape of the chief engineer"
	job = "Chief Engineer"
	path = /obj/item/clothing/neck/skillcape/chiefengineer
	id = "ce"

/datum/skillcape/trimmed/chiefengineer
	name = "cape of the grand constructor"
	job = "Chief Engineer"
	path = /obj/item/clothing/neck/skillcape/trimmed/chiefengineer
	id = "ce_trimmed"

/datum/skillcape/researchdirector
	name = "cape of the research director"
	job = "Research Director"
	path = /obj/item/clothing/neck/skillcape/researchdirector
	id = "rd"

/datum/skillcape/trimmed/researchdirector
	name = "cape of the grand scholar"
	job = "Research Director"
	path = /obj/item/clothing/neck/skillcape/trimmed/researchdirector
	id = "rd_trimmed"

/datum/skillcape/cmo
	name = "cape of the chief medical officer"
	job = "Chief Medical Officer"
	path = /obj/item/clothing/neck/skillcape/cmo
	id = "cmo"

/datum/skillcape/trimmed/cmo
	name = "cape of the grand surgeon"
	job = "Chief Medical Officer"
	path = /obj/item/clothing/neck/skillcape/trimmed/cmo
	id = "cmo_trimmed"

/datum/skillcape/warden
	name = "cape of the warden"
	job = "Warden"
	path = /obj/item/clothing/neck/skillcape/warden
	id = "warden"

/datum/skillcape/trimmed/warden
	name = "cape of the grand warden"
	job = "Warden"
	path = /obj/item/clothing/neck/skillcape/trimmed/warden
	id = "warden_trimmed"

/datum/skillcape/security
	name = "cape of the security officer"
	job = "Security Officer"
	path = /obj/item/clothing/neck/skillcape/security
	id = "security"

/datum/skillcape/trimmed/security
	name = "cape of the grand security officer"
	job = "Security Officer"
	path = /obj/item/clothing/neck/skillcape/trimmed/security
	id = "security_trimmed"

/datum/skillcape/detective
	name = "cape of the detective"
	job = "Detective"
	path = /obj/item/clothing/neck/skillcape/detective
	id = "detective"

/datum/skillcape/trimmed/detective
	name = "cape of the grand detective"
	job = "Detective"
	path = /obj/item/clothing/neck/skillcape/trimmed/detective
	id = "detective_trimmed"

/datum/skillcape/physician
    name = "cape of the brig physician"
    job = "Brig Physician"
    path = /obj/item/clothing/neck/skillcape/physician

/datum/skillcape/trimmed/physician
    name = "cape of the grand brig physician"
    job = "Brig Physician"
    path = /obj/item/clothing/neck/skillcape/trimmed/physician

/datum/skillcape/network_admin
	name = "cape of the network admin"
	job = "Network Admin"
	path = /obj/item/clothing/neck/skillcape/network_admin
	id = "network_admin"

/datum/skillcape/trimmed/network_admin
	name = "cape of the grand network admin"
	job = "Network Admin"
	path = /obj/item/clothing/neck/skillcape/trimmed/network_admin
	id = "signaltech_trimmed"

/datum/skillcape/atmos
	name = "cape of the atmospheric technician"
	job = "Atmospheric Technician"
	path = /obj/item/clothing/neck/skillcape/atmos
	id = "atmos"

/datum/skillcape/trimmed/atmos
	name = "cape of the grand atmospheric technician"
	job = "Atmospheric Technician"
	path = /obj/item/clothing/neck/skillcape/trimmed/atmos
	id = "atmos_trimmed"

/datum/skillcape/engineer
	name = "cape of the station engineer"
	job = "Station Engineer"
	path = /obj/item/clothing/neck/skillcape/engineer
	id = "engineer"

/datum/skillcape/trimmed/engineer
	name = "cape of the grand station engineer"
	job = "Station Engineer"
	path = /obj/item/clothing/neck/skillcape/trimmed/engineer
	id = "engineer_trimmed"

/datum/skillcape/science
	name = "cape of the scientist"
	job = "Scientist"
	path = /obj/item/clothing/neck/skillcape/science
	id = "science"

/datum/skillcape/trimmed/science
	name = "cape of the grand scientist"
	job = "Scientist"
	path = /obj/item/clothing/neck/skillcape/trimmed/science
	id = "science_trimmed"

/datum/skillcape/robo
	name = "cape of the roboticist"
	job = "Roboticist"
	path = /obj/item/clothing/neck/skillcape/robo
	id = "robo"

/datum/skillcape/trimmed/robo
	name = "cape of the grand roboticist"
	job = "Roboticist"
	path = /obj/item/clothing/neck/skillcape/trimmed/robo
	id = "robo_trimmed"

/datum/skillcape/psych
	name = "cape of the psychiatrist"
	job = "Psychiatrist"
	path = /obj/item/clothing/neck/skillcape/psych
	id = "psych"

/datum/skillcape/trimmed/psych
	name = "cape of the grand psychiatrist"
	job = "Psychiatrist"
	path = /obj/item/clothing/neck/skillcape/trimmed/psych
	id = "psych_trimmed"

/datum/skillcape/paramedic
	name = "cape of the paramedic"
	job = "Paramedic"
	path = /obj/item/clothing/neck/skillcape/paramedic
	id = "psych"

/datum/skillcape/trimmed/paramedic
	name = "cape of the grand paramedic"
	job = "Paramedic"
	path = /obj/item/clothing/neck/skillcape/trimmed/paramedic
	id = "psych_trimmed"

/datum/skillcape/gene
	name = "cape of the geneticist"
	job = "Geneticist"
	path = /obj/item/clothing/neck/skillcape/gene
	id = "gene"

/datum/skillcape/trimmed/gene
	name = "cape of the grand geneticist"
	job = "Geneticist"
	path = /obj/item/clothing/neck/skillcape/trimmed/gene
	id = "gene_trimmed"

/datum/skillcape/viro
	name = "cape of the virologist"
	job = "Virologist"
	path = /obj/item/clothing/neck/skillcape/viro
	id = "viro"

/datum/skillcape/trimmed/viro
	name = "cape of the grand virologist"
	job = "Virologist"
	path = /obj/item/clothing/neck/skillcape/trimmed/viro
	id = "viro_trimmed"

/datum/skillcape/chem
	name = "cape of the chemist"
	job = "Chemist"
	path = /obj/item/clothing/neck/skillcape/chem
	id = "chem"

/datum/skillcape/trimmed/chem
	name = "cape of the grand chemist"
	job = "Chemist"
	path = /obj/item/clothing/neck/skillcape/trimmed/chem
	id = "chem_trimmed"

/datum/skillcape/doctor
	name = "cape of the doctor"
	job = "Medical Doctor"
	path = /obj/item/clothing/neck/skillcape/doctor
	id = "doctor"

/datum/skillcape/trimmed/doctor
	name = "cape of the grand doctor"
	job = "Medical Doctor"
	path = /obj/item/clothing/neck/skillcape/trimmed/doctor
	id = "doctor_trimmed"

/datum/skillcape/minemedic
	name = "cape of the mining medic"
	job = "Mining Medic"
	path = /obj/item/clothing/neck/skillcape/minemedic
	id = "minemeic"

/datum/skillcape/trimmed/minemedic
	name = "cape of the grand minic medic"
	job = "Mining Medic"
	path = /obj/item/clothing/neck/skillcape/trimmed/minemedic
	id = "minemeic_trimmed"

/datum/skillcape/mining
	name = "cape of the miner"
	job = "Shaft Miner"
	path = /obj/item/clothing/neck/skillcape/mining
	id = "mining"

/datum/skillcape/trimmed/mining
	name = "cape of the grand miner"
	job = "Shaft Miner"
	path = /obj/item/clothing/neck/skillcape/trimmed/mining
	id = "mining_trimmed"

/datum/skillcape/cargo
	name = "cape of the cargo technician"
	job = "Cargo Technician"
	path = /obj/item/clothing/neck/skillcape/cargo
	id = "cargo"

/datum/skillcape/trimmed/cargo
	name = "cape of the grand cargo technician"
	job = "Cargo Technician"
	path = /obj/item/clothing/neck/skillcape/trimmed/cargo
	id = "cargo_trimmed"

/datum/skillcape/quartermaster
	name = "cape of the quartermaster"
	job = "Quartermaster"
	path = /obj/item/clothing/neck/skillcape/quartermaster
	id = "qm"

/datum/skillcape/trimmed/quartermaster
	name = "cape of the grand quartermaster"
	job = "Quartermaster"
	path = /obj/item/clothing/neck/skillcape/trimmed/quartermaster
	id = "qm_trimmed"

/datum/skillcape/tourist
	name = "cape of the tourist"
	job = "Tourist"
	path = /obj/item/clothing/neck/skillcape/tourist
	id = "tourist"

/datum/skillcape/trimmed/tourist
	name = "cape of the grand tourist"
	job = "Tourist"
	path = /obj/item/clothing/neck/skillcape/trimmed/tourist
	id = "tourist_trimmed"

/datum/skillcape/assistant
	name = "cape of the greytider"
	job = "Assistant"
	path = /obj/item/clothing/neck/skillcape/assistant
	id = "assistant"

/datum/skillcape/trimmed/assistant
	name = "cape of the grand greytider"
	job = "Assistant"
	path = /obj/item/clothing/neck/skillcape/trimmed/assistant
	id = "assistant_trimmed"

/datum/skillcape/clown
	name = "cape of the clown"
	job = "Clown"
	path = /obj/item/clothing/neck/skillcape/clown
	id = "clown"

/datum/skillcape/trimmed/clown
	name = "cape of the grand clown"
	job = "Clown"
	path = /obj/item/clothing/neck/skillcape/trimmed/clown
	id = "clown_trimmed"

/datum/skillcape/mime
	name = "cape of the mime"
	job = "Mime"
	path = /obj/item/clothing/neck/skillcape/mime
	id = "mime"

/datum/skillcape/trimmed/mime
	name = "cape of the grand mime"
	job = "Mime"
	path = /obj/item/clothing/neck/skillcape/trimmed/mime
	id = "mime_trimmed"

/datum/skillcape/chaplain
	name = "cape of the chaplain"
	job = "Chaplain"
	path = /obj/item/clothing/neck/skillcape/chaplain
	id = "chaplain"

/datum/skillcape/trimmed/chaplain
	name = "cape of the grand chaplain"
	job = "Chaplain"
	path = /obj/item/clothing/neck/skillcape/trimmed/chaplain
	id = "chaplain_trimmed"

/datum/skillcape/curator
	name = "cape of the curator"
	job = "Curator"
	path = /obj/item/clothing/neck/skillcape/curator
	id = "curator"

/datum/skillcape/trimmed/curator
	name = "cape of the grand curator"
	job = "Curator"
	path = /obj/item/clothing/neck/skillcape/trimmed/curator
	id = "curator_trimmed"

/datum/skillcape/lawyer
	name = "cape of the lawyer"
	job = "Lawyer"
	path = /obj/item/clothing/neck/skillcape/lawyer
	id = "lawyer"

/datum/skillcape/trimmed/lawyer
	name = "cape of the grand lawyer"
	job = "Lawyer"
	path = /obj/item/clothing/neck/skillcape/trimmed/lawyer
	id = "lawyer_trimmed"

/datum/skillcape/clerk
	name = "cape of the clerk"
	job = "Clerk"
	path = /obj/item/clothing/neck/skillcape/clerk
	id = "clerk"

/datum/skillcape/trimmed/clerk
	name = "cape of the grand clerk"
	job = "Clerk"
	path = /obj/item/clothing/neck/skillcape/trimmed/clerk
	id = "clerk_trimmed"

/datum/skillcape/janitor
	name = "cape of the janitor"
	job = "Janitor"
	path = /obj/item/clothing/neck/skillcape/janitor
	id = "janitor"

/datum/skillcape/trimmed/janitor
	name = "cape of the grand janitor"
	job = "Janitor"
	path = /obj/item/clothing/neck/skillcape/trimmed/janitor
	id = "janitor_trimmed"

/datum/skillcape/bartender
	name = "cape of the bartender"
	job = "Bartender"
	path = /obj/item/clothing/neck/skillcape/bartender
	id = "bartender"

/datum/skillcape/trimmed/bartender
	name = "cape of the grand bartender"
	job = "Bartender"
	path = /obj/item/clothing/neck/skillcape/trimmed/bartender
	id = "bartender_trimmed"

/datum/skillcape/cook
	name = "cape of the cook"
	job = "Cook"
	path = /obj/item/clothing/neck/skillcape/cook
	id = "cook"

/datum/skillcape/trimmed/cook
	name = "cape of the grand cook"
	job = "Cook"
	path = /obj/item/clothing/neck/skillcape/trimmed/cook
	id = "cook_trimmed"

/datum/skillcape/botany
	name = "cape of the botanist"
	job = "Botanist"
	path = /obj/item/clothing/neck/skillcape/botany
	id = "botany"

/datum/skillcape/trimmed/botany
	name = "cape of the grand botanist"
	job = "Botanist"
	path = /obj/item/clothing/neck/skillcape/trimmed/botany
	id = "botany_trimmed"

/datum/skillcape/admin
	name = "cape of mighty judgement"
	job = "Admin"
	path = /obj/item/clothing/neck/skillcape/admin
	id = "admin"
	special = TRUE

/datum/skillcape/trimmed/admin
	name = "cape of the supreme judge"
	job = "Admin"
	path = /obj/item/clothing/neck/skillcape/trimmed/admin
	id = "admin_trimmed"
	special = TRUE

/datum/skillcape/mentor
	name = "cape of the sage"
	job = "Mentor"
	path = /obj/item/clothing/neck/skillcape/mentor
	id = "mentor"
	special = TRUE

/datum/skillcape/ghost
	name = "cape of invisible skill"
	job = "Ghost"
	path = /obj/item/clothing/neck/skillcape
	id = "ghost"
