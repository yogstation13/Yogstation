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

  const mapped_destinations = destinations.map(destination => {
    return (
      <Button width="144px" lineHeight={1.85} selected={destinations[currentTag - 1] === destination} key={destination} onClick={() => act('ChangeSelectedTag', { 'tag': destination })}>{destination}</Button>
    );
  });

  return (
    <Window title="TagMaster 3.0" width={450} height={350}>
      <Window.Content>
        <Section title="TagMaster 3.0 - The future, 20 years ago!">
          <LabeledList>
            <LabeledList.Item label="Current Destination">
              {(currentTag) !== "" ? destinations[currentTag - 1] : "NONE"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {mapped_destinations}


      </Window.Content>
    </Window>
  );
};
