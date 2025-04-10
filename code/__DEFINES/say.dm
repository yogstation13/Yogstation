/*
	Defines for use in saycode and text formatting.
	Currently contains speech spans and message modes
*/

#define RADIO_EXTENSION "department specific"
#define RADIO_KEY "department specific key"

#define LANGUAGE_EXTENSION "language specific"
#define LANGUAGE_EXTENSION_KEY ","

//Message modes. Each one defines a radio channel, more or less.
#define MODE_HEADSET "headset"
#define MODE_KEY_HEADSET ";"

#define MODE_SING "sing"
#define MODE_KEY_SING "%"

#define WHISPER_MODE "the type of whisper"
#define MODE_WHISPER "whisper"
#define MODE_KEY_WHISPER "#"
#define MODE_WHISPER_CRIT "whispercrit"

#define MODE_ROBOT "robot"

#define MODE_RADIO "radio"
#define MODE_KEY_RADIO "r"

#define MODE_INTERCOM "intercom"
#define MODE_KEY_INTERCOM "i"

#define MODE_DEPARTMENT "department"
#define MODE_KEY_DEPARTMENT "h"
#define MODE_TOKEN_DEPARTMENT ":h"

#define MODE_ADMIN "admin"
#define MODE_KEY_ADMIN "p"

#define MODE_DEADMIN "deadmin"
#define MODE_KEY_DEADMIN "d"

#define MODE_BINARY "binary"
#define MODE_KEY_BINARY "b"
#define MODE_TOKEN_BINARY ":b"

#define MODE_ALIEN "alientalk"
#define MODE_KEY_ALIEN "a"
#define MODE_TOKEN_ALIEN ":a"

#define MODE_HOLOPAD "holopad"
#define MODE_KEY_HOLOPAD "h"
#define MODE_TOKEN_HOLOPAD ":h"

#define MODE_CHANGELING "changeling"
#define MODE_KEY_CHANGELING "g"
#define MODE_TOKEN_CHANGELING ":g"

#define MODE_VOCALCORDS "cords"
#define MODE_KEY_VOCALCORDS "x"

#define MODE_MONKEY "monkeyhive"
#define MODE_KEY_MONKEY  "k"
#define MODE_TOKEN_MONKEY  ":k"

#define MODE_DARKSPAWN "mindlink"
#define MODE_KEY_DARKSPAWN  "w"
#define MODE_TOKEN_DARKSPAWN  ":w"

//Spans. Robot speech, italics, etc. Applied in compose_message().
#define SPAN_ROBOT "robot"
#define SPAN_YELL "yell"
#define SPAN_ITALICS "italics"
#define SPAN_SANS "sans"
#define SPAN_PAPYRUS "papyrus"
#define SPAN_REALLYBIG "reallybig"
#define SPAN_COMMAND "command_headset"
#define SPAN_CLOWN "clown"
#define SPAN_SINGING "singing"
#define SPAN_CULTLARGE "cultlarge"
#define SPAN_HELIUM "small"
#define SPAN_PROGENITOR "progenitor"
#define SPAN_COLOSSUS "colossus"

//bitflag #defines for return value of the radio() proc.
#define ITALICS			(1<<0)
#define REDUCE_RANGE	(1<<1)
#define NOPASS			(1<<2)

//Eavesdropping
#define EAVESDROP_EXTRA_RANGE 1 //how much past the specified message_range does the message get starred, whispering only

// A link given to ghost alice to follow bob
#define FOLLOW_LINK(alice, bob) "<a href=byond://?src=[REF(alice)];follow=[REF(bob)]>(F)</a>"
#define TURF_LINK(alice, turfy) "<a href=byond://?src=[REF(alice)];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(T)</a>"
#define FOLLOW_OR_TURF_LINK(alice, bob, turfy) "<a href=byond://?src=[REF(alice)];follow=[REF(bob)];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(F)</a>"

#define LINGHIVE_NONE 0
#define LINGHIVE_OUTSIDER 1
#define LINGHIVE_LING 2
#define LINGHIVE_LINK 3

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN			1024
#define MAX_NAME_LEN			42
#define MAX_BROADCAST_LEN		512
#define MAX_CHARTER_LEN			64

// Audio/Visual Flags. Used to determine what sense are required to notice a message.
#define MSG_VISUAL (1<<0)
#define MSG_AUDIBLE (1<<1)

//Used in visible_message_flags, audible_message_flags and runechat_flags
#define EMOTE_MESSAGE (1<<0)

//Typing indicator defines, used in /mob/create_typing_indicator()
#define BUBBLE_DEFAULT "default"
#define BUBBLE_LAWYER "lawyer"
#define BUBBLE_ROBOT "robot"
#define BUBBLE_MACHINE "machine"
#define BUBBLE_SYNDIBOT "syndibot"
#define BUBBLE_SWARMER "swarmer"
#define BUBBLE_SLIME "slime"
#define BUBBLE_CLOCK "clock"
#define BUBBLE_ALIEN "alien"
#define BUBBLE_ALIENROYAL "alienroyal"
#define BUBBLE_DARKSPAWN "darkspawn"
#define BUBBLE_GUARDIAN "guardian"
#define BUBBLE_BLOB "blob"


#define MAX_FLAVOR_LEN 4096		//double the maximum message length.

/// Default volume of speech sound effects (this is actually multiplied by 5 when used)
#define DEFAULT_SPEECH_VOLUME 60
