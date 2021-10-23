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
    this.buttonRef = createRef();
    this.state = {
      text: "",
      cursorloc: 0,
    };
    this.act = props.act;
    this.handleOnInput = e => {
      if(e.target.value !== "")
      {
        this.state.text = e.target.value;
      }
      this.state.cursorloc = e.target.selectionStart;
      this.forceUpdate();
      this.fixcursor(e.target);
    };
    this.fixcursor = (node) => {
      //Hope to Allah you don't have IE8
      node.selectionStart = this.state.cursorloc;
      node.selectionEnd = this.state.cursorloc;
    };
    this.lexify = (txt) =>
    {
      let normal = 'rgb(0,128,255)';
      let classy = 'rgb(255,0,128)';
      let operator = 'rgb(255,128,0)';
      var keywords = [
        ["main", normal],
        ["return",normal],
        ["Value",classy],
        ["Object",classy],
        ["\/",operator],
        ["\{",operator],
        ["\}",operator],
      ]
      function recurse(my_txt,lvl)
      {
        if(!my_txt)
        {
          return;
        }
        if(lvl >= keywords.length)
        {
          return my_txt;
        }
        // I wanted to use regexes here like a sensible person but a certain flag I want doesn't work on my machine so, bollocks to that
        let keyword = keywords[lvl][0];
        let colour = keywords[lvl][1];
        if(!keyword)
        {
          return (<pre>Couldn't understand what the keyword was!</pre>);
        }
        //Try to find our keyword
        let index = my_txt.search(keyword);
        if(index === -1) // if keyword not found
          return recurse(my_txt,lvl+1);
        
        let header = my_txt.substring(0,index);
        let footer = my_txt.substring(index+keyword.length);
        return (
          <font>
          {recurse(header,lvl+1)}
          <font color={colour}>{keyword}</font>
          {recurse(footer,lvl+1)}
          </font>
        );
      }
      
      return (
      <pre>{recurse(txt,0)}</pre>
      );
    }
  }

  getValue() {
    return this.state.text;
  }

  render() {
    const { text } = this.state;
    return (
        <Box>
        <textarea ref={this.textareaRef} onInput={this.handleOnInput} id='joao_textarea'
         maxlength={32000} scrollable={false}>{text}</textarea>
        <code id='joao_code' ref={this.codeRef} scrollable={false}>
          {this.lexify(text)}
        </code>
        <Button ref={this.buttonRef} onClick={() => {this.act('savecode',{"code": this.state.text})}}>Save Code</Button>
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
  if(screen_state == 3) // SCREEN_CODING
  {
    return (
    <Window resizable title="Traffic Control Computer" theme="hackerman">
      <Window.Content>
        <JoaoBox act={act}>Input code here...</JoaoBox>
        <Button onClick = {() => {act('back',{})}}>Back</Button>
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
