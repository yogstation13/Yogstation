import { useBackend } from '../backend';
import { Box, Button, Divider, Section, LabeledList, Icon, NoticeBox, Input, ProgressBar, Tooltip, Flex } from '../components';
import { Window } from '../layouts';


const generate_server_list = (servers, act) => {
  if (!servers || servers.length === 0)
  {
    return (
      <NoticeBox textAlign="center" warning>
        <Icon name="exclamation-triangle" size={5} /><br />
        No Servers stored in Buffer!<br />
        Please scan for servers to continue.
      </NoticeBox>
    );
  }
  const mapped_servers = servers.map(server => {
    return (<LabeledList.Item
      key={server}
      label={server}
      buttons={(
        <Button onClick={() => act('ViewServer', { 'server_id': server })}>
          Select Server
        </Button>
      )} />);
  });
  return mapped_servers;
};

const generate_logs = (logs, act) => {
  if (!logs || logs.length === 0)
  {
    return (
      <NoticeBox textAlign="center" warning>
        <Icon name="exclamation-triangle" size={5} /><br />
        No logs detected!<br />
      </NoticeBox>
    );
  }
  let mapped_logs = [];
  for (const [index, log] of Object.entries(logs)) {
    if (log["is_error"])
    {
      mapped_logs.push(
        <Box>
          <Button backgroundColor="bad" onClick={(e, value) => { act('DeleteLog', { "name": log["packet_id"] }); }}>Delete</Button>
          <NoticeBox textAlign="center" warning mb={2} pb={2} pl={1} pt={1}>
            <Icon name="exclamation-triangle" size={2} /><br />
            {log["message"]}
          </NoticeBox>
        </Box>);
    }
    else
    {
      if (log["job"])
      {
        mapped_logs.push(
          <Box backgroundColor="#333340" mb={2} pb={2} pl={1} pt={1} nowrap={false}>
            <Box>
              <Button backgroundColor="bad" onClick={(e, value) => { act('DeleteLog', { "name": log["packet_id"] }); }}>Delete</Button> {log["packet_id"]} 
            </Box>
            <Divider />
            <b>Name: </b> {log["name"]}<br />
            <b>Job: </b> {log["job"]}<br />
            <b>Received Message: </b> {log["message"]}<br />
                        
          </Box>
        );
        continue;
      }
      mapped_logs.push(
        <Box backgroundColor="#333340" mb={2} pb={2} pl={1} pt={1} nowrap={false}>
          <Box>
            <Button backgroundColor="bad" onClick={(e, value) => { act('DeleteLog', { "name": log["packet_id"] }); }}>Delete</Button> {log["packet_id"]}
          </Box>
          <b>Name: </b> {log["name"]}<br />
          <b>Received Message: </b> {log["message"]}<br />
          <Button bad onClick={(e, value) => { act('DeleteLog', { "name": log["packet_id"] }); }}>Delete</Button>
        </Box>);
    }
  }
  return mapped_logs;
};

export const LogBrowser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen_state,
    network,
    //
    servers,
    //
    selected_name,
    logs,
    totaltraffic,
    define_max_storage,
  } = data;

  if (screen_state === 0) // MAIN MENU
  {
    return (
      <Window 
        title="Telecommunications Monitoring Console"
        width={460}
        height={550}>
        <Window.Content>
          <Box>
            Current network: <Input placeholder={network ? network : "NO NETWORK"} onChange={(e, value) => { act('SetNetwork', { "network": value }); }} />
          </Box>
          <Divider />
          <Button onClick={(e, value) => { act('Scan', {}); }}><Icon name="binoculars" />Scan for Servers</Button>
          <Section>
            {generate_server_list(servers, act)}
          </Section>
        </Window.Content>
      </Window>
    );
  }
  else if (screen_state === 1) // SERVER LOGS
  {
    return (
      <Window 
        title="Telecommunications Monitoring Console"
        width={460}
        height={550}>
        <Window.Content scrollable>
          <Flex>
            <Flex.Item>
              <Button onClick={(e, value) => { act('Back', {}); }}><Icon name="backward" />Back</Button>
            </Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item>
              <Button onClick={(e, value) => { act('Refresh', {}); }}><Icon name="sync-alt" />Refresh</Button>
            </Flex.Item>
          </Flex>
          <Divider />
          <Section title="Server Information">
            <Icon name="wifi" size={1} />&emsp;Network:<br /> {network}<br /><br />
            <Icon name="server" size={1} />&emsp;Server:<br />{selected_name}<br /><br />
            <Box position="relative">
              <Icon name="project-diagram" />&emsp;Total Traffic Storage:<Tooltip
                position="bottom-right"
                content="The total log storage capacity of the server. Old logs are deleted if the storage becomes full." />
              <ProgressBar
                ranges={{
                  good: [0, define_max_storage * 0.50],
                  average: [define_max_storage * 0.50, define_max_storage * 0.70],
                  bad: [define_max_storage * 0.70, define_max_storage],
                }}
                minValue={0}
                maxValue={define_max_storage}
                value={totaltraffic}>{totaltraffic} GB
              </ProgressBar>
            </Box>
          </Section>
          <Section title="Stored Logs">
            {generate_logs(logs, act)}
          </Section>
        </Window.Content>
      </Window>
    );
  }
  
};
