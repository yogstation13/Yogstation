import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, Stack, Tabs } from '../components';

import { NtosWindow } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';
import { jobIsHead, jobToColor } from './CrewConsoleNova';

type Data = {
  selected: string;
  settings: Settings;
  sensors: CrewSensor[];
};

type Settings = {
  sortBy: string;
  sortAsc: boolean;
  blueshield: boolean;
};

type CrewSensor = {
  dev: string;
  ref: string;
  name: string;
  assignment: string;
  trim: string;
  ijob: number;
  area: String;
  dist: number;
  degrees: number;
  zdiff: number;
};

const SORT_NAMES = {
  dist: 'Distance',
  ijob: 'Job',
  name: 'Name',
  area: 'Area',
};

const SORT_OPTIONS = ['dist', 'ijob', 'name', 'area'];

const areaSort = (a: CrewSensor, b: CrewSensor) => {
  a.area ??= '~';
  b.area ??= '~';
  if (a.area < b.area) return -1;
  if (a.area > b.area) return 1;
  return 0;
};

export const NtosLifeline = () => {
  return (
    <NtosWindow width={400} height={600} theme="ntos">
      <NtosLifelineContent />
    </NtosWindow>
  );
};

const NtosLifelineContent = () => {
  const { data, act } = useBackend<Data>();
  const { sensors, settings } = data;
  const { sortAsc, sortBy, blueshield } = settings;

  const setSortAsc = (val: boolean) => {
    act('sortAsc', { val: val });
  };
  const setSortBy = (val: string) => {
    act('sortBy', { val: val });
  };
  const setBlueshield = (val: boolean) => {
    act('blueshield', { val: val });
  };
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    'searchQuery',
    '',
  );

  const cycleSortBy = () => {
    let idx = SORT_OPTIONS.indexOf(sortBy) + 1;
    if (idx === SORT_OPTIONS.length) idx = 0;
    setSortBy(SORT_OPTIONS[idx]);
  };

  const nameSearch = createSearch(
    searchQuery,
    (crew: CrewSensor) => crew.name + crew.assignment,
  );

  const sorted = sensors
    .filter(nameSearch)
    .filter(
      (sensor) =>
        !blueshield ||
        jobIsHead(sensor.ijob) ||
        (sensor.ijob >= 200 && sensor.ijob < 300),
    )
    .sort((a, b) => {
      if (a.dist < 0 || b.dist < 0) {
        return b.dist - a.dist;
      }
      switch (sortBy) {
        case 'name':
          return sortAsc ? +(a.name > b.name) : +(b.name > a.name);
        case 'ijob':
          return sortAsc ? a.ijob - b.ijob : b.ijob - a.ijob;
        case 'dist':
          return sortAsc ? a.dist - b.dist : b.dist - a.dist;
        case 'area':
          return sortAsc ? areaSort(a, b) : areaSort(b, a);
        default:
          return 0;
      }
    });

  return (
    <NtosWindow.Content scrollable minHeight="540px">
      <Stack vertical>
        <Stack.Item>
          <Flex>
            <Input
              placeholder="Search for name..."
              style={{ flex: 1 }}
              onInput={(e: { target: HTMLTextAreaElement }) =>
                setSearchQuery((e.target as HTMLTextAreaElement).value)
              }
            />
            <Button selected="True" onClick={cycleSortBy}>
              {SORT_NAMES[sortBy]}
            </Button>
            <Button selected="True" onClick={() => setSortAsc(!sortAsc)}>
              <Icon
                style={{ marginLeft: '2px' }}
                name={sortAsc ? 'chevron-up' : 'chevron-down'}
              />
            </Button>
            <Button.Checkbox
              checked={blueshield}
              onClick={() => setBlueshield(!blueshield)}
            >
              <Icon name={JOB2ICON['Blueshield']} />
            </Button.Checkbox>
          </Flex>
        </Stack.Item>
        <Stack.Item>
          {sorted.map((object, index) => (
            <CrewTab key={index} sensor={object} />
          ))}
        </Stack.Item>
      </Stack>
    </NtosWindow.Content>
  );
};

const CrewTab = (props: { sensor: CrewSensor }) => {
  const { act, data } = useBackend<Data>();
  const { sensor } = props;
  const selected = data.selected === sensor.ref;

  return (
    <Tabs.Tab
      className="candystripe"
      label="name"
      selected={selected}
      onClick={() => {
        act('select', {
          ref: sensor.ref,
        });
      }}
      style={{ margin: '2px 2px 0px 0px' }}
    >
      <Icon
        name={selected ? 'check-square-o' : 'square-o'}
        style={{ float: 'left', padding: '4px 4px 4px 2px' }}
      />
      <Box style={{ display: 'flex' }}>
        <Box>
          <Icon
            color={jobToColor(sensor.ijob)}
            name={JOB2ICON[sensor.trim] || 'question'}
            width="25px"
            style={{ float: 'left', padding: '4px' }}
          />
        </Box>
        <Box>
          <span
            style={{
              color: jobToColor(sensor.ijob),
              ...(jobIsHead(sensor.ijob) && { 'font-weight': 'bold' }),
            }}
          >
            {sensor.name} ({sensor.assignment})
          </span>
          <br />
          <SensorLocation sensor={sensor} />
        </Box>
      </Box>
    </Tabs.Tab>
  );
};

const SensorLocation = (props: { sensor: CrewSensor }) => {
  const { sensor } = props;
  const dist = sensor.dist;

  if (dist >= 0) {
    let zdiff = '-';
    if (sensor.zdiff > 0) {
      zdiff = '↑'.repeat(sensor.zdiff);
    } else if (sensor.zdiff < 0) {
      zdiff = '↓'.repeat(-sensor.zdiff);
    }
    return (
      <span>
        {sensor.dist > 0 && (
          <Icon mr={0.2} size={0.8} name="arrow-up" rotation={sensor.degrees} />
        )}
        {sensor.dist}m {zdiff} [{sensor.area}]
      </span>
    );
  }
  if (dist === -1) {
    return <Icon name="question" size={0.9} />;
  }
  const zdiff =
    sensor.zdiff === 0 ? (
      <Icon name="house" size={0.9} />
    ) : (
      <Icon name="volcano" size={0.9} />
    );

  if (dist === -2) {
    return (
      <span>
        {zdiff} [{sensor.area}]
      </span>
    );
  }
  return { ...zdiff };
};
