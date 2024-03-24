import { Box, Button, Section, NoticeBox, Icon, Fragment, Flex } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';


export const LoginScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    username,
    has_access } = data;
  const { theme = 'ntos' } = props;

  return (
    <Window width={775} height={500} resizable theme={theme}>
      <Window.Content scrollable>
        <Section title="Welcome">
          <Flex align="center" justify="center" mt="0.5rem">
            <Flex.Item>
              <Fragment>
                {data.user_image && (
                  <Fragment style={`position:relative`}>
                    <img src={data.user_image}
                      width="125px" height="125px"
                      style={`-ms-interpolation-mode: nearest-neighbor;
                      border-radius: 50%; border: 3px solid white;
                      margin-right:-125px`} />
                    <img src="scanlines.png"
                      width="125px" height="125px"
                      style={`-ms-interpolation-mode: nearest-neighbor;
                      border-radius: 50%; border: 3px solid white;opacity: 0.3;`} />
                  </Fragment>
                ) || (
                  <Icon name="user-circle"
                    verticalAlign="middle" size="4.5" mr="1rem" />
                )}
                <Box inline fontSize="18px" bold>{username ? username : "Unknown"}</Box>
                <NoticeBox success={has_access} danger={!has_access}
                  textAlign="center" mt="1.5rem">
                  {has_access ? "Access Granted" : "Access Denied"}
                </NoticeBox>
                <Box textAlign="center">
                  <Button icon="sign-in-alt" color={has_access ? "good" : "bad"} fluid
                    onClick={() => {
                      act("log_in");
                    }} >
                    Log In
                  </Button>
                </Box>
              </Fragment>
            </Flex.Item>
          </Flex>
        </Section>

      </Window.Content>
    </Window>
  );
};
