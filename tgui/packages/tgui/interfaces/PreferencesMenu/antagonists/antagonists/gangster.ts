import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const GANGSTER_MECHANICAL_DESCRIPTION
   = multiline`
      Convert others into your gang and send them off to claim territory to fund illicit gear.
      Work against other gangs and security to claim the nuclear disk, then hijack the station using the dominator machine.
   `;


const Gangster: Antagonist = {
  key: "gangster",
  name: "Gang Leader",
  description: [
    multiline`
      It's time for a take over. Other gangs have had their eye on this place, but your corporate employer expects results.
      Make sure yours is the one that dominates the station subsystems, so that you can enjoy this new turf of paradise.
    `,
    GANGSTER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Gangster;
