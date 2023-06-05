import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const REVOLUTIONARY_MECHANICAL_DESCRIPTION
   = multiline`
      Turn ordinary crew members to your side by using a flash to turn them into revolutionaries, then work together to kill or exile all heads of staff off of the station.
      Make sure you do not suffer a similar fate; the revolution depends on you.
   `;


const HeadRevolutionary: Antagonist = {
  key: "headrevolutionary",
  name: "Head Revolutionary",
  description: [
    multiline`
      While other Syndicate agents might work in subterfuge or brutality, yours is one of insurrection.
      Possessing specialized training, you are capable of flashing anti-corporate beliefs onto other's minds through rapid-image exposure.
      The station's downfall will be its own crew.
    `,
    REVOLUTIONARY_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default HeadRevolutionary;
