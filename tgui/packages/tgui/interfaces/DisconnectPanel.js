import { useBackend } from '../backend';
import { Section, Collapsible, Button } from '../components';
import { Window } from '../layouts';

const sec2time = function (seconds) {
  let h = Math.floor(seconds / 3600);
  let m = Math.floor(seconds % 3600 / 60).toString().padStart(2, "0");
  let s = Math.floor(seconds % 3600 % 60).toString().padStart(2, "0");
  return h + ":" + m + ":" + s;
};

export const DisconnectPanel = (props, context) => {
  const { act, data } = useBackend(context);

  data.users.sort((a, b) => {
    if (a.connected !== b.connected) {
      return a.connected - b.connected;
    }
    if (a.connected) {
      return a.last.connect - b.last.connect;
    }
    return a.last.disconnect - b.last.disconnect;
  });

  return (
    <Window
      title="Disconnect Panel"
      width={700}
      height={700}
      resizable>
      <Window.Content scrollable>
        <Section>
          {data.users.map(user => (
            <Collapsible
              key={user.ckey}
              color={user.connected ? 'green' : (user.last.living ? 'red' : 'yellow')}
              title={user.ckey + " - "
                    + (user.connected ? "Connected" : "Disconnected") + " - "
                    + user.last.job + " - "
                    + sec2time((data.world_time
                            - (user.connected ? user.last.connect : user.last.disconnect))/10)}>
              <Section>
                <Button onClick={() => act('follow', { ckey: user.ckey })}>Follow</Button>
                <Button onClick={() => act('player-panel', { ckey: user.ckey })}>Player Panel</Button>
                <Button onClick={() => act('pm', { ckey: user.ckey })}>Private Message</Button>
                <Button onClick={() => act('notes', { ckey: user.ckey })}>Notes</Button>
                <Button
                  onClick={() => act('acryo', { ckey: user.ckey })}
                  disabled={user.connected}>
                  Admin Cryo
                </Button>
                <Collapsible title="History">
                  {user.history.reverse().map(datapoint => (
                    <Section
                      key={user.ckey}
                      color={datapoint.living ? 'yellow' : 'green'}>
                      {sec2time(datapoint.disconnect/10)}-{sec2time(datapoint.connect/10)}
                      ({sec2time(((datapoint.connect || data.world_time)
                      - datapoint.disconnect)/10)})
                      As {datapoint.job} ({datapoint.type})
                    </Section>
                  ))}
                </Collapsible>
              </Section>
            </Collapsible>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
