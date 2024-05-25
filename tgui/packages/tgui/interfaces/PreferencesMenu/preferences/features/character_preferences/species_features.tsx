// THIS IS A NOVA SECTOR UI FILE
import {
  Feature,
  FeatureTextInput,
} from "../base";

export const flavor_text: Feature<string> = {
  name: 'Flavor Text',
  description:
    "Appears when your character is examined (but only if they're identifiable - try a gas mask).",
  component: FeatureTextInput,
};

