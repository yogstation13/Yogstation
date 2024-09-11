import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SENTIENTCREATURE_MECHANICAL_DESCRIPTION
   = multiline`
      Become a Xenian Creature.
      Includes zombies, headcrabs, and antlions.
   `;

const SentientCreature: Antagonist = {
  key: "sentientcreature",
  name: "Xenian Creature",
  description: [
    multiline`
      You're an exceptionally intelligent Xenian lifeform.
      Time to do what you do best.
    `,
    SENTIENTCREATURE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default SentientCreature;
