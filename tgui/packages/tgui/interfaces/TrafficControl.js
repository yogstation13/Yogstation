import { useBackend } from '../backend';
import { useDispatch } from '../../common/redux';
import { Button, LabeledList, Section, Icon, Divider, ByondUi, Box, Tabs, NoticeBox } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';
import { Component, createRef, createTextVNode } from 'inferno';

export class JoaoBox extends Component {
  constructor(props, context) {
    super(props, context);
    this.textareaRef = createRef();
    this.codeRef = createRef();
    this.state = {
      text: "",
      cursorloc: 0,
    };
    this.handleOnInput = e => {
      if(e.target.value !== "")
      {
        this.state.text = e.target.value;
      }

      this.forceUpdate();
    };
    this.lexify = txt =>
    {
      let normal = 'rgb(0,128,255';
      let classy = 'rgb(255,0,128)';
      let operator = 'rgb(255,128,0)';
      let keywords = [
        ["main", normal],
        ["return",normal],
        ["Value",classy],
        ["Object",classy],
      ]
      function recurse(my_txt,lvl)
      {
        if(lvl >= keywords.length)
        {
          return <Box inline preserveWhitespace >{my_txt}</Box>;
        }
        let rgx = new RegExp("(.*)(" + keywords[lvl][0] + ")(.*)");

        let arr = my_txt.match(rgx);
        if(!arr)
        {
          return recurse(my_txt,lvl+1);
        }
        /*
        return (
          <pre>
          {recurse(arr[1],lvl+1)}
          <span style={keywords[lvl][1]}>{arr[2]}</span>
          {recurse(arr[3],lvl+1)}
          </pre>
        );
        */
        return (
          <Box>
          {recurse(arr[1],lvl+1)}
          <Box color={keywords[lvl][1]} inline backgroundColor='rgba(255,255,255,0)'>{arr[2]}</Box>
          {recurse(arr[3],lvl+1)}
          </Box>
        );
      }
      
      return recurse(txt,0);
    }
  }

  getValue() {
    return this.state.text;
  }

  render() {
    const { text, cursorloc } = this.state;
    return (
        <Box>
        <textarea ref={this.textareaRef} onInput={this.handleOnInput} id='joao_textarea' maxlength='32000' scrollable={false}>{text}</textarea>
        <code id='joao_code' ref={this.codeRef} scrollable={false}>
          {this.lexify(text)}
        </code>
        </Box>
    );
  }
}

export const TrafficControl = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    auth,
    screen_state,
    is_authorized,
    servers,
    serverSelected_id,
    serverSelected_enabledcode,
    logs
  } = data;
  const cooler_auth = auth ? auth : "NO ACCESS";
  const dispatch = useDispatch(context);
  if(!is_authorized)
  {
    return (
      <Window title="Traffic Control Computer" width={480} height={480}>
          <Window.Content>
              
              Identification: <Button onClick={() => act('auth', {})} color={(auth)
                ? 'good'
                : 'bad'}><Icon name="address-card">  </Icon>{cooler_auth}</Button>
              <Divider></Divider>
              <NoticeBox textAlign='center' danger>
              <Icon name='exclamation-triangle' size={5}></Icon><br></br>
              No Authorization Found!<br></br>
              Please insert identification card to continue.
              </NoticeBox>
          </Window.Content>
      </Window>
    );
  }

  if(screen_state == 0) // MAIN MENU
  {
      const server_list = (servers && servers.map((server) => {
        let should_be_disabled = serverSelected_id != -1 && server == serverSelected_id;
        return <LabeledList.Item
          label={server}
          buttons={(
            <Button onClick ={() => act('select', {'server_id': server})} disabled={should_be_disabled}>
              {should_be_disabled ? "Server Selected" : "Select Server"}
            </Button>
          )}>
        </LabeledList.Item>
      })) || "";

      const server_display = (serverSelected_id != -1 && (
       <Section title='Server Information'>
         <Box>Name: {serverSelected_id}</Box>
         <Box>Code execution status: <Button onClick={() => act('toggle_code', {})} color={(serverSelected_enabledcode)
                  ? 'good'
                  : 'bad'}>
                    {(serverSelected_enabledcode ? "Enabled" : "Disabled")}</Button></Box>
         <Button onClick={() => act('goto', {"screen_state":3})}>View Code</Button>
       </Section> 
      )) || (<NoticeBox textAlign='center' warning>No Server Selected!</NoticeBox>);
      return (
        <Window resizable title="Traffic Control Computer">
            <Window.Content scrollable>
                
                Identification: <Button onClick={() => act('auth', {})} color={(auth)
                  ? 'good'
                  : 'bad'}><Icon name="address-card"></Icon>{cooler_auth}</Button>
                <Divider></Divider>
                <Tabs>
                <Tabs.Tab selected={1}>
                  Server List
                </Tabs.Tab>
                <Tabs.Tab selected={0} onClick={() => {act('goto',{"screen_state":2})}}>
                  Computer Logs
                </Tabs.Tab>
                </Tabs>
                <LabeledList>
                  <Button onClick={() => {act('scan',{})}}><Icon name='binoculars'></Icon>Scan for Servers</Button>
                  {server_list}
                </LabeledList>
                <Divider></Divider>
                {server_display}
            </Window.Content>
        </Window>
      );
  }
  if(screen_state == 2) // COMPUTER LOGS
  {
    const log_list = (logs && logs.map((log) => {
      return <Box>
        {log}
      </Box>
    })) || "";
    return (<Window resizable title="Traffic Control Computer">
      <Window.Content scrollable>
        Identification: <Button onClick={() => act('auth', {})} color={(auth)
          ? 'good'
          : 'bad'}><Icon name="address-card">  </Icon>{cooler_auth}</Button>
        <Divider></Divider>
        <Tabs>
        <Tabs.Tab selected={0} onClick={() => {act('goto',{"screen_state":0})}}>
          Server List
        </Tabs.Tab>
        <Tabs.Tab selected={1}>
          Computer Logs
        </Tabs.Tab>
        </Tabs>
        {log_list}
      </Window.Content>
    </Window>);
  }

  return (
  <Window resizable title="Traffic Control Computer">
    <Window.Content scrollable>
        
        Identification: <Button onClick={() => act('auth', {})} color={(auth)
          ? 'good'
          : 'bad'}><Icon name="address-card">  </Icon>{cooler_auth}</Button>
        <Divider></Divider>
        <Tabs>
        <Tabs.Tab selected={0}>
           <Button onClick={() =>  act('goto', {screen_state: 0})}>Server List</Button>
        </Tabs.Tab>
        <Tabs.Tab selected={0}>
          <Button onClick={() =>  act('goto', {screen_state: 2})}>Computer Logs</Button>
        </Tabs.Tab>
        </Tabs>
        <NoticeBox textAlign='center' danger>
        <Icon name='bug' size={5}></Icon><br></br>
        You found a bug!<br></br>
        Please report this to Altoids on the Yogstation Discord.
        </NoticeBox>
    </Window.Content>
  </Window>);
};
