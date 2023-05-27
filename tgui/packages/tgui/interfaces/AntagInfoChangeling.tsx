import { useBackend } from '../backend';
import { Dimmer, Section, Stack, NoticeBox } from '../components';
import { Window } from '../layouts';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const hivemindstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

const fallenstyle = {
  color: 'black',
  fontWeight: 'bold',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Info = {
  true_name: string;
  stolen_antag_info: string;
  objectives: Objective[];
};

export const AntagInfoChangeling = (props, context) => {
  return (
    <Window width={720} height={720}>
      <Window.Content
        style={{
          'backgroundImage': 'none',
        }}>
        <Stack vertical fill>
          <Stack.Item maxHeight={13.2}>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
          <Stack.Item>
            <HivemindSection />
          </Stack.Item>
          <Stack.Item grow={3}>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

const HivemindSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const { true_name } = data;
  return (
    <Section fill title="Hivemind">
      <Stack vertical fill>
        <Stack.Item textColor="label">
          All Changelings, regardless of origin, are linked together by the{' '}
          <span style={hivemindstyle}>hivemind</span>. You may communicate to
          other Changelings under your mental alias,{' '}
          <span style={hivemindstyle}>{true_name}</span>, by starting a message
          with <span style={hivemindstyle}>:g</span>. Work together, and you
          will bring the station to new heights of terror.
        </Stack.Item>
        <Stack.Item>
          <NoticeBox danger>
            Other Changelings are strong allies, but some Changelings may betray
            you. Changelings grow in power greatly by absorbing their kind, and
            getting absorbed by another Changeling will leave you as a{' '}
            <span style={fallenstyle}>Fallen Changeling</span>. There is no
            greater humiliation.
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const { true_name, objectives } = data;
  return (
    <Section
      fill
      title="Intro"
      scrollable={!!objectives && objectives.length > 4}>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          You are {true_name}, a
          <span style={hivestyle}> {"Changeling"}</span>.
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Section fill title="Abilities">
      <Stack fill>
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={absorbstyle}>&ensp;Absorb DNA</span> ability allows
              you to steal the DNA and memories of a victim, granting you their 
              memories or speech patterns and possibly even greater things.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={revivestyle}>&ensp;Reviving Stasis</span> ability
              allows you to revive. It means nothing short of a complete body
              destruction can stop you! Obviously, this is loud and so should
              not be done in front of people you are not planning on silencing.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              Your
              <span style={transformstyle}>&ensp;Transform</span> ability allows
              you to change into the form of those you have collected DNA from,
              lethally and nonlethally. It will also mimic (NOT REAL CLOTHING)
              the clothing they were wearing for every slot you have open.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item basis={0} textColor="label" grow>
              The
              <span style={storestyle}>&ensp;Cellular Emporium</span> is where
              you purchase more abilities beyond your starting kit. You have 10
              genetic points to spend on abilities and you are able to readapt
              after absorbing a body, refunding your points for different kits.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const VictimPatternsSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { stolen_antag_info } = data;
  return (
    <Section
      fill
      scrollable={!!stolen_antag_info}
      title="Additional Stolen Information">
      {(!!stolen_antag_info && stolen_antag_info) || (
        <Dimmer fontSize="20px">Absorb a victim first!</Dimmer>
      )}
    </Section>
  );
};
