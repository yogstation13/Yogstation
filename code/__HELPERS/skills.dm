/* 
This is where all the skills will be defined. 

The actual skill check execution can be found under do_after() in mobs.dm
skill checks can be called with do_after()

Example: 
do_after(user, skill = SKILL_MEDICAL, target = src) . This will require a basic medical check.


Skills are something that will create a time block if the skill is not present. The duration of this is defined by skill_delay in do_after(). By default it is 3 seconds.
You can set skill_required to TRUE in do_after() to reject an individual if they  do not meet requirements for the skill. This should probably be reserved for very specific tasks aimed specifically to stop cross department powergaming.
*/


#define SKILL_PLACEHOLDER "undefined" // here for debug + placeholder for do_after() proc
#define SKILL_DEBUG "divine" // you bypass all skill checks if you have this skill. More of a debug skill or an admin tool. You can probably use this skill to make certain items admin interact only.
#define SKILL_ASSISTANT "assisting"
#define SKILL_MEDICAL "medical"
#define SKILL_MEDICAL_ADVANCED "advanced medical"
#define SKILL_MEDICAL_CHEM "chemistry"
#define SKILL_SECURITY "security"
#define SKILL_SECURITY_WARDEN "warden"
#define SKILL_SECURITY_DETECTIVE "detective"
#define SKILL_SCIENCE "science"
#define SKILL_ROBOTICS "robotics"
#define SKILL_SERVICE "service"
#define SKILL_CLOWN "clowning"
#define SKILL_MIME "miming"
#define SKILL_COMMAND "command"
#define SKILL_CARGO "cargo"
#define SKILL_MINING "mining"
#define SKILL_ENGINEERING "engineering"
#define SKILL_ATMOS "atmospheric"
#define SKILL_TCOMS "telecommunication"
#define SKILL_GENETICS "genetic"
#define SKILL_VIROLOGY "virology"
#define SKILL_XENOBIO "xenobiology"
#define SKILL_RELIGIOUS "supernatural"
#define SKILL_JANITOR "janitorial"
#define SKILL_COOKING "cooking"
#define SKILL_BARTENDING "bartending"
#define SKILL_BOTANY "botanical"
#define SKILL_ARTIST "artistic"
#define SKILL_CURATOR "librarian"
#define SKILL_LAWYER "law"