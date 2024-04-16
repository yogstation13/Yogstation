import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Wires = (props, context) => {
  const { act, data } = useBackend(context);
  const wires = data.wires || [];
  const statuses = data.status || [];
  const colorblind = data.colorblind;
  return (
    <Window
      width={350}
      height={150 + wires.length * 30}>
      <Window.Content>
        <Section>
          <LabeledList>
            {wires.map(wire => (
              <LabeledList.Item
                key={wire.color}
                className="candystripe"
                label={colorblind ? "grey" : wire.color}
                labelColor={colorblind ? "grey" : wire.color}
                color={colorblind ? "grey" : wire.color}
                buttons={(
                  <>
                    <Button
                      content={wire.cut ? 'Mend' : 'Cut'}
                      onClick={() => act('cut', {
                        wire: wire.color,
                      })} />
                    <Button
                      content="Pulse"
                      onClick={() => act('pulse', {
                        wire: wire.color,
                      })} />
                    <Button
                      content={wire.attached ? 'Detach' : 'Attach'}
                      onClick={() => act('attach', {
                        wire: wire.color,
                      })} />
                  </>
                )}>
                {!!wire.wire && (
                  <i>
                    ({wire.wire})
                  </i>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        {!!statuses.length && (
          <Section>
            {statuses.map(status => (
              <Box key={status}>
                {status}
              </Box>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
