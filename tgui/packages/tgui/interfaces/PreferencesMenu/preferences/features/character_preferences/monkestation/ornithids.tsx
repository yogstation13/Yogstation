import {
  Feature,
  FeatureChoiced,
  FeatureColorInput,
  FeatureDropdownInput,
} from '../../base';

export const feature_arm_wings: FeatureChoiced = {
  name: 'Arm Wings',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feather_color: Feature<string> = {
  name: 'Feather Color',
  small_supplemental: true,
  description:
    "The color of your character's feathers. \
  (Armwings, Plumage).",
  component: FeatureColorInput,
};

export const feather_color_secondary: Feature<string> = {
  name: 'Feather Color Secondary',
  small_supplemental: true,
  description:
    "The color of your character's feathers. \
  (Armwings, Plumage).",
  component: FeatureColorInput,
};

export const feather_color_tri: Feature<string> = {
  name: 'Feather Color Tri',
  small_supplemental: true,
  description:
    "The color of your character's feathers. \
  (Armwings, Plumage).",
  component: FeatureColorInput,
};

export const feather_tail_color: Feature<string> = {
  name: 'Tail Color',
  small_supplemental: false,
  description:
    "The color of your character's tail feathers. \
  (Armwings, Plumage).",
  component: FeatureColorInput,
};

export const plummage_color: Feature<string> = {
  name: 'Plummage Color',
  small_supplemental: false,
  description:
    "The color of your character's plummage. \
  (Armwings, Plumage).",
  component: FeatureColorInput,
};
export const feature_avian_tail: FeatureChoiced = {
  name: 'Tail',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_avian_ears: FeatureChoiced = {
  name: 'Plumage',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_satyr_horns: FeatureChoiced = {
  name: 'Satyr Horns',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_satyr_fluff: FeatureChoiced = {
  name: 'Satyr Fluff',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_satyr_tail: FeatureChoiced = {
  name: 'Tail',
  small_supplemental: false,
  component: FeatureDropdownInput,
};
