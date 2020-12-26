import { useBackend } from '../backend';
import { Box, Section, LabeledList, Button, ProgressBar, AnimatedNumber } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    open,
    occupant = {},
    occupied,
  } = data;

  const chems = data.chems || [];

  const damageTypes = [
    {
      label: 'Brute',
      type: 'bruteLoss',
    },
    {
      label: 'Burn',
      type: 'fireLoss',
    },
    {
      label: 'Toxin',
      type: 'toxLoss',
    },
    {
      label: 'Oxygen',
      type: 'oxyLoss',
    },
  ];

  return (
    <Window width={310} height={465}>
      <Window.Content scrollable>
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          minHeight="210px"
          buttons={!!occupant.stat && (
            <Box
              inline
              bold
              color={occupant.statstate}>
              {occupant.stat}
            </Box>
          )}>
          {!!occupied && (
            <Fragment>
              <ProgressBar
                value={occupant.health}
                minValue={occupant.minHealth}
                maxValue={occupant.maxHealth}
                ranges={{
                  good: [50, Infinity],
                  average: [0, 50],
                  bad: [-Infinity, 0],
                }} />
              <Box mt={1} />
              <LabeledList>
                {damageTypes.map(type => (
                  <LabeledList.Item
                    key={type.type}
                    label={type.label}>
                    <ProgressBar
                      value={occupant[type.type]}
                      minValue={0}
                      maxValue={occupant.maxHealth}
                      color="bad" />
                  </LabeledList.Item>
                ))}
                <LabeledList.Item
                  label="Cells"
                  color={occupant.cloneLoss ? 'bad' : 'good'}>
                  {occupant.cloneLoss ? 'Damaged' : 'Healthy'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Brain"
                  color={occupant.brainLoss ? 'bad' : 'good'}>
                  {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
                </LabeledList.Item>
              </LabeledList>
            </Fragment>
          )}
        </Section>
        {!!occupied && (
          <Section title="Reagents" minHeight="50px">
            {occupant.reagents.map(reagent => (
              <Box key={reagent.name}>
                {reagent.name} -
                <AnimatedNumber
                  value={reagent.volume}
                  format={value => {
                    return " " + Math.round(value * 100) / 100 + " units";
                  }} />
              </Box>

            ))}
          </Section>
        )}
        <Section
          title="Medicines"
          minHeight="205px"
          buttons={(
            <Button
              icon={open ? 'door-open' : 'door-closed'}
              content={open ? 'Open' : 'Closed'}
              onClick={() => act('door')} />
          )}>
          {chems.map(chem => (
            <Button
              key={chem.name}
              icon="flask"
              content={chem.name}
              disabled={!(occupied && chem.allowed)}
              width="350px"
              onClick={() => act('inject', {
                chem: chem.id,
              })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
