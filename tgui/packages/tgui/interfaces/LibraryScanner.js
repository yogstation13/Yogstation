import { useBackend, useSharedState } from '../backend';
import { Button, Dropdown, LabeledList, Section, Table, Input, Tabs, NumberInput, Divider, Box } from '../components';
import { Window } from '../layouts';

export const LibraryScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    cache,
    id,
  } = data;
  return (
    <Window
      title="NTos Retro Scanner"
      width={400}
      height={180}>
      <Window.Content>
        {cache.length !== 0 ? (
          <Section>
            Book loaded
            <br />
            {cache["name"]} by {cache["author"]}
            <br />
            <Button
              content="Eject"
              onClick={() => act('ejectbook')}
            />
          </Section>
        ) : (
          <Section>
            No book loaded into memory
          </Section>
        )}
        {id.length !== 0 ? (
          <Section>
            ID Loaded
            <br />
            {id["name"]} ({id["assignment"]})
            <br />
            <Button
              content="Clear"
              onClick={() => act('clearid')}
            />
          </Section>
        ) : (
          <Section>
            No ID Card Scanned
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
