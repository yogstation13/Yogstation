import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const BLOODSUCKER_MECHANICAL_DESCRIPTION
   = multiline`
      Develop your own power and establish Vassals to accomplish your goals.
			Avoid Sol's harsh rays, siphon blood, and maintain the Masquerade to excel.
   `;

const Bloodsucker: Antagonist = {
  key: "bloodsucker",
  name: "Bloodsucker",
  description: [
    multiline`
      You are descended from the cursed blood of Cain, the first Kindred. 
			As an ambitious, upstart vampire, you seek to raise your influence through exploits on a newly-founded Nanotrasen station.
			The Camarilla clan has their eyes on you; perform well.
    `,
    BLOODSUCKER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Bloodsucker;
