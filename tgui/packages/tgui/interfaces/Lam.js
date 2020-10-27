import { map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { clamp } from 'common/math';
import { vecLength, vecSubtract } from 'common/vector';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

const coordsToVec = coords => map(parseFloat)(coords.split(', '));

export const Lam = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetdest,
    tcoords,
    scibomb,
    countdown,
    locked,
    loaded,
    updating,
    stopcount,
  } = data;
  const signals = flow([
    map((signal, index) => {
      // Calculate distance to the target. BYOND distance is capped to 127,
      // that's why we roll our own calculations here.
      const dist = signal.dist && (
        Math.round(vecLength(vecSubtract(
          coordsToVec(tcoords),
          coordsToVec(signal.coords))))
      );
      return { ...signal, dist, index };
    }),
    sortBy(
      // Signals with distance metric go first
      signal => signal.dist === undefined,
      // Sort alphabetically
      signal => signal.entrytag),
  ])(data.signals || []);
  return (
    <Window resizable width={470} height={700}>
      <Window.Content>
        <Section
          title="Targetting Panel"
          buttons={(
            <Button
              icon={locked ? "lock" : "lock-open"}
              content={locked ? "Locked" : "Unlocked"}
              color={locked ? "grey" : "green"}
              onClick={() => act('lock')} />
          )}>



          <LabeledList>
            <LabeledList.Item label="Delay Timer">
              <Button
                icon={"clock"}
                content={countdown}
                tooltip={"Time before payload is transported to Lavaland. Minimum 15 seconds."}
                tooltipPosition="right"
                onClick={() => act('count')} />
            </LabeledList.Item>


            <LabeledList.Item label="Payload Status">
              <Button
                icon={loaded ? "bomb" : "window-close"}
                content={loaded ? "Loaded!" : "Empty"}
                tooltip={loaded ? "Remove the TTV?" : "Insert payload here. Trigger not required!"}
                tooltipPosition="right"
                color={loaded ? "bad" : ""}
                onClick={() => act('unload')} />
            </LabeledList.Item>

            <LabeledList.Item label="Launch Mode">
              <Button
                icon={stopcount ? "check" : "ban"}
                content={stopcount ? "Fire" : "Abort"}
                color={stopcount ? "grey" : "yellow"}
                selected={loaded && tcoords && stopcount}
                onClick={() => act('launch')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>


        {!locked && (
          <Section
            title="Available Targets">
            <Box fontSize="14px">
              Selected Target: {targetdest} ({tcoords}{!tcoords ? "N/A" : ""}) 
            </Box>
            <Table>
              <Table.Row bold>
                <Table.Cell content="Name" />
                <Table.Cell collapsing content="Coordinates" />
              </Table.Row>

              {signals.map(signal => (
                <Table.Row
                  key={signal.entrytag + signal.coords + signal.index}
                  className="candystripe">
                  <Table.Cell bold color="label">
                    {signal.entrytag}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    {signal.coords}
                  </Table.Cell>
                  <Table.Cell
                    collapsing
                    textAlign="right">
                    <Button
                      icon="crosshairs"
                      tooltip={"Target this location!"}
                      tooltipPosition="left"
                      onClick={() => act('target', {
                        targetdest: signal.entrytag,
                        tcoords: signal.coords,
                      })} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>  
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
