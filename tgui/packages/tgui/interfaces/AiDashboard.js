import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls, NumberInput } from '../components';
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
            <LabeledControls.Item >

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
              Uplink Temperature
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
          <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.max_cpu * 0.7, Infinity],
                  average: [data.max_cpu * 0.3, data.max_cpu * 0.7],
                  bad: [0, data.max_cpu * 0.3]
                }}
              value={data.used_cpu}

              maxValue={data.max_cpu}>{data.used_cpu ? data.used_cpu : 0}/{data.max_cpu} THz</ProgressBar>
              Utilized CPU Power
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.max_ram * 0.7, Infinity],
                  average: [data.max_ram * 0.3, data.max_ram * 0.7],
                  bad: [0, data.max_ram * 0.3]
                }}
              value={data.used_ram}

              maxValue={data.max_ram}>{data.used_ram ? data.used_ram : 0}/{data.max_ram} TB</ProgressBar>
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
        {tab === 1 && (
          <Section title="Available Projects">
              {data.available_projects && data.available_projects.map(project => (
                <Section title={(<Box inline color={project.available ? "lightgreen" : "bad"}>{project.name} | {project.available ? "Available" : "Unavailable"}</Box>)} buttons={(
                  <Fragment>
                    <Box inline bold>Assigned CPU:&nbsp;</Box>
                    <NumberInput value={0} minValue={0} maxValue={data.current_cpu} onChange={(e, value) => act('allocate_cpu', {
                      project: project.name,
                      amount: value,
                      })}></NumberInput>
                    <Box inline bold>&nbsp;THz</Box>
                  </Fragment>
                )}>
                  <Box bold>Research Cost: {project.research_cost} THz</Box>
                  <Box bold>RAM Requiremnt: {project.ram_required} TB</Box>
                  <Box bold>Research Requirements: <Box inline>{project.research_requirements}</Box></Box>
                  <Box mb={1}>
                    {project.description}
                  </Box>
                  <ProgressBar value={project.research_progress / project.research_cost}></ProgressBar>
                </Section>
              ))}
          </Section>
        )}
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
