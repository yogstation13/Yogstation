import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Tabs, Button, BlockQuote, Flex } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { ObjectivePrintout, Objective, ReplaceObjectivesButton } from './common/Objectives';

const Velvet = {
  fontWeight: 'bold',
  color: '#7264FF',
};

const Lucidity = {
  fontWeight: 'bold',
  color: '#00AAFF',
};

type Data = {
  categories: Category[];
};

type Category = {
  name: String;
  knowledgeData: Knowledge[];
};

type Knowledge = {
  path: string;
  name: string;
  desc: string;
  lore_description: string;
  cost: number;
  disabled: boolean;
  menutab: string;
  infinite: boolean;
  icon: string;
};

type Classes = {
  classData: Class[];
}

type Class = {
  path: string;
  name: string;
  description: string;
  long_description: string;
  color: string;
}

type Info = {
  willpower: number;
  lucidity_drained: number;
  divulged: BooleanLike;
  ascended: BooleanLike;
  max_thralls: number;
  current_thralls: number;
  has_class: BooleanLike;
  objectives: Objective[];
  categories: Category[];
  thrall_names: string[];
};

export const AntagInfoDarkspawn = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { divulged, has_class } = data;

  const [currentTab, setTab] = useLocalState(context, 'currentTab', 0);

  return (
    <Window width={750} height={650}>
      <Window.Content
        style={{
          'background-image': 'none',
          'background': 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}>
        <Stack vertical fill>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}>
                Information
              </Tabs.Tab>
              {!!divulged && !!has_class && (
                <Tabs.Tab
                  icon={currentTab === 1 ? 'book-open' : 'book'}
                  selected={currentTab === 1}
                  onClick={() => setTab(1)}>
                  Research
                </Tabs.Tab>
              )}
              {!has_class && (
                <Tabs.Tab
                  icon={currentTab === 2 ? 'book-open' : 'book'}
                  selected={currentTab === 2}
                  onClick={() => setTab(2)}>
                  Class Selection
                </Tabs.Tab>
              )}
            </Tabs>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || (currentTab === 1 && <ResearchInfo />) || <ClassSelection />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (props, context) => {
  const { data, act } = useBackend<Info>(context);
  const { objectives, ascended } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="You are the Darkspawn!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
            <Stack.Divider />
            {!ascended && (
              <Stack.Item>
                <ObjectivePrintout
                  fill
                  titleMessage={
                    'In order to ascend, you have these tasks to fulfill'
                  }
                  objectives={objectives}
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack vertical textAlign="center" fontSize="14px">
      <i>
        <Stack.Item>
            Eternity spent dormant, floating in an <span style={Velvet}>endless void</span>.
        </Stack.Item>
        <Stack.Item>
            Ripples herald chaos as a <span style={Lucidity} >bright blue light</span> tears you from your slumber.&nbsp;
        </Stack.Item>
        <Stack.Item>
            As you plunge into normalspace, you violently <span style={Velvet}>curse</span> the being that caused such an event.&nbsp;
        </Stack.Item>
        <Stack.Item>
            You quickly fashion a <span style={{ "color":"#FF0000" }} >crude facsimile</span> of the lifeforms nearby.
        </Stack.Item>
        <Stack.Item>
            It won&apos;t last long, but it&apos;s enough to trick these fools.
        </Stack.Item>
      </i>
      <Stack.Item fontSize="20px">
        <b>
          <span style={Velvet}>Nullspace</span> awaits your return.
        </b>
      </Stack.Item>
    </Stack>
  );
};

const GuideSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { has_class } = data;

  return (
    <Stack vertical fontSize="16px">
      <Stack.Item>
        - Collaborate with fellow darkspawns, use .w to converse using the mindlink.
      </Stack.Item>
      {!has_class && (
      <Stack.Item>
        - Select a class in the selection tab to decide what kind of gameplay you want.
      </Stack.Item>
      )}
      <Stack.Item>
        - Incapacitate crewmembers and devour their will to gain <span style={Lucidity}>lucidity</span> and <span style={Velvet}>willpower</span>.
      </Stack.Item>
      <Stack.Item>
        - Spend <span style={Velvet}>willpower</span> in the research tab to unlock new abilities and passive skills.
      </Stack.Item>
      <Stack.Item>
        - Once a certain amount <span style={Lucidity}>lucidity</span> has been drained, perform the sacrament and ascend as a progenitor.
      </Stack.Item>
    </Stack>
  );
};

const InformationSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { willpower, lucidity_drained, ascended, current_thralls, max_thralls, thrall_names } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>You have</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ASCENDED
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          You have <b>{willpower || 0}</b>&nbsp;
          <span style={Velvet}>
            willpower
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          You have drained a total of&nbsp;
          <b>{lucidity_drained || 0}</b>&nbsp;
          <span style={Lucidity}>lucidity</span>.
        </Stack.Item>
        {!!max_thralls && (
        <Stack.Item>
          You currently have <b>{current_thralls || 0}/{max_thralls || 0}</b>&nbsp;
          <span style={Velvet}>
            thralls
          </span>
          .
        </Stack.Item>
        )}
        {!!current_thralls && !!thrall_names && (
        <Stack.Item>
          They are:
          {thrall_names.map(thrall => (
            <Stack.Item key={thrall}>{capitalize(thrall)}</Stack.Item>
          ))}
        </Stack.Item>
        )}
      </Stack>
    </Stack.Item>
  );
};

// Research tab
const ResearchInfo = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const { willpower, categories = [] } = data;

  const [selectedKnowledge, setSelectedKnowledge] = useLocalState<Knowledge | null>(context, "knowledge", null);

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item fontSize="18px" textAlign="center">
            You have <b>{willpower || 0}</b>&nbsp;
            <span style={Velvet}>
              willpower
            </span>{' '}
            to spend.
          </Stack.Item>

          <Stack
            m={1}
            fill>
            <Stack.Item grow={1} overflowY="auto" >
              <MenuTabs />
            </Stack.Item>

            <Stack.Item grow={1}>
              <Stack fill fluid direction="column">
                <Stack.Item>
                  <KnowledgePreview />
                </Stack.Item>
                <Stack.Item>
                {selectedKnowledge && (
                  <Button
                  content={(selectedKnowledge.disabled && "Not enough willpower") || "Purchase"}
                  textAlign="center"
                  fontSize="16px"
                  disabled={selectedKnowledge.disabled}
                  fluid
                  color={(selectedKnowledge.disabled && "grey") || "green"}
                  onClick={() => {
                  act("purchase", { upgrade_path: selectedKnowledge.path });
                  (!selectedKnowledge.infinite && setSelectedKnowledge(null));
                  }} />
                )}
                </Stack.Item>
              </Stack>

            </Stack.Item>
          </Stack>

        </Stack>
      </Stack.Item>
    </Stack>
  );
};

// the skills on the left side of the menu
const MenuTabs = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { categories = [] } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<Category>(
    context,
    'category',
    categories[0]
  );

  const [selectedKnowledge, setSelectedKnowledge] = useLocalState<Knowledge | null>(context, "knowledge", null);

  return (
    <Section >

      <Tabs >
        {categories.map(category => (
          <Tabs.Tab
            width="100%"
            fontSize="16px"
            key={category}
            selected={category === selectedCategory}
            onClick={() => setSelectedCategory(category)}>
            {capitalize(category.name)}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Tabs vertical >
        {Object.entries(selectedCategory.knowledgeData).map(([knowledge, psiWeb]) => (
          <Tabs.Tab
            fontSize="16px"
            key={knowledge}
            Autofocus
            selected={psiWeb === selectedKnowledge}
            onClick={() => setSelectedKnowledge(psiWeb)}>
            {capitalize(psiWeb.name)}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const KnowledgePreview = (props, context) => {

  const [selectedKnowledge] = useLocalState<Knowledge | null>(context, "knowledge", null);

  if(selectedKnowledge!==null) {
    return (
      <Section overflow-wrap="break-word" fontSize="16px" textAlign="center" fill title={capitalize(selectedKnowledge?.name)}>
        <Stack fill fluid vertical justify="flex-start" fontSize="16px" textAlign="center">

          <Stack.Item fontSize="15px" color="purple">willpower cost: {selectedKnowledge?.cost}</Stack.Item>

          {!!selectedKnowledge.icon && (
          <Stack.Item>
            <Box
            as="img"
            src={`data:image/jpeg;base64,${selectedKnowledge.icon}`}
            height="128px"
            style={{
              'background': 'radial-gradient(circle, rgb(114, 100, 255) 0%, rgb(33, 0, 127) 100%);',
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated' }} />
          </Stack.Item>
          )}

          <Stack.Item color="gold">{selectedKnowledge?.desc}</Stack.Item>
          <Stack.Item style={Velvet} fontSize="14px">{selectedKnowledge?.lore_description}</Stack.Item>
          <Stack.Item fontSize="12px" color="purple">{!!(selectedKnowledge?.infinite) && "Can be purchased multiple times"}</Stack.Item>
        </Stack>
      </Section>
      );
  }else{
    return(
      <Section overflow-wrap="break-word" fill fluid>
        <Stack vertical fontSize="16px" align="center" height="50px" textAlign="center">

          <Stack.Item width="100%" color="gold">Select a knowledge to learn</Stack.Item>

        </Stack>
      </Section>
    );
  }
};

const ClassSelection = (props, context) => {
  const { act, data } = useBackend<Classes>(context);
  const { classData = [] } = data;

  const [currentTab, setTab] = useLocalState(context, 'currentTab', 0);

  return (
    <Flex justify="space-evenly" height="100%" width="100%"
    style={{
      "align-items": "center",
      "height": "100%",
      "justify-content": "center",
    }}>
      {classData.map(darkspawnclass => (
        <Flex
        width="100%"
        direction="column"
        key={darkspawnclass}
        fontSize="16px"
        textAlign="center"
        >
          <Flex.Item height="50px" fontSize="20px" color={darkspawnclass.color}>{capitalize(darkspawnclass.name)}</Flex.Item>
          <Flex.Item height="50px">{darkspawnclass.description}</Flex.Item>
          <Flex.Item height="70px" fontSize="14px" style={Velvet}>{darkspawnclass.long_description}</Flex.Item>
          <Flex.Item height="50px">
            <Tabs.Tab
            height="50px"
            fontSize="20px"
            onClick={() => {
            act("select", { class_path: darkspawnclass.path });
            setTab(0);
            }}>
              Choose
            </Tabs.Tab>
          </Flex.Item>

        </Flex>
      ))}
    </Flex>
  );
};
