import { useBackend } from '../backend';
import { Button, Section, Flex } from '../components';
import { Window } from '../layouts';

export const BrigTimer = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={300}
      height={138}>
      <Window.Content scrollable>
        <Section
          title="Cell Timer"
          buttons={(
            <>
              <Button
                icon="clock-o"
                content={data.timing ? 'Stop' : 'Start'}
                selected={data.timing}
                onClick={() => act(data.timing ? 'stop' : 'start')} />
              <Button
                icon="lightbulb-o"
                content={data.flash_charging ? 'Recharging' : 'Flash'}
                disabled={data.flash_charging}
                onClick={() => act('flash')} />
              <Button
                icon="id-card-alt"
                content={data.desired_name ? data.desired_name : "Enter Prisoner Name"}
                onClick={() => act("prisoner_name")} />
            </>
          )}>
          <Flex>
            <Flex.Item>
              <Button
                icon="fast-backward"
                onClick={() => act('time', { adjust: -600 })} />
              <Button
                icon="backward"
                onClick={() => act('time', { adjust: -100 })} />
              {' '}
              {String(data.minutes).padStart(2, '0')}:
              {String(data.seconds).padStart(2, '0')}
              {' '}
              <Button
                icon="forward"
                onClick={() => act('time', { adjust: 100 })} />
              <Button
                icon="fast-forward"
                onClick={() => act('time', { adjust: 600 })} />
              <br />
              <Button
                icon="hourglass-start"
                content="Short"
                onClick={() => act('preset', { preset: 'short' })} />
              <Button
                icon="hourglass-start"
                content="Medium"
                onClick={() => act('preset', { preset: 'medium' })} />
              <Button
                icon="hourglass-start"
                content="Long"
                onClick={() => act('preset', { preset: 'long' })} />
            </Flex.Item>
            <Flex.Item>
              <Section title="Current Inputted Crimes">
                {data.desired_crime}
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Crimes">
          <Flex direction="column">
            <Flex.Item grow={1}>
              {Object.keys(data.pettyCrimes).map(petty => {
                let value = data.pettyCrimes[petty];
                return (
                  <Button
                    key={petty}
                    content={value.name}
                    color={value.colour}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })} />
                );
              })}
            </Flex.Item>
            <Flex.Item>
              <hr />
              {Object.keys(data.minorCrimes).map(minor => {
                let value = data.minorCrimes[minor];
                return (
                  <Button
                    key={minor}
                    content={value.name}
                    color={value.colour}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })} />
                );
              })}
            </Flex.Item>
            <Flex.Item>
              <hr />
              {Object.keys(data.moderateCrimes).map(moderate => {
                let value = data.moderateCrimes[moderate];
                return (
                  <Button
                    key={moderate}
                    content={value.name}
                    color={value.colour}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })} />
                );
              })}
            </Flex.Item>
            <Flex.Item>
              <hr />
              {Object.keys(data.majorCrimes).map(major => {
                let value = data.majorCrimes[major];
                return (
                  <Button
                    key={major}
                    content={value.name}
                    color={value.colour}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })} />
                );
              })}
            </Flex.Item>
            <Flex.Item>
              <hr />
              {Object.keys(data.severeCrimes).map(severe => {
                let value = data.severeCrimes[severe];
                return (
                  <Button
                    key={severe}
                    content={value.name}
                    color={value.colour}
                    icon={value.icon}
                    tooltip={value.tooltip}
                    onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })} />
                );
              })}
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
