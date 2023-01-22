import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const MONSTERHUNTER_MECHANICAL_DESCRIPTION
   = multiline`
      IN PROGRESS
   `;

const MonsterHunter: Antagonist = {
  key: "monsterhunter",
  name: "Monster Hunter",
  description: [
    multiline`
      IN PROGRESS
    `,
    MONSTERHUNTER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default MonsterHunter;
