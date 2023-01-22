import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const ZOMBIE_MECHANICAL_DESCRIPTION
   = multiline`
      IN PROGRESS
   `;

const Zombie: Antagonist = {
  key: "zombie",
  name: "Zombie",
  description: [
    multiline`
      IN PROGRESS
    `,
    ZOMBIE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default Zombie;
