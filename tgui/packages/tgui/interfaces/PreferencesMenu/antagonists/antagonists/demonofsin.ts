import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const DEMONOFSIN_MECHANICAL_DESCRIPTION
   = multiline`
      Fulfill an objective based on the sin your demon represents.
      Avoid holy influence and transform into your true form if you need to defend yourself or inflict pain.
   `;


const DemonOfSin: Antagonist = {
  key: "demonofsin",
  name: "Demon of Sin",
  description: [
    multiline`
      Sentience breeds sin. Whether by accident or intent, you have escaped Hell and roam the material universe under a human disguise now.
      Whether it is gluttony or greed, pride or wrath, you will embody your deadly sin. The mortals will give you opportunity.
    `,
    DEMONOFSIN_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default DemonOfSin;
