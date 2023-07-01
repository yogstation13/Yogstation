import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const WIZARD_MECHANICAL_DESCRIPTION
  = multiline`
      Prepare a set of malicious spells as an envoy of the Wizard Federation, then teleport onto the station and wreak havoc.
      Flex your arcane superiority and force all to bow before your power.
    `;


const Wizard: Antagonist = {
  key: "wizard",
  name: "Wizard",
  description: [
    multiline`
      The studies progress and the mana is crunchy and the scrolls are glimmering and understanding it all coming on
      you feel alive it's all so thrilling the enlightenment the domination the reach and
      headmaster instructs you to decimate troublemakers who are you to disobey you leave.
    `,
    WIZARD_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Wizard;
