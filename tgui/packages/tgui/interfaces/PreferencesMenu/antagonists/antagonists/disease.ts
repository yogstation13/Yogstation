import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const DISEASE_MECHANICAL_DESCRIPTION
   = multiline`
      Infect a host, and gain more points to acquire symptoms or upgrades as you infect more individuals.
      Avoid being cured, and do whatever it takes to reach Centcom in an active host to spread further.
   `;


const SentientDisease: Antagonist = {
  key: "disease",
  name: "Sentient Disease",
  description: [
    multiline`
      In the year 2517, most infectious agents have been cured or otherwise killed.
      With easy vaccine creation and distribution, it's typically only those who can't afford care that succumb to the monstrous bugs that develop.
      Enough resistance has resulted in the emergence of sentient infectors.
    `,
    DISEASE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default SentientDisease;
