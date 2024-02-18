import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const HERETIC_MECHANICAL_DESCRIPTION
   = multiline`
      Become a student of the Mansus via sacrifice and exploration.
      Compile ingredients to perform rituals.
      Seeking ultimate power, complete your research and ascend, and be counted among the Long.
   `;


const Heretic: Antagonist = {
  key: "heretic",
  name: "Heretic",
  description: [
    multiline`
      The dreams began some time back.
      Stumbling through brambles and trees, you found yourself in a tavern.
      Unfamiliar faces discuss the Lores that establish the fabric of your reality, and the place with no walls that surrounds all things.
      They ignore you for now. They will not soon enough.
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Heretic;
