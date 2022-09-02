import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const FolderObjective = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tc,
    difficulty,
    objective_text,
    admin_msg
  } = data;
  return (
    <Window
      width={400}
      height={300}
      theme="syndicate">
      <Window.Content>
        <Section title="Handheld Objective Device">
          <LabeledList bold>
            <LabeledList.Item label="DIFFICULTY" buttons={difficulty}/>
            <LabeledList.Item label="BOUNTY" buttons={tc+"TC"}/>
            <LabeledList.Item label="OBJECTIVE">{objective_text}</LabeledList.Item>
          </LabeledList>
        </Section>
        {admin_msg ? (
          <NoticeBox info textAlign="center">
            Your objective status is being reviewed by command.
            Please try again later.
          </NoticeBox>
        ) : ""}
        <Button
          fluid
          content="Check Completion"
          textAlign="center"
          onClick={() => act('check_done')} />
      </Window.Content>
    </Window>
  );
};
