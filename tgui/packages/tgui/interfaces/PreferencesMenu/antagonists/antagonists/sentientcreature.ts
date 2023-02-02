import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SENTIENTCREATURE_MECHANICAL_DESCRIPTION
   = multiline`
      TBD
   `;

const SentientCreature: Antagonist = {
  key: "sentientcreature",
  name: "Sentient Creature",
  description: [
    multiline`
      TBD
    `,
    SENTIENTCREATURE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default SentientCreature;
