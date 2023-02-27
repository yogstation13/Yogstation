import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const CLOWNOP_MECHANICAL_DESCRIPTION
   = multiline`
      Plan an attack on the station in this parallel to Nuclear Operative.
			Utilize clown technology and specialized gear to best the crew, secure the disk, and detonate the device.
   `;


const ClownOperative: Antagonist = {
  key: "clownoperative",
  name: "Clown Operative",
  description: [
    multiline`
      HONK! The operation is simple. Move in. Prank.
			Detonate the bananium device and summon the Honkmother.
			The Clown Planet depends on you!
    `,
    CLOWNOP_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default ClownOperative;
