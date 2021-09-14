import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls } from '../components';
import { Window } from '../layouts';

export const AiDashboard = (props, context) => {
  const { act, data } = useBackend(context);

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  return (
    <Window
      width={650}
      height={450}
      resizable
      title="Dashboard">
      <Window.Content scrollable>
        <Section title={"Status"}>
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
              ranges = {{
                good: [50, 100],
                average: [25, 50],
                bad: [0, 25]
              }}

              value={(data.integrity + 100) * 0.5}
              maxValue={100}>{(data.integrity + 100) * 0.5}%</ProgressBar>
            System Integrity
            </LabeledControls.Item>
            <LabeledControls.Item>

             <Box bold color="average">
              {data.location_name}
              <Box>
                ({data.location_coords})
              </Box>

              </Box>

              Current Uplink Location
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity]
                }}
              value={data.temperature}

              maxValue={750}>{data.temperature}K</ProgressBar>
              Current Uplink Temperature
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
          <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity]
                }}
              value={data.temperature}

              maxValue={750}>{data.temperature}K</ProgressBar>
              Utilized CPU Power
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity]
                }}
              value={data.temperature}

              maxValue={750}>{data.temperature}K</ProgressBar>
              Utilized RAM Capacity
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
            Cloud Resources
          </Tabs.Tab>
        </Tabs>
        {tab === 3 && (
            <Section title="Computing Resources">
              <Section title="CPU Resources">
                <ProgressBar
                  value={data.current_cpu}
                maxValue={data.max_cpu}>{data.current_cpu ? data.current_cpu : 0}/{data.max_cpu} THz</ProgressBar>
              </Section>
              <Section title="RAM Resources">
                <ProgressBar
                value={data.current_ram}
                maxValue={data.max_ram}>{data.current_ram ? data.current_ram : 0 }/{data.max_ram} TB</ProgressBar>
              </Section>
            </Section>
        )}


      </Window.Content>
    </Window>
  );
};
