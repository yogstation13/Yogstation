import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const REVENANT_MECHANICAL_DESCRIPTION
   = multiline`
   Stalk the halls of the station as a ghastly spirit and absorb the essence of the dead or isolated.
   Avoid combat, as you are fragile.
   `;

const Revenant: Antagonist = {
  key: "revenant",
  name: "Revenant",
  description: [
    multiline`
    Whispering, fleeting, agony.
    Enough pain rolls up and you float over to respond, like flies to rotting meat.
    You flit in, and you hear voices roll over you, and you find those lonely, clouded with despair.
    Time to feast.
    `,
    REVENANT_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Revenant;
