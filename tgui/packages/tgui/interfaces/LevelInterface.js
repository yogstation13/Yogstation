import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

export const LevelInterface = (props, context) => {
  const { act, data } = useBackend(context);
  const { alertLevel } = data;
  return (
    <Window width={500} height={172}>
      <Window.Content fontSize={2}>
        {alertLevel <= 2 ? (
          <Box>
            <Button
              minWidth={13}
              icon="thumbs-up"
              backgroundColor={alertLevel === 0 ? "#00aa00" : "#004400"}
              textColor={alertLevel === 0 ? "white" : "grey"}
              content={"Green"}
              onClick={() => act('set_level', {
                level_number: 0,
              })} />
            <Box inline fontSize={1} textColor={alertLevel === 0 ? "#ffffff" : "grey"}>
              No known active threats.
              <br />
              No random searches.
            </Box>
            <br />
            <Button
              minWidth={13}
              icon="magnifying-glass"
              backgroundColor={alertLevel === 1 ? "#0000ee" : "#000044"}
              textColor={alertLevel === 1 ? "white" : "grey"}
              content={"Blue"}
              onClick={() => act('set_level', {
                level_number: 1,
              })} />
            <Box inline fontSize={1} textColor={alertLevel === 1 ? "#ffffff" : "grey"}>
              Evidence of an active threat has been discovered.
              <br />
              Crew may be randomly searched.
            </Box>
            <br />
            <Button
              minWidth={13}
              icon="gun"
              backgroundColor={alertLevel === 2 ? "#dd0000" : "#440000"}
              textColor={alertLevel === 2 ? "white" : "grey"}
              content={"Red"}
              onClick={() => act('set_level', {
                level_number: 2,
              })} />
            <Box inline fontSize={1} textColor={alertLevel === 2 ? "#ffffff" : "grey"}>
              Deadly threat confirmed.
              <br />
              Security is to arm up and mobilize.
            </Box>
          </Box>
        ) : (
          <Box>
            <Button
              minWidth={13}
              icon="person-military-rifle"
              backgroundColor={alertLevel === 3 ? "#cc8400" : "#7f5200"}
              textColor={alertLevel === 3 ? "white" : "grey"}
              content={"Gamma"} />
            <Box inline fontSize={1} textColor={alertLevel === 3 ? "#ffffff" : "grey"}>
              The station is at risk of major asset loss.
              <br />
              Arm all capable personnel.
            </Box>
            <br />
            <Button
              minWidth={13}
              icon="explosion"
              backgroundColor={alertLevel === 5 ? "#800080" : "#400040"}
              textColor={alertLevel === 5 ? "white" : "grey"}
              content={"Delta"} />
            <Box inline fontSize={1} textColor={alertLevel === 5 ? "#ffffff" : "grey"}>
              Station destruction is imminent.
              <br />
              Martial law is in effect.
            </Box>
            <br />
            {alertLevel === 4 && (
              <Box>
                <Button
                  minWidth={13}
                  icon="eye-slash"
                  backgroundColor={"black"}
                  textColor="#56d5c9"
                  content="Epsilon" />
                <Box
                  inline
                  fontSize={1}
                  backgroundColor="transparent"
                  textColor="#56d5c9" >
                  <Box>
                    Authorities are arriving to negotiate new contracts.
                    <br />
                    Compliance is mandatory. Glory to Nanotrasen.
                  </Box>
                </Box>
              </Box>
            )}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
