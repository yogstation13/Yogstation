import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { NoticeBox, Button, Flex, Box } from '../components';
import { Window } from '../layouts';

export const ArmamentsDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const { inventory = [] } = data;
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
        <Flex
          justify="space-between"
          spacing={1}>
          {inventory.map(weapon => (
            <Flex.Item
              key={weapon}>
              <Button
                key={weapon}
                fluid
                disabled={!data.allowed || !data.can_claim}
                width="260px"
                height="260px"
                textAlign="center"
                onClick={() => act('dispense_weapon', {
                  weapon: weapon.path,
                  magazine: weapon.mag_path,
                })} >
                <Flex
                  height="100%"
                  direction="column">
                  <Box
                    as="img"
                    class="gun_icon"
                    position="relative"
                    src={resolveAsset(weapon.gun_icon)}
                    height="100%"
                    width="100%"
                    style={{
                      '-ms-interpolation-mode': 'nearest-neighbor' }} />
                  {!!(weapon.mag_icon) && (
                    <Box
                      as="img"
                      class="gun_icon"
                      position="absolute"
                      left="40%"
                      bottom="10%"
                      src={resolveAsset(weapon.mag_icon)}
                      height="50%"
                      width="50%"
                      style={{
                        '-ms-interpolation-mode': 'nearest-neighbor' }} />)}
                </Flex>
              </Button>

            </Flex.Item>))}
        </Flex>

      </Window.Content>
    </Window>
  );
};
