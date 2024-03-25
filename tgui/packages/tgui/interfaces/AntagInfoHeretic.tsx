import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Tabs, Button, BlockQuote } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { ObjectivePrintout, Objective, ReplaceObjectivesButton } from './common/Objectives';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type Knowledge = {
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  disabled: boolean;
  hereticPath: string;
  color: string;
};

type KnowledgeInfo = {
  learnableKnowledge: Knowledge[];
  learnedKnowledge: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
  path: string;
};

const IntroductionSection = (props, context) => {
  const { data, act } = useBackend<Info>(context);
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="You are the Heretic!" fill fontSize="14px">
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
                    can_change_objective
                      ? 'In order to ascend, you have these tasks to fulfill'
                      : 'Use your dark knowledge to fulfil your personal goal'
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={'Reject Ascension'}
                      button_colour={'red'}
                      button_tooltip={
                        'Turn your back on the Mansus to accomplish a task of your choosing. Selecting this option will prevent you from ascending!'
                      }
                    />
                  }
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
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Another day at a meaningless job. You feel a&nbsp;
            <span style={hereticBlue}>shimmer</span>
            &nbsp;around you, as a realization of something&nbsp;
            <span style={hereticRed}>strange</span>
            &nbsp;in the air unfolds. You look inwards and discover something
            that will change your life.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            The <span style={hereticPurple}>Gates of Mansus</span>
            &nbsp;open up to your mind.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Find reality smashing&nbsp;
          <span style={hereticPurple}>influences</span>
          &nbsp;around the station invisible to the normal eye and&nbsp;
          <b>use your codex </b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>.
        </Stack.Item>
        <Stack.Item>
          - Use your&nbsp;
          <span style={hereticRed}>Living Heart</span>
          &nbsp;to track down&nbsp;
          <span style={hereticRed}>sacrifice targets</span>, but be careful:
          You are able to target other heretics, so be careful whom you hunt.
          This action is tied to your <b>heart</b> - if you lose it, you must
          complete a ritual to regain it.
        </Stack.Item>
        <Stack.Item>
          - Draw a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> by using a
          your codex on the floor. This rune allows you to complete
          rituals and sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Follow your <span style={hereticRed}>Living Heart</span> to find
          your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> once you have killed them&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. The Mansus{' '}
          <b>ONLY</b> accepts targets pointed to by the&nbsp;
          <span style={hereticRed}>Living Heart</span>.
        </Stack.Item>
        <Stack.Item>
          -  Each <span style={hereticYellow}>Lore-Specific</span> upgrade will be available after gaining three research of the previous tier.
          This means you need three tier one abilities before you can claim your Grasp Mark,
          then three tier two abilities before you can claim your Blade Upgrade.
          As it follows, three tier three abilities are required before you unlock your Ascension Rite.
        </Stack.Item>
        <Stack.Item>
          - Accomplish all of your research to be able to learn the{' '}
          <span style={hereticYellow}>final ritual</span>. Complete the ritual
          to become all powerful!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { charges, total_sacrifices, ascended } = data;
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
          You have <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>
            knowledge point{charges !== 1 ? 's' : ''}
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          You have made a total of&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>sacrifices</span>.
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ResearchedKnowledge = (props, context) => {
  const { data } = useBackend<KnowledgeInfo>(context);
  const { learnedKnowledge } = data;

  return (
    <Stack.Item grow>
      <Section title="Researched Knowledge" fill scrollable>
        <Stack vertical>
          {(!learnedKnowledge.length && 'None!') ||
            learnedKnowledge.map((learned) => (
              <Stack.Item key={learned.name}>
                <Button
                  width="100%"
                  color={learned.color}
                  content={`${learned.hereticPath} - ${learned.name}`}
                  tooltip={learned.desc}
                />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const KnowledgeShop = (props, context) => {
  const { data, act } = useBackend<KnowledgeInfo>(context);
  const { path } = props;
  const { learnableKnowledge } = data;
  const pathKnowledge = learnableKnowledge.filter((Knowledge) => Knowledge.hereticPath === path);
  const otherKnowledge = learnableKnowledge.filter((Knowledge) => Knowledge.hereticPath !== path);
  otherKnowledge.sort((a, b) => {
    const nameA = a.hereticPath.toUpperCase(); // ignore upper and lowercase
    const nameB = b.hereticPath.toUpperCase(); // ignore upper and lowercase
    if (nameA < nameB) {
      return -1;
    }
    if (nameA > nameB) {
      return 1;
    }

    // names must be equal
    return 0;
  });
  const sortedKnowledge = pathKnowledge.concat(otherKnowledge);

  return (
    <Stack.Item grow>
      <Section title="Potential Knowledge" fill scrollable>
        {(!sortedKnowledge && 'None!') ||
          sortedKnowledge.map((toLearn) => (
            <Stack.Item key={toLearn.name} mb={1}>
              <Button
                width="100%"
                color={toLearn.color}
                disabled={toLearn.disabled}
                content={`${toLearn.hereticPath} - ${
                  toLearn.cost > 0
                    ? `${toLearn.name}: ${toLearn.cost}
                  point${toLearn.cost !== 1 ? 's' : ''}`
                    : toLearn.name
                }`}
                tooltip={toLearn.desc}
                onClick={() => act('research', {
                  name: toLearn.name,
                  cost: toLearn.cost,
                })} />
              {!!toLearn.gainFlavor && (
                <BlockQuote>
                  <i>{toLearn.gainFlavor}</i>
                </BlockQuote>
              )}
            </Stack.Item>
          ))}
      </Section>
    </Stack.Item>
  );
};

const ResearchInfo = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { charges, path } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item fontSize="20px" textAlign="center">
            You have <b>{charges || 0}</b>&nbsp;
            <span style={hereticBlue}>
              knowledge point{charges !== 1 ? 's' : ''}
            </span>{' '}
            to spend.
          </Stack.Item>
          <Stack.Item grow>
            <Stack height="100%">
              <ResearchedKnowledge />
              <KnowledgeShop path={path} />
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { ascended } = data;

  const [currentTab, setTab] = useLocalState(context, 'currentTab', 0);

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          'background-image': 'none',
          'background': ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}>
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}>
                Research
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || <ResearchInfo />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
