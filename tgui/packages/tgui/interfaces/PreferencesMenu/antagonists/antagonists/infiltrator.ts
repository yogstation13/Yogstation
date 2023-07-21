import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const INFILTRATOR_MECHANICAL_DESCRIPTION
   = multiline`
      With the rest of your squad, gear up and covertly infiltrate the ranks of the station from your external shuttle.
      Work together to sabotage, kidnap, subvert, and steal.
   `;


const Infiltrator: Antagonist = {
  key: "infiltrator",
  name: "Syndicate Infiltrator",
  description: [
    multiline`
      It's been quiet on the moon base ever since your team moved in to keep tabs on the nearby Nanotrasen station.
      Nothing you observe provokes the brief transmission that comes in one day.
      The objectives are simple, and to be done as quietly as possible.
    `,
    INFILTRATOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Infiltrator;
