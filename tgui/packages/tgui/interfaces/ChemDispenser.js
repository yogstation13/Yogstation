import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const ChemDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const recording = !!data.recordingRecipe;
  // TODO: Change how this piece of shit is built on server side
  // It has to be a list, not a fucking OBJECT!
  const recipes = Object.keys(data.recipes)
    .map(name => ({
      name,
      contents: data.recipes[name],
    }));
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = recording
    && Object.keys(data.recordingRecipe)
      .map(id => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))
    || data.beakerContents
    || [];
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={recording && (
            <Box inline mx={1} color="red">
              <Icon name="circle" mr={1} />
              Recording
            </Box>
          )}>
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar
                value={data.energy / data.maxEnergy}>
                {toFixed(data.energy) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Dispense"
          buttons={(
            beakerTransferAmounts.map(amount => (
              <Button
                key={amount}
                icon="plus"
                selected={amount === data.amount}
                content={amount}
                onClick={() => act('amount', {
                  target: amount,
                })} />
            ))
          )}>
          <Box mr={-1}>
            {data.chemicals.map(chemical => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight="21px"
                content={chemical.title}
                onClick={() => act('dispense', {
                  reagent: chemical.id,
                })} />
            ))}
          </Box>
        </Section>
        <Section
          title="Beaker"
          buttons={(
            beakerTransferAmounts.map(amount => (
              <Button
                key={amount}
                icon="minus"
                disabled={recording}
                content={amount}
                onClick={() => act('remove', { amount })} />
            ))
          )}>
          <LabeledList>
            <LabeledList.Item
              label="Beaker"
              buttons={!!data.isBeakerLoaded && (
                <Button
                  icon="eject"
                  content="Eject"
                  disabled={!data.isBeakerLoaded}
                  onClick={() => act('eject')} />
              )}>
              {recording
                && 'Virtual beaker'
                || data.isBeakerLoaded
                  && (
                    <Fragment>
                      <AnimatedNumber
                        initial={0}
                        value={data.beakerCurrentVolume} />
                      /{data.beakerMaxVolume} units
                    </Fragment>
                  )
                || 'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Contents">
              <Box color="label">
                {(!data.isBeakerLoaded && !recording) && 'N/A'
                  || beakerContents.length === 0 && 'Nothing'}
              </Box>
              {beakerContents.map(chemical => (
                <Box
                  key={chemical.name}
                  color="label">
                  <AnimatedNumber
                    initial={0}
                    value={chemical.volume} />
                  {' '}
                  units of {chemical.name}
                </Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
