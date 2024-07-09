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
  } = data;

  return (
    <Window width={300} height={300}>
      <Window.Content >
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          minHeight="100px"
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
              <Box mt={1} />
              <LabeledList>
                <LabeledList.Item
                  label="Brain"
                  color={occupant.brainLoss ? 'bad' : 'good'}>
                  {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
                </LabeledList.Item>
              </LabeledList>
            </>
          )}

          <Box mt={1} />
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
          <Button
            icon='door-open'
            content='Activate'
            onClick={() => act('activate')}
            disabled={!ready} />
          {!ready && (
            <Box
              lineHeight="20px"
              color="label">
              Awakener cooling down ({timeleft}) seconds
            </Box>)}
        </Section>
      </Window.Content>
    </Window>
  );
};
