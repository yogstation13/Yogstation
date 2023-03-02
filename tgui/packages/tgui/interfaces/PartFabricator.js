import { useBackend } from '../backend';
import { Button, Box, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const PartFabricator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    // Static, generated requirements
    capacitor_energy, // Number
    matterbin_moles, // Number
    scanner_chemicals = [], // Array of Strings
    scanner_chemicals_num = [], // Array of Numbers
    laser_money, // Number
    manipulator_temp, // Number
    // Variable, current tab we're on
    tab, // String
    // Variable, for display
    current_ESMs, // Number
    current_energy, // Number
    current_augurs, // Number
    current_moles, // Number
    current_posibrain, // String
    current_reagents = [], // Array of Strings
    current_reagents_num = [], // Array of Numbers
    current_lasergun, // String
    current_money, // Number
    current_organs, // String
    current_organs_num, // Number (0-1)
    current_temp, // Number
    // Variable, progress in printing
    production_progress,
  } = data;
  const tabTitle = {
    "capacitor":"Cubic Capacitor",
    "matterbin":"Matter Bin of Holding",
    "scanner":"Hexaphasic Scanning Module",
    "laser":"Quint-Hyper Micro-Laser",
    "manipulator":"Planck-Manipulator",
  };
  return (
    <Window width={480} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === "capacitor"}
                onClick={() => act('goCapacitor')}
                >
                Capacitor
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "matterbin"}
                onClick={() => act('goMatterBin')}
                >
                Matter Bin
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "scanner"}
                onClick={() => act('goScanner')}
                >
                Scanner
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "laser"}
                onClick={() => act('goLaser')}
                >
                Laser
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === "manipulator"}
                onClick={() => act('goManipulator')}
                >
                Manipulator
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section title={"Requirements"}>
              {tab === "capacitor" && (
                <Box>
                  Electrical stasis manifolds: {current_ESMs}/1{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar value={current_ESMs/1} />
                  <br />
                  <br />
                  Energy in grid:{" "}
                  {Math.round((current_energy/1000000000 + Number.EPSILON) * 1000) / 1000}
                  /
                  {Math.round((capacitor_energy/1000000000 + Number.EPSILON) * 1000) / 1000} GW
                  <ProgressBar value={current_energy/capacitor_energy} />
                </Box>
                )}
              {tab === "matterbin" && (
                <Box>
                  Organic Augurs: {current_augurs}/1{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar value={current_augurs/1} />
                  <br />
                  <br />
                  Freon:{" "}
                  {Math.round((current_moles + Number.EPSILON) * 1000) / 1000}
                  /
                  {Math.round((matterbin_moles + Number.EPSILON) * 1000) / 1000} moles
                  <ProgressBar value={current_moles/matterbin_moles} />
                </Box>
                )}
              {tab === "scanner" && (
                <Box>
                  {current_posibrain}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar value={current_posibrain === "Artificial brain active"} />
                  <br />
                  <br />
                  {scanner_chemicals.map((chem, reqindex) =>
                    (<Box key={reqindex}>
                      {scanner_chemicals_num[reqindex]}u of {chem}{" "}
                      <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Flush Reagents</Button>
                      <ProgressBar
                        value={
                          current_reagents_num[current_reagents.findIndex((e) => e === chem)]/scanner_chemicals_num[reqindex] || "0"
                        }
                        />
                      <br />
                      <br />
                     </Box>)
                  )}
                </Box>
                )}
              {tab === "laser" && (
                <Box>
                  {current_lasergun}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar value={current_organs_num} />
                  <br />
                  <br />
                  Money: {current_money}/{laser_money} credits
                  <ProgressBar value={current_money/laser_money} />
                </Box>
                )}
              {tab === "manipulator" && (
                <Box>
                  {current_organs}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar value={current_ESMs/1} />
                  <br />
                  <br />
                  Temperature:{"  "}
                  {Math.round((current_temp + Number.EPSILON) * 1000) / 1000}
                  /
                  {Math.round((manipulator_temp + Number.EPSILON) * 1000) / 1000} Kelvin
                  <ProgressBar value={current_temp/manipulator_temp} />
                </Box>
                )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            {production_progress <= 0 ?
            (
              <Button
                fluid
                content="PRINT"
                onClick={() => act('tryPrint')} />
            )
            :
            (
              <ProgressBar value={production_progress} />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
