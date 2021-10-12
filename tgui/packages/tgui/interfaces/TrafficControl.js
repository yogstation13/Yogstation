import { useBackend } from '../backend';
import { Button, LabeledList, Section, Icon, Divider, ByondUi, Box } from '../components';
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
      let normal = 'color:rgb(0,128,255';
      let classy = 'color:rgb(255,0,128)';
      let operator = 'color:rgb(255,128,0)';
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
          return (<pre>{my_txt}</pre>);
        }
        let rgx = new RegExp("(.*)(" + keywords[lvl][0] + ")(.*)");

        let arr = my_txt.match(rgx);
        if(!arr)
        {
          return recurse(my_txt,lvl+1);
        }
        return (
          <pre>
          {recurse(arr[1],lvl+1)}
          <span style={keywords[lvl][1]}>{arr[2]}</span>
          {recurse(arr[3],lvl+1)}
          </pre>
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
        <Section>
        <textarea ref={this.textareaRef} onInput={this.handleOnInput} id='joao_textarea' maxlength='32000'>{text}</textarea>
        <code id='joao_code' ref={this.codeRef}>
          {this.lexify(text)}
        </code>
        </Section>
    );
  }
}

export const TrafficControl = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    auth,
    screen_state,
  } = data;
  const cooler_auth = auth ? auth : "NO ACCESS"
  if(screen_state == 0) // MAIN MENU
  {
      return (
        <Window resizable title="Traffic Control Computer">
            <Window.Content scrollable>
                
                Identification: <Button onClick={() => act('auth', {})} color={(auth)
                  ? 'good'
                  : 'bad'}><Icon name="address-card">  </Icon>{cooler_auth}</Button>
                <Divider></Divider>
                <JoaoBox></JoaoBox>
            </Window.Content>
        </Window>
      );
  }
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Health status">
          <LabeledList>
            <LabeledList.Item label="Health">
              {health}
            </LabeledList.Item>
            <LabeledList.Item label="Color">
              {color}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Dispatch a 'test' action"
                onClick={() => act('test')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
