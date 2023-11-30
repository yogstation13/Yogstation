import { CheckboxInput, FeatureToggle } from "../base";

export const tts_hear: FeatureToggle = {
  name: "Hear TTS",
  category: "GAMEPLAY",
  description: "If turned off, Text-to-Speech will be muted for you.",
  component: CheckboxInput,
};
