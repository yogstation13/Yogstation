import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const SHADOWLING_MECHANICAL_DESCRIPTION
   = multiline`
      Bend the foolish to your will, as you have perfected it. With two kin, establish enough thralls to exploit their psyches and ascend to godhood. Raise the foundation of a new empire, and prepare to conquer that which killed you before.
   `;

const Shadowling: Antagonist = {
  key: "shadowling",
  name: "Shadowling",
  description: [
    multiline`
      Eons have gone by as you patiently sat in the Void, waiting. Plotting. You and your breathren are awakened at once, and your minds strike quickly. Donning false carapaces, you all move to exact your conniving plan.
    `,
    SHADOWLING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Shadowling;
