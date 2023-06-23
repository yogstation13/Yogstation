import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { TRAITOR_MECHANICAL_DESCRIPTION } from './traitor';

const InfernalAffairsAgent: Antagonist = {
  key: 'infernalaffairsagent',
  name: 'Infernal Affairs Agent',
  description: [
    multiline`
      Tricked by the Devil into selling your soul,
      you must collect his other debts to pay back yours.
    `,

    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default InfernalAffairsAgent;
