import { useBackend } from '../backend';
import { Box, Button, Section, Table, Stack, Grid } from '../components';
import { Window } from '../layouts';

interface MuteStates {
  ic: boolean;
  ooc: boolean;
  pray: boolean;
  adminhelp: boolean;
  deadchat: boolean;
  webreq: boolean;
}

// Default values for PlayerData
const DEFAULT_PLAYER_DATA: PlayerData = {
  characterName: 'Unknown',
  ckey: '',
  ipAddress: '0.0.0.0',
  CID: 'NO_CID',
  gameState: 'Unknown',
  dbLink: '',
  byondVersion: '0.0.0',
  mobType: 'null',
  relatedByCid: '',
  relatedByIp: '',
  firstSeen: 'Never',
  accountRegistered: 'Unknown',
  muteStates: {
    ic: false,
    ooc: false,
    pray: false,
    adminhelp: false,
    deadchat: false,
    webreq: false,
  },
};

interface PlayerData {
  characterName: string;
  ckey: string;
  ipAddress: string;
  CID: string;
  gameState: string;
  dbLink: string;
  byondVersion: string;
  mobType: string;
  relatedByCid: string;
  relatedByIp: string;
  firstSeen: string;
  accountRegistered: string;
  muteStates: MuteStates;
}

interface BackendData {
  Data: PlayerData;
}

const isMobType = (currentType: string, checkType: string): boolean => {
  const types = {
    ghost: ['ghost', 'dead', 'observer'],
    human: ['human', 'carbon'],
    monkey: ['monkey', 'primate'],
    cyborg: ['cyborg', 'robot', 'borg'],
    ai: ['ai', 'artificial intelligence'],
  };
  return (
    types[checkType]?.some((type) =>
      currentType.toLowerCase().includes(type),
    ) || false
  );
};

export const VUAP_personal = (props) => {
  const { data, act } = useBackend<BackendData>();

  // Use default values if data is missing
  const playerData = {
    ...DEFAULT_PLAYER_DATA,
    ...data?.Data,
    muteStates: {
      ...DEFAULT_PLAYER_DATA.muteStates,
      ...data?.Data?.muteStates,
    },
  };

  const handleAction = (action: string, params = {}) => {
    if (!playerData.ckey) {
      act(action, { selectedPlayerCkey: playerData.ckey, ...params });
    }
    act(action, { selectedPlayerCkey: playerData.ckey, ...params });
  };

  const toggleMute = (type: string) => {
    if (!playerData.ckey) {
      return;
    }
    handleAction('toggleMute', { type });
  };

  const toggleAllMutes = () => {
    if (!playerData.ckey) {
      return;
    }
    handleAction('toggleAllMutes');
  };

  // Add error display if critical data is missing
  if (!playerData.ckey) {
    return (
      <Window title="Options Panel - Error" width={800} height={1050}>
        <Window.Content>
          <Section title="Error">
            <Box color="red">
              No valid player data found. Please refresh or select a valid
              player.
            </Box>
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title={`Options Panel - ${playerData.ckey}`}
      width={800}
      height={850}
    >
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => handleAction('refresh')}
            />
          </Stack.Item>

          <Stack.Item>
            <Section title="Player Information">
              <Table>
                <Table.Row>
                  <Table.Cell bold>Character:</Table.Cell>
                  <Table.Cell>{playerData.characterName}</Table.Cell>
                  <Table.Cell bold>Ckey:</Table.Cell>
                  <Table.Cell>{playerData.ckey}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>IP Address:</Table.Cell>
                  <Table.Cell>{playerData.ipAddress}</Table.Cell>
                  <Table.Cell bold>Game State:</Table.Cell>
                  <Table.Cell>{playerData.gameState}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>DB Link:</Table.Cell>
                  <Button
                    content="Centcom DB Link"
                    color="green"
                    onClick={() => handleAction('dblink')}
                  />
                  <Table.Cell bold>Byond Version:</Table.Cell>
                  <Table.Cell>{playerData.byondVersion}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Mob Type:</Table.Cell>
                  <Table.Cell>{playerData.mobType}</Table.Cell>
                  <Table.Cell bold>CID:</Table.Cell>
                  <Table.Cell>{playerData.CID}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>First Seen:</Table.Cell>
                  <Table.Cell>{playerData.firstSeen}</Table.Cell>
                  <Table.Cell bold>Account Registered:</Table.Cell>
                  <Table.Cell>{playerData.accountRegistered}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Related By CID:</Table.Cell>
                  <Button
                    content="Related by CID"
                    color="blue"
                    onClick={() => handleAction('relatedbycid')}
                  />
                  <Table.Cell bold>Related By IP:</Table.Cell>
                  <Button
                    content="Related by IP"
                    color="blue"
                    onClick={() => handleAction('relatedbyip')}
                  />
                </Table.Row>
              </Table>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Grid>
              <Grid.Column>
                <Section title="Punish">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="times"
                        content="KICK"
                        color="red"
                        onClick={() => handleAction('kick')}
                      />
                      <Button
                        fluid
                        icon="ban"
                        content="BAN"
                        color="red"
                        onClick={() => handleAction('ban')}
                      />
                      <Button
                        fluid
                        icon="bolt"
                        content="SMITE"
                        color="red"
                        onClick={() => handleAction('smite')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        content="PRISON"
                        color="red"
                        onClick={() => handleAction('prison')}
                      />
                      <Button
                        fluid
                        content="UNPRISON"
                        color="red"
                        onClick={() => handleAction('unprison')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>

              <Grid.Column>
                <Section title="Message">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment"
                        content="PM"
                        onClick={() => handleAction('pm')}
                      />
                      <Button
                        fluid
                        icon="user-secret"
                        content="SM"
                        onClick={() => handleAction('sm')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment-alt"
                        content="NARRATE"
                        onClick={() => handleAction('narrate')}
                      />
                      <Button
                        fluid
                        icon="music"
                        content="PLAY SOUND TO"
                        onClick={() => handleAction('playsoundto')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                <Section title="Movement">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="running"
                        content="JUMPTO"
                        onClick={() => handleAction('jumpto')}
                      />
                      <Button
                        fluid
                        icon="download"
                        content="GET"
                        onClick={() => handleAction('get')}
                      />
                      <Button
                        fluid
                        icon="paper-plane"
                        content="SEND"
                        onClick={() => handleAction('send')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="sign-out-alt"
                        content="LOBBY"
                        onClick={() => handleAction('lobby')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="FLW"
                        onClick={() => handleAction('flw')}
                      />
                      <Button
                        fluid
                        icon="columns"
                        content="SEND TO CRYO"
                        onClick={() => handleAction('cryo')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>

              <Grid.Column>
                <Section title="Info">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="code"
                        content="VV"
                        onClick={() => handleAction('vv')}
                      />
                      <Button
                        fluid
                        icon="user-secret"
                        content="TRAITOR PANEL"
                        onClick={() => handleAction('tp')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="PLAYTIME"
                        onClick={() => handleAction('playtime')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="book"
                        content="LOGS"
                        onClick={() => handleAction('logs')}
                      />
                      <Button
                        fluid
                        icon="clipboard"
                        content="NOTES"
                        onClick={() => handleAction('notes')}
                      />
                      <Button
                        fluid
                        icon="language"
                        content="LANGUAGE"
                        onClick={() => handleAction('language')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                <Section title="Transformation">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="ghost"
                        content="MAKE GHOST"
                        color={
                          isMobType(playerData.mobType, 'ghost') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeghost')}
                      />
                      <Button
                        fluid
                        icon="user"
                        content="MAKE HUMAN"
                        color={
                          isMobType(playerData.mobType, 'human') ? 'good' : ''
                        }
                        onClick={() => handleAction('makehuman')}
                      />
                      <Button
                        fluid
                        icon="paw"
                        content="MAKE MONKEY"
                        color={
                          isMobType(playerData.mobType, 'monkey') ? 'good' : ''
                        }
                        onClick={() => handleAction('makemonkey')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="robot"
                        content="MAKE CYBORG"
                        color={
                          isMobType(playerData.mobType, 'cyborg') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeborg')}
                      />
                      <Button
                        fluid
                        icon="microchip"
                        content="MAKE AI"
                        color={
                          isMobType(playerData.mobType, 'ai') ? 'good' : ''
                        }
                        onClick={() => handleAction('makeai')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
                <Section title="Health">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="heart"
                        content="HEALTHSCAN"
                        onClick={() => handleAction('healthscan')}
                      />
                      <Button
                        fluid
                        content="CHEMSCAN"
                        onClick={() => handleAction('chemscan')}
                      />
                      <Button
                        fluid
                        content="GIVE DISEASE"
                        onClick={() => handleAction('giveDisease')}
                      />
                      <Button
                        fluid
                        content="CURE ALL BAD DISEASES"
                        onClick={() => handleAction('cureAllDiseases')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="plus"
                        content="AHEAL"
                        onClick={() => handleAction('aheal')}
                      />
                      <Button
                        fluid
                        content="MODIFY TRAITS"
                        onClick={() => handleAction('modifytraits')}
                      />
                      <Button
                        fluid
                        content="DISEASE PANEL"
                        onClick={() => handleAction('diseasePanel')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
              <Grid.Column>
                <Section title="Misc">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment"
                        content="FORCESAY"
                        onClick={() => handleAction('forcesay')}
                      />
                      <Button
                        fluid
                        icon="user-edit"
                        content="APPLY CLIENT QUIRKS"
                        onClick={() => handleAction('applyquirks')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME 1"
                        onClick={() => handleAction('thunderdome1')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME 2"
                        onClick={() => handleAction('thunderdome2')}
                      />
                      <Button
                        fluid
                        icon="heart"
                        content="SPAWN COOKIE"
                        onClick={() => handleAction('spawncookie')}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="star"
                        content="COMMEND"
                        onClick={() => handleAction('commend')}
                      />
                      <Button
                        fluid
                        icon="brain"
                        content="SKILLS"
                        onClick={() => handleAction('skills')}
                      />
                      <Button
                        fluid
                        icon="gavel"
                        content="THUNDERDOME ADMIN"
                        onClick={() => handleAction('thunderdomeadmin')}
                      />
                      <Button
                        fluid
                        icon="eye"
                        content="THUNDERDOME OBSERVER"
                        onClick={() => handleAction('thunderdomeobserver')}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                <Section title="Mute Controls">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.ic}
                        onClick={() => toggleMute('ic')}
                        content="IC"
                        color={!playerData.muteStates.ic ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.ooc}
                        onClick={() => toggleMute('ooc')}
                        content="OOC"
                        color={!playerData.muteStates.ooc ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.pray}
                        onClick={() => toggleMute('pray')}
                        content="PRAY"
                        color={!playerData.muteStates.pray ? 'green' : 'red'}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.adminhelp}
                        onClick={() => toggleMute('adminhelp')}
                        content="ADMINHELP"
                        color={
                          !playerData.muteStates.adminhelp ? 'green' : 'red'
                        }
                      />
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.deadchat}
                        onClick={() => toggleMute('deadchat')}
                        content="DEADCHAT"
                        color={
                          !playerData.muteStates.deadchat ? 'green' : 'red'
                        }
                      />
                      <Button.Checkbox
                        fluid
                        checked={playerData.muteStates.webreq}
                        onClick={() => toggleMute('webreq')}
                        content="WEBREQ"
                        color={!playerData.muteStates.webreq ? 'green' : 'red'}
                      />
                      <Button
                        fluid
                        content="Toggle All"
                        onClick={toggleAllMutes}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export default VUAP_personal;
