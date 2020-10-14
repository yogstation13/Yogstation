/datum/skillcape
    var/name = ""
    var/hours = 300
    var/job
    var/special = FALSE //If its TRUE it wont have a related job, it's for the switch statement in preferences.dm
    var/capetype = "" // goes along with special, for the switch statement.
    var/path = /obj/item/clothing/neck/skillcape

/datum/skillcape/trimmed
    name = "trimmed cape of skill"
    hours = 500
    path = /obj/item/clothing/neck/skillcape/trimmed


/datum/skillcape/maximum
    name = "cape of the absolute pinnacle of beings"
    special = TRUE
    capetype = "max"
    path = "/obj/item/clothing/neck/skillcape/maximum"

/datum/skillcape/captain
    name = "cape of the captain"
    job = /datum/job/captain
    path = "/obj/item/clothing/neck/skillcape/captain"

/datum/skillcape/trimmed/captain
    name = "cape of the grand commander"  
    job = /datum/job/captain
    path = "/obj/item/clothing/neck/skillcape/trimmed/captain"

/datum/skillcape/hop
    name = "cape of the head of personel"
    job = /datum/job/hop
    path = "/obj/item/clothing/neck/skillcape/hop"

/datum/skillcape/trimmed/hop
    name = "cape of the grand torchbearer"
    job = /datum/job/hop
    path = "/obj/item/clothing/neck/skillcape/trimmed/hop"

/datum/skillcape/hos
    name = "cape of the head of security"
    job = /datum/job/hos
    path = "/obj/item/clothing/neck/skillcape/hos"

/datum/skillcape/trimmed/hos
    name = "cape of the grand executor"
    job = /datum/job/hos
    path = "/obj/item/clothing/neck/skillcape/trimmed/hos"

/datum/skillcape/chiefengineer
    name = "cape of the chief engineer"
    job = /datum/job/chief_engineer
    path = "/obj/item/clothing/neck/skillcape/chiefengineer"

/datum/skillcape/trimmed/chiefengineer
    name = "cape of the grand constructor."
    job = /datum/job/chief_engineer
    path = "/obj/item/clothing/neck/skillcape/trimmed/chiefengineer"

/datum/skillcape/researchdirector
    name = "cape of the research director"
    job = /datum/job/rd
    path = "/obj/item/clothing/neck/skillcape/researchdirector"

/datum/skillcape/trimmed/researchdirector
    name = "cape of the grand scholar"
    job = /datum/job/rd
    path = "/obj/item/clothing/neck/skillcape/trimmed/researchdirector"

/datum/skillcape/cmo
    name = "cape of the chief medical officer"
    job = /datum/job/cmo
    path = "/obj/item/clothing/neck/skillcape/cmo"

/datum/skillcape/trimmed/cmo
    name = "cape of the grand surgeon"
    job = /datum/job/cmo
    path = "/obj/item/clothing/neck/skillcape/trimmed/cmo"

/datum/skillcape/warden
    name = "cape of the warden"
    job = /datum/job/warden
    path = "/obj/item/neck/skillcape/warden"

/datum/skillcape/trimmed/warden
    name = "cape of the grand warden"
    job = /datum/job/warden
    path = "/obj/item/neck/skillcape/trimmed/warden"

/datum/skillcape/security
    name = "cape of the security officer"
    job = /datum/job/officer
    path = "/obj/item/neck/skillcape/security"

/datum/skillcape/trimmed/security
    name = "cape of the grand security officer"
    job = /datum/job/officer
    path = "/obj/item/neck/skillcape/trimmed/security"

/datum/skillcape/detective
    name = "cape of the detective"
    job = /datum/job/detective
    path = "/obj/item/neck/skillcape/detective"

/datum/skillcape/trimmed/detective
    name = "cape of the grand detective"
    job = /datum/job/detective
    path = "/obj/item/neck/skillcape/trimmed/detective"

/datum/skillcape/signaltech
    name = "cape of the signal technician"
    job = /datum/job/signal_tech
    path = "/obj/item/neck/skillcape/signaltech"

/datum/skillcape/trimmed/signaltech
    name = "cape of the grand signal technician"
    job = /datum/job/signal_tech
    path = "/obj/item/neck/skillcape/trimmed/signaltech"

/datum/skillcape/atmos
    name = "cape of the atmospheric technician"
    job = /datum/job/atmos
    path = "/obj/item/neck/skillcape/atmos"

/datum/skillcape/trimmed/atmos
    name = "cape of the grand atmospheric technician"
    job = /datum/job/atmos
    path = "/obj/item/neck/skillcape/trimmed/atmos"

/datum/skillcape/engineer
    name = "cape of the station engineer"
    job = /datum/job/engineer
    path = "/obj/item/neck/skillcape/engineer"

/datum/skillcape/trimmed/engineer
    name = "cape of the grand station engineer"
    job = /datum/job/engineer
    path = "/obj/item/neck/skillcape/trimmed/engineer"

/datum/skillcape/science
    name = "cape of the scientist"
    job = /datum/job/scientist
    path = "/obj/item/neck/skillcape/science"

/datum/skillcape/trimmed/science
    name = "cape of the grand scientist"
    job = /datum/job/scientist
    path = "/obj/item/neck/skillcape/trimmed/science"

/datum/skillcape/robo
    name = "cape of the roboticist"
    job = /datum/job/roboticist
    path = "/obj/item/neck/skillcape/robo"

/datum/skillcape/trimmed/robo
    name = "cape of the grand roboticist"
    job = /datum/job/roboticist
    path = "/obj/item/neck/skillcape/trimmed/robo"

/datum/skillcape/psych
    name = "cape of the psychiatrist"
    job = /datum/job/psych
    path = "/obj/item/neck/skillcape/psych"

/datum/skillcape/trimmed/psych
    name = "cape of the grand psychiatrist"
    job = /datum/job/psych
    path = "/obj/item/neck/skillcape/trimmed/psych"

/datum/skillcape/paramedic
    name = "cape of the paramedic"
    job = /datum/job/paramedic
    path = "/obj/item/neck/skillcape/paramedic"

/datum/skillcape/trimmed/paramedic
    name = "cape of the grand paramedic"
    job = /datum/job/paramedic
    path = "/obj/item/neck/skillcape/trimmed/paramedic"

/datum/skillcape/gene
    name = "cape of the geneticist"
    job = /datum/job/geneticist
    path = "/obj/item/neck/skillcape/gene"

/datum/skillcape/trimmed/gene
    name = "cape of the grand geneticist"
    job = /datum/job/geneticist
    path = "/obj/item/neck/skillcape/trimmed/gene"

/datum/skillcape/viro
    name = "cape of the virologist"
    job = /datum/job/virologist
    path = "/obj/item/neck/skillcape/viro"

/datum/skillcape/trimmed/viro
    name = "cape of the grand virologist"
    job = /datum/job/virologist
    path = "/obj/item/neck/skillcape/trimmed/viro"

/datum/skillcape/chem
    name = "cape of the chemist"
    job = /datum/job/chemist
    path = "/obj/item/neck/skillcape/chem"

/datum/skillcape/trimmed/chem
    name = "cape of the grand chemist"
    job = /datum/job/chemist
    path = "/obj/item/neck/skillcape/trimmed/chem"

/datum/skillcape/doctor
    name = "cape of the doctor"
    job = /datum/job/doctor
    path = "/obj/item/neck/skillcape/doctor"

/datum/skillcape/trimmed/doctor
    name = "cape of the grand doctor"
    job = /datum/job/doctor
    path = "/obj/item/neck/skillcape/trimmed/doctor"

/datum/skillcape/minemedic
    name = "cape of the mining medic"
    job = /datum/job/miningmedic
    path = "/obj/item/neck/skillcape/minemedic"

/datum/skillcape/trimmed/minemedic
    name = "cape of the grand minic medic"
    job = /datum/job/miningmedic
    path = "/obj/item/neck/skillcape/trimmed/minemedic"

/datum/skillcape/mining
    name = "cape of the miner"
    job = /datum/job/mining
    path = "/obj/item/neck/skillcape/mining"

/datum/skillcape/trimmed/mining
    name = "cape of the grand miner"
    job = /datum/job/mining
    path = "/obj/item/neck/skillcape/trimmed/mining"

/datum/skillcape/cargo
    name = "cape of the cargo technician"
    job = /datum/job/cargo_tech
    path = "/obj/item/neck/skillcape/cargo"

/datum/skillcape/trimmed/cargo
    name = "cape of the grand cargo technician"
    job = /datum/job/cargo_tech
    path = "/obj/item/neck/skillcape/trimmed/cargo"

/datum/skillcape/quartermaster
    name = "cape of the quartermaster"
    job = /datum/job/qm
    path = "/obj/item/neck/skillcape/quartermaster"

/datum/skillcape/trimmed/quartermaster
    name = "cape of the grand quartermaster"
    job = /datum/job/qm
    path = "/obj/item/neck/skillcape/trimmed/quartermaster"

/datum/skillcape/tourist
    name = "cape of the tourist"
    job = /datum/job/tourist
    path = "/obj/item/neck/skillcape/tourist"

/datum/skillcape/trimmed/tourist
    name = "cape of the grand tourist"
    job = /datum/job/tourist
    path = "/obj/item/neck/skillcape/trimmed/tourist"

/datum/skillcape/assistant
    name = "cape of the greytider"
    job = /datum/job/assistant
    path = "/obj/item/neck/skillcape/assistant"

/datum/skillcape/trimmed/assistant
    name = "cape of the grand greytider"
    job = /datum/job/assistant
    path = "/obj/item/neck/skillcape/trimmed/assistant"

/datum/skillcape/clown
    name = "cape of the clown"
    job = /datum/job/clown
    path = "/obj/item/neck/skillcape/clown"

/datum/skillcape/trimmed/clown
    name = "cape of the grand clown"
    job = /datum/job/clown
    path = "/obj/item/neck/skillcape/trimmed/clown"

/datum/skillcape/mime
    name = "cape of the mime"
    job = /datum/job/mime
    path = "/obj/item/neck/skillcape/mime"

/datum/skillcape/trimmed/mime
    name = "cape of the grand mime"
    job = /datum/job/mime
    path = "/obj/item/neck/skillcape/trimmed/mime"

/datum/skillcape/chaplain
    name = "cape of the chaplain"
    job = /datum/job/chaplain
    path = "/obj/item/neck/skillcape/chaplain"

/datum/skillcape/trimmed/chaplain
    name = "cape of the grand chaplain"
    job = /datum/job/chaplain
    path = "/obj/item/neck/skillcape/trimmed/chaplain"

/datum/skillcape/curator
    name = "cape of the curator"
    job = /datum/job/curator
    path = "/obj/item/neck/skillcape/curator"

/datum/skillcape/trimmed/curator
    name = "cape of the grand curator"
    job = /datum/job/curator
    path = "/obj/item/neck/skillcape/trimmed/curator"

/datum/skillcape/lawyer
    name = "cape of the lawyer"
    job = /datum/job/lawyer
    path = "/obj/item/neck/skillcape/lawyer"

/datum/skillcape/trimmed/lawyer
    name = "cape of the grand lawyer"
    job = /datum/job/lawyer
    path = "/obj/item/neck/skillcape/trimmed/lawyer"

/datum/skillcape/clerk
    name = "cape of the clerk"
    job = /datum/job/clerk
    path = "/obj/item/neck/skillcape/clerk"

/datum/skillcape/trimmed/clerk
    name = "cape of the grand clerk"
    job = /datum/job/clerk
    path = "/obj/item/neck/skillcape/trimmed/clerk"

/datum/skillcape/janitor
    name = "cape of the janitor"
    job = /datum/job/janitor
    path = "/obj/item/neck/skillcape/janitor"

/datum/skillcape/trimmed/janitor
    name = "cape of the grand janitor"
    job = /datum/job/janitor
    path = "/obj/item/neck/skillcape/trimmed/janitor"

/datum/skillcape/bartender
    name = "cape of the bartender"
    job = /datum/job/bartender
    path = "/obj/item/neck/skillcape/bartender"

/datum/skillcape/trimmed/bartender
    name = "cape of the grand bartender"
    job = /datum/job/bartender
    path = "/obj/item/neck/skillcape/trimmed/bartender"

/datum/skillcape/cook
    name = "cape of the cook"
    job = /datum/job/cook
    path = "/obj/item/neck/skillcape/cook"

/datum/skillcape/trimmed/cook
    name = "cape of the grand cook"
    job = /datum/job/cook
    path = "/obj/item/neck/skillcape/trimmed/cook"

/datum/skillcape/botany
    name = "cape of the botanist"
    job = /datum/job/hydro
    path = "/obj/item/neck/skillcape/botany"

/datum/skillcape/trimmed/botany
    name = "cape of the grand botanist"
    job = /datum/job/hydro
    path = "/obj/item/neck/skillcape/trimmed/botany"


