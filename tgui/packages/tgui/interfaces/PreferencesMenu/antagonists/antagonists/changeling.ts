import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const CHANGELING_MECHANICAL_DESCRIPTION
   = multiline`
      Assume the guise of a crew member as a DNA-absorbing slug.
      Use unnatural powers and resilience to absorb further victims or other changelings and complete your objectives.
   `;


const Changeling: Antagonist = {
  key: "changeling",
  name: "Changeling",
  description: [
    multiline`
      We celebrate this day! Another's misfortune is our bounty, and we have found a suitable form.
			They bring to us memories, responsibilities, and opportunities. We shall continue our normal schedule, but we must feed.
			Surely a familiar face will lower their trust?
    `,
    CHANGELING_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Changeling;
