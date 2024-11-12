import { Section, Box, LabeledList } from '../components';
import { Window } from '../layouts';

export const BarDrone = () => {
  return (
    <Window title="Drone Information" width={600} height={320}>
      <Section title="">
        <Box color="red" fontSize="18px" margin="5px 0">
          <b>
            DO NOT INTERFERE WITH THE ROUND AS A DRONE OR YOU WILL BE DRONE
            BANNED
          </b>
        </Box>
        <Box fontSize="14px" margin="5px 0" color="#ffffff">
          Drones are a ghost role that are allowed to fix the station and build
          things. Interfering with the round as a drone is against the rules.
        </Box>
        <Box fontSize="14px" color="#ffffff" margin="5px 0">
          Actions that constitute interference include, but are not limited to:
        </Box>
        <LabeledList>
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
            If you do not have the regular drone laws, follow your laws to the
            best of your ability.
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
