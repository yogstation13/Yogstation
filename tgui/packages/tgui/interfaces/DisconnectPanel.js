import { useBackend } from '../backend';
import { Section, Collapsible, Button } from '../components';
import { Window } from '../layouts';

function sec2time(seconds) {
  var h = Math.floor(seconds / 3600);
  var m = Math.floor(seconds % 3600 / 60).toString().padStart(2, "0");
  var s = Math.floor(seconds % 3600 % 60).toString().padStart(2, "0");
  return h + ":" + m + ":" + s;
}

export const DisconnectPanel = (props, context) => {
  const { act, data } = useBackend(context);
  data.users[0].connected = 0;
  return (<Window
      title="Disconnect Panel"
      width={700}
      height={700}
      resizable>
        <Window.Content scrollable>
          <Section>
            {data.users.map(user => (
              <Collapsible color={user.connected ? 'green' : 'red'} title={user.ckey + " - " + (user.connected ? "Connected" : "Disconnected") + " - " + sec2time((data.world_time - user.disconnect)/10)}>
                <Button>Follow</Button>
                <Collapsible title="History">
                  Hi
                </Collapsible>
              </Collapsible>
            ))}
          </Section>
        </Window.Content>
      </Window>
  );
};
