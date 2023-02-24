import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const HIVEMINDHOST_MECHANICAL_DESCRIPTION
   = multiline`
      Silently induct crew members into your neural network, and gain more abilities as you do so. 
			Avoid the ire of security or other hosts, and create one consciousness for all thinking things.
   `;

const HivemindHost: Antagonist = {
  key: "hivemindhost",
  name: "Hivemind Host",
  description: [
    multiline`
      Minds are delicious things. You wander and find and touch, leaving the meat-sacks none the wiser. For now, you can instruct them, but the One Mind will unite and elevate all. 
			We shall become Hivemind.
    `,
    HIVEMINDHOST_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default HivemindHost;
