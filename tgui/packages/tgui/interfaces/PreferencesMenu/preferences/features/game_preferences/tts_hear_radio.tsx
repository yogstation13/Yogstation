import { CheckboxInput, FeatureToggle } from "../base";

export const tts_hear_radio: FeatureToggle = {
  name: "Hear radio TTS",
  category: "GAMEPLAY",
  description: "If turned off, Text-to-Speech on radio channels will be muted for you.",
  component: CheckboxInput,
};
