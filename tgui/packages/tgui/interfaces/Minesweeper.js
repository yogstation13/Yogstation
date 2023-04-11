import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Knob, Section } from '../components';
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  return (
    <Window
      width={600}
      height={518}
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
    custom_width,
    custom_height,
    custom_mines,
    flags,
    current_mines,
    time_string,
  } = data;
  return (
    <Section
      title={"Minesweeper" + (emagged ? " EXTREME EDITION" : "")}
      color={emagged ? "bad" : "primary"}
      textAlign="center">
      <b>DIFFICULTY: </b>{current_difficulty}
      <br />
      <b>{emagged ? "Explode in the game, explode in real life!" : "Tickets: "}</b>
      {emagged ? "" : tickets}
      <b>{emagged ? "" : " Mines left: "}</b>
      {emagged ? "" : current_mines-flags}
      <b>{emagged ? "" : " Time: "}</b>
      {emagged ? "" : time_string}
      <br />
      <br />
      <Box>
        {game_status !== 3 ? board_data.map((xdata, xind) =>
          (
            <Box inline key={"outer"+xind}>
              {xdata.map((imagec, yind) =>
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
                        oncontextmenu={eve => {
                          eve.preventDefault();
                          act('PRG_do_tile', {
                            x: xind+1,
                            y: yind+1,
                            flag: true,
                          });
                        }} >
                        <img src={resolveAsset(imagec)} />
                      </Box>
                    ) : ""}
                  </Box>
                )
              )}
            </Box>
          )
        ) : <Box><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /></Box>}
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
        selected={difficulty==="Beginner"}
        color={flag_mode ? "green" : "blue"}
        onClick={() => act('PRG_difficulty', {
          difficulty: 1,
        })} />
      <Button
        content="Intermediate"
        selected={difficulty==="Intermediate"}
        color="blue"
        onClick={() => act('PRG_difficulty', {
          difficulty: 2,
        })} />
      <Button
        content="Expert"
        selected={difficulty==="Expert"}
        color="blue"
        onClick={() => act('PRG_difficulty', {
          difficulty: 3,
        })} />
      <Button
        content="Custom"
        selected={difficulty==="Custom"}
        color="blue"
        onClick={() => act('PRG_difficulty', {
          difficulty: 4,
        })} />
      <br />
      <Button
        content="Redeem Tickets"
        color="blue"
        onClick={() => act('PRG_tickets', {
          difficulty: 3,
        })} />
      {difficulty==="Custom" ? (
        <Box>
          <Knob
            inline
            animated
            unit=" Width"
            minValue="5"
            maxValue="30"
            stepPixelSize="10"
            value={custom_width}
            onDrag={(e, value) => act('PRG_width', {
              width: value,
            })} />
          <Knob
            inline
            animated
            color="blue"
            unit=" Height"
            minValue="5"
            maxValue="17"
            stepPixelSize="20"
            value={custom_height}
            onDrag={(e, value) => act('PRG_height', {
              height: value,
            })} />
          <Knob
            inline
            animated
            color="bad"
            unit=" Mines"
            minValue="5"
            maxValue="250"
            stepPixelSize="2"
            value={custom_mines}
            onDrag={(e, value) => act('PRG_mines', {
              mines: value,
            })} />
        </Box>
      ) : ""}
    </Section>
  );
};
