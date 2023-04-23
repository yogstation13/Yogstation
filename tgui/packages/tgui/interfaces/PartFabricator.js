import { useBackend, useLocalState } from '../backend';
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
    manipulator_plant, // String
    manipulator_plant_num, // Number
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
    current_plants, // Number
    current_temp, // Number
    // Variable, progress in printing
    production_progress,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);
  return (
    <Window width={480} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
                >
                Capacitor
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
                >
                Matter Bin
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 3}
                onClick={() => setTabIndex(3)}
                >
                Scanner
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 4}
                onClick={() => setTabIndex(4)}
                >
                Laser
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 5}
                onClick={() => setTabIndex(5)}
                >
                Manipulator
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section title={"Requirements"}>
              {tabIndex === 1 && (
                <Box>
                  Electrical stasis manifolds: {current_ESMs}/1{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectESM')}>Eject</Button>
                  <ProgressBar
                    value={current_ESMs/1}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                  <br />
                  <br />
                  Energy in grid:{" "}
                  {formatPower(current_energy)} / {formatPower(capacitor_energy)}
                  <ProgressBar
                    value={current_energy/capacitor_energy}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                </Box>
                )}
              {tabIndex === 2 && (
                <Box>
                  Organic Augurs: {current_augurs}/1{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectAugur')}>Eject</Button>
                  <ProgressBar
                    value={current_augurs/1}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                  <br />
                  <br />
                  Freon:{" "}
                  {toFixed(current_moles, 3)} moles / {toFixed(matterbin_moles, 3)} moles
                  <ProgressBar
                    value={current_moles/matterbin_moles}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                </Box>
                )}
              {tabIndex === 3 && (
                <Box>
                  {current_posibrain}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectPosi')}>Eject</Button>
                  <ProgressBar
                    value={current_posibrain === "Artificial brain active"}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                  <br />
                  <br />
                  {scanner_chemicals.map((chem, reqindex) =>
                    (<Box key={reqindex}>
                      {current_reagents_num[current_reagents.findIndex((e) => e === chem)] || "0"}/{scanner_chemicals_num[reqindex]}u of {chem}{" "}
                      <Button color="bad" icon="eject" onClick={(e, value) => act('flushChems')}>Flush</Button>
                      <ProgressBar
                        value={
                          current_reagents_num[current_reagents.findIndex((e) => e === chem)]/scanner_chemicals_num[reqindex] || "0"
                        }
                        ranges={{
                          good: [1, Infinity],
                          average: [0.5, 1],
                          bad: [-Infinity, 0.5],
                        }}
                        />
                      <br />
                      <br />
                     </Box>)
                  )}
                </Box>
                )}
              {tabIndex === 4 && (
                <Box>
                  {current_lasergun}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectLaserGun')}>Eject</Button>
                  <ProgressBar
                    value={current_lasergun === "Laser gun loaded"}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                  <br />
                  <br />
                  Money: {current_money}/{laser_money} credits{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectMoney')}>Eject</Button>
                  <ProgressBar
                    value={current_money/laser_money}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                </Box>
                )}
              {tabIndex === 5 && (
                <Box>
                  {manipulator_plant}: {current_plants}/{manipulator_plant_num}{" "}
                  <Button color="bad" icon="eject" onClick={(e, value) => act('ejectPlants')}>Eject</Button>
                  <ProgressBar
                    value={current_plants/manipulator_plant_num}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
                  <br />
                  <br />
                  Temperature:{"  "}
                  {Math.round((current_temp + Number.EPSILON) * 1000) / 1000}
                  /
                  {Math.round((manipulator_temp + Number.EPSILON) * 1000) / 1000} Kelvin
                  <ProgressBar
                    value={current_temp/manipulator_temp}
                    ranges={{
                      good: [1, Infinity],
                      average: [0.5, 1],
                      bad: [-Infinity, 0.5],
                    }}
                    />
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
                onClick={() => act('tryPrint', {tab:tabIndex})} />
            )
            :
            (
              <ProgressBar value={production_progress/100} />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
