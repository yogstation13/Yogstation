// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//! when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//! before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//! before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETING "parent_qdeleting"				//! just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"
/// handler for vv_do_topic (usr, href_list)
#define COMSIG_VV_TOPIC "vv_topic"
	#define COMPONENT_VV_HANDLED (1<<0)

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// Antagonist signals
/// Called on the mind when an antagonist is being gained, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_GAINED "antagonist_gained"

/// Called on the mind when an antagonist is being removed, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_REMOVED "antagonist_removed"
