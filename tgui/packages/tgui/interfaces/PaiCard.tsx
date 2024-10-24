import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Button, BlockQuote, Box } from '../components';
import { Window } from '../layouts';

type Module = {
  module_name: string;
  title: string;
  cost: number;
}

type Candidate = {
  name: string;
  description: string;
  prefrole: string;
  ooccomments: string;
}

type Data = {
  pai: boolean;
  screen: number;
  candidates: Candidate[];
  name: string;
  master: string;
  masterdna: string;
  laws_zeroth: string;
  laws: string[];
  transmit: boolean;
  receive: boolean;
  holomatrix: boolean;
  modules: Module[];
  ram: number;
}

export const PaiCard = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { pai, screen, candidates } = data;
  if(pai) {
    return (
      <Window>
        <PaiManagement />
      </Window>
    );
  } else {
    return (
      <Window width={450} height={500}>
        {!screen && (
          <Section title="No personality installed">
            <Stack.Item>Searching for a personality...</Stack.Item>
            <Stack.Item>Press view available personalities to notify potential candidates.</Stack.Item>
            <Button onClick={() => act("request")}>View available personalities</Button>
          </Section>
        )}
        {!!screen && (
          <Section title="Requesting AI personalities from central database...">
            <BlockQuote color="white">If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</BlockQuote>
            {candidates.map(candidate => (
              <BlockQuote key="">
                <Stack.Item>Name: {candidate.name}</Stack.Item>
                <Stack.Item>Description: {candidate.description}</Stack.Item>
                <Stack.Item>Preferred role: {candidate.prefrole}</Stack.Item>
                <Stack.Item>OOC comments: {candidate.ooccomments}</Stack.Item>
                <Button onClick={() => act("download", { candidate_name: candidate.name })}>Download {candidate.name}</Button>
              </BlockQuote>
            ))}
            <Button icon="chevron-left" onClick={() => act("return")}>Back</Button>
          </Section>
        )}
      </Window>
    );
  }
};

export const PaiManagement = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { name, master, masterdna } = data;
  const { laws_zeroth, laws } = data;
  const { transmit, receive, holomatrix, modules, ram } = data;
  return (
    <Section title={name+"'s configuration interface"}>
      <Stack vertical>
        <Box bold={1}>Master:</Box>
        {!!master && (
          <Box>{master} ({masterdna})</Box>
        )}
        {!master && (
          <Box>
            <Stack.Item>None</Stack.Item>
            <Stack.Item><Button onClick={() => act("setdna")}>Imprint Master DNA</Button></Stack.Item>
          </Box>
        )}
        <Stack.Item>
          <Box bold={1}>Prime Directive:</Box>
          {laws_zeroth}
        </Stack.Item>
        <Stack.Item>
          <Box bold={1}>Additional directives:</Box>
          {laws.map(data => data)}
        </Stack.Item>
        <Box><Button onClick={() => act("setlaws")}>Configure directives</Button></Box> {/* Without the box, Stack will make this button fluid for some reason */}
        <Stack.Item>
          <Box bold={1}>Radio Uplink:</Box>
          <Button.Checkbox icon="arrow-up" onClick={() => act("radio", { radio: 1 })} checked={transmit}>Transmit</Button.Checkbox>
          <Button.Checkbox icon="arrow-down" onClick={() => act("radio", { radio: 0 })} checked={receive}>Receive</Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Box bold={1}>Other:</Box>
          <Button.Checkbox onClick={() => act("holomatrix")} checked={holomatrix}>Holomatrix projectors</Button.Checkbox>
          <Box><Button onClick={() => act("wipe")}>Wipe current pAI personality</Button></Box>
        </Stack.Item>
        <Stack.Item>
          <Box bold={1}>Downloaded modules: ({ram} GQ)</Box>
          {modules.length === 0 && (
            <Stack.Item>
              No downloaded modules.
            </Stack.Item>
          )}
          {modules.length !== 0 && modules.map(module => (
            <Stack.Item key="">
              {module}
            </Stack.Item>
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
