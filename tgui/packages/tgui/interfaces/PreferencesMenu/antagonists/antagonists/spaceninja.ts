import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SPACENINJA_MECHANICAL_DESCRIPTION
   = multiline`
      Assist either the Syndicate or Nanotrasen as a hired, stealthy mercenary.
      Fulfill your contract and flex technological prowess as you do so.
   `;


const SpaceNinja: Antagonist = {
  key: "spaceninja",
  name: "Space Ninja",
  description: [
    multiline`
      The flesh is imperfect. This... metal, this suit, is what humanity shall become.
      It is the future. A contract comes in, and you answer.
      Superiority must be established. Honor will be fulfilled.
    `,
    SPACENINJA_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default SpaceNinja;
