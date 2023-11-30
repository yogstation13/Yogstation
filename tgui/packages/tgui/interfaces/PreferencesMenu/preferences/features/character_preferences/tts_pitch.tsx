import { Feature, FeatureNumberInput } from "../base";

export const tts_pitch: Feature<number> = {
  name: "Text-to-Speech Pitch",
  component: FeatureNumberInput,
};
