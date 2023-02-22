import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const DEMONOFSIN_MECHANICAL_DESCRIPTION
   = multiline`
      IN PROGRESS
   `;

const DemonOfSin: Antagonist = {
  key: "demonofsin",
  name: "Demon of Sin",
  description: [
    multiline`
      IN PROGRESS
    `,
    DEMONOFSIN_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default DemonOfSin;
