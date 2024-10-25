https://github.com/Monkestation/Monkestation2.0/pull/2199

## \<NTSL Coding> 

MODULE ID: NTSL

### Description:

Allows people to change how comms work via NTSL
for example, adding in their job after their name

### TG Proc/File Changes:

- code\datums\chatmessage.dm -- Added a if(!speaker); return; due to NTSL code not passing a speaker when you use broadcast()
- code\datums\id_trim\jobs.dm -- Added the ACCESS_TCOMMS_ADMIN to the CE's trim
- code\game\say.dm -- Adds a </a> to the end of endspanpart, also a lot of stuff for AI tracking
- code\game\machinery\telecomms\telecomunications.dm -- Added some logging if there's a wrong filter path
- code\game\machinery\telecomms\broadcasting.dm -- Added a lvls var to the signal, needed for broadcast() on comms to work
- code\game\machinery\telecomms\machines\server.dm -- Added stuff to make the servers actually compile NTSL
- code\modules\research\techweb\all_nodes.dm -- Added the programming console thingy to the telecomms techweb

- icons\ui_icons\achievements.dmi -- Added the achievement icon for loud and silent birb
- icons\obj\card.dmi -- Added the icon for signal techs

- tgui\packages\tgui\interfaces\common\JobToIcon.ts -- Added an icon state to the signal techs so they show up in TGUI

### Included files that are not contained in this module:

- monkestation\code\modules\jobs\job_types\signal_technician.dm
- monkestation\code\modules\clothing\under\jobs\engineering.dm
- monkestation\code\modules\clothing\spacesuits\plasmamen.dm

- monkestation\icons\obj\clothing\uniforms.dmi
- monkestation\icons\mob\clothing\uniform.dmi
- monkestation\icons\obj\clothing\plasmaman.dmi
- monkestation\icons\mob\clothing\plasmaman.dmi
- monkestation\icons\obj\clothing\plasmaman_head.dmi
- monkestation\icons\mob\clothing\plasmaman_head.dmi

- tgui\packages\tgui\interfaces\NTSLCoding.js -- Interface for the traffic console

### Defines:

- code\__DEFINES\access.dm
- code\__DEFINES\jobs.dm
- code\__DEFINES\achievements.dm -- Added poly achievement defines, since apparently we dont modularize dat
- code\__DEFINES\logging.dm -- Added NTSL log stuff

- code\__DEFINES\~monkestation\access.dm
- code\__DEFINES\~monkestation\jobs.dm
- code\__DEFINES\~monkestation\NTSL.dm

### Credits:

- Altoids1 -- Original author in 2019
- JohnFulpWillard -- Doing a lot of stuff apparently
- Gboster-0 -- Porting to Monkestation, fixes
