import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const PIRATE_MECHANICAL_DESCRIPTION
   = multiline`
      IN PROGRESS
   `;

const Pirate: Antagonist = {
  key: "pirate",
  name: "Pirate",
  description: [
    multiline`
      IN PROGRESS
    `,
    PIRATE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default Pirate;
