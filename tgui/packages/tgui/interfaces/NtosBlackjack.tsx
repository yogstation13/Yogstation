import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

enum GameState {
  Continue = 0,
  Loss = 1,
  Win = 2,
  Tie = 3,
  Idle = 4,
  DealerTurn = 5,
}

const GameStateFlavor = {
  0:"Good luck!",
  1:"Better luck next time!",
  2:"Congratulations!",
  3:"Tied!",
  4:"Gamble responsibly!",
  5:"Dealer is drawing...",
};

const ColorSuit = {
  "S":"black",
  "H":"red",
  "C":"black",
  "D":"red",
};

const IconSuit = {
  "S":"spa",
  "H":"heart",
  "C":"cubes",
  "D":"diamond",
};

type Data = {
  game_state: GameState;
  active_dealer_cards: Array<string>;
  active_player_cards: Array<string>;
  credits_stored: number;
  local_credits: number;
  has_id: boolean;
  active_wager: number;
  set_wager: number;
  game_end_reason: string;
};

export const NtosBlackjack = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  return (
    <NtosWindow
      width={600}
      height={572}>
      <NtosWindow.Content>
        <Stack fill>
          <Stack.Item>
            <Section fill>
              <br />
              <br />
              <br />
              <Button.Confirm
                disabled={data.credits_stored < data.set_wager}
                onClick={() => act('PRG_new_game')}
                textAlign='center'
                width={15}
                content={"New Game"} />
              <br />
              <br />
              <br />
              <Button.Confirm
                disabled={data.local_credits < 1}
                onClick={() => act('PRG_eject_credits')}
                textAlign='center'
                width={15}
                content={"Eject Credits"} />
              <br />
              <Button.Input
                currentValue={data.set_wager}
                onCommit={(e:any, value:string) => act('PRG_set_wager', {
                  wager: value,
                })}
                textAlign='center'
                width={15}
                content={"Set Wager"} />
              <br />
              <br />
              <br />
              <Button.Confirm
                disabled={data.game_state !== GameState.Continue}
                onClick={() => act('PRG_hit')}
                textAlign='center'
                width={15}
                content={"Hit"} />
              <br />
              <Button.Confirm
                disabled={data.game_state !== GameState.Continue}
                onClick={() => act('PRG_stand')}
                textAlign='center'
                width={15}
                content={"Stand"} />
              <br />
              <Button.Confirm
                disabled={data.game_state !== GameState.Continue || data.credits_stored < data.set_wager}
                onClick={() => act('PRG_double_down')}
                textAlign='center'
                width={15}
                content={"Double Down"} />
              <br />
              <br />
              <br />
              <Box textAlign='center'>
                Credits {data.has_id ? " in account" : ""}
                <br />
                {data.credits_stored}
                <br />
                <br />
                Active Bet
                <br />
                {data.active_wager}
                <br />
                <br />
                <br />
                <br />
                {data.game_end_reason}
                <br />
                {GameStateFlavor[data.game_state]}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section fill>
                  <Box textAlign='center'>
                    Dealer&apos;s hand
                  </Box>
                  <br />
                  <Stack>
                    {data.active_dealer_cards.map((card_string, index) =>
                      (<Stack.Item
                        bold
                        fontSize={1.4}
                        height={7}
                        width={5}
                        backgroundColor='white'
                        color={ColorSuit[card_string.slice(-1)]}
                        key={'dealercard'+index}>
                        <Stack fill vertical>
                          <Stack.Item>
                            <Box px={0.4} fill>
                              {card_string.slice(0, -1)}
                            </Box>
                          </Stack.Item>
                          <Stack.Item grow align='center'>
                            <Icon name={IconSuit[card_string.slice(-1)]} />
                          </Stack.Item>
                          <Stack.Item align='end'>
                            <Box px={0.6} fill textAlign='right'>
                              {card_string.slice(0, -1)}
                            </Box>
                          </Stack.Item>
                        </Stack>
                       </Stack.Item>)
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill>
                  <Box textAlign='center'>
                    Your hand
                  </Box>
                  <br />
                  <Stack>
                    {data.active_player_cards.map((card_string, index) =>
                      (<Stack.Item
                        bold
                        fontSize={1.4}
                        height={7}
                        width={5}
                        backgroundColor='white'
                        color={ColorSuit[card_string.slice(-1)]}
                        key={'playercard'+index}>
                        <Stack fill vertical>
                          <Stack.Item>
                            <Box px={0.4} fill>
                              {card_string.slice(0, -1)}
                            </Box>
                          </Stack.Item>
                          <Stack.Item grow align='center'>
                            <Icon name={IconSuit[card_string.slice(-1)]} />
                          </Stack.Item>
                          <Stack.Item align='end'>
                            <Box px={0.6} fill textAlign='right'>
                              {card_string.slice(0, -1)}
                            </Box>
                          </Stack.Item>
                        </Stack>
                       </Stack.Item>)
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
