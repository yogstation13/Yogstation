import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const VRSleeper = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={350}
      height={400}>
      <Window.Content>
        {!!data.vr_avatar && (
          <Section title="Virtual Avatar">
            <LabeledList>
              <LabeledList.Item label="Name">{data.vr_avatar.name}</LabeledList.Item>
              <LabeledList.Item label="Status">{data.vr_avatar.status}</LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar min="0" max={data.vr_avatar.maxhealth} value={data.vr_avatar.health}>{Math.round(data.vr_avatar.health/data.vr_avatar.maxhealth * 100) + "%"}</ProgressBar>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) || (
          <Section title="Virtual Avatar">No Virtual Avatar Detected</Section>
        )}
        <Section title="VR Commands">
          <Button icon={data.toggle_open ? "times" : "plus"} onClick={() => act('toggle_open')}>
            {data.toggle_open ? "Close" : "Open"}
          </Button>
          {!!data.isoccupant && (
            <Button icon="signal" onClick={() => act('vr_connect')}>
              Connect to VR
            </Button>
          )}
          {!!data.vr_avatar && (
            <Button icon="ban" onClick={() => act('delete_avatar')}>Delete Virtual Avatar</Button>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
