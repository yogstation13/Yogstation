import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const VAMPIRE_MECHANICAL_DESCRIPTION
   = multiline`
      Use powers of the night to complete your objectives. Suck blood from individuals to fuel your supernatural abilities and grow in power.
   `;


const Vampire: Antagonist = {
  key: "vampire",
  name: "Vampire",
  description: [
    multiline`
      The gift of Lilith courses through you; you've never known such power before!
      But immortality carries a price, and the Thirst drives you to action.
      You've observed your colleagues for some weeks; it's time to feed.
    `,
    VAMPIRE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Vampire;
