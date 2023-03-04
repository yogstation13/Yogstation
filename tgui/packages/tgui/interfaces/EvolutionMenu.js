import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, Collapsible, Box, ProgressBar, Section, NoticeBox, Tabs, Flex } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';

export const EvolutionMenu = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  return (
    <Window
      width={620}
      height={580}
      theme="zombie"
      resizable>
      <Window.Content scrollable>
        <Tabs vertical>
          <Tabs.Tab
            icon="brain"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Host Status
          </Tabs.Tab>
          <Tabs.Tab
            icon="dna"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Host Genetic Management
          </Tabs.Tab>
          <Tabs.Tab
            icon="biohazard"
            lineHeight="23px"
            selected={tab === 3}
            onClick={() => setTab(3)}>
            Research Matrix
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <HostStatus />
        )}
        {tab === 2 && (
          <GeneticManagement />
        )}
        {tab === 3 && (
          <ResearchMatrix />
        )}
      </Window.Content>
    </Window>
  );
};

const HostStatus = (props, context) => {
  const { data } = useBackend(context);
  const {
    mutation_rate,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Mutation Rate">
          <ProgressBar
            value={mutation_rate}
            minValue={0}
            maxValue={4}
            ranges={{
              good: [0],
              average: [2],
              bad: [4],
            }} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GeneticManagement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mutations,
    mutation_points,
  } = data;
  return (
    <Section title="Mutations">
      <Box>Available Points: {mutation_points}</Box>
      <LabeledList>
        {mutations.map(mutation => (

          <LabeledList.Item label={mutation.name} key={mutation.name}>
            <Box>{mutation.desc}</Box>
            <Box>Cost to unlock: {mutation.mutation_cost}</Box>
            <Button
              selected={mutation.owned}
              disabled={!mutation.can_purchase}
              onClick={() => act('upgrade', {
                'id': mutation.id,
              })}
              content={mutation.owned ? "Mutated" : "Mutate"}
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const ResearchMatrix = (props, context) => {
  const { data } = useBackend(context);
  const {
    info_abilities,
    abilities,
  } = data;
  return (
    <Fragment>
      <Collapsible
        key="GameplayInfo"
        title="Gameplay Info"
        width="300px" >
        <Section>
            {`As a frail piece of a former eldritch horror,<br />
            you cannot fully control your targets without damaging their brains nor suck their souls.<br />
            As a means to fully rebuild yourself you have decided to extract DNA from the cognizant beings resided on the station,<br />
            using your adaptative form to produce spores to help you on your harvest.<br />
            * Your objective as a zombie is to infect as many people as possible, using Alt-click to slowly infect an alive person, and rapidly infect a crit/sleep or dead one.<br />
            * In the top right you are able to use your communicate ability to talk with your fellow monsters to coordinate hatching spots and possible class combinations.<br />
            * After zombifying, you'll be equipped with the evolution button, which lets you choose beetween 5 classes, all focused on one type of playstyle.<br />
            * These classes grant you different passives, unlocks new abilities to mutate and perks to your claws that can be explained further by examining them.`}
        </Section>
      </Collapsible>
      <Collapsible
        key="AbilityInfo"
        title="Ability Info"
        width="300px" >
        <Section>
        {info_abilities}
          <LabeledList>
          {abilities.map(ability => (
            <LabeledList.Item label={ability.name} key={ability.name}>
              <Box>{ability.desc}</Box>
              <Box>{ability.cost}</Box>
              <Box>{ability.constant_cost}</Box>
            </LabeledList.Item>
          ))}
          </LabeledList>
        </Section>
      </Collapsible>
    </Fragment>
  );
};
