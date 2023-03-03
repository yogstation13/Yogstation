import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SENTIENTCREATURE_MECHANICAL_DESCRIPTION
   = multiline`
      Exist as one of the station pets, only you can speak and understand people!
      Adopt a persona of your liking, and enjoy your life as a simple being.
   `;

const SentientCreature: Antagonist = {
  key: "sentientcreature",
  name: "Sentient Creature",
  description: [
    multiline`
      You suddenly come to your senses. What a bizarre dream! The details are already fuzzy, but you can recall some experience as a dim-witted creature of various appendages.
      You look down, and realize you're still in that form!
    `,
    SENTIENTCREATURE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default SentientCreature;
