import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const ELDRITCHHORROR_MECHANICAL_DESCRIPTION
   = multiline`
      IN PROGRESS
   `;

const EldritchHorror: Antagonist = {
  key: "eldritchhorror",
  name: "Eldritch Horror",
  description: [
    multiline`
      IN PROGRESS
    `,
    ELDRITCHHORROR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default EldritchHorror;
