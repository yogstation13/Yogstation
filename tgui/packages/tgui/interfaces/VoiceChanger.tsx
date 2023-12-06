import { useBackend } from '../backend';
import { Dropdown, LabeledList, Knob } from '../components';
import { Window } from '../layouts';

type Data = {
  voice_list: Array<string>;
  voice_display: Record<string, string>;
  current_voice: string;
  current_pitch: number;
  emp: boolean;
};

export const VoiceChanger = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  return (
    <Window theme='syndicate' title='Voice Changer' width={300} height={270}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Voice">
            <Dropdown
              disabled={data.emp === true}
              selected={data.current_voice}
              onSelected={(newValue: string) => act('change_voice', {
                voice: newValue,
              })}
              displayText={data.voice_display[data.current_voice]}
              width='100%'
              options={
                data.voice_list
                  .map(choice => {
                    return {
                      displayText: data.voice_display[choice],
                      value: choice,
                    };
                  })
              } />
          </LabeledList.Item>
          <LabeledList.Item label="Pitch">
            <Knob
              disabled={data.emp === true}
              value={data.current_pitch}
              minValue={0.8}
              maxValue={1.2}
              step={0.01}
              onChange={(e, newValue: string) => act('change_pitch', {
                pitch: newValue,
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
