import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls, NumberInput, Input, LabeledList, Flex } from '../components';
import { Window } from '../layouts';

export const AiDashboard = (props, context) => {
  const { act, data } = useBackend(context);

  const [search, setSearch] = useLocalState(context, 'search', null);
  const [searchCompleted, setSearchCompleted] = useLocalState(context, 'searchCompleted', null);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const [selectedCategory, setCategory] = useLocalState(context, 'selectedCategory', data.categories[0]);
  const [activeProjectsOnly, setActiveProjectsOnly] = useLocalState(context, 'activeProjectsOnly', true);

  let remaining_cpu = (1 - data.used_cpu) * 100;
  let amount_of_cpu = data.current_cpu ? data.current_cpu * data.max_cpu : 0;

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
          <Section title="Available Projects" buttons={(
            <Input
              value={search}
              placeholder="Search.."
              onInput={(e, value) => setSearch(value)} />
          )}>
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={!search ? selectedCategory === category : null}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.available_projects.filter(project => {
              if (search) {
                const searchableString = String(project.name).toLowerCase();
                return searchableString.match(new RegExp(search, "i"));
              }
              return project.category === selectedCategory;
            }).map((project, index) => (
              <Section key={index} title={(<Box inline color={project.available ? "lightgreen" : "bad"}>{project.name} | {project.available ? "Available" : "Unavailable"}</Box>)} buttons={(
                <Fragment>
                  <Box inline bold>Assigned CPU:&nbsp;</Box>
                  <NumberInput unit="%" value={project.assigned_cpu*100} minValue={0} maxValue={remaining_cpu + (project.assigned_cpu * 100)} onChange={(e, value) => act('allocate_cpu', {
                    project_name: project.name,
                    amount: Math.round((value / 100) * 100) / 100,
                  })} />
                  <Button icon="arrow-up" disabled={data.used_cpu === 1} onClick={(e, value) => act('max_cpu', {
                    project_name: project.name,
                  })}>Max
                  </Button>
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
                <ProgressBar value={project.research_progress / project.research_cost}>
                  {Math.round((project.research_progress / project.research_cost * 100)* 100)
                    / 100}%
                  ({Math.round(project.research_progress * 100) / 100}/{project.research_cost} THz)
                </ProgressBar>
              </Section>
            ))}
          </Section>
        )}
        {tab === 2 && (
          <Section title="Completed Projects" buttons={(
            <Fragment>
              <Button.Checkbox checked={activeProjectsOnly}
                onClick={() => setActiveProjectsOnly(!activeProjectsOnly)}>
                See Runnable Projects Only
              </Button.Checkbox>
              <Input value={searchCompleted} placeholder="Search.." onInput={(e, value) => setSearchCompleted(value)} />
            </Fragment>
          )}>
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={!searchCompleted ? selectedCategory === category : null}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.completed_projects.filter(project => {
              if (searchCompleted) {
                const searchableString = String(project.name).toLowerCase();
                return searchableString.match(new RegExp(searchCompleted, "i"));
              }
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
                    <NumberInput value={ability.assigned_cpu} minValue={0} maxValue={remaining_cpu + (ability.assigned_cpu * 100)} onChange={(e, value) => act('allocate_recharge_cpu', {
                      project_name: ability.project_name,
                      amount: Math.round((value / 100) * 100) / 100,
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
            <Section title="Networked Resources"
              buttons={(
                <Button icon="trash" onClick={() => act("clear_ai_resources")}>Clear AI Resources</Button>
              )}>
              <LabeledList.Item>
                CPU Capacity:
                <Flex>
                  <ProgressBar minValue={0} value={data.current_cpu}
                    maxValue={1} >{amount_of_cpu} THz
                  </ProgressBar>
                  <NumberInput width="60px" unit="%" value={data.current_cpu * 100} minValue={0} maxValue={100} onChange={(e, value) => act('set_cpu', {
                    amount_cpu: Math.round((value / 100) * 100) / 100,
                  })} />
                  <Button height={1.75} icon="arrow-up" onClick={() => act("max_cpu_assign")}>Max
                  </Button>
                </Flex>

              </LabeledList.Item>
              <LabeledList.Item>
                RAM Capacity:
                <Flex>
                  <ProgressBar minValue={0} value={data.current_ram}
                    maxValue={data.max_ram} >{data.current_ram} TB
                  </ProgressBar>
                  <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_ram")} />
                  <Button height={1.75} icon="minus" onClick={() => act('remove_ram')} />
                </Flex>

              </LabeledList.Item>
            </Section>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
