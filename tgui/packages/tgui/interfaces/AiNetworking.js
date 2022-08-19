import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, NoticeBox, RoundGauge } from '../components';
import { LabeledListDivider, LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const AiNetworking = (props, context) => {
  const { act, data } = useBackend(context);


  if (data.locked) {
    return (
      <Window
        width={500}
        height={450}
        resizable>
        <Window.Content scrollable>
          <Section title="Lockscreen">
            <NoticeBox textAlign="center" danger>Machine locked</NoticeBox>
            <Box textAlign="center">
              <Button icon="lock-open" onClick={() => act('toggle_lock')} color="good" tooltip="If not already connected, this will allow foreign devices to connect to this one.">Unlock</Button>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      width={500}
      height={450}
      resizable>
      <Window.Content scrollable>
        <Section title={"Networking | " + data.label} buttons={(
          <Fragment>
            <Button icon="lock" onClick={() => act('toggle_lock')} color="bad" tooltip="If not connected this will prevent others connecting to this device. Will not sever existing connections.">Lock</Button>
            <Button icon="pen" onClick={() => act('switch_label')}>Set Label</Button>
          </Fragment>
        )}>
          <LabeledList>
            {data.possible_targets.map(target => (
              data.is_connected === target ? (
                <Fragment>
                  <LabeledListItem label={target} buttons={(
                    <Button icon="eject" onClick={() => act('disconnect')}
                      disabled={!data.is_connected} color="bad">Disconnect
                    </Button>
                  )} />

                  <LabeledListDivider />
                </Fragment>
              ) : (
                <Fragment>
                  <LabeledListItem label={target} buttons={(
                    <Button icon="wifi" onClick={() => act('connect', { target_label: target })}
                      disabled={data.is_connected} tooltip={data.is_connected ? "Already connected. Please disconnect" : ""} tooltipPosition="left">Connect
                    </Button>
                  )} />
                  <LabeledListDivider />
                </Fragment>
              )
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
