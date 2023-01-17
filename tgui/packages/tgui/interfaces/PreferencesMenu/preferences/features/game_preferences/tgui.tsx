import { CheckboxInput, FeatureToggle } from '../base';

export const tgui_fancy: FeatureToggle = {
  name: 'Enable fancy TGUI',
  category: 'UI',
  description: 'Makes TGUI windows look better, at the cost of compatibility.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Lock TGUI to main monitor',
  category: 'UI',
  description: 'Locks TGUI windows to your main monitor.',
  component: CheckboxInput,
};
