// shamelessly copied from traits.dm
// filter accessor defines
#define ADD_FILTER(target, filter, source) \
	do { \
		var/list/_L; \
		if (!target.tts_filters) { \
			target.tts_filters = list(); \
			_L = target.tts_filters; \
			_L[filter] = list(source); \
		} else { \
			_L = target.tts_filters; \
			if (_L[filter]) { \
				_L[filter] |= list(source); \
			} else { \
				_L[filter] = list(source); \
			} \
		} \
	} while (0)
#define REMOVE_FILTER(target, filter, sources) \
	do { \
		var/list/_L = target.tts_filters; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[filter]) { \
			for (var/_T in _L[filter]) { \
				if ((!_S && (_T != ROUNDSTART_FILTER)) || (_T in _S)) { \
					_L[filter] -= _T \
				} \
			};\
			if (!length(_L[filter])) { \
				_L -= filter; \
			}; \
			if (!length(_L)) { \
				target.tts_filters = null \
			}; \
		} \
	} while (0)
#define REMOVE_FILTER_NOT_FROM(target, filter, sources) \
	do { \
		var/list/_filters_list = target.tts_filters; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_filters_list && _filters_list[filter]) { \
			for (var/_filter_source in _filters_list[filter]) { \
				if (!(_filter_source in _sources_list)) { \
					_filters_list[filter] -= _filter_source \
				} \
			};\
			if (!length(_filters_list[filter])) { \
				_filters_list -= filter; \
			}; \
			if (!length(_filters_list)) { \
				target.tts_filters = null \
			}; \
		} \
	} while (0)
#define REMOVE_FILTERS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.tts_filters; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					}; \
				};\
			if (!length(_L)) { \
				target.tts_filters = null\
			};\
		}\
	} while (0)
#define REMOVE_FILTERS_IN(target, sources) \
	do { \
		var/list/_L = target.tts_filters; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					}; \
				};\
			if (!length(_L)) { \
				target.tts_filters = null\
			};\
		}\
	} while (0)
#define HAS_FILTER(target, filter) (target.tts_filters ? (target.tts_filters[filter] ? TRUE : FALSE) : FALSE)
#define HAS_FILTER_FROM(target, filter, source) (target.tts_filters ? (target.tts_filters[filter] ? (source in target.tts_filters[filter]) : FALSE) : FALSE)

// common filter sources
#define ROUNDSTART_FILTER "roundstart" // quirks, mob types, cannot be removed
#define RADIO_PROCESSING_FILTER "radio_processing"

// tts filters
#define TTS_FILTER_LIZARD "lizard"
#define TTS_FILTER_ALIEN "alien"
#define TTS_FILTER_ETHEREAL "ethereal"
#define TTS_FILTER_ROBOT "robotic"
#define TTS_FILTER_MASK "masked"
#define TTS_FILTER_SECHAILER "robocop"
#define TTS_FILTER_RADIO "radio"
