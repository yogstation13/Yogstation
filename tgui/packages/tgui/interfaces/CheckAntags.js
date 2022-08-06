import { useBackend } from '../backend';
import { Box, Button, Divider, Grid, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const CheckAntags = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mode,
    replacementmode,
    time,
    shuttlecalled,
    shuttletransit,
    shuttletime,
    continue1,
    continue2,
    midround_time_limit,
    midround_living_limit,
    end_on_death_limits,
    connected_players,
    lobby_players,
    observers,
    observers_connected,
    living_players,
    living_players_connected,
    living_players_antagonist,
    brains,
    other_players,
    living_skipped,
    drones,
    antags,
    antag_types,
    priority_sections,
    sections,
  } = data;
  return (
    <Window
      width={750}
      height={700}
      theme={'ntos'}>
      <Window.Content scrollable>
        <Grid height={15}>
          <Grid.Column>
            <Section title="Round Status" fill>
              {replacementmode ? 'Former Game Mode: ' : 'Current Game Mode: '} <Box inline bold>{mode}</Box>
              {replacementmode ? 'Replacement Game Mode: ' : ''} <Box inline bold>{replacementmode ? replacementmode : ''}</Box>
              <br />
              <br />
              Round Duration:
              <br />
              <Box inline bold>{time}</Box>
              <br />
              <br />
              <Box bold>Emergency Shuttle</Box>
              {shuttlecalled ? '' : <Input
                selfClear
                placeholder={shuttletime}
                onChange={(e, value) => act('edit_shuttle_time', {
                  time: value,
                })} />}
              <Button.Confirm
                disabled={!shuttlecalled && !shuttletransit}
                content={shuttlecalled ? 'Call Shuttle' : 'Send Back'}
                onClick={() => act(shuttlecalled ? 'callshuttle' : 'recallshuttle')} />
            </Section>
          </Grid.Column>
          <Grid.Column size={1.3}>
            <Section title="Continuous Round Status" fill>
              <Button
                content={continue1 ? 'Continue if antagonists die' : 'End on antagonist death'}
                onClick={() => act(continue1 ? 'end_antag_death' : 'cont_antag_death')} />
              {continue1 ? <Button
                content={continue2 ? 'creating replacement antagonists' : 'not creating new antagonists'}
                onClick={() => act(continue2 ? 'dont_create_new' : 'create_new')} /> : ''}
              <br />
              <br />
              {continue1 && continue2 ? 'Time limit: ' : ''}
              {continue1 && continue2 ? <NumberInput
                minValue={1}
                maxValue={120}
                value={midround_time_limit}
                onChange={(e, value) => act('midround_time_limit', {
                  timelimit: value,
                })} /> : ''}{continue1 && continue2 ? ' minutes into round' : ''}
              <br />
              {continue1 && continue2 ? 'Living crew limit: ' : ''}
              {continue1 && continue2 ? <NumberInput
                minValue={1}
                maxValue={100}
                value={midround_living_limit*100}
                onChange={(e, value) => act('living_crew_limit', {
                  crewlimit: value,
                })} /> : ''}{continue1 && continue2 ? '% of crew alive' : ''}
              <br />
              {continue1 && continue2 ? 'If limits past: ' : ''}
              {continue1 && continue2 ? <Button
                content={end_on_death_limits ? 'End The Round' : 'Continue As Extended'}
                onClick={() => act(end_on_death_limits ? 'cont_death_limits' : 'end_death_limits')} /> : ''}
            </Section>
          </Grid.Column>
        </Grid>
        <br />
        <Grid height={38.5}>
          <Grid.Column>
            <Section title="Game Manipulation" fill>
              <Button.Confirm
                content="End Round Now"
                onClick={() => act('end_round')} /> <br />
              <Button
                content="Delay Round End"
                onClick={() => act('delay_round')} /> <br />
              <Button
                content="Enable/Disable CTF"
                onClick={() => act('toggle_ctf')} /> <br />
              <Button.Confirm
                content="Reboot World"
                onClick={() => act('trigger_reboot')} /> <br />
              <Button
                content="Check Teams"
                onClick={() => act('check_teams')} /> <br />
              <Divider />
              <Box bold color="blue">Players</Box>
              <Box color="blue">{connected_players - lobby_players} ingame <br /> {connected_players} connected <br /> {lobby_players} in lobby</Box>
              <br />
              <Box bold color="green">Living Players</Box>
              <Box color="green">{living_players_connected} active <br /> {living_players - living_players_connected} disconnected <br /> {living_players_antagonist} antagonists</Box>
              <br />
              <Box bold color="pink">SKIPPED [CC Z-level]</Box>
              <Box color="pink">{living_skipped} living players <br /> {drones} living drones</Box>
              <br />
              <Box bold color="red">Dead/Observing Players</Box>
              <Box color="red">{observers_connected} active <br /> {observers - observers_connected} disconnected <br /> {brains} brains</Box>
              <br />
              { other_players ? { other_players }+"invalid players!" : "" }
            </Section>
          </Grid.Column>
          <Grid.Column size={3}>
            <Section title="Antagonists" fill>
              {priority_sections.map((teamdata, index) =>
                (<Section title={teamdata[0]}>
                  {teamdata[1].map((antagdata, idx) =>
                    <Box>
                      <Button
                        content={antagdata[2] ? antagdata[1].substring(0, 20)+' '+antagdata[2] : antagdata[1].substring(0, 34)}
                        disabled={!antagdata[4]} // Requires mob
                        color={antagdata[2] ? 'bad' : 'good'}
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plypp", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="VV"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyvv", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="PM"
                        disabled={!antagdata[5]} // Requires client
                        tooltipPosition="right"
                        tooltip={!antagdata[5] ? 'No client!' : ''}
                        onClick={() => act("plypm", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="FLW"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyflw", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="Show Objectives"
                        onClick={() => act("plyobj", {
                          player_objs: antagdata[3],
                        })} />
                    </Box>
                  )}
                  {teamdata[2] !== [] ? <Section title={teamdata[2][0]}>
                    {teamdata[2][1].map((flwdata, idx) =>
                      (<Box>
                        <Box inline>{flwdata[0]+" "}</Box>
                        <Button
                          content="FLW"
                          onClick={() => act("objflw", {
                            objref: flwdata[1],
                          })} />
                      </Box>)
                    )}
                  </Section> : ''}
                </Section>)
              )}

              {sections.map((teamdata, index) =>
                (<Section title={teamdata[0]}>
                  {teamdata[1].map((antagdata, idx) =>
                    <Box>
                      <Button
                        content={antagdata[2] ? antagdata[1].substring(0, 20)+' '+antagdata[2] : antagdata[1].substring(0, 34)}
                        disabled={!antagdata[4]} // Requires mob
                        color={antagdata[2] ? 'bad' : 'good'}
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plypp", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="VV"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyvv", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="PM"
                        disabled={!antagdata[5]} // Requires client
                        tooltipPosition="right"
                        tooltip={!antagdata[5] ? 'No client!' : ''}
                        onClick={() => act("plypm", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="FLW"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyflw", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="Show Objectives"
                        onClick={() => act("plyobj", {
                          player_objs: antagdata[3],
                        })} />
                    </Box>
                  )}
                  {teamdata[2] !== [] ? <Section title={teamdata[2][0]}>
                    {teamdata[2][1].map((flwdata, idx) =>
                      (<Box>
                        <Box inline>{flwdata[0]}</Box>
                        <Button
                          content="FLW"
                          onClick={() => act("objflw", {
                            objref: flwdata[1],
                          })} />
                        <br />
                      </Box>)
                    )}
                  </Section> : ''}
                </Section>)
              )}

              {antag_types.map((type, index) =>
                (<Section title={type+'s'}>
                  {antags.map((antagdata, idx) => // Antag constructor
                    (type === antagdata[0] ? <Box>
                      <Button
                        content={antagdata[2] ? antagdata[1].substring(0, 20)+' '+antagdata[2] : antagdata[1].substring(0, 34)}
                        disabled={!antagdata[4]} // Requires mob
                        color={antagdata[2] ? 'bad' : 'good'}
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plypp", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="VV"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyvv", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="PM"
                        disabled={!antagdata[5]} // Requires client
                        tooltipPosition="right"
                        tooltip={!antagdata[5] ? 'No client!' : ''}
                        onClick={() => act("plypm", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="FLW"
                        disabled={!antagdata[4]} // Requires mob
                        tooltipPosition="right"
                        tooltip={!antagdata[4] ? 'No mob!' : ''}
                        onClick={() => act("plyflw", {
                          player_objs: antagdata[3],
                        })} />
                      <Button
                        content="Show Objectives"
                        onClick={() => act("plyobj", {
                          player_objs: antagdata[3],
                        })} />
                    </Box> : '')
                  )}
                </Section>)
              )}
            </Section>
          </Grid.Column>
        </Grid>
      </Window.Content>
    </Window>
  );
};
