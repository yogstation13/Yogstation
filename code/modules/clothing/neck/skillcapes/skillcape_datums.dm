/datum/skillcape
    var/name = ""
    var/minutes = 18000
    var/job
    var/special = FALSE //If its TRUE it wont have a related job, it's for the switch statement in preferences.dm
    var/capetype = "" // goes along with special, for the switch statement.
    var/path = /obj/item/clothing/neck/skillcape

/datum/skillcape/trimmed
    name = "trimmed cape of skill"
    minutes = 30000
    path = /obj/item/clothing/neck/skillcape/trimmed


/datum/skillcape/maximum
    name = "cape of the absolute pinnacle of beings"
    special = TRUE
    capetype = "max"
    path = /obj/item/clothing/neck/skillcape/maximum

/datum/skillcape/captain
    name = "cape of the captain"
    job = "Captain"
    path = /obj/item/clothing/neck/skillcape/captain

/datum/skillcape/trimmed/captain
    name = "cape of the grand commander"  
    job = "Captain"
    path = /obj/item/clothing/neck/skillcape/trimmed/captain

/datum/skillcape/hop
    name = "cape of the head of personel"
    job = "Head of Personnel"
    path = /obj/item/clothing/neck/skillcape/hop

/datum/skillcape/trimmed/hop
    name = "cape of the grand torchbearer"
    job = "Head of Personnel"
    path = /obj/item/clothing/neck/skillcape/trimmed/hop

/datum/skillcape/hos
    name = "cape of the head of security"
    job = "Head of Security"
    path = /obj/item/clothing/neck/skillcape/hos

/datum/skillcape/trimmed/hos
    name = "cape of the grand executor"
    job = "Head of Security"
    path = /obj/item/clothing/neck/skillcape/trimmed/hos

/datum/skillcape/chiefengineer
    name = "cape of the chief engineer"
    job = "Chief Engineer"
    path = /obj/item/clothing/neck/skillcape/chiefengineer

/datum/skillcape/trimmed/chiefengineer
    name = "cape of the grand constructor"
    job = "Chief Engineer"
    path = /obj/item/clothing/neck/skillcape/trimmed/chiefengineer

/datum/skillcape/researchdirector
    name = "cape of the research director"
    job = "Research Director"
    path = /obj/item/clothing/neck/skillcape/researchdirector

/datum/skillcape/trimmed/researchdirector
    name = "cape of the grand scholar"
    job = "Research Director"
    path = /obj/item/clothing/neck/skillcape/trimmed/researchdirector

/datum/skillcape/cmo
    name = "cape of the chief medical officer"
    job = "Chief Medical Officer"
    path = /obj/item/clothing/neck/skillcape/cmo

/datum/skillcape/trimmed/cmo
    name = "cape of the grand surgeon"
    job = "Chief Medical Officer"
    path = /obj/item/clothing/neck/skillcape/trimmed/cmo

/datum/skillcape/warden
    name = "cape of the warden"
    job = "Warden"
    path = /obj/item/clothing/neck/skillcape/warden

/datum/skillcape/trimmed/warden
    name = "cape of the grand warden"
    job = "Warden"
    path = /obj/item/clothing/neck/skillcape/trimmed/warden

/datum/skillcape/security
    name = "cape of the security officer"
    job = "Security Officer"
    path = /obj/item/clothing/neck/skillcape/security

/datum/skillcape/trimmed/security
    name = "cape of the grand security officer"
    job = "Security Officer"
    path = /obj/item/clothing/neck/skillcape/trimmed/security

/datum/skillcape/detective
    name = "cape of the detective"
    job = "Detective"
    path = /obj/item/clothing/neck/skillcape/detective

/datum/skillcape/trimmed/detective
    name = "cape of the grand detective"
    job = "Detective"
    path = /obj/item/clothing/neck/skillcape/trimmed/detective

/datum/skillcape/signaltech
    name = "cape of the signal technician"
    job = "Signal Technician"
    path = /obj/item/clothing/neck/skillcape/signaltech

/datum/skillcape/trimmed/signaltech
    name = "cape of the grand signal technician"
    job = "Signal Technician"
    path = /obj/item/clothing/neck/skillcape/trimmed/signaltech

/datum/skillcape/atmos
    name = "cape of the atmospheric technician"
    job = "Atmospheric Technician"
    path = /obj/item/clothing/neck/skillcape/atmos

/datum/skillcape/trimmed/atmos
    name = "cape of the grand atmospheric technician"
    job = "Atmospheric Technician"
    path = /obj/item/clothing/neck/skillcape/trimmed/atmos

/datum/skillcape/engineer
    name = "cape of the station engineer"
    job = "Station Engineer"
    path = /obj/item/clothing/neck/skillcape/engineer

/datum/skillcape/trimmed/engineer
    name = "cape of the grand station engineer"
    job = "Station Engineer"
    path = /obj/item/clothing/neck/skillcape/trimmed/engineer

/datum/skillcape/science
    name = "cape of the scientist"
    job = "Scientist"
    path = /obj/item/clothing/neck/skillcape/science

/datum/skillcape/trimmed/science
    name = "cape of the grand scientist"
    job = "Scientist"
    path = /obj/item/clothing/neck/skillcape/trimmed/science

/datum/skillcape/robo
    name = "cape of the roboticist"
    job = "Roboticist"
    path = /obj/item/clothing/neck/skillcape/robo

/datum/skillcape/trimmed/robo
    name = "cape of the grand roboticist"
    job = "Roboticist"
    path = /obj/item/clothing/neck/skillcape/trimmed/robo

/datum/skillcape/psych
    name = "cape of the psychiatrist"
    job = "Psychiatrist"
    path = /obj/item/clothing/neck/skillcape/psych

/datum/skillcape/trimmed/psych
    name = "cape of the grand psychiatrist"
    job = "Psychiatrist"
    path = /obj/item/clothing/neck/skillcape/trimmed/psych

/datum/skillcape/paramedic
    name = "cape of the paramedic"
    job = "Paramedic"
    path = /obj/item/clothing/neck/skillcape/paramedic

/datum/skillcape/trimmed/paramedic
    name = "cape of the grand paramedic"
    job = "Paramedic"
    path = /obj/item/clothing/neck/skillcape/trimmed/paramedic

/datum/skillcape/gene
    name = "cape of the geneticist"
    job = "Geneticist"
    path = /obj/item/clothing/neck/skillcape/gene

/datum/skillcape/trimmed/gene
    name = "cape of the grand geneticist"
    job = "Geneticist"
    path = /obj/item/clothing/neck/skillcape/trimmed/gene

/datum/skillcape/viro
    name = "cape of the virologist"
    job = "Virologist"
    path = /obj/item/clothing/neck/skillcape/viro

/datum/skillcape/trimmed/viro
    name = "cape of the grand virologist"
    job = "Virologist"
    path = /obj/item/clothing/neck/skillcape/trimmed/viro

/datum/skillcape/chem
    name = "cape of the chemist"
    job = "Chemist"
    path = /obj/item/clothing/neck/skillcape/chem

/datum/skillcape/trimmed/chem
    name = "cape of the grand chemist"
    job = "Chemist"
    path = /obj/item/clothing/neck/skillcape/trimmed/chem

/datum/skillcape/doctor
    name = "cape of the doctor"
    job = "Medical Doctor"
    path = /obj/item/clothing/neck/skillcape/doctor

/datum/skillcape/trimmed/doctor
    name = "cape of the grand doctor"
    job = "Medical Doctor"
    path = /obj/item/clothing/neck/skillcape/trimmed/doctor

/datum/skillcape/minemedic
    name = "cape of the mining medic"
    job = "Mining Medic"
    path = /obj/item/clothing/neck/skillcape/minemedic

/datum/skillcape/trimmed/minemedic
    name = "cape of the grand minic medic"
    job = "Mining Medic"
    path = /obj/item/clothing/neck/skillcape/trimmed/minemedic

/datum/skillcape/mining
    name = "cape of the miner"
    job = "Shaft Miner"
    path = /obj/item/clothing/neck/skillcape/mining

/datum/skillcape/trimmed/mining
    name = "cape of the grand miner"
    job = "Shaft Miner"
    path = /obj/item/clothing/neck/skillcape/trimmed/mining

/datum/skillcape/cargo
    name = "cape of the cargo technician"
    job = "Cargo Technician"
    path = /obj/item/clothing/neck/skillcape/cargo

/datum/skillcape/trimmed/cargo
    name = "cape of the grand cargo technician"
    job = "Cargo Technician"
    path = /obj/item/clothing/neck/skillcape/trimmed/cargo

/datum/skillcape/quartermaster
    name = "cape of the quartermaster"
    job = "Quartermaster"
    path = /obj/item/clothing/neck/skillcape/quartermaster

/datum/skillcape/trimmed/quartermaster
    name = "cape of the grand quartermaster"
    job = "Quartermaster"
    path = /obj/item/clothing/neck/skillcape/trimmed/quartermaster

/datum/skillcape/tourist
    name = "cape of the tourist"
    job = "Tourist"
    path = /obj/item/clothing/neck/skillcape/tourist

/datum/skillcape/trimmed/tourist
    name = "cape of the grand tourist"
    job = "Tourist"
    path = /obj/item/clothing/neck/skillcape/trimmed/tourist

/datum/skillcape/assistant
    name = "cape of the greytider"
    job = "Assistant"
    path = /obj/item/clothing/neck/skillcape/assistant

/datum/skillcape/trimmed/assistant
    name = "cape of the grand greytider"
    job = "Assistant"
    path = /obj/item/clothing/neck/skillcape/trimmed/assistant

/datum/skillcape/clown
    name = "cape of the clown"
    job = "Clown"
    path = /obj/item/clothing/neck/skillcape/clown

/datum/skillcape/trimmed/clown
    name = "cape of the grand clown"
    job = "Clown"
    path = /obj/item/clothing/neck/skillcape/trimmed/clown

/datum/skillcape/mime
    name = "cape of the mime"
    job = "Mime"
    path = /obj/item/clothing/neck/skillcape/mime

/datum/skillcape/trimmed/mime
    name = "cape of the grand mime"
    job = "Mime"
    path = /obj/item/clothing/neck/skillcape/trimmed/mime

/datum/skillcape/chaplain
    name = "cape of the chaplain"
    job = "Chaplain"
    path = /obj/item/clothing/neck/skillcape/chaplain

/datum/skillcape/trimmed/chaplain
    name = "cape of the grand chaplain"
    job = "Chaplain"
    path = /obj/item/clothing/neck/skillcape/trimmed/chaplain

/datum/skillcape/curator
    name = "cape of the curator"
    job = "Curator"
    path = /obj/item/clothing/neck/skillcape/curator

/datum/skillcape/trimmed/curator
    name = "cape of the grand curator"
    job = "Curator"
    path = /obj/item/clothing/neck/skillcape/trimmed/curator

/datum/skillcape/lawyer
    name = "cape of the lawyer"
    job = "Lawyer"
    path = /obj/item/clothing/neck/skillcape/lawyer

/datum/skillcape/trimmed/lawyer
    name = "cape of the grand lawyer"
    job = "Lawyer"
    path = /obj/item/clothing/neck/skillcape/trimmed/lawyer

/datum/skillcape/clerk
    name = "cape of the clerk"
    job = "Clerk"
    path = /obj/item/clothing/neck/skillcape/clerk

/datum/skillcape/trimmed/clerk
    name = "cape of the grand clerk"
    job = "Clerk"
    path = /obj/item/clothing/neck/skillcape/trimmed/clerk

/datum/skillcape/janitor
    name = "cape of the janitor"
    job = "Janitor"
    path = /obj/item/clothing/neck/skillcape/janitor

/datum/skillcape/trimmed/janitor
    name = "cape of the grand janitor"
    job = "Janitor"
    path = /obj/item/clothing/neck/skillcape/trimmed/janitor

/datum/skillcape/bartender
    name = "cape of the bartender"
    job = "Bartender"
    path = /obj/item/clothing/neck/skillcape/bartender

/datum/skillcape/trimmed/bartender
    name = "cape of the grand bartender"
    job = "Bartender"
    path = /obj/item/clothing/neck/skillcape/trimmed/bartender

/datum/skillcape/cook
    name = "cape of the cook"
    job = "Cook"
    path = /obj/item/clothing/neck/skillcape/cook

/datum/skillcape/trimmed/cook
    name = "cape of the grand cook"
    job = "Cook"
    path = /obj/item/clothing/neck/skillcape/trimmed/cook

/datum/skillcape/botany
    name = "cape of the botanist"
    job = "Botanist"
    path = /obj/item/clothing/neck/skillcape/botany

/datum/skillcape/trimmed/botany
    name = "cape of the grand botanist"
    job = "Botanist"
    path = /obj/item/clothing/neck/skillcape/trimmed/botany


