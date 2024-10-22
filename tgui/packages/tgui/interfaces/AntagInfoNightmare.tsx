import { BlockQuote, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoNightmare = (props) => {
  return (
    <Window width={620} height={470}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">You are a Nightmare.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature from beyond the stars that has incredibly
                    strong powers in the darkness, becoming nigh unbeatable.
                    Unfortunately, you wither and burn away in the light. You
                    must use your
                    <span style={noticestyle}>&ensp;light eater</span> to dim
                    the station, making hunting easier.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Tip #1:&ensp;</span>
                  Move often. The station will be hunting you after you are
                  discovered, so don&apos;t stay in one area for long.
                  <br />
                  <span style={tipstyle}>Tip #2:&ensp;</span>
                  Pick unfair fights. You are incredibly strong in one versus
                  one situations, use it. The more you fight, the harder it will
                  be to keep it dark.
                  <br />
                  <span style={tipstyle}>Tip #3:&ensp;</span>
                  Fully destroy APCs when possible. Instead of hunting lights
                  that can be fixed, hunt the APCs which are harder to repair.
                  Additionally, breaking APCs will dim lighting, which your
                  light eater can automatically snuff out for you.
                  <br />
                  <span style={tipstyle}>Tip #4:&ensp;</span>
                  Since your light eater automatically snuffs out nearby lights,
                  you don&apos;t have to worry about things like the green glow
                  of APCs. This works even while jaunting, allowing you to black
                  out entire rooms in seconds if the power is off.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Powers">
              <LabeledList>
                <LabeledList.Item label="Shadow Dance">
                  Whilst in the shadows, you are immune to all ranged attacks,
                  whilst also rapidly regenerating health and slowly recovering
                  from wounds. However, lasers will bypass this, as they produce
                  a lot of light.
                </LabeledList.Item>
                <LabeledList.Item label="Shadow Walk">
                  You are allowed unlimited, unrestricted movement in the dark.
                  While jaunting, your natural healing is amplified. Light will
                  pull you out of this.
                </LabeledList.Item>
                <LabeledList.Item label="Heart of Darkness">
                  Your heart invites the shadows. If you die in the darkness,
                  you will eventually revive if left alone.
                </LabeledList.Item>
                <LabeledList.Item label="Light Eater">
                  Your twisted appendage. It will consume the light of what it
                  touches, be it victim or object. When unobstructed by bright
                  light, it&apos;ll lash out at anything dim in your vicinity,
                  completely hiding you in the shadows.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
