import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const MONKEY_MECHANICAL_DESCRIPTION
   = multiline`
      Enter the station infected with a disease that will eventually turn you into a monkey. Bite others to spread the virus, and escape to Centcom to continue the cycle.
   `;

const Monkey: Antagonist = {
  key: "monkey",
  name: "Monkey",
  description: [
    multiline`
      You thought it'd be an ordinary day, but ever since a monkey bit you the day before, you've felt yourself regressing into something more base. 
			When you look at your colleagues, all you can think of is sinking your teeth into them and flailing wildly.

    `,
    MONKEY_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Monkey;
