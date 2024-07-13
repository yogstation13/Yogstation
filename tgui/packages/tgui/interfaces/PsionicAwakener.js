import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber } from '../components';
import { Window } from '../layouts';

export const PsionicAwakener = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    open,
    occupant = {},
    occupied,
    ready,
    timeleft,
    result,
    active_treatment,
    treatment_cost,
    nullspace,
    nullspace_max,
  } = data;

  const treatments = data.treatments || [];

  return (
    <Window width={350} height={500}>
      <Window.Content >
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          buttons={!!occupant.stat && (
            <Box
              inline
              bold
              color={occupant.statstate}>
              {occupant.stat}
            </Box>
          )}>
          {!!occupied && (
            <LabeledList>
              <LabeledList.Item
                label="Brain">
                <ProgressBar
                  label="Brain"
                  value={200 - occupant.brainLoss}
                  maxValue={200}
                  color={occupant.brainLoss ? 'bad' : 'good'} />
              </LabeledList.Item>
              {!!result && (
                <LabeledList.Item
                label="Result">
                {result}
                </LabeledList.Item>
              )}
            </LabeledList>
          )}
        </Section>
        <Section
          title="Awaken"
          minHeight="100px"
          buttons={(
            <Button
              icon={open ? 'door-open' : 'door-closed'}
              content={open ? 'Open' : 'Closed'}
              onClick={() => act('door')} />
          )}>
          <LabeledList>
            <LabeledList.Item
              label="Nullspace Dust"
              color='purple'>
              <ProgressBar
                label="Nullspace Dust"
                value={nullspace}
                maxValue={nullspace_max}
                color='white'>{
                nullspace ? nullspace : 0}/{nullspace_max}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label="Selected">
              {active_treatment}
            </LabeledList.Item>
            <LabeledList.Item
              label="Dust Cost">
              {treatment_cost ? treatment_cost : "nothing"}
            </LabeledList.Item>
            <LabeledList.Item
              label="Treatment">
              <Button
                icon='power-off'
                content='Activate'
                onClick={() => act('activate')}
                disabled={!ready || (treatment_cost > nullspace)} />
            </LabeledList.Item>
            {!ready && (
              <LabeledList.Item
                label="Cooling down">
              <Box
                lineHeight="20px"
                color="label">
                ({timeleft}) seconds
              </Box>
              </LabeledList.Item>
            )}
            {treatment_cost > nullspace && (
              <LabeledList.Item
                label="Error"
                color='bad'
                >
                INSUFFICIENT NULLSPACE
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section
          title="Treatments">
          {treatments.map(treatment => (
            <Button
              key={treatment}
              content={treatment}
              color={active_treatment===treatment ? 'green' : null}
              width='100%'
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
