import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const OBSESSED_MECHANICAL_DESCRIPTION
   = multiline`Avoid the fugitive hunters sent after you with any allies if you have them, and make sure you stay free by the time the shift ends.
   `;

const Obsessed: Antagonist = {
  key: "obsessed",
  name: "Obsessed",
  description: [
    multiline`
    Beauty is often misunderstood. Fate even more so.
    The others, your colleagues, they don't- they don't hear the voices that whisper sense.
    Maybe someday, you'll hear them too, and you'll realize just how important you are.
    Don't try to flee. You can't.
    `,
    OBSESSED_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Obsessed;
