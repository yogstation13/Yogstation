import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const TRAITOR_MECHANICAL_DESCRIPTION
   = multiline`
      Utilize a hidden uplink to acquire equipment, then set out to accomplish your objectives how you see fit. Be cunning, be fierce, be swift.
   `;


const Traitor: Antagonist = {
  key: "traitor",
  name: "Rebel Spy",
  description: [
    multiline`
      You have been called in by Lambda to do a job for them that is best for the resistance at large, no matter the cost.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;

