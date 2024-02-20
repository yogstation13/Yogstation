import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const IAA_MECHANICAL_DESCRIPTION
   = multiline`
      Minimize damage to Nanotrasen civilians and their station, but utilize an uplink to eliminate all rogue agents. Be wary; others will be moving against you.
   `;


const internalaffairsagent: Antagonist = {
  key: "internalaffairsagent",
  name: "Internal Affairs Agent",
  description: [
    multiline`
      Someone's ratted. The trust of your agent cell is in question. Presume any and all confirmed targets dangerous, and watch your own back, operative. Clean up this mess and await further instructions.
    `,
    IAA_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default internalaffairsagent;
