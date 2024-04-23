import { multiline } from 'common/string';
import { createDropdownInput, Feature } from '../base';

export const multiz_performance: Feature<number> = {
  name: 'Multi-Z Detail',
  category: 'GAMEPLAY',
  description: multiline`
    How many Z-levels should be rendered when peering through open space.
    Lowering this value will improve game performance.
  `,
  component: createDropdownInput({
    [-1]: 'Server Default: Uncapped',
    2: 'High: 2 z-levels',
    1: 'Medium: 1 z-level',
    0: 'Low: None',
  }),
};
