import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const ELDRITCHHORROR_MECHANICAL_DESCRIPTION
   = multiline`
      As an abnormal creature, cunningly ambush individuals to enter into their minds and devour their souls to become more powerful.
      If summoned by a Curator, aid them in their objectives.
   `;


const EldritchHorror: Antagonist = {
  key: "eldritchhorror",
  name: "Eldritch Horror",
  description: [
    multiline`
      So many brains, so many souls! Wriggle and whisper and weave, listen to the neurons fire and the sparks pulse with ambition!
      I'll have to be sneaky, I'll have to be quick. The Cup's always empty, and the Priest wants it filled!
    `,
    ELDRITCHHORROR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default EldritchHorror;
