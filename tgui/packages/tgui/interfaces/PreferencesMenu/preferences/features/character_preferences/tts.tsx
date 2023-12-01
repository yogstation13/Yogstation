import { Feature, FeatureDropdownInput, FeatureChoiced, FeatureNumberInput } from "../base";

export const tts_voice: FeatureChoiced = {
  name: "Text-to-Speech Voice",
  component: FeatureDropdownInput,
};

export const tts_pitch: Feature<number> = {
  name: "Text-to-Speech Pitch",
  component: FeatureNumberInput,
};
