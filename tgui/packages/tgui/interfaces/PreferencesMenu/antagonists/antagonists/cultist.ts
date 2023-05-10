import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Cultist: Antagonist = {
  key: "cultist",
  name: "Cultist",
  description: [
    multiline`
      It begins as a pulsing of your veins. The blood quickens, then grows bright and then dark. You will kill in the name of the Geometer, but you will also beckon more into her crimson flock. Most of all, you will see her returned beyond the Veil. Here, it is weakened. Now, you will act.
    `,

    multiline`
     Conspire with other blood cultists to convert other crew and take over the station. Track down your sacrifice target, kill them via ritual, then call upon Nar-Sie where the Veil is weak. Defend her crystals until she is ready, and witness her glory rip into our dimension.
    `,
  ],
  category: Category.Roundstart,
};

export default Cultist;
