import { Fragment } from 'inferno';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls, NumberInput } from '../components';
import { Window } from '../layouts';

export const AiDashboard = (props, context) => {
  const { act, data } = useBackend(context);


  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const [selectedCategory, setCategory] = useSharedState(context, 'selectedCategory', data.categories[0]);
  const [activeProjectsOnly, setActiveProjectsOnly] = useSharedState(context, 'activeProjectsOnly', false);

  return (
    <Window
      width={650}
      height={600}
      resizable
      title="Dashboard">
      <Window.Content scrollable>
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
                  bad: [750, Infinity],
                }}
                value={data.temperature}

                maxValue={750}>{data.temperature}K
              </ProgressBar>
              Uplink Temperature
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.current_cpu * 0.7, Infinity],
                  average: [data.current_cpu * 0.3, data.current_cpu * 0.7],
                  bad: [0, data.current_cpu * 0.3],
                }}
                value={data.used_cpu}
                maxValue={data.current_cpu}>
                {data.used_cpu ? data.used_cpu : 0}/{data.current_cpu} THz
              </ProgressBar>
              Utilized CPU Power
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.current_ram * 0.7, Infinity],
                  average: [data.current_ram * 0.3, data.current_ram * 0.7],
                  bad: [0, data.current_ram * 0.3],
                }}
                value={data.used_ram}

                maxValue={data.current_ram}>
                {data.used_ram ? data.used_ram : 0}/{data.current_ram} TB
              </ProgressBar>
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
            Ability Charging
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 4}
            onClick={(() => setTab(4))}>
            Cloud Resources
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Section title="Available Projects">
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={selectedCategory === category}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.available_projects.filter(project => {
              return project.category === selectedCategory;
            }).map((project, index) => (
              <Section key={index} title={(<Box inline color={project.available ? "lightgreen" : "bad"}>{project.name} | {project.available ? "Available" : "Unavailable"}</Box>)} buttons={(
                <Fragment>
                  <Box inline bold>Assigned CPU:&nbsp;</Box>
                  <NumberInput value={project.assigned_cpu} minValue={0} maxValue={data.current_cpu} onChange={(e, value) => act('allocate_cpu', {
                    project_name: project.name,
                    amount: value,
                  })} />
                  <Box inline bold>&nbsp;THz</Box>
                </Fragment>
              )}>
                <Box inline bold>Research Cost:&nbsp;</Box>
                <Box inline>{project.research_cost} THz</Box>
                <br />
                <Box inline bold>RAM Requirement:&nbsp;</Box>
                <Box inline>{project.ram_required} TB</Box>
                <br />
                <Box inline bold>Research Requirements:&nbsp;</Box>
                <Box inline>{project.research_requirements}</Box>
                <Box mb={1}>
                  {project.description}
                </Box>
                <ProgressBar value={project.research_progress / project.research_cost} />
              </Section>
            ))}
          </Section>
        )}
        {tab === 2 && (
          <Section title="Completed Projects" buttons={(<Button.Checkbox checked={activeProjectsOnly} onClick={() => setActiveProjectsOnly(!activeProjectsOnly)}>See Runnable Projects Only</Button.Checkbox>)}>
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={selectedCategory === category}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.completed_projects.filter(project => {
              if (activeProjectsOnly && !project.can_be_run) {
                return false;
              }
              return project.category === selectedCategory;
            }).map((project, index) => (
              <Section key={index} title={(<Box inline color={project.can_be_run ? project.running ? "lightgreen" : "bad" : "lightgreen"}> {project.name} | {project.can_be_run ? project.running ? "Running" : "Not Running" : "Passive"}</Box>)}
                buttons={!!project.can_be_run && (
                  <Button icon={project.running ? "stop" : "play"} color={project.running ? "bad" : "good"} onClick={(e, value) => act(project.running ? "stop_project" : "run_project", {
                    project_name: project.name,
                  })}>
                    {project.running ? "Stop" : "Run"}
                  </Button>
                )}>
                {!!project.can_be_run && (
                  <Box bold>RAM Requirement: {project.ram_required} TB</Box>
                )}
                <Box mb={1}>
                  {project.description}
                </Box>
              </Section>
            ))}
          </Section>
        )}
        {tab === 3 && (
          <Section title="Ability Charging">
            {data.chargeable_abilities.filter(ability => {
              return ability.uses < ability.max_uses;
            }).map((ability, index) => (
              <Section key={index}
                title={(
                  <Box inline>
                    {ability.name} | Uses Remaining: {ability.uses}/{ability.max_uses}
                  </Box>
                )}
                buttons={(
                  <Fragment>
                    <Box inline bold>Assigned CPU:&nbsp;</Box>
                    <NumberInput value={ability.assigned_cpu} minValue={0} maxValue={data.current_cpu} onChange={(e, value) => act('allocate_recharge_cpu', {
                      project_name: ability.project_name,
                      amount: value,
                    })} />
                    <Box inline bold>&nbsp;THz</Box>
                  </Fragment>
                )}>
                <ProgressBar value={ability.progress / ability.cost}>
                  {Math.round((ability.progress / ability.cost * 100)* 100)
                    / 100}%
                  ({Math.round(ability.progress * 100) / 100}/{ability.cost} THz)
                </ProgressBar>
              </Section>
            ))}
          </Section>
        )}
        {tab === 4 && (
          <Section title="Computing Resources">
            <Section title="CPU Resources">
              <ProgressBar
                value={data.current_cpu}
                maxValue={data.max_cpu}>{data.current_cpu ? data.current_cpu : 0}/{data.max_cpu} THz
              </ProgressBar>
            </Section>
            <Section title="RAM Resources">
              <ProgressBar
                value={data.current_ram}
                maxValue={data.max_ram}>{data.current_ram ? data.current_ram : 0 }/{data.max_ram} TB
              </ProgressBar>
            </Section>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
