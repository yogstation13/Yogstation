import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const ABDUCTOR_MECHANICAL_DESCRIPTION
   = multiline`
      You and a partner will become a scientist and an agent.
      As an agent, abduct unassuming victims and bring them back to your UFO.
      As a scientist, scout out victims for your agent, keep them safe, and
      operate on whoever they bring back.
   `;


const Abductor: Antagonist = {
  key: "abductor",
  name: "Abductor",
  description: [
    multiline`
      Your dimension scopes have found a new research facility! The aliens seem to
      have made it a proper research facility, but little do they know, they're
      the test subjects! Time for you and your colleague to start analysis.
    `,
    ABDUCTOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Abductor;
