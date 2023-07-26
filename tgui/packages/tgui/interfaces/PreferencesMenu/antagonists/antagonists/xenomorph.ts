import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const XENOMORPH_MECHANICAL_DESCRIPTION
   = multiline`
      Spawn in the dark maintenance tunnels as a fresh alien larva, and quickly grow into something deadlier.
      Infest the station with chestbursters and resin, and eventually hijack the shuttle to escape to Centcom.
   `;


const Xenomorph: Antagonist = {
  key: "xenomorph",
  name: "Xenomorph",
  description: [
    multiline`
      The xenomorph hive is quick to infest, grow, and eliminate. I admire the creatures' beauty. Perfect organisms.
      No matter what humanity tries, they'll still spread, and breed, and you'll die.
      I would say good luck, but I don't want to mislead you.
    `,
    XENOMORPH_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Xenomorph;
