import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const OBSESSED_MECHANICAL_DESCRIPTION
   = multiline`
      Protect and be with the target of your obsession, but be careful not to let your mania show.
      Follow the Voices' beckoning, and keep your target on the station with you, forever.
   `;


const Obsessed: Antagonist = {
  key: "obsessed",
  name: "Obsessed",
  description: [
    multiline`
      Beauty is often misunderstood. Fate even more so. The others, your colleagues, they don't- they don't hear the voices that whisper sense.
      Maybe someday, you'll hear them too, and you'll realize just how important you are.
      Don't try to flee. You can't.
    `,
    OBSESSED_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Obsessed;
