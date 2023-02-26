import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const PIRATE_MECHANICAL_DESCRIPTION
   = multiline`
      Dock near the station with two other skeleton crew and terrorize the crew for refusing to pay you.
      Stow any and all stolen goods on your ship, and scurry away with your countless prizes.
   `;


const Pirate: Antagonist = {
  key: "pirate",
  name: "Pirate",
  description: [
    multiline`
      YARR! Pirating be a good life, ye think.
      Ye and yer fellow crew be sailing the stars fer years now, but Hector's rum never be the same after ye were cursed to be skeletons!
      Though the Syndicate be paying ye fine, in addition to whatever booty ye loot. Here's a Nanotrasen station; prime fer a raid!
    `,
    PIRATE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default Pirate;
