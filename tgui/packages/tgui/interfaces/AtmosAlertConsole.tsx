import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  priority_alerts: AlertData[];
  minor_alerts: AlertData[];
};

type AlertData = {
  name: string;
  ref: string;
};

export const AtmosAlertConsole = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { priority_alerts = [], minor_alerts = [] } = data;
  return (
    <Window
      width={350}
      height={300}
      resizable>
      <Window.Content scrollable>
        <Section title="Alarms">
          <ul>
            {priority_alerts.length === 0 && (
              <li className="color-good">
                No Priority Alerts
              </li>
            )}
            {priority_alerts.map((alert) => (
              <li key={alert.name}>
                <Button
                  icon="times"
                  content={alert.name}
                  color="bad"
                  onClick={() => act('clear', { zone_ref: alert.ref })} />
              </li>
            ))}
            {minor_alerts.length === 0 && (
              <li className="color-good">
                No Minor Alerts
              </li>
            )}
            {minor_alerts.map((alert) => (
              <li key={alert.name}>
                <Button
                  icon="times"
                  content={alert.name}
                  color="average"
                  onClick={() => act('clear', { zone_ref: alert.ref })} />
              </li>
            ))}
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
