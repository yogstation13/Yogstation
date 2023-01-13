import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const BLOODBROTHER_MECHANICAL_DESCRIPTION
   = multiline`
      Complete a set of traitor objectives with a single ally using only makeshift weaponry and what you two can scavenge. 
			Win or lose together.
   `;


const BloodBrother: Antagonist = {
  key: "bloodbrother",
  name: "Blood Brother",
  description: [
    multiline`
      The courses and tribulations you've overcome have been arduous. Now comes your final test; complete the objectives expected from a trained, equipped agent. 
			You will be given no codewords and no uplink. 
			Only another trainee, and your fates will be the same. 
			Good luck.
    `,
    BLOODBROTHER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default BloodBrother;
