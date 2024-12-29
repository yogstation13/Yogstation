import { toFixed } from 'common/math';
import { capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Flex, Tabs, Stack, BlockQuote, Table, Dropdown, ProgressBar, NumberInput, Icon } from '../components';
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
  crimes: Crime[];
  important_notes: string;
  comments: Comment[];
}

type Crime = {
  crime_name: string;
  crime_details: string;
  author: string;
  time_added: string;
}

type Comment = {
  comment_text: string;
  author: string;
  time: string;
}

type Data = {
  modules: string[];
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
  selected_med_record: MedRecord;
  selected_sec_record: SecRecord;
}

const AirlockJackTextSwitch = params => {
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

export const SecRecordColour = criminal_status => {
  switch (criminal_status) {
    case "Arrest":
      return "#990000;";
    case "Discharged":
      return "#5C4949;";
    case "None":
      return "#740349;";
    case "Search":
      return "#5C4949;";
    case "Parole":
      return "#046713;";
    case "Incarcerated":
      return "#181818;";
    case "Suspected":
      return "#CD6500;";
  }
};

const SecRecordIcon = criminal_status => {
  switch (criminal_status) {
    case "Arrest":
      return "fingerprint";
    case "Discharged":
      return "dove";
    case "None":
      return "";
    case "Search":
      return "search";
    case "Parole":
      return "unlink";
    case "Incarcerated":
      return "dungeon";
    case "Suspected":
      return "exclamation";
  }
  return "";
};

let custom_width;
custom_width = 650;

export const PaiInterface = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { modules_tabs = [] } = data;
  const [selectedMainTab, setMainTab] = useLocalState(context, "selectedMainTab", 0);
  return (
    <Window width={custom_width} height={550}> {/* Width matters for records, height matters for download more software */}
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
  const { selected_med_record, selected_sec_record } = data;
  switch(modules_tabs[selectedMainTab].module_name) { // To actually make records readable without extending every other module unnecessarily
    case "medical records":
      custom_width = 960;
      break;
    case "security records":
      custom_width = 960;
      break;
    default:
      custom_width = 650;
  }
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
          <Table>
            <Table.Row>
              <Table.Cell>
                Frequency:
              </Table.Cell>
              <Table.Cell>
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
                      icon="sync"
                      ml={2.1}
                      content="Reset"
                      onClick={() => act("signallerreset", {
                        reset: "freq",
                      })} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                Code:
              </Table.Cell>
              <Table.Cell>
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
                      icon="sync"
                      ml={2.1}
                      content="Reset"
                      onClick={() => act("signallerreset", {
                        reset: "code",
                      })} />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                Color:
              </Table.Cell>
              <Table.Cell>
                <Button
                    icon="sync"
                    width={13.1}
                    color={color}
                    content={color}
                    onClick={() => act("signallercolor")} />
              </Table.Cell>
            </Table.Row>
          </Table>
          <Button
              mb={-0.1}
              icon="arrow-up"
              content="Send Signal"
              textAlign="center"
              onClick={() => act("signallersignal")} />
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
                    Fingerprints (F) | DNA (D):
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
                      <Box>F: {MedRecord.fingerprint}</Box>
                      <Box>D: {MedRecord.dna}</Box>
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
    case "security records":
      if(selected_sec_record) {
        const { crimes } = data.selected_sec_record;
        const { comments } = data.selected_sec_record;
        return (
          <Section title={modules_tabs[selectedMainTab].title}>
            <Button icon="arrow-left"
              onClick={() => act("sec_record back")}>
                Back
            </Button>
            <Stack vertical ml={2}>
              <Stack.Item>
                Name: {selected_sec_record.name}
              </Stack.Item>
              <Stack.Item>
                ID: {selected_sec_record.id}
              </Stack.Item>
              <Stack.Item>
                Gender: {selected_sec_record.gender}
              </Stack.Item>
              <Stack.Item>
                Age: {selected_sec_record.age}
              </Stack.Item>
              <Stack.Item>
                Rank: {selected_sec_record.rank}
              </Stack.Item>
              <Stack.Item>
                Fingerprint: {selected_sec_record.fingerprint}
              </Stack.Item>
              <Stack.Item>
                Physical Status: {selected_sec_record.p_state}
              </Stack.Item>
              <Stack.Item>
                Mental Status: {selected_sec_record.m_state}
              </Stack.Item>
              <br />
              <Stack.Item>
                Criminal Status: <Button backgroundColor={SecRecordColour(selected_sec_record.criminal_status)}>{selected_sec_record.criminal_status}</Button>
              </Stack.Item>
              <br />
              <Table>
                <Table.Row>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Crime:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Details:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Author:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Time Added:
                  </Table.Cell>
                </Table.Row>
                {crimes.map(crime => (
                  <Table.Row
                    key={crime}>
                    <Table.Cell>
                      {crime.crime_name}
                    </Table.Cell>
                    <Table.Cell>
                      {crime.crime_details}
                    </Table.Cell>
                    <Table.Cell>
                      {crime.author}
                    </Table.Cell>
                    <Table.Cell>
                      {crime.time_added}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
              <br />
              <Table>
                <Table.Row>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Comment:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Author:
                  </Table.Cell>
                  <Table.Cell textAlign={"center"} bold={1}>
                    Time Added:
                  </Table.Cell>
                </Table.Row>
                {comments.map(comment => (
                  <Table.Row
                    key={comment}>
                    <Table.Cell>
                      {comment.comment_text}
                    </Table.Cell>
                    <Table.Cell>
                      {comment.author}
                    </Table.Cell>
                    <Table.Cell>
                      {comment.time}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
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
                  Rank:
                </Table.Cell>
                <Table.Cell textAlign={"center"} bold={1}>
                  Fingerprints:
                </Table.Cell>
                <Table.Cell textAlign={"center"} bold={1}>
                  Criminal Status:
                </Table.Cell>
              </Table.Row>
              {sec_records.map(SecRecord => (
                <Table.Row
                  key={SecRecord}
                  height={3}>
                    <Table.Cell backgroundColor={SecRecordColour(SecRecord.criminal_status)}>
                      <Button
                        onClick={() => act("sec_record", { record: SecRecord.id })} m={1}>
                          {SecRecord.name}
                      </Button>
                    </Table.Cell>
                    <Table.Cell backgroundColor={SecRecordColour(SecRecord.criminal_status)}>
                      {SecRecord.id}
                    </Table.Cell>
                    <Table.Cell backgroundColor={SecRecordColour(SecRecord.criminal_status)}>
                      {SecRecord.rank}
                    </Table.Cell>
                    <Table.Cell backgroundColor={SecRecordColour(SecRecord.criminal_status)}>
                      {SecRecord.fingerprint}
                    </Table.Cell>
                    <Table.Cell backgroundColor={SecRecordColour(SecRecord.criminal_status)}>
                      <Box textAlign="center" bold>
                        {SecRecord.criminal_status}
                      </Box>
                      {SecRecordIcon(SecRecord.criminal_status) && (
                        <Box textAlign="center" bold>
                          <Icon name={SecRecordIcon(SecRecord.criminal_status)} />
                        </Box>
                      )}
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
  return null; // Necessary to avoid "PaiBox cannot be used as a JSX Element. It's Return type 'Element | Undefined' is not a valid JSX component" runtiming
  };
