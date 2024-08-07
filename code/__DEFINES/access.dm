/*	READ BEFORE ADDING/REMOVING ACCESSES
*  Access is broken down by department, department special functions/rooms, and departmental roles
*	The first access for the department will always be its general access function
*	Please try to make the strings for any new accesses as close to the name of the define as possible
*	If you are going to add an access to the list, make sure to also add it to its respective region further below
*	If you're varediting on the map, it uses the string. If you're editing the object directly, use the define name
*
*	NOTE: Some of this documentation may be inaccurate, as it originates from /TG/ -Myriad
*/


//---  COMMAND  ---//

/// Command General Access, used for accessing the doors to the bridge, the communications console, and the general access that Tablet/Computer Programs check for "heads".
#define ACCESS_COMMAND "command"
/// Access to critical-to-function AI rooms and equipment such as the AI Core, AI Upload, AI mini-sat maintenance, turret controls, and foam dispensers.
#define ACCESS_AI_MASTER "ai_master"
/// Access to non-critical rooms in the mini-sat the AI usually resides in. Given to Network Admins to let them do maintenance on the AI.
#define ACCESS_AI_SAT "ai_sat"
/// Access to the Teleporter Room, and some cargo crates.
#define ACCESS_TELEPORTER "teleporter"
/// Access to the EVA Storage Room, and some cargo crates.
#define ACCESS_EVA "eva"
/// Access to the vault on the station, for accessing the station's budget, the nuke core, or the Ore Silo.
#define ACCESS_VAULT "vault"
/// Access to make an announcement through the Requests Console found in an office.
#define ACCESS_RC_ANNOUNCE "rc_announce"
/// Access used for events (Red Alert, BSA, Emergency Maintenance) which require at least two people to swipe at the same time to authorize it
#define ACCESS_KEYCARD_AUTH "keycard_auth"
/// Access used to override "personal control" on all personal lockers, meaning you are able to open any of those lockers/wardrobes.
#define ACCESS_PERSONAL_LOCKERS "personal_lockers"
/// Access used for Access-Changing Programs, this one will unlock all options that can be ever given via that program.
#define ACCESS_CHANGE_IDS "change_ids"
/// Access used for the Captain's personal quarters in mapping, the spare ID cabinet, and the antique gun (but only on gamma alert or above).
#define ACCESS_CAPTAIN "captain"


//---  SECURITY  ---//

/// Security's General Access, armaments vendor, security lockers, and other secure gear. Applied to things to Officers and Wardens should access, but never Lawyers or Detectives.
#define ACCESS_SECURITY "security"
/// Access to the front doors of the Brig, the "secure" portion of the Courtroom, and department outposts. Given to Lawyers, Heads of Staff, and Detectives.
#define ACCESS_SEC_BASIC "sec_basic"
/// Access to brig cells, brig timers, permabrig, gulag, gulag teleporter, gulag shuttle, prisoner management console, and some security cargo crates.
#define ACCESS_BRIG "brig"
/// Access to the armory, security incinerator (when present), and the execution/re-education chamber.
#define ACCESS_ARMORY "armory"
/// Access for the Detective, their office, and medical data console. Always mixed with ACCESS_SECURITY in the security office/delivery windoor, and the arrivals and departure sec checkpoints.
#define ACCESS_DETECTIVE "detective"
/// Access for the Brig Physician and their locker, also used for the Brig Infirmary doors.
#define ACCESS_BRIG_PHYS "brig_phys"
/// The "Weapons Permit" Access, or the one that lets you walk past secbots without them charging at you as you hold your weaponry.
#define ACCESS_WEAPONS_PERMIT "weapons_permit"
/// Access used for the Head of Security's personal quarters in mapping, as well as other HoS-related things.
#define ACCESS_HOS "hos"


//---  ENGINEERING  ---//

/// Engineering General Access, grants access to the standard parts of Engineering and the Engine Room.
#define ACCESS_ENGINEERING "engineering"
/// Access to Atmospherics Sections of the Engineering Department, as well as air alarms.
#define ACCESS_ATMOSPHERICS "atmospherics"
/// Access to all maintenance tunnels on the station. This overrides any "departmental maintenance" access, this has free roaming range everywhere.
#define ACCESS_MAINT_TUNNELS "maint_tunnels"
/// Access to all external "space facing" airlocks on the station. Used such that people don't easily "jump ship", or restict free ingress/egress to only a few points on the station.
#define ACCESS_EXTERNAL_AIRLOCKS "external airlocks"
/// Access to get into APCs, engineering equipment lockers, typically mapped in for key power rooms across the station, engineering vending machines, emitters, and some other stuff.
#define ACCESS_ENGINE_EQUIP "engine_equip"
/// Access to "construction" areas of the station. However, in mapping, it's also used to get access to the front door and lathe room of the engineering department.
#define ACCESS_CONSTRUCTION "construction"
/// Access to the Tech Storage room, containing lots of machine boards and other miscellaneous engineering gear.
#define ACCESS_TECH_STORAGE "tech_storage"
/// Access to the Secure Tech Storage room, containing unreplaceable high-value machine boards.
#define ACCESS_SECURE_TECH "secure_tech"
/// Access to the Telecomms Server Room, traffic control console, machinery, and tablets.
#define ACCESS_TCOMMS "tcomms"
/// Access needed to view message logs recorded on the message monitor console in Telecomms. 
#define ACCESS_TCOMMS_ADMIN "tcomms_admin"
/// Access to the Auxiliary Base Room, as well as the ability to launch it.
#define ACCESS_AUX_BASE "aux_base"
/// Access for the Chief Engineer's office, as well as some other CE-related things.
#define ACCESS_CE "ce"


//---  MEDICAL  ---//

/// General access to Medbay, like the front doors, the treatment center, the medical records console, defibrillator mounts, and more.
#define ACCESS_MEDICAL "medical"
/// Access to the surgery rooms, as well as the equipment and buttons there.
#define ACCESS_SURGERY "surgery"
/// Access to the Paramedic Staging Area.
#define ACCESS_PARAMEDIC "paramedic"
/// Access to the Morgue.
#define ACCESS_MORGUE "morgue"
/// Access to the chemistry lab, or the smaller room in medical with the multiple chem dispensers and pill pressers. The Chemist's main position.
#define ACCESS_CHEMISTRY "chemistry"
/// Access to the cloning lab, usually adjacent to the genetics lab. Given to Medical Doctors so they can't also enter Genetics.
#define ACCESS_CLONING "cloning"
/// Access to the Virology portion of the medical department, as well as the virology crate.
#define ACCESS_VIROLOGY "virology"
/// Access to the Psychologist's office.
#define ACCESS_PSYCHOLOGY "psychology"
/// Access for the Chief Medical Officer's personal quarters in mapping, as well as some other CMO-related things.
#define ACCESS_CMO "cmo"


//---  SUPPLY  ---//

/// General access needed to enter Cargo, allows entry into the Cargo Office and Mail/Delivery Office.
#define ACCESS_CARGO "cargo"
/// Access to the Cargo Bay and Warehouse. Separated from the above to prevent miners processing cargo.
#define ACCESS_CARGO_BAY "cargo_bay"
/// Access to the "on-station" Mining Portion of the Cargo Department.
#define ACCESS_MINING "mining"
/// Access to the "off-station" Mining Station, which contains gear dedicated for miners to do their job best, as well as seek shelter from the inhospitable elements.
#define ACCESS_MINING_STATION "mining_station"
/// Access for the Quartermaster's personal quarters in mapping, as well as some other QM-related things.
#define ACCESS_QM "qm"


//---  SCIENCE  ---//

/// General access for Science, allows for entry to the general hallways of Science, as well as the main lathe room.
#define ACCESS_SCIENCE "science"
/// Access needed to research tech nodes at R&D consoles. May also be needed to access some scientific equipment.
#define ACCESS_RESEARCH "research"
/// Access to the Toxins Mixing Lab and Toxins Test Area equipment.
#define ACCESS_TOXINS "toxins"
/// Access to the Toxins Storage Room, where all of the bomb-making gases are stored.
#define ACCESS_TOXINS_STORAGE "toxins_storage"
/// Access to the Experimentation Lab, containing the E.X.P.E.R.I-MENTOR. Uses of this access is set to change in the future.
#define ACCESS_EXPERIMENTATION "experimentation"
/// Access to the Genetics division of Science.
#define ACCESS_GENETICS "genetics"
/// Access to the Robotics division of Science, as well as opening up silicon cyborgs and other simple robots.
#define ACCESS_ROBOTICS "robotics"
/// Access to the Robotics division of Science, as well as opening up silicon cyborgs and other simple robots.
#define ACCESS_ROBO_CONTROL "robo_control"
/// Access to the Xenobiology division of Science.
#define ACCESS_XENOBIOLOGY "xenobiology"
/// Access to the research Server Room, containing the important R&D research servers and AI networking machines.
#define ACCESS_RND_SERVERS "rnd_servers"
/// Access for the Research Director's personal quarters in mapping, the R&D server room, as well as some other RD-related things.
#define ACCESS_RD "rd"


//---  SERVICE  ---//

/// General access for Service, allows for entry to the Service Hallway.
#define ACCESS_SERVICE "service"
/// Access to the Theatre, as well as other vending machines related to the theatre. Sometimes also used as the "clown's" access in code.
#define ACCESS_THEATRE "theatre"
/// Access to the Chaplain's office.
#define ACCESS_CHAPEL_OFFICE "chapel_office"
/// Access to the chapel's crematorium.
#define ACCESS_CREMATORIUM "crematorium"
/// Access to the curator's private rooms in the Library and the trophy display cases, as well as access both into and out of the Library via Maintenance.
#define ACCESS_LIBRARY "library"
/// Access to the Bar, the Bar's Backroom, the bar sign, the bar robot portal, and the bar's vending machines. Some other bar-things too.
#define ACCESS_BAR "bar"
/// Access to the Kitchen, the Kitchen's Coldroom, the kitchen's vending machines, and the food robot portal. Some other chef-things too.
#define ACCESS_KITCHEN "kitchen"
/// Access to the Botany Division of the station and some other Botanist things.
#define ACCESS_HYDROPONICS "hydroponics"
/// Access to the Janitor's room, and some tablet apps for control of the station's janitorial equipment.
#define ACCESS_JANITOR "janitor"
/// Access to the Lawyer's office.
#define ACCESS_LAWYER "lawyer"
/// Access to the Gift Shop's back doors.
#define ACCESS_CLERK "clerk"
/// Access used for the Head of Personnel's personal quarters in mapping, as well as the security console and other HoP-related things.
#define ACCESS_HOP "hop"



//---  RUINS  ---//
// For generic ruin access. Why would normal crew have access to a long-abandoned derelict or a 2000 year-old temple?

#define ACCESS_RUINS_GENERAL "ruins_general"
#define ACCESS_RUINS_COMMAND "ruins_command"
#define ACCESS_RUINS_SECURITY "ruins_security"
#define ACCESS_RUINS_ENGINEERING "ruins_engineering"
#define ACCESS_RUINS_MEDICAL "ruins_medical"
#define ACCESS_RUINS_SUPPLY "ruins_supply"
#define ACCESS_RUINS_SCIENCE "ruins_science"
#define ACCESS_RUINS_MAINTENANCE "ruins_maintenance"
#define ACCESS_RUINS_MATERIALS "ruins_materials"
#define ACCESS_RUINS_GENERIC1 "ruins_generic1"
#define ACCESS_RUINS_GENERIC2 "ruins_generic2"
#define ACCESS_RUINS_GENERIC3 "ruins_generic3"
#define ACCESS_RUINS_GENERIC4 "ruins_generic4"


//---  MECH  ---//
// Mech Access, allows maintanenace of internal components and altering keycard requirements.

#define ACCESS_MECH_SECURITY "mech_security"
#define ACCESS_MECH_ENGINE "mech_engine"
#define ACCESS_MECH_MEDICAL "mech_medical"
#define ACCESS_MECH_MINING "mech_mining"
#define ACCESS_MECH_SCIENCE "mech_science"
#define ACCESS_MECH_RUINS "mech_ruins"


//---  ADMIN  ---//
// Used for admin events and things of the like. Lots of extra space for more admin tools in the future

/// General facilities. Centcom ferry.
#define ACCESS_CENT_GENERAL "cent_general"
#define ACCESS_CENT_THUNDER "cent_thunder"
#define ACCESS_CENT_MEDICAL "cent_medical"
#define ACCESS_CENT_LIVING "cent_living"
#define ACCESS_CENT_STORAGE "cent_storage"
#define ACCESS_CENT_TELEPORTER "cent_teleporter"
#define ACCESS_CENT_CAPTAIN "cent_captain"
#define ACCESS_CENT_BAR "cent_bar"
/// Special Ops. Captain's display case, Marauder/Seraph mechs, .
#define ACCESS_CENT_SPECOPS "cent_specops" ///Remind me to separate to captain, centcom, and syndicate mech access later -SonofSpace


//---  ANTAGONISTS  ---//

/// SYNDICATE
#define ACCESS_SYNDICATE "syndicate"
#define ACCESS_SYNDICATE_LEADER "syndicate_leader"

/// CULTS
#define ACCESS_BLOODCULT "bloodcult"
#define ACCESS_CLOCKCULT "clockcult"


//---  MISCELLANEOUS  ---//
/// For things that aren't ever supposed to be accessed
#define ACCESS_INACCESSIBLE "inaccessible"

/// - - - END ACCESS IDS - - - ///



/// A list of access levels that, when added to an ID card, will warn admins.
#define ACCESS_ALERT_ADMINS list(ACCESS_CHANGE_IDS)

/// Logging define for ID card access changes
#define LOG_ID_ACCESS_CHANGE(user, id_card, change_description) \
	log_game("[key_name(user)] [change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]"); \
	user.investigate_log("[change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]", INVESTIGATE_ACCESSCHANGES); \
	user.log_message("[change_description] to an ID card [(id_card.registered_name) ? "belonging to [id_card.registered_name]." : "with no registered name."]", LOG_GAME); \
