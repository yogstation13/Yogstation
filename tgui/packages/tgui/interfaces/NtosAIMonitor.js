import { NtosWindow } from '../layouts';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Box, Section, Tabs, NoticeBox, Flex, ProgressBar } from '../components';

export const NtosAIMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);

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
      width={500}
      height={450}
      resizable>
      <NtosWindow.Content scrollable>
        <Fragment>
          <Tabs>
            <Tabs.Tab
              selected={tab === 1}
              onClick={(() => setTab(1))}>
              Networking Devices
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 2}
              onClick={(() => setTab(2))}>
              AI Upload
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === 3}
              onClick={(() => setTab(3))}>
              AI Download
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && (
            <Section title="poo" />
          )}
          {tab === 2 && (
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
          {tab === 3 && (
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
