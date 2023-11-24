import { multiline } from 'common/string';
import { CheckboxInput, FeatureChoiced, FeatureDropdownInput } from '../base';


export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: multiline`
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};
