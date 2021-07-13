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
  //data.users[0].connected = 0

  data.users.sort((a, b) => {
    if(a.connected != b.connected)
      return a.connected - b.connected
    if(a.connected)
      return a.last.connect - b.last.connect
    return a.last.disconnect - b.last.disconnect
  })

  return (<Window
      title="Disconnect Panel"
      width={700}
      height={700}
      resizable>
        <Window.Content scrollable>
          <Section>
            {data.users.map(user => (
              <Collapsible
                color={user.connected ? 'green' : (user.last.living ? 'red' : 'yellow')}
                title={user.ckey + " - " +
                      (user.connected ? "Connected" : "Disconnected") + " - " +
                      user.last.job + " - " +
                      sec2time((data.world_time - (user.connected ? user.last.connect : user.last.disconnect))/10)}>
                <Section>
                  <Button>Follow</Button>
                  <Button>Player Panel</Button>
                  <Button>Private Message</Button>
                  <Button>Notes</Button>
                  <Collapsible title="History">
                    {user.history.reverse().map(datapoint => (
                      <Section
                        color={datapoint.living ? 'yellow' : 'green'}>
                        {sec2time(datapoint.disconnect)}-{sec2time(datapoint.connect)} ({sec2time(datapoint.connect - datapoint.disconnect)})
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
