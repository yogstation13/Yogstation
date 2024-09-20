import { Feature, FeatureNumberInput, CheckboxInput, FeatureToggle } from "../base";

export const speech_hear: FeatureToggle = {
  name: "Hear speech sounds",
  category: "SOUND",
  description: "If turned off, speech sounds will be muted for you.",
  component: CheckboxInput,
};

export const speech_volume: Feature<number> = {
  name: "Speech volume",
  category: "SOUND",
  description: "Controls the volume at which you hear in-person speech sounds.",
  component: FeatureNumberInput,
};

// export const speech_hear_radio: FeatureToggle = {
//   name: "Hear radio speech",
//   category: "SOUND",
//   description: "If turned off, speech sounds over radio channels will be muted for you.",
//   component: CheckboxInput,
// };

// export const speech_volume_radio: Feature<number> = {
//   name: "Speech radio volume",
//   category: "SOUND",
//   description: "Controls the volume at which you hear speech sounds over radio channels.",
//   component: FeatureNumberInput,
// };
