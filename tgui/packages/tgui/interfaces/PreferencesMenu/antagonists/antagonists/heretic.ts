import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const HERETIC_MECHANICAL_DESCRIPTION
   = multiline`
      Fulfill the requests of your eldritch patrons and become a student of the Mansus via sacrifice and research.
      Compile ingredients to perform rituals.
      Seeking ultimate power, complete your studies and ascend, and be counted among the Long.
   `;


const Heretic: Antagonist = {
  key: "heretic",
  name: "Heretic",
  description: [
    multiline`
      The dreams began some time back.
      Stumbling through brambles and trees, you found yourself in a tavern.
      Unfamiliar faces discuss the Lores that establish the fabric of your reality, and the place with no walls that surrounds all things.
      They gift you awareness and wish you well.
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Heretic;
