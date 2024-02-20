import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const MONSTERHUNTER_MECHANICAL_DESCRIPTION
   = multiline`
      Work secretly to rid the station of all supernatural threats as a specially trained witcher.
      Take a prize from the station while avoiding the ire of security elements.
   `;


const MonsterHunter: Antagonist = {
  key: "monsterhunter",
  name: "Monster Hunter",
  description: [
    multiline`
      There are few of your kind left.
      With expansion into space, heirs to ancient, human families were thankfully able to pass knowledge onto other species, now part of our galactic community.
      But the Undead and greater horrors still stalk our halls. Authority is corrupt; you will be Justice's sword.
    `,
    MONSTERHUNTER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default MonsterHunter;
