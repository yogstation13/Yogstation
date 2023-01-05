import { classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Fragment, Icon, NoticeBox, ColorBox, Section, Slider, ProgressBar, LabeledList, Table, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosRobotact = (props, context) => {
  const { act, data } = useBackend(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow
      width={800}
      height={400}
      theme={PC_device_theme}>
      <NtosWindow.Content>
        <NtosRobotactContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosRobotactContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab_main, setTab_main] = useSharedState(context, 'tab_main', 1);
  const [tab_sub, setTab_sub] = useSharedState(context, 'tab_sub', 1);
  const {
    charge,
    maxcharge,
    integrity,
    lampIntensity,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
    alertLength,
    sensors,
    printerPictures,
    printerToner,
    printerTonerMax,
    cameraActive,
    thrustersInstalled,
    thrustersStatus,
    light_on,
    comp_light_color,
  } = data;
  const borgName = data.name || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
  const borgUpgrades = data.borgUpgrades || [];
  return (
    <Flex
      direction={"column"}>
      <Flex.Item
        position="relative"
        mb={1}>
        <Tabs>
          <Tabs.Tab
            icon="heart"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}>
            Status
          </Tabs.Tab>
          <Tabs.Tab
            icon="list-ol"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}>
            Laws
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 3}
            onClick={() => setTab_main(3)}>
            Logs
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      {tab_main === 1 && (
        <Flex
          direction={"row"}>
          <Flex.Item
            width="50%">
            <Section
              title="Details"
              buttons={(
                <Button
                  content="Power Alert"
                  disabled={charge}
                  onClick={() => act('alertPower')} />
              )}>
              <LabeledList>
                <LabeledList.Item
                  label="Unit">
                  {borgName.slice(0, 17)}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Type">
                  {borgType}
                </LabeledList.Item>
                <LabeledList.Item
                  label="AI">
                  {masterAI.slice(0, 17)}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Charge">
                  <ProgressBar
                    value={charge / maxcharge}
                    ranges={{
                      good: [0.5, Infinity],
                      average: [0.1, 0.5],
                      bad: [-Infinity, 0.1],
                    }}>
                    <AnimatedNumber value={charge} />
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item
                  label="Chassis Integrity">
                  <ProgressBar
                    value={integrity}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      bad: [-Infinity, 25],
                      average: [25, 75],
                      good: [75, Infinity],
                    }} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section
              title="Lamp"
              buttons={(
                <Fragment>
                  <Button
                    width="144px"
                    icon="lightbulb"
                    selected={light_on}
                    onClick={() => act('toggle_light')}>
                    Flashlight: {light_on ? 'ON' : 'OFF'}
                  </Button>
                  <Button
                    ml={1}
                    mr={1}
                    onClick={() => act('light_color')}>
                    Color:
                    <ColorBox ml={1} color={comp_light_color} />
                  </Button>
                  <Button
                    icon="angle-up"
                    disabled={lampIntensity >= 5}
                    onClick={() => act('lampIntensity', {
                      ref: lampIntensity + 1,
                    })} />
                  <Button
                    icon="angle-down"
                    disabled={lampIntensity <= 1}
                    onClick={() => act('lampIntensity', {
                      ref: lampIntensity - 1,
                    })} />
                </Fragment>
              )}>
              <Slider
                value={lampIntensity}
                step={1}
                stepPixelSize={25}
                maxValue={5}
                minValue={1}
                onChange={(e, value) => act('lampIntensity', {
                  ref: value,
                })} />
              Lamp power usage: {lampIntensity/2} watts
            </Section>
          </Flex.Item>
          <Flex.Item
            width="50%"
            ml={1}>
            <Section
              fitted>
              <Tabs
                fluid={1}
                textAlign="center">
                <Tabs.Tab
                  icon=""
                  lineHeight="23px"
                  selected={tab_sub === 1}
                  onClick={() => setTab_sub(1)}>
                  Actions
                </Tabs.Tab>
                <Tabs.Tab
                  icon=""
                  lineHeight="23px"
                  selected={tab_sub === 2}
                  onClick={() => setTab_sub(2)}>
                  Upgrades
                </Tabs.Tab>
                <Tabs.Tab
                  icon=""
                  lineHeight="23px"
                  selected={tab_sub === 3}
                  onClick={() => setTab_sub(3)}>
                  Diagnostics
                </Tabs.Tab>
              </Tabs>
            </Section>
            {tab_sub === 1 && (
              <Section>
                <LabeledList>
                  <LabeledList.Item
                    label={"Alerts (" + alertLength + ")"}>
                    <Button
                      content="View"
                      onClick={() => act('viewAlerts')} />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Maintenance Cover">
                    <Button.Confirm
                      content="Unlock"
                      disabled={cover==="UNLOCKED"}
                      onClick={() => act('coverunlock')} />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Sensor Overlay">
                    <Button
                      content={sensors}
                      onClick={() => act('toggleSensors')} />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label={"Stored Photos (" + printerPictures + ")"}>
                    <Button
                      content="View"
                      disabled={!printerPictures}
                      onClick={() => act('viewImage')} />
                    <Button
                      content="Print"
                      disabled={!printerPictures}
                      onClick={() => act('printImage')} />
                    <Button
                      icon="camera"
                      selected={cameraActive}
                      onClick={() => act('takeImage')} />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Printer Toner">
                    <ProgressBar
                      value={printerToner / printerTonerMax} />
                  </LabeledList.Item>
                  {!!thrustersInstalled && (
                    <LabeledList.Item
                      label="Toggle Thrusters">
                      <Button
                        content={thrustersStatus}
                        onClick={() => act('toggleThrusters')} />
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item
                    label="Self Destruct">
                    <Button.Confirm
                      content="ACTIVATE"
                      color="red"
                      onClick={() => act('selfDestruct')} />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
            {tab_sub === 2 && (
              <Section>
                {borgUpgrades.map(upgrade => (
                  <Box
                    mb={1}
                    key={upgrade}>
                    {upgrade}
                  </Box>
                ))}
              </Section>
            )}
            {tab_sub === 3 && (
              <Section>
                <LabeledList>
                  <LabeledList.Item
                    label="AI Connection"
                    color={wireAI==="FAULT"?'red': wireAI==="READY"?'yellow': 'green'}>
                    {wireAI}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="LawSync"
                    color={wireLaw==="FAULT"?"red":"green"}>
                    {wireLaw}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Camera"
                    color={wireCamera==="FAULT"?'red': wireCamera==="DISABLED"?'yellow': 'green'}>
                    {wireCamera}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Module Controller"
                    color={wireModule==="FAULT"?"red":"green"}>
                    {wireModule}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Motor Controller"
                    color={locomotion==="FAULT"?'red': locomotion==="DISABLED"?'yellow': 'green'}>
                    {locomotion}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Maintenance Cover"
                    color={cover==="UNLOCKED"?"red":"green"}>
                    {cover}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      )}
      {tab_main === 2 && (
        <Flex.Item
          height={24}>
          <Section
            title="Laws"
            fill
            scrollable
            buttons={(
              <Fragment>
                <Button
                  content="State Laws"
                  onClick={() => act('lawstate')} />
                <Button
                  icon="volume-off"
                  onClick={() => act('lawchannel')} />
              </Fragment>
            )}>
            {laws.map(law => (
              <Box
                mb={1}
                key={law}>
                {law}
              </Box>
            ))}
          </Section>
        </Flex.Item>
      )}
      {tab_main === 3 && (
        <Flex.Item>
          <Section
            backgroundColor="black"
            height={24}>
            <NtosWindow.Content scrollable>
              {borgLog.map(log => (
                <Box
                  mb={1}
                  key={log}>
                  <font color="green">{log}</font>
                </Box>
              ))}
            </NtosWindow.Content>
          </Section>
        </Flex.Item>
      )}
    </Flex>
  );
};
