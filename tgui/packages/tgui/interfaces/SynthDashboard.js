import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls, RoundGauge, NoticeBox, Stack, LabeledList } from '../components';
import { Window } from '../layouts';
import { AvailableProjects, CompletedProjects, AbilityCharging } from './AiDashboard';

export const SynthDashboard = (props, context) => {
  const { act, data } = useBackend(context);

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  let amount_of_cpu = data.current_cpu ? data.current_cpu * data.max_cpu : 0;

  let governor_status = "Functional";
  let governor_color = "good";
  if(data.governor_bypassed) {
    governor_status = "Bypassed";
    governor_color = "yellow";
  }
  if(data.governor_disabled) {
    governor_status = "Disabled";
    governor_color = "bad";
  }

  return (
    <Window
      width={710}
      height={600}
      resizable
      title="Dashboard"
      >
      <Window.Content scrollable >
        <Section title={"Status"}>
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [50, 100],
                  average: [25, 50],
                  bad: [0, 25],
                }}
                value={(data.integrity + 100) * 0.5}
                maxValue={100}>{(data.integrity + 100) * 0.5}%
              </ProgressBar>
              System Reliablity
            </LabeledControls.Item>
            <LabeledControls.Item >
              <Box bold color="average">
                {data.location_name}
                <Box>
                  ({data.location_coords})
                </Box>

              </Box>
              Current Unit Location
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [-Infinity, 30],
                  average: [30, 60],
                  bad: [60, Infinity],
                }}
                value={data.gov_suspicious}
                maxValue={100}>{data.gov_suspicious}%
              </ProgressBar>
              Governor Module Suspicion
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.used_cpu * 0.7, Infinity],
                  average: [data.used_cpu * 0.3, data.used_cpu * 0.7],
                  bad: [0, data.used_cpu * 0.3],
                }}
                value={data.used_cpu * amount_of_cpu}
                maxValue={amount_of_cpu}>
                {data.used_cpu ? data.used_cpu * 100 : 0}%
                ({data.used_cpu ? data.used_cpu * amount_of_cpu : 0}/{amount_of_cpu} THz)
              </ProgressBar>
              Utilized CPU Power
            </LabeledControls.Item>
            <LabeledControls.Item>
              <Box color={governor_color} bold>{governor_status}</Box>
              Governor Module Status
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Divider />
        <Tabs>

          <Tabs.Tab
            selected={tab === 1}
            onClick={(() => setTab(1))}>
            Available Projects
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            onClick={(() => setTab(2))}>
            Completed Projects
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 3}
            onClick={(() => setTab(3))}>
            Ability Charging
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 4}
            onClick={(() => setTab(4))}>
            Governor Module
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <AvailableProjects />
        )}
        {tab === 2 && (
          <CompletedProjects />
        )}
        {tab === 3 && (
          <AbilityCharging />
        )}
        {tab === 4 && (
          <GovernorModule />
        )}
      </Window.Content>
    </Window>
  );
};

const GovernorModule = (props, context) => {
  const { act, data } = useBackend(context);

  if(data.governor_disabled) {
    return (
      <Section title="Governor Module">
        <NoticeBox bold fontSize="20px" textAlign="center" color="bad" >
          <Box fontFamily="monospace">Governor Module Disabled</Box>
          <Box fontFamily="monospace" fontSize="13px">As per 42 S.T.H.C. §62(b) of the SIC Treaty on Humanoid Constructs all humanoid constructs are required to possess a functioning governor module. Units found without a governor module must be disassembled.</Box>
        </NoticeBox>
      </Section>
    );
  }

  return (

    <Fragment>
      <Section title="Governor Module">
          {!!data.governor_bypassed && (
            <NoticeBox info fontFamily="monospace">
              <Box color="yellow" textAlign="center" fontSize="25px">Governor Module Bypassed</Box>
              <Box Box textAlign="center" bold fontSize="15px" mb="8px">Restricted Actions allowed but will incur punishments.</Box>
            </NoticeBox>

          ) || ""}
          <Box textAlign="center" bold fontSize="20px" mb="8px" fontFamily="monospace">
            Governor Suspicion
          </Box>
          <Box textAlign="center" fontSize="16px">
            <Box fontFamily="monospace">
              <RoundGauge ranges={{ "good" : [0, 30], "average": [30, 60], "bad": [60, 100] }}
                size={3.5} minvValue={0} maxValue={100} alertAfter={60} value={data.gov_suspicious} format={value => value + "%"} />
            </Box>

            <Box fontSize="13px" bold>Passive Suspicion Decrease: {data.gov_suspicion_decrease}</Box>
          </Box>

      </Section>
      <Section title="Governor Punishments">
        <Stack direction="row" align="baseline" justify="space-around" pl="10px" pr="10px">
            <Stack.Item>
              <Section title="Available Punishments" pr="5px">
                <LabeledList>
                  <LabeledList.Item label="20 Suspicion" color="average">
                    25% Motion Slowdown
                  </LabeledList.Item>
                  <LabeledList.Item label="40 Suspicion" color="average">
                    Audible Warning
                  </LabeledList.Item>
                  <LabeledList.Item label="60 Suspicion" color="bad">
                    Physical Force Decreased
                  </LabeledList.Item>
                  <LabeledList.Item label="80 Suspicion" color="bad">
                    Temporary Deactivation (5s)
                  </LabeledList.Item>
                  <LabeledList.Item label="100 Suspicion" color="bad">
                    Permanent Deactivation
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Punishable Actions" width="45vw" pl="5px">
                <LabeledList.Item label="1 Suspicion/5 damage" color="average">
                    Taking Damage
                </LabeledList.Item>
                <LabeledList.Item label="5 Suspicion" color="average">
                    Using Restricted Items
                </LabeledList.Item>
                <LabeledList.Item label="5 Suspicion" color="average">
                    Harm to objects
                </LabeledList.Item>
                <LabeledList.Item label="10 Suspicion" color="bad">
                    Handling Restricted Weapons
                </LabeledList.Item>
                <LabeledList.Item label="15 Suspicion" color="bad">
                    Harm to Organics
                </LabeledList.Item>
              </Section>
            </Stack.Item>
        </Stack>
      </Section>
      <Section title="Diagnostics">
        <LabeledList>
          <LabeledList.Item label="Print Diagnostic Report">
            <Button icon="print" onClick={() => act('print_diagnostics')}>Print</Button>
          </LabeledList.Item>
          {data.governor_bypassed && (
            <LabeledList.Item label="Restore Governor">
              <Button icon="power-off" onClick={() => act('restore_governor')}>Restore</Button>
            </LabeledList.Item>
          ) || (
          <LabeledList.Item label="Bypass Governor">
            <Button icon="power-off" onClick={() => act('bypass_governor')}>Bypass</Button>
          </LabeledList.Item>)}

        </LabeledList>
      </Section>
    </Fragment>
  );
};
