import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, NoticeBox, AnimatedNumber } from '../components';
import { Window } from '../layouts';

type firstPodInformation = {
  firstOpen: Boolean
  firstLocked: Boolean;
  firstName: String;
  firstStat: String;
  firstMindType: String;
};

type secondPodInformation = {
  secondOpen: Boolean;
  secondLocked: Boolean;
  secondName: String;
  secondStat: String;
  secondMindType: String;
};

type generalInformation = {
  fullyConnected: Boolean;
  fullyOccupied: Boolean;
  canDelayTransfer: Boolean;
  active: Boolean;
  progress: Number;
}

export const MindMachineHub = (props, context) => {
  const { act, data } = useBackend<generalInformation>(context);
  const { fullyConnected } = data;
  return (
    <Window width={400} height={520} title="Mind Machine Hub">
      <Window.Content>
        {!fullyConnected && (
          <NoticeBox>No connected pods detected.</NoticeBox>
        )}
        {!!fullyConnected && (
          <ConnectedSection />
        )}
      </Window.Content>
    </Window>
  );
};

const ConnectedSection = (props, context) => {
  const { act, data } = useBackend<generalInformation>(context);
  const { fullyOccupied, canDelayTransfer, active, progress } = data;

  return (
    <Section>
      <FirstPodLabeledList />
      <SecondPodLabeledList />
      <Section
        title="Controls">
        <Button
          icon="first-aid"
          content="Transfer"
          disabled={!fullyOccupied || active}
          width="350px"
          onClick={() => act('activate', {})}
        />
        <Button
          icon="first-aid"
          content="Delayed Transfer"
          disabled={!canDelayTransfer && !active}
          width="350px"
          onClick={() => act('activate_delay', {})}
        />
      </Section>
      {!!active && progress !== null && (
        <ProgressBar
        value={progress}
        minValue={0}
        maxValue={100} />
      )}
    </Section>
  );
};

const FirstPodLabeledList = (props, context) => {
  const { act, data } = useBackend<firstPodInformation>(context);
  const { firstOpen, firstLocked, firstName, firstStat, firstMindType } = data;
  return (
    <Section title="First Occupant">
      <LabeledList>
        <LabeledList.Item
          label="Name">
          {firstName ? firstName : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Status">
          {firstStat ? firstStat : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Mind Type">
          {firstMindType ? firstMindType : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Controls"
          buttons={(
            <>
              <Button
                icon={firstOpen ? 'door-open' : 'door-closed'}
                content={firstOpen ? 'Open' : 'Closed'}
                disabled={!firstOpen && firstLocked}
                onClick={() => act('first_toggledoor')} />
              <Button
                icon={firstLocked ? 'door-closed' : 'door-open'}
                content={firstLocked ? 'Locked' : 'Unlocked'}
                disabled={firstOpen}
                onClick={() => act('first_togglelock')} />
            </>
          )}
        />
      </LabeledList>
    </Section>
  );
};

const SecondPodLabeledList = (props, context) => {
  const { act, data } = useBackend<secondPodInformation>(context);
  const { secondOpen, secondLocked, secondName, secondStat, secondMindType } = data;
  return (
    <Section title="Second Occupant">
      <LabeledList>
        <LabeledList.Item
          label="Name">
          {secondName ? secondName : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Status">
          {secondStat ? secondStat : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Mind Type">
          {secondMindType ? secondMindType : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Controls"
          buttons={(
            <>
              <Button
                icon={secondOpen ? 'door-open' : 'door-closed'}
                content={secondOpen ? 'Open' : 'Closed'}
                disabled={!secondOpen && secondLocked}
                onClick={() => act('second_toggledoor')} />
              <Button
                icon={secondLocked ? 'door-closed' : 'door-open'}
                content={secondLocked ? 'Locked' : 'Unlocked'}
                disabled={secondOpen}
                onClick={() => act('second_togglelock')} />
            </>
          )}
        />
      </LabeledList>
    </Section>
  );
};
