import { CheckboxInput, FeatureToggle } from '../../base';

export const verify_overflow: FeatureToggle = {
  name: 'Confirm Ready During Job Overflow',
  category: 'GAMEPLAY',
  description:
    'When enabled, readying up will bring up a confirmation prompt if the current round has a different overflow job.',
  component: CheckboxInput,
};
