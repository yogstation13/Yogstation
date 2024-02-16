import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Collapsible, Button, Divider, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareString = (a, b) => a < b ? -1 : a > b;

const compareNumberedText = (a, b) => {
  const aName = a.name;
  const bName = b.name;

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return compareString(aName, bName);
};

const JumpButton = (props, context) => {
  const { act } = useBackend(context);
  const { thing } = props;

  return (
    <Button
      onClick={() => act("jump", {
        ref: thing.ref,
      })}>
      {thing.name}
    </Button>
  );
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return source.length > 0 && (
    <Collapsible open title={`${title} - (${source.length})`}>
      {things.map(thing => (
        <JumpButton
          key={thing.name}
          thing={thing}
        />
      ))}
    </Collapsible>
  );
};

export const Jump = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mobs,
    areas,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  const jumpMostRelevant = searchText => {
    for (const source of [
      mobs, areas,
    ]) {
      const member = source
        .filter(searchFor(searchText))
        .sort(compareNumberedText)[0];
      if (member !== undefined) {
        act("jump", { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window
      title="Jump Menu"
      width={350}
      height={700}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Icon
                name="search"
                mr={1} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                onEnter={(_, value) => jumpMostRelevant(value)} />
            </Flex.Item>
            <Flex.Item>
              <Divider vertical />
            </Flex.Item>
            <Flex.Item>
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-start"
                icon="sync-alt"
                onClick={() => act("refresh")} />
            </Flex.Item>
          </Flex>
        </Section>
        <BasicSection
          title="Mobs"
          source={mobs}
          searchText={searchText}
        />

        <BasicSection
          title="Areas"
          source={areas}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
