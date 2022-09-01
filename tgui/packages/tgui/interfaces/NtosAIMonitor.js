import { NtosWindow } from '../layouts';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Box, Section, Tabs, NoticeBox, Flex, ProgressBar, LabeledList, NumberInput, Divider } from '../components';

export const NtosAIMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const [clusterTab, setClusterTab] = useLocalState(context, 'clustertab', 1)

  if (!data.has_ai_net) {
    return (
      <NtosWindow
        width={350}
        height={150}
        resizable>
        <NtosWindow.Content scrollable>
          <Section>
            <NoticeBox>
              No network connection. Please connect to ethernet cable to proceed!
            </NoticeBox>
          </Section>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

  return (
    <NtosWindow
      width={550}
      height={600}
      resizable>
      <NtosWindow.Content scrollable>
        <Fragment>
          <Tabs>
            <Tabs.Tab
              selected={tab === 1}
              onClick={(() => setTab(1))}>
              Cluster Management
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 2}
              onClick={(() => setTab(2))}>
              Networking Devices
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 3}
              onClick={(() => setTab(3))}>
              AI Upload
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 4}
              onClick={(() => setTab(4))}>
              AI Download
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && (
              <Fragment>
                <Divider />
                <Tabs>
                  <Tabs.Tab
                    selected={clusterTab === 1}
                    onClick={(() => setClusterTab(1))}>
                    Resource Allocation
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={clusterTab === 2}
                    onClick={(() => setClusterTab(2))}>
                    Local Computing
                  </Tabs.Tab>
                </Tabs>
              </Fragment>
          )}
          {(clusterTab === 1 && tab === 1) && (
            <ResourceAllocation />
          )}
          {(clusterTab === 2&& tab === 1) && (
            <Section title="poo2"></Section>
          )}
          {tab === 2 && (
            <Section title="Networking Devices">
              <LabeledList>
                {data.networking_devices.map((networker, index) => {
                  return (
                    <LabeledList.Item label={networker.label} buttons={(<Button icon="wifi" color="good" tooltip="Remotely control this device" tooltipPosition="left" onClick={() => act("control_networking", { ref: networker.ref })}>Control</Button>)}>
                      <Box color={networker.has_partner ? "good" : "bad"}>{networker.has_partner ? "ONLINE - CONNECTED TO " + networker.has_partner  : "DISCONNECTED"}</Box>
                    </LabeledList.Item>
                  );
                })}
              </LabeledList>
            </Section>
          )}
          {tab === 3 && (
            <Section title="Upload">
              <Box textAlign="center" mb={0.5}>
                <Button disabled={!data.holding_mmi} color="good" icon="upload" tooltip={!data.holding_mmi ? "You need to be holding an MMI/Posibrain" : ""} onClick={() => act("upload_person")}>Upload from MMI/Posibrain</Button>
              </Box>
              {!data.intellicard && (
                <Flex align="center" justify="center">
                  <Flex.Item>
                    <NoticeBox>No IntelliCard inserted!</NoticeBox>
                  </Flex.Item>
                </Flex>
              ) || (
                <Box>
                  {data.intellicard_ai && (
                    <Flex align="center" justify="center">
                      <Flex.Item width="50%">
                        <Section textAlign="center" title={data.intellicard_ai}>
                          <ProgressBar ranges={{ good: [75, Infinity], average: [25, 75], bad: [-Infinity, 25] }} mb={0.75} minValue="0" maxValue="100" value={data.intellicard_ai_health} />
                          <Button color="good" icon="upload" disabled={!data.can_upload} tooltip={!data.can_upload ? "A common cause of upload being unavailable is a lack of any active AI data cores." : null}
                            onClick={() => act("upload_ai")}>Upload
                          </Button>
                        </Section>
                      </Flex.Item>
                    </Flex>
                  ) || (
                    <Flex align="center" justify="center">
                      <Flex.Item>
                        <NoticeBox>Intellicard contains no AI!</NoticeBox>
                      </Flex.Item>
                    </Flex>
                  )}
                </Box>
              )}
            </Section>
          )}
          {tab === 4 && (
            <Section title="AIs Available for Download">
              {data.downloading && (
                <Fragment>
                  <NoticeBox mb={0.1} danger>Currently downloading {data.downloading}</NoticeBox>
                  <ProgressBar color="bad" minValue="0" value={data.download_progress} maxValue="100" />
                  <Button mt={0.5} fluid color="bad" icon="stop" tooltip="WARNING" textAlign="center" onClick={() => act("stop_download")}>Cancel Download</Button>
                  {!!data.current_ai_ref && data.current_ai_ref === data.downloading_ref && (
                    <Button color="average" icon="download" onClick={() => act("skip_download")}>Instantly finish download</Button>
                  )}
                </Fragment>

              )|| (
                <Box>
                  {data.ai_list.filter(ai => {
                    return !!ai.in_core;
                  }).map((ai, index) => {
                    return (
                      <Section key={index} title={(<Box inline color={ai.active ? "good" : "bad"}>{ai.name} | {ai.active ? "Active" : "Inactive"}</Box>)}
                        buttons={(
                          <Fragment>
                            <Button icon="compact-disc" onClick={() => act("apply_object", { ai_ref: ai.ref })}>Apply Upgrade</Button>
                            <Button color={ai.can_download ? "good" : "bad"} tooltipPosition={"left"} tooltip={!data.intellicard ? ai.can_download ? "Requires IntelliCard" : "&¤!65%" : null} disabled={data.intellicard ? !ai.can_download : true} icon="download" onClick={() => act("start_download", { download_target: ai.ref })}>{ai.can_download ? "Download" : "&gr4&!/"}</Button>
                            {!!data.is_infiltrator && !ai.being_hijacked && (
                              <Button color="good" tooltip="Requires serial exploitation unit" icon="download" onClick={() => act("start_hijack", { target_ai: ai.ref })}>Start hijacking</Button>
                            ) }
                            {!!ai.being_hijacked && (
                              <Button color="bad" icon="stop" onClick={() => act("stop_hijack", { target_ai: ai.ref })}>Stop hijacking</Button>
                            )}
                          </Fragment>
                        )}>
                        <Box bold>Integrity:</Box>
                        <ProgressBar mt={0.5} minValue={0}
                          ranges={{
                            good: [75, Infinity],
                            average: [25, 75],
                            bad: [-Infinity, 25],
                          }}
                          value={ai.health} maxValue={100} />
                      </Section>
                    );
                  })}
                </Box>
              )}
            </Section>
          )}
        </Fragment>
      </NtosWindow.Content>
    </NtosWindow>
  );
};




const ResourceAllocation = (props, context) => {
  const { act, data } = useBackend(context);
  let remaining_cpu = (1 - data.total_assigned_cpu) * 100;

  return (
    <Fragment>
      <Section title="Network CPU Resources">
        <ProgressBar
          value={data.total_assigned_cpu}
          ranges={{
            good: [0.8, Infinity],
            average: [0.4, 0.8],
            bad: [-Infinity, 0.4],
          }}
          maxValue={1}>{data.total_cpu * data.total_assigned_cpu}/{data.total_cpu} THz
          ({data.total_assigned_cpu * 100}%)
        </ProgressBar>
      </Section>
      <Section title="Network RAM Resources">
        <ProgressBar
          ranges={{
            good: [data.total_ram * 0.8, Infinity],
            average: [data.total_ram * 0.4, data.total_ram * 0.8],
            bad: [-Infinity, data.total_ram * 0.4],
          }}
          value={data.total_assigned_ram}
          maxValue={data.total_ram}>{data.total_assigned_ram}/{data.total_ram} TB
        </ProgressBar>
      </Section>
      <Section title="Network Resource Allocation">
        <LabeledList>
          <LabeledList.Item>
            CPU Capacity:
            <Flex>
              <ProgressBar minValue={0} value={data.total_cpu * ai.assigned_cpu}
                maxValue={data.total_cpu} >{data.total_cpu * ai.assigned_cpu} THz
              </ProgressBar>
              <NumberInput width="60px" unit="%" value={ai.assigned_cpu * 100} minValue={0} maxValue={remaining_cpu + (ai.assigned_cpu * 100)} onChange={(e, value) => act('set_cpu', {
                target_ai: ai.ref,
                amount_cpu: Math.round((value / 100) * 100) / 100,
              })} />
              <Button height={1.75} icon="arrow-up" onClick={() => act("max_cpu", {
                target_ai: ai.ref,
              })}>Max
              </Button>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item>
            RAM Capacity:
            <Flex>
              <ProgressBar minValue={0} value={ai.assigned_ram}
                maxValue={data.total_ram} >{ai.assigned_ram} TB
              </ProgressBar>
              <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_ram", {
                target_ai: ai.ref,
              })} />
              <Button height={1.75} icon="minus" onClick={() => act("remove_ram", {
                target_ai: ai.ref,
              })} />
            </Flex>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Active AI's">
        <LabeledList>
          {data.ai_list.map((ai, index) => {
            return (
              <Section key={index} title={ai.name}
                buttons={(
                  <Button icon="trash" onClick={() => act("clear_ai_resources", { target_ai: ai.ref })}>Clear AI Resources</Button>
                )}>
                <LabeledList.Item>
                  CPU Capacity:
                  <Flex>
                    <ProgressBar minValue={0} value={data.total_cpu * ai.assigned_cpu}
                      maxValue={data.total_cpu} >{data.total_cpu * ai.assigned_cpu} THz
                    </ProgressBar>
                    <NumberInput width="60px" unit="%" value={ai.assigned_cpu * 100} minValue={0} maxValue={remaining_cpu + (ai.assigned_cpu * 100)} onChange={(e, value) => act('set_cpu', {
                      target_ai: ai.ref,
                      amount_cpu: Math.round((value / 100) * 100) / 100,
                    })} />
                    <Button height={1.75} icon="arrow-up" onClick={() => act("max_cpu", {
                      target_ai: ai.ref,
                    })}>Max
                    </Button>
                  </Flex>
                </LabeledList.Item>
                <LabeledList.Item>
                  RAM Capacity:
                  <Flex>
                    <ProgressBar minValue={0} value={ai.assigned_ram}
                      maxValue={data.total_ram} >{ai.assigned_ram} TB
                    </ProgressBar>
                    <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_ram", {
                      target_ai: ai.ref,
                    })} />
                    <Button height={1.75} icon="minus" onClick={() => act("remove_ram", {
                      target_ai: ai.ref,
                    })} />
                  </Flex>

                </LabeledList.Item>
              </Section>
            );
          })}
        </LabeledList>
      </Section>
    </Fragment>
  );
};
