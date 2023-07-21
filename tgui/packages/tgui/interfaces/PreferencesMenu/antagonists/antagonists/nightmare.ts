import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const NIGHTMARE_MECHANICAL_DESCRIPTION
   = multiline`
      You've been pulled from a nightmare by the brightness. Though your corpse is mangled, it still serves as an agile weapon. Snuff the light, so you may return to the eternal dream without answers.
   `;


const Nightmare: Antagonist = {
  key: "nightmare",
  name: "Nightmare",
  description: [
    multiline`
      It's just you. You reach, and the light BURNS. You call, to no response, and the STARS fill your eyes and SEAR your twisted carapace. THE RAYS BLIND AND BREAK AND BECKON.
    `,
    NIGHTMARE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Nightmare;
