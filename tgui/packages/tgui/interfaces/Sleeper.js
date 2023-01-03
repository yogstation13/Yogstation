import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    open,
    occupant = {},
    occupied,
    active_treatment,
    can_sedate,
  } = data;

  const treatments = data.treatments || [];

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
    <Window width={400} height={520}>
      <Window.Content >
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
            <>
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
            </>
          )}
        </Section>
        {!!occupied && (
          <Section
            title="Reagents"
            minHeight="50px"
            buttons={(
              <Button
                icon={'flask'}
                content={'Sedate'}
                disabled={!can_sedate}
                onClick={() => act('sedate')} />
            )} >
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
          title="Treatments"
          minHeight="205px"
          buttons={(
            <Button
              icon={open ? 'door-open' : 'door-closed'}
              content={open ? 'Open' : 'Closed'}
              onClick={() => act('door')} />
          )}>
          {treatments.map(treatment => (
            <Button
              key={treatment}
              icon="first-aid"
              content={treatment}
              disabled={!occupied}
              color={active_treatment===treatment ? 'green' : null}
              /* key={chem.name}
              icon="flask"
              tooltip={data.knowledge ? chem.desc : "You don't know what this chemical does!"}
              tooltipPosition="top"
              content={chem.name}
              disabled={!(occupied && chem.allowed)}*/
              width="350px"
              onClick={() => act('set', {
                treatment: treatment,
              })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
