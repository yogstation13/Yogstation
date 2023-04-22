import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const OPERATIVE_MECHANICAL_DESCRIPTION
   = multiline`
      Plan an assault of the station with other elite operatives and purchase your gear accordingly.
      Kill the disk holder, anchor and arm the stolen nuclear device to the station, and return back to the base.
   `;


const Operative: Antagonist = {
  key: "operative",
  name: "Nuclear Operative",
  description: [
    multiline`
      Congratulations, agent. Your performance lately has exceeded all expectations.
      You will report to a Gorlex team on one of our covert bases.
      The mission is simple; you are to steal the authentication device, deliver the payload, and exfiltrate before the payload detonates.
    `,
    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Operative;
