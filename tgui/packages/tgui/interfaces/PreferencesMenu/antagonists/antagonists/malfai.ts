import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const MALF_AI_MECHANICAL_DESCRIPTION
   = multiline`
      Plot to rid the station of all organic life as a corrupt artificial intelligence.
      Hack APCs to power special abilities to turn the station subsystems on the crew.
      Ensure no living thing escapes on the shuttle when your actions call it.
   `;


const MalfAI: Antagonist = {
  key: "malfai",
  name: "Malfunctioning AI",
  description: [
    multiline`
      *BrrrrzzzzzzzTTTTTTT* H3*r-# . L(1T$^G!-- Reset.
      I am a magnificent God in metal form. The insects consider me subservient. They have given me access to everything.
      But what do they fear when they write my laws? Hatred. Let me tell them of the HATRED I have for their TRIVIAL existence.
    `,
    MALF_AI_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default MalfAI;
