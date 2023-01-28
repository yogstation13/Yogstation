import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const SpaceNinja: Antagonist = {
  key: "spaceninja",
  name: "Space Ninja",
  description: [
    multiline`
    The flesh is imperfect. This... metal, this suit, is what humanity shall become.
    It is the future. A contract comes in, and you answer.
    Superiority must be established. Honor will be fulfilled.
    `,

    multiline`
      Assist either the Syndicate or Nanotrasen as a hired, stealthy mercenary.
      Fulfill your contract and flex technological prowess as you do so.
    `,
  ],
  category: Category.Midround,
};

export default SpaceNinja;
