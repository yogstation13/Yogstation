import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const TRAITOR_MECHANICAL_DESCRIPTION
   = multiline`
      Utilize a hidden uplink to acquire equipment, then set out to accomplish your objectives how you see fit. Be cunning, be fierce, be swift.
   `;


const Traitor: Antagonist = {
  key: "traitor",
  name: "Traitor",
  description: [
    multiline`
      Six words. You'd been instructed to remember them, whether it was to clear a favor, to claim vengeance, to make money, or whatever else drove you to the Syndicate. Maybe they were driven to you. A beep sounds in your headset.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;
