import { Section, Box, LabeledList } from '../components';
import { Window } from '../layouts';

export const BarDrone = () => {
  return (
    // MONKESTATION EDIT START
    // <Window title="Drone Information" width={600} height={320}>
    <Window title="Bar Drone Information" width={600} height={522}>
      {/* MONKESTATION EDIT END */}
      <Section title="">
        <Box color="red" fontSize="18px" margin="5px 0">
          <b>
            {/* MONKESTATION EDIT START */}
            {/* DO NOT INTERFERE WITH THE ROUND AS A DRONE OR YOU WILL BE DRONE
            BANNED */}
            DO NOT INTERFERE WITH THE ROUND OUTSIDE OF YOUR LAWS AS A BARDRONE
            OR YOU WILL BE DRONE BANNED
            {/* MONKESTATION EDIT END */}
          </b>
        </Box>
        <Box fontSize="14px" margin="5px 0" color="#ffffff">
          {/* MONKESTATION EDIT START */}
          {/* Drones are a ghost role that are allowed to fix the station and build
          things. Interfering with the round as a drone is against the rules. */}
          Bar Drones are a ghost role designed to serve drinks, entertain
          patrons, and maintain their bar. Actions outside of your laws and
          guidelines are against the rules.
          {/* MONKESTATION EDIT END */}
        </Box>
        <Box fontSize="14px" color="#ffffff" margin="5px 0">
          Actions that constitute interference include, but are not limited to:
        </Box>
        <LabeledList>
          {/* MONKESTATION EDIT START*/}
          {/*
           <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Interacting with round-critical objects (IDs, weapons,
              contraband, powersinks, bombs, etc.)
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Interacting with living beings (communication, attacking,
              healing, etc.)
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Interacting with non-living beings (dragging bodies, looting
              bodies, etc.)
            </Box>
          </LabeledList.Item>
           */}
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Harming sapient creatures (attacking, poisoning, or any form of
              intentional harm).
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Interacting with non-conscious individuals (dead, passed out, or
              SSD). Call for medical assistance instead.
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Getting involved in altercations (fights, disputes, or
              conflicts). Remove yourself from these situations.
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Protecting the bar from aggressors (do not play security or
              attempt to defend the bar).
            </Box>
          </LabeledList.Item>
        </LabeledList>
        <Box fontSize="14px" margin="10px 0" color="#ffffff">
          <b>Guidelines for Bar Drones:</b>
        </Box>
        <LabeledList>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Serve drinks and interact with patrons.
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Operate only at a bar with the permission of its users or
              owners.
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - You may create your own bar if you have permission from a
              relevant head of staff. Do not monopolize station resources.
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="">
            <Box fontSize="14px" color="#ffffff">
              - Focus on maintaining the integrity of the bar. Keep it clean,
              operational, and welcoming.
            </Box>
          </LabeledList.Item>
          {/* MONKESTATION EDIT END */}
        </LabeledList>
        <Box color="red" fontSize="14px" margin="10px 0">
          These rules are at admin discretion and will be heavily enforced.
        </Box>
        <Box
          color="red"
          fontSize="14px"
          margin="10px 0"
          textDecoration="underline, bold"
        >
          <b>
            {/* MONKESTATION EDIT START */}
            {/* If you do not have the regular drone laws, follow your laws to the
            best of your ability. */}
            If you have questions about these rules, AHELP for clarification.
            {/* MONKESTATION EDIT END */}
          </b>
        </Box>
        <Box fontSize="14px" color="#ffffff" margin="5px 0">
          Prefix your message with <b>:b</b> to speak in Drone Chat.
        </Box>
        <Box fontSize="14px" color="#ffffff" margin="5px 0">
          Drone Rules and more info can be found at our wiki{' '}
          <a href="https://wiki.monkestation.com/en/jobs/non-human/drone">
            HERE
          </a>
          .
        </Box>
      </Section>
    </Window>
  );
};
