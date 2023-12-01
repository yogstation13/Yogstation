import { Feature, FeatureNumberInput, CheckboxInput, FeatureToggle } from "../base";

export const tts_hear: FeatureToggle = {
  name: "Hear TTS",
  category: "SOUND",
  description: "If turned off, Text-to-Speech will be muted for you.",
  component: CheckboxInput,
};

export const tts_volume: Feature<number> = {
  name: "TTS volume",
  category: "SOUND",
  description: "Controls the volume at which you hear in-person Text-to-Speech.",
  component: FeatureNumberInput,
};

export const tts_hear_radio: FeatureToggle = {
  name: "Hear radio TTS",
  category: "SOUND",
  description: "If turned off, Text-to-Speech on radio channels will be muted for you.",
  component: CheckboxInput,
};

export const tts_volume_radio: Feature<number> = {
  name: "TTS radio volume",
  category: "SOUND",
  description: "Controls the volume at which you hear Text-to-Speech on radio channels.",
  component: FeatureNumberInput,
};
