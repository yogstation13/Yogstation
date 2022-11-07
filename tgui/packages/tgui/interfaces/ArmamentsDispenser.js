import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NoticeBox, Button, Flex } from '../components';
import { Window } from '../layouts';

export const ArmamentsDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Armaments Dispenser"
      width={540}
      height={335}
      resizable>
      <Window.Content>
        {(data.allowed === 1 && data.can_claim === 1) && (
          <NoticeBox textAlign="center" info>
            Please select your preferred weapon.
          </NoticeBox>
        )}
        {data.allowed !== 1 && (
          <NoticeBox textAlign="center" danger>
            You are not a security officer or warden!
          </NoticeBox>
        )}
        {(data.can_claim !== 1 && data.allowed === 1) && (
          <NoticeBox textAlign="center" danger>
            You have already claimed a weapon or do not have a registered account!
          </NoticeBox>
        )}
        <Flex justify="space-between" spacing={1}>
          <Flex.Item>
            <Button
              fluid
              disabled={!data.allowed || !data.can_claim}
              width="260px"
              height="260px"
              textAlign="center"
              content={<img src={resolveAsset('disablerbig.png')} />}
              onClick={() => act('dispense_weapon', {
                weapon: "disabler",
              })} />
          </Flex.Item>
          <Flex.Item>
            <Button
              fluid
              disabled={!data.allowed || !data.can_claim}
              width="260px"
              height="260px"
              textAlign="center"
              content={<img src={resolveAsset('ntuspbig.png')} />}
              onClick={() => act('dispense_weapon', {
                weapon: "usp",
              })} />
          </Flex.Item>
        </Flex>

      </Window.Content>
    </Window>
  );
};
