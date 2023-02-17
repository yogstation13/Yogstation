import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const NullRod = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    names = [],
    desc = [],
    icons = [],
  } = data;
  return (
    <Window
      width={335}
      height={160}>
      <Window.Content>
        <NoticeBox textAlign="center">
          Nullrod {names[1]}
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};
