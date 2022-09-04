import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  return (
    <Window
      width={600}
      height={486}
      resizable>
      <Window.Content>
        <MinesweeperContent />
      </Window.Content>
    </Window>
  );
};

export const MinesweeperContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    board_data = [],
    game_status,
    difficulty,
    current_difficulty,
    emagged,
    flag_mode,
    tickets,
  } = data;
  return (
    <Section
      title={"Minesweeper" + (emagged ? " EXTREME EDITION" : "")}
      color={emagged ? "bad" : "primary"}
      textAlign="center">
      <b>DIFFICULTY: </b>{current_difficulty}
      <br />
      <b>{emagged ? "Explode in the game, explode in real life!" : "Tickets: "}</b>{emagged ? "" : tickets}
      <br />
      <br />
      <Box>
        {game_status != 3 ? board_data.map((ydata, yind) => // P.username, REF(P), blocked_users.Find(P)
          (
            <Box inline>
              {ydata.map((imagec, xind) => // P.username, REF(P), blocked_users.Find(P)
                (
                  <Box key={xind+","+yind}>
                    {imagec ? (
                      <Box
                        lineHeight={0}
                        onClick={() => act('PRG_do_tile', {
                          x: xind+1,
                          y: yind+1,
                          flag: false,
                        })}
                        oncontextmenu={(e) => {e.preventDefault(), act('PRG_do_tile', {
                          x: xind+1,
                          y: yind+1,
                          flag: true,
                        })}} >
                          <img src={resolveAsset(imagec)} />
                      </Box>
                    ) : ""}
                  </Box>
                )
              )}
            </Box>
          )
        ) : ""}
      </Box>
      <br />
      <Button
        content="Toggle Flagging"
        color={flag_mode ? "green" : "blue"}
        onClick={() => act('PRG_toggle_flag')} />
      <Button
        content="New Game"
        color="blue"
        onClick={() => act('PRG_new_game')} />
      <br />
      <Button
        content="Beginner"
        selected={difficulty=="Beginner"}
        color={flag_mode ? "green" : "blue"}
        onClick={() => act('PRG_difficulty', {
          difficulty: 1,
        })} />
      <Button
        content="Intermediate"
        selected={difficulty=="Intermediate"}
        color="blue"
        onClick={() => act('PRG_difficulty', {
          difficulty: 2,
        })} />
      <Button
        content="Expert"
        selected={difficulty=="Expert"}
        color="blue"
        onClick={() => act('PRG_difficulty', {
          difficulty: 3,
        })} />
      <br />
      <Button
        content="Redeem Tickets"
        color="blue"
        onClick={() => act('PRG_tickets', {
          difficulty: 3,
        })} />
    </Section>
  );
};
