import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList } from '../components';
import { GridColumn } from '../components/Grid';
import { Window } from '../layouts';

export const DestinationTagger = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    // data go here
    currentTag,
    destinations,
  } = data;

  return (
    <Window title="TagMaster 3.0" width={462} height={750}>
      <Window.Content>
        <Section title="TagMaster 3.0 - The future, 20 years ago!">
          <LabeledList>
            <LabeledList.Item label="Current Destination">
              {currentTag}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {
          Object.entries(destinations).map((department, index) => {
            let wa = department[0];
            return(
              <Section title={wa} key={wa}>
                {
                  department[1].map(destination => {
                    return(<Button width="144px" lineHeight={1.85} selected={currentTag === destination} key={destination} onClick={() => act('ChangeSelectedTag', { 'tag': destination })}>{destination}</Button>);
                  })
                }
              </Section>
            );
          })
        }
      </Window.Content>
    </Window>
  );
};
