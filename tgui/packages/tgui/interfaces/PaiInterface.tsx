import { toFixed } from 'common/math';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs, Stack, BlockQuote, Table, Dropdown, ProgressBar, NumberInput } from '../components';
import { Window } from '../layouts';

type Module = {
  module_name: string;
  title: string;
  cost: number;
}

type MedRecord = { /* This should probably be cut down, but it's all valid medical record information */
  name: string;
  id: string;
  gender: string;
  age: number;
  fingerprint: string;
  p_state: string;
  m_state: string;
  blood_type: string;
  dna: string;
  minor_disabilities: string;
  minor_disabilities_details: string;
  major_disabilities: string;
  major_disabilities_details: string;
  allergies: string;
  allergies_details: string;
  current_diseases: string;
  current_diseases_details: string;
  important_notes: string;
  comments: string[];
}

type SecRecord = {
  name: string;
  id: string;
  gender: string;
  age: number;
  rank: string;
  fingerprint: string;
  p_state: string;
  m_state: string;
  criminal_status: string;
  crimes: string[];
  important_notes: string;
  comments: string[];
}

type Data = {
  modules: Data[];
  modules_list: Module[];
  modules_tabs: Module[];
  laws_zeroth: string;
  laws: string[];
  master: string;
  masterdna: string;
  ram: number;
  pressure: number;
  gases: string[];
  temperature: number;
  hacking: boolean;
  hackprogress: number;
  cable: string;
  door: string[];
  code: number;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  color: string;
  med_records: MedRecord[];
  sec_records: SecRecord[];
  selected_med_record: MedRecord[];
  selected_sec_record: SecRecord[];
}

export const AirlockJackTextSwitch = params => {
  switch (params) {
    case 0:
      return "Connection handshake";
    case 20:
      return "Starting brute-force encryption crack";
    case 40:
      return "Running brute-force encryption crack";
    case 60:
      return "Alert: Station AI network has been notified!";
    case 80:
      return "Success! Hijacking door subroutines...";
  }
};

export const MedRecordColour = (mental, physical) => {
  if(mental === "*Insane*"||physical === "*Deceased*") {
    return "#990000;";
  } else if(mental === "*Unstable*"||physical === "*Unconscious*") {
    return "#CD6500;";
  } else if(mental === "*Watch*"||physical === "Physically Unfit") {
    return "#3BB9FF;";
  } else {
    return "#4F7529;";
  }
};

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { modules_tabs = [] } = data;
  const [selectedMainTab, setMainTab] = useLocalState(context, "selectedMainTab", 0);
  return (
    <Window width={650} height={550}> {/* Width matters for medical records, height matters for download more software */}
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>
            <PaiBox />
          </Flex.Item>
          <Flex.Item>
            <Section title="Modules">
              <Tabs vertical>
                {modules_tabs.map((module, index) => (
                  <Tabs.Tab
                    key={index}
                    selected={index === selectedMainTab}
                    onClick={() => setMainTab(index)}>
                      {capitalize(module.module_name)}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const PaiBox = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedMainTab, setMainTab] = useLocalState(context, "selectedMainTab", 0);
  const { modules, ram, modules_list, modules_tabs = [] } = data;
  const { laws_zeroth, laws, master, masterdna } = data;
  const { pressure, gases, temperature } = data;
  const { hacking, hackprogress, cable, door } = data;
  const { code, frequency, minFrequency, maxFrequency, color } = data;
  const { med_records, sec_records } = data;
  const [record_view, set_record_view] = useLocalState(context, "record_view", 0);
  const { selected_med_record } = data;
  switch(modules_tabs[selectedMainTab].module_name) {
    case "directives":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          <Stack vertical>
            <Stack.Item>
              {!master && (
              <Box>
                You are bound to no one.
              </Box>)}
              {!!master && (
              <Box>
                Your master: {master} ({masterdna})
              </Box>
              )}
              <Button
                onClick={() => act("getdna")}>
                Request carrier DNA sample
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Box bold={1}>Prime Directive:</Box>
              {laws_zeroth}
            </Stack.Item>
            <Stack.Item>
              <Box bold={1}>Supplemental Directives:</Box>
              {laws.map(data => data)}
            </Stack.Item>
            <Stack.Item>
              <BlockQuote>
                <Box italic={1}>
                  Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
                  comprehending the subtle nuances of human language. You may parse the &quot;spirit&quot; of a directive and follow its intent,
                  rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
                  only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.
                </Box>
                <Box bold={1}>
                  Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
                  simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
                  prime directive to the best of your ability.
                </Box>
              </BlockQuote>
            </Stack.Item>
          </Stack>
        </Section>
      );
    case "screen display":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          Select your new display image.
          <Stack.Item>
            <Dropdown options={["Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What", "Null", "Sunglasses"]}
            onSelected={(value) => act("update_image", { updated_image: value })} />
          </Stack.Item>
        </Section>
      );
    case "download additional software":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          <Stack vertical>
            <Stack.Item>
              <Box bold={1}>Remaining available memory:</Box>
              <ProgressBar ranges={{
                good: [-Infinity, 50],
                average: [50, 75],
                bad: [75, Infinity] }}
                value={100-ram}
                maxValue={100}>
                  {ram} GQ
              </ProgressBar>
            </Stack.Item>
            <Stack.Item>
              <Box bold={1}>Downloaded modules:</Box>
            </Stack.Item>
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
            <Stack.Item>
              <Box bold={1}>Available modules:</Box>
            </Stack.Item>
            <Stack.Item>
              <Table>
                {modules_list.map(module => (
                  <Table.Row
                    key={module}>
                    <Table.Cell>
                      {module.module_name}
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <Button
                        fluid
                        content={module.cost+" GQ"}
                        disabled={module.cost>ram}
                        onClick={() => act("buy", { name: module.module_name, cost: module.cost })} />
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Stack.Item>
          </Stack>
        </Section>
      );
    case "atmosphere sensor":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          {!pressure && (
            <Stack.Item>
              Air Pressure: None
            </Stack.Item>
          )}
          {!!pressure && (
            <Stack.Item>
              Air Pressure: {pressure} kPa
            </Stack.Item>
          )}
          <Stack.Item>
            Detected gases:
          </Stack.Item>
          {!gases && (
            <Stack.Item>
              None
            </Stack.Item>
          )}
          {!!gases && gases.map(gas => (
            <Stack.Item key="">
              {gas}
            </Stack.Item>
          ))}
          {!temperature && (
            <Stack.Item>
              Temperature: None
            </Stack.Item>
          )}
          {!!temperature && (
            <Stack.Item>
              Temperature: {temperature}&deg;C
            </Stack.Item>
          )}
          <Button onClick={() => act("atmossensor")}>
            Take new reading
          </Button>
        </Section>
      );
    case "remote signaller":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          <Stack vertical>
            <Stack.Item>
              Frequency:
              <NumberInput
                  animate
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={6}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={value => toFixed(value, 1)}
                  width="80px"
                  onDrag={(e, value) => act('signallerfreq', {
                    freq: value,
                  })} />
              <Button
                ml={1.3}
                icon="sync"
                content="Reset"
                onClick={() => act("signallerreset", {
                  reset: "freq",
                })} />
            </Stack.Item>
            <Stack.Item>
              Code:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <NumberInput
                animate
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onDrag={(e, value) => act("signallercode", {
                  code: value,
                })} />
              <Button
                ml={1.1}
                icon="sync"
                content="Reset"
                onClick={() => act("signallerreset", {
                  reset: "code",
                })} />
            </Stack.Item>
            <Stack.Item>
              Color:
              <Button
                ml={5.2}
                icon="sync"
                width={13.1}
                color={color}
                content={color}
                onClick={() => act("signallercolor")} />
            </Stack.Item>
            <Stack.Item>
              <Button
              mb={-0.1}
              icon="arrow-up"
              content="Send Signal"
              textAlign="center"
              onClick={() => act("signallersignal")} />
            </Stack.Item>
          </Stack>
        </Section>
      );
    case "medical records":
      if(selected_med_record) {
        return (
          <Section title={modules_tabs[selectedMainTab].title}>
            <Button icon="arrow-left"
              onClick={() => act("med_record back")}>
              Back
            </Button>
            <Stack vertical ml={2}>
              <Stack.Item>
                Name: {selected_med_record.name}
              </Stack.Item>
              <Stack.Item>
                ID: {selected_med_record.id}
              </Stack.Item>
              <Stack.Item>
                Gender: {selected_med_record.gender}
              </Stack.Item>
              <Stack.Item>
                Physical status: {selected_med_record.p_state}
              </Stack.Item>
              <Stack.Item>
                Mental status: {selected_med_record.m_state}
              </Stack.Item>
              <Stack.Item>
                Blood type: {selected_med_record.blood_type}
              </Stack.Item>
              <Stack.Item>
                DNA: {selected_med_record.dna}
              </Stack.Item>
              <br />
              <Stack.Item>
                Minor disabilities: {selected_med_record.minor_disabilities}
              </Stack.Item>
              <Stack.Item>
                Details: {selected_med_record.minor_disabilities_details}
              </Stack.Item>
              <Stack.Item>
                Major disabilities: {selected_med_record.major_disabilities}
              </Stack.Item>
              <Stack.Item>
                Details: {selected_med_record.major_disabilities_details}
              </Stack.Item>
              <Stack.Item>
                Allergies: {selected_med_record.allergies}
              </Stack.Item>
              <Stack.Item>
                Details: {selected_med_record.allergies_details}
              </Stack.Item>
              <Stack.Item>
                Current diseases: {selected_med_record.current_diseases}
              </Stack.Item>
              <Stack.Item>
                Details: {selected_med_record.current_diseases_details}
              </Stack.Item>
              <Stack.Item>
                Important notes: {selected_med_record.important_notes}
              </Stack.Item>
              <Stack.Item>
                Comments: {selected_med_record.comments}
              </Stack.Item>
            </Stack>
          </Section>
        );
      } else {
          return (
            <Section title={modules_tabs[selectedMainTab].title}>
              <Table>
                <Table.Row>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Name:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    ID:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Blood type:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Physical status:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Mental status:
                  </Table.Cell>
                </Table.Row>
                {med_records.map(MedRecord => (
                  <Table.Row
                    key={MedRecord}
                    height={3}>
                    <Table.Cell backgroundColor={MedRecordColour(MedRecord.m_state, MedRecord.p_state)}>
                      <Button
                        onClick={() => act("med_record", { record: MedRecord.id })} m={1}>
                        {MedRecord.name}
                      </Button>
                    </Table.Cell>
                    <Table.Cell backgroundColor={MedRecordColour(MedRecord.m_state, MedRecord.p_state)}>
                      {MedRecord.id}
                    </Table.Cell>
                    <Table.Cell backgroundColor={MedRecordColour(MedRecord.m_state, MedRecord.p_state)} textAlign={"center"}>
                      {MedRecord.blood_type}
                    </Table.Cell>
                    <Table.Cell backgroundColor={MedRecordColour(MedRecord.m_state, MedRecord.p_state)} textAlign={"center"}>
                      {MedRecord.p_state}
                    </Table.Cell>
                    <Table.Cell backgroundColor={MedRecordColour(MedRecord.m_state, MedRecord.p_state)} textAlign={"center"}>
                      {MedRecord.m_state}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          );
        }
    case "host scan":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          <Button onClick={() => act("hostscan")}>
            Change scan type
          </Button>
        </Section>
      );
    case "loudness booster":
      return (
        <Section title={modules_tabs[selectedMainTab].title}>
          <Button onClick={() => act("loudness")}>
            Open Synthesizer Interface
          </Button>
        </Section>
      );
    case "door jack":
      if(hacking) {
        return (
          <Section title={modules_tabs[selectedMainTab].title}>
            <Box bold={1}>Status:</Box>
            <ProgressBar ranges={{
              good: [75, Infinity],
              average: [50, 75],
              bad: [-Infinity, 50] }}
              value={hackprogress}
              maxValue={100}>
                {AirlockJackTextSwitch(hackprogress)}
            </ProgressBar>
            {cable === "Retracted" && (
              <Button onClick={() => act("cable")}>
                Extend cable
              </Button>
            )}
            {cable === "Extended" && (
              <Button onClick={() => act("retract")}>
                Retract cable
              </Button>
            )}
            {cable === "Extended" && door !== null && (
              hacking ? (
                <Button onClick={() => act("cancel")}>
                  Cancel Airlock Jack
                </Button>
                ) : (
                  <Button onClick={() => act("jack")}>
                    Begin Airlock Jack
                  </Button>
                )
              )}
          </Section>
        );
      } else {
          return (
            <Section title={modules_tabs[selectedMainTab].title}>
              <Box bold={1}>Status:</Box>
              <ProgressBar ranges={{
                good: [75, Infinity],
                average: [50, 75],
                bad: [-Infinity, 50] }}
                value={hackprogress}
                maxValue={100}>
                  {cable === "Retracted" && (
                    <Box>Cable retracted</Box>
                  )}
                  {cable === "Extended" && door === null && (
                    <Box>Cable extended</Box>
                  )}
                  {cable === "Extended" && door !== null && (
                    <Box>Compatible interface detected</Box>
                  )}
              </ProgressBar>
              {cable === "Retracted" && (
                <Button onClick={() => act("cable")}>
                  Extend cable
                </Button>
              )}
              {cable === "Extended" && (
                <Button onClick={() => act("retract")}>
                  Retract cable
                </Button>
              )}
              {cable === "Extended" && door !== null && (
                hacking ? (
                  <Button onClick={() => act("cancel")}>
                    Cancel Airlock Jack
                  </Button>
                  ) : (
                    <Button onClick={() => act("jack")}>
                      Begin Airlock Jack
                    </Button>
                  )
                )}
            </Section>
          );
        }
      }
  return null;
  };
