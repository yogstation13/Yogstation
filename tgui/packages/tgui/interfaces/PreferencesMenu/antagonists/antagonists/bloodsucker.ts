import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const BLOODSUCKER_MECHANICAL_DESCRIPTION
   = multiline`
      Start with an uplink to purchase your gear and take on your sinister
      objectives. Ascend through the ranks and become an infamous legend.
   `;

const Bloodsucker: Antagonist = {
  key: "bloodsucker",
  name: "Bloodsucker",
  description: [
    multiline`
      An unpaid debt. A score to be settled. Maybe you were just in the wrong
      place at the wrong time. Whatever the reasons, you were selected to
      infiltrate Space Station 13.
    `,
    BLOODSUCKER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Bloodsucker;
