/// The time an admin has to cancel a cross-sector message
#define CROSS_SECTOR_CANCEL_TIME (10 SECONDS)

/// The extended time an admin has to cancel a cross-sector message if they pass the filter, for instance
#define EXTENDED_CROSS_SECTOR_CANCEL_TIME (30 SECONDS)

//Security levels affect the escape shuttle timer
/// Security level is green. (no threats)
#define SEC_LEVEL_GREEN		0
/// Security level is blue. (caution advised)
#define SEC_LEVEL_BLUE		1
// monkestation start: additional alert levels
/// Security level is yellow. (Engineering issue)
#define SEC_LEVEL_YELLOW	2
/// Security level is amber. (biological issue, so blob or bloodlings)
#define SEC_LEVEL_AMBER		3
/// Security level is red. (hostile threats)
#define SEC_LEVEL_RED		4
/// Security level is gamma. (Its like red alert, but CC flavored)
#define SEC_LEVEL_GAMMA		5
/// Security level is delta. (station destruction immiment)
#define SEC_LEVEL_DELTA		6
/// Security level is lambda. (oh god eldtrich beings won the video game)
#define SEC_LEVEL_LAMBDA	7
// Security level is epsilon. (yall fucked up)
#define SEC_LEVEL_EPSILON	8
// monkestation end
