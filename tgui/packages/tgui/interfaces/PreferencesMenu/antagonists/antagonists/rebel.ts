import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const REBEL_MECHANICAL_DESCRIPTION
   = multiline`
      Make a plan to take down the Combine at any cost.
      Loyalists are the enemy, the benefactors will go down.
   `;


const Rebel: Antagonist = {
  key: "rebel",
  name: "Rebel",
  description: [
    multiline`
      You've been living like crap for far too long.
      Now is the day you rebel. Finally, change is in the air!
    `,
    REBEL_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Rebel;
