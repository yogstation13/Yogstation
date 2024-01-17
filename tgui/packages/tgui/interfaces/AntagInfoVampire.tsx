import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type Info = {
  antag_name: string;
  objectives: Objective[];
  loud: boolean;
};

const vampireRed = {
  fontWeight: 'bold',
  color: 'red',
};

export const AntagInfoVampire = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { antag_name } = data;
  const { loud } = data;
  return (
    <Window width={620} height={250}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name}!
            </Stack.Item>
            <Stack.Item>
              <div>You can consume blood from humanoid life by <span style={vampireRed}>punching their head while on the harm intent</span>.</div>
              <div>Your bloodsucking speed depends on grab strength.</div>
              <div>Having a <b>neck grab or stronger</b> increases blood drain rate by 50%.</div>
              <div>This <span style={vampireRed}>WILL</span> alert everyone who can see it, as well as make a noise.</div>
              <div>{loud ? '' : 'You can extract blood '}<span style={vampireRed}>{loud ? '' : 'stealthily'}</span>{loud ? '' : ' by initiating without a grab.'}</div>
              <div>{loud ? '' : 'This will reduce the amount of blood taken by 50%.'}</div>
              <div>{loud ? 'You can no longer drain blood stealthily.' : 'The ability to drain blood stealthily will be lost above 150 total blood.'}</div>
              <div>Note that you <b>cannot</b> draw blood from <b>catatonics or corpses</b>.</div>
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your objectives:</Stack.Item>
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
