import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const DEVIL_MECHANICAL_DESCRIPTION
   = multiline`
      Make deals with crew members to slowly accrue power, but be wary of revealing your weaknesses.
      As you collect more contracts, your disguise will fall away, and the mortals will grow desperate in their pursuit to banish you.
   `;


const Devil: Antagonist = {
  key: "devil",
  name: "Devil",
  description: [
    multiline`
      The Fallen Angel, Lucifer, is a fine friend to those down on fortune, and you are one of his many agents.
      While you can take several forms, you don one of a corporate worker to infiltrate a pit of despondency.
      The poor souls have little to live for; temptation should prove simple.
    `,
    DEVIL_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Devil;
