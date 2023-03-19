import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SPACEDRAGON_MECHANICAL_DESCRIPTION
   = multiline`
      Spawn on the outer edges of station in space as a large, powerful space dragon.
      Eat people to regain health and summon carps as allies in your carnage.
   `;


const SpaceDragon: Antagonist = {
  key: "spacedragon",
  name: "Space Dragon",
  description: [
    multiline`
      Part carp, part magic, all viciousness. The space dragon is a being believed to have been created by the Wizard Federation, though its purpose remains unclear.
      Is it simply an agent they send out to wreck havoc? Are there specific goals it has? What intelligence does it have?
    `,
    SPACEDRAGON_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default SpaceDragon;
