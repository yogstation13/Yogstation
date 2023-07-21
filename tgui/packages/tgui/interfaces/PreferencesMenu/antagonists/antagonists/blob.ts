import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const BLOB_MECHANICAL_DESCRIPTION
   = multiline`
      Spawn onto the station in a location of your choosing and plan to expand enough to reach critical mass.
      Manage resources, expansion, blobbernauts, and the threat of the crew simultaneously.
   `;


const Blob: Antagonist = {
  key: "blob",
  name: "Blob",
  description: [
    multiline`
      "The mass, while primarily undetailed and smooth in appearance, is actually made up of several neurons that are capable of rapidly self-producing.
      It can almost instantly change its properties in response to external threats and seems only to be motivated by a need to expand."
    `,
    BLOB_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Blob;
