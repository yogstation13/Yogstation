// THIS IS A NOVA SECTOR UI FILE
import {
  Feature,
  FeatureColorInput,
  FeatureShortTextInput,
  FeatureTextInput,
} from "../base";

export const feature_mcolor2: Feature<string> = {
  name: 'Mutant color 2',
  component: FeatureColorInput,
};
export const feature_mcolor3: Feature<string> = {
  name: 'Mutant color 3',
  component: FeatureColorInput,
};

export const flavor_text: Feature<string> = {
  name: 'Flavor Text',
  description:
    "Appears when your character is examined (but only if they're identifiable - try a gas mask).",
  component: FeatureTextInput,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Flavor Text (Silicon)',
  description: "Only appears if you're playing as a borg/AI.",
  component: FeatureTextInput,
};

export const ooc_notes: Feature<string> = {
  name: 'OOC Notes',
  component: FeatureTextInput,
};

export const custom_species: Feature<string> = {
  name: 'Custom Species Name',
  description:
    'Appears on examine. If left blank, you will use your default species name (E.g. Human, Lizardperson).',
  component: FeatureShortTextInput,
};

export const custom_species_lore: Feature<string> = {
  name: 'Custom Species Lore',
  description: "Won't show up if there's no custom species.",
  component: FeatureTextInput,
};
export const general_record: Feature<string> = {
  name: 'Records - General',
  description:
    'Viewable with any records access. \
    For general viewing-things like employment, qualifications, etc.',
  component: FeatureTextInput,
};

export const security_record: Feature<string> = {
  name: 'Records - Security',
  description:
    'Viewable with security access. \
  For criminal records, arrest history, things like that.',
  component: FeatureTextInput,
};

export const medical_record: Feature<string> = {
  name: 'Records - Medical',
  description:
    'Viewable with medical access. \
  For things like medical history, prescriptions, DNR orders, etc.',
  component: FeatureTextInput,
};

export const exploitable_info: Feature<string> = {
  name: 'Records - Exploitable',
  description:
    'Can be IC or OOC. Viewable by certain antagonists/OPFOR users, as well as ghosts. Generally contains \
  things like weaknesses, strengths, important background, trigger words, etc. It ALSO may contain things like \
  antagonist preferences, e.g. if you want to be antagonized, by whom, with what, etc.',
  component: FeatureTextInput,
};

export const background_info: Feature<string> = {
  name: 'Records - Background',
  description:
    'Only viewable by yourself and ghosts. You can have whatever you want in here - it may be valuable as a way to orient yourself to what your character is.',
  component: FeatureTextInput,
};

