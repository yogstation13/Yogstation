import { Box, Stack } from "../../../../components";
import { FeatureColorInput, FeatureChoicedServerData, FeatureValueProps, StandardizedDropdown, Feature, FeatureChoiced, FeatureDropdownInput } from "./base";
import { SkinToneServerData } from "./character_preferences/skin_tone";
import { sortHexValues } from "./character_preferences/skin_tone";

export const eye_color: Feature<string> = {
  name: "Eye Color",
  sortingPrefix: "aaaa",
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: "Facial hair color",
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: "Hair color",
  component: FeatureColorInput,
};

export const feature_gradientstyle: FeatureChoiced = {
  name: "Hair gradient",
  component: FeatureDropdownInput,
};

export const feature_gradientcolor: Feature<string> = {
  name: "Hair gradient color",
  component: FeatureColorInput,
};
