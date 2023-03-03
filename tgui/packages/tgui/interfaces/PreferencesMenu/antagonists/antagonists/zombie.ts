import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const ZOMBIE_MECHANICAL_DESCRIPTION
   = multiline`
      Shamble into the station's maintenance ducts and find living flesh to infect.
      Force the shuttle to be called and move as a horde to infect Centcom on your arrival.
   `;


const Zombie: Antagonist = {
  key: "zombie",
  name: "Zombie",
  description: [
    multiline`
      My name is... is... I am... remembering... don't forget. Don't forget the... need to control... wasn't me, was... it?
      Can't speak. Trying... it moves me... words aren't... mine... Staggering.
      Don't, won't win.
    `,
    ZOMBIE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default Zombie;
