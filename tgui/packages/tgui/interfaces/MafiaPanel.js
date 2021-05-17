import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
    actions,
    phase,
    roleinfo,
    role_theme,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles,
  } = data;
  return (
    <Window
      title="Mafia"
      theme={role_theme}
      width={650}
      height={550}
      resizable>
      <Window.Content>
        <Section title={phase}>
          {!!roleinfo && (
            <Fragment>
              <Box>
                <TimeDisplay auto="down" value={timeleft} />
              </Box>
              <Box>
                <b>You are a {roleinfo.role}</b>
              </Box>
              <Box>
                <b>{roleinfo.desc}</b>
              </Box>
            </Fragment>
          )}
        </Section>
        <Flex>
          {!!actions && actions.map(action => (
            <Flex.Item key={action}>
              <Button
                onClick={() => act("mf_action", { atype: action })}>
                {action}
              </Button>
            </Flex.Item>
          ))}
          {!!roleinfo && (
            <Stack.Item>
              <MafiaJudgement />
            </Stack.Item>
          )}
          {phase !== 'No Game' && (
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow={1.34} basis={0}>
                  <MafiaPlayers />
                </Stack.Item>
                <Stack.Item grow={1} basis={0}>
                  <Stack fill vertical>
                    <Stack.Item grow>
                      <MafiaListOfRoles />
                    </Stack.Item>
                    {!!roleinfo && (
                      <Stack.Item height="80px">
                        <Section fill scrollable>
                          {roleinfo?.action_log?.map(line => (
                            <Box key={line}>{line}</Box>
                          ))}
                        </Section>
                      </Stack.Item>
                    )}
                  </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
          {!!admin_controls && (
            <Stack.Item>
              <MafiaAdmin />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MafiaLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
    phase,
    timeleft,
  } = data;
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Ready") : null;
  return (
    <Section
      fill
      scrollable
      title="Lobby"
      buttons={(
        <>
          Phase = {phase}
          {' | '}
          <TimeDisplay auto="down" value={timeleft} />
          {' '}
          <Button
            icon="clipboard-check"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              Signs you up for the next game. If there
              is an ongoing one, you will be signed up
              for the next.
            `}
            content="Sign Up"
            onClick={() => act('mf_signup')} />
          <Button
            icon="eye"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              Spectates games until you turn it off.
              Automatically enabled when you die in game,
              because I assumed you would want to see the
              conclusion. You won't get messages if you
              rejoin SS13.
            `}
            content="Spectate"
            onClick={() => act('mf_spectate')} />
        </>
      )}>
      <NoticeBox info>
        The lobby currently has {readyGhosts.length + '/12'} valid
        players signed up.
      </NoticeBox>
      {lobbydata?.map(lobbyist => (
        <Stack
          key={lobbyist}
          className="candystripe"
          p={1}
          align="baseline">
          <Stack.Item grow>
            {lobbyist.name}
          </Stack.Item>
          <Stack.Item>
            Status:
          </Stack.Item>
          <Stack.Item
            color={lobbyist.status === 'Ready' ? 'green' : 'red'}>
            {lobbyist.status} {lobbyist.spectating}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const MafiaRole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    roleinfo,
    timeleft,
  } = data;
  return (
    <Section
      title={phase}
      minHeight="100px"
      maxHeight="50px"
      buttons={(
        <Box
          style={{
            'font-family': 'Consolas, monospace',
            'font-size': '14px',
            'line-height': 1.5,
            'font-weight': 'bold',
          }}>
          <TimeDisplay auto="down" value={timeleft} />
        </Box>
      )}>
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            You are the {roleinfo.role}
          </Box>
          <Box italic>
            {roleinfo.desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.revealed_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(0px, 10%)',
              'vertical-align': 'middle',
            }} />
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.hud_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(-5px, -5px)',
              'vertical-align': 'middle',
            }} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaListOfRoles = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    all_roles,
  } = data;
  return (
    <Section
      fill
      scrollable
      title="Roles and Notes"
      minHeight="120px"
      buttons={
        <>
          <Button
            color="transparent"
            icon="address-book"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              The top section is the roles in the game. You can
              press the question mark to get a quick blurb
              about the role itself.`}
          />
          <Button
            color="transparent"
            icon="edit"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              The bottom section are your notes. on some roles this
              will just be an empty box, but on others it records the
              actions of your abilities (so for example, your
              detective work revealing a changeling).`}
          />
        </>
      }>
      <Flex direction="column">
        {all_roles?.map(r => (
          <Flex.Item
            key={r}
            height="30px"
            className="Section__title candystripe">
            <Flex
              height="18px"
              align="center"
              justify="space-between">
              <Flex.Item>
                {r}
              </Flex.Item>
              <Flex.Item
                textAlign="right">
                <Button
                  color="transparent"
                  icon="question"
                  onClick={() => act('mf_lookup', {
                    atype: r.slice(0, -3),
                  })}
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaJudgement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    judgement_phase,
  } = data;
  return (
    <Section
      title="Judgement"
      buttons={
        <Button
          color="transparent"
          icon="info"
          tooltipPosition="left"
          tooltip={multiline`
            When someone is on trial, you are in charge of their fate.
            Innocent winning means the person on trial can live to see
            another day... and in losing they do not. You can go back
            to abstaining with the middle button if you reconsider.
          `}
        />
      }>
      <Flex justify="space-around">
        <Button
          icon="smile-beam"
          content="INNOCENT!"
          color="good"
          disabled={!judgement_phase}
          onClick={() => act('vote_innocent')} />
        {!judgement_phase && (
          <Box>
            There is nobody on trial at the moment.
          </Box>
        )}
        <Section title="Players">
          <LabeledList>
            {!!players && players.map(player => (
              <LabeledList.Item
                className="candystripe"
                key={player.ref}
                label={player.name}>
                {!player.alive && (<Box color="red">DEAD</Box>)}
                {player.votes !== undefined && !!player.alive
                && (<Fragment>Votes : {player.votes} </Fragment>)}
                {
                  !!player.actions && player.actions.map(action => {
                    return (
                      <Button
                        key={action}
                        onClick={() => act('mf_targ_action', {
                          atype: action,
                          target: player.ref,
                        })}>
                        {action}
                      </Button>); })
                }
              </LabeledList.Item>)
            )}
          </LabeledList>
        </Section>
        {!!judgement_phase && (
          <Section title="JUDGEMENT">
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                color="good"
                onClick={() => act("vote_innocent")}>
                INNOCENT!
              </Button>
              Use these buttons to vote the accused innocent or guilty!
              <Button
                icon="angry"
                color="bad"
                onClick={() => act("vote_guilty")}>
                GUILTY!
              </Button>
            </Flex>
          </Section>
        )}
        <Flex mt={1} spacing={1}>
          <Flex.Item grow={1} basis={0}>
            <Section
              title="Roles"
              minHeight={10}>
              {!!all_roles && all_roles.map(r => (
                <Box key={r}>
                  <Flex justify="space-between">
                    {r}
                    <Button
                      content="?"
                      onClick={() => act("mf_lookup", {
                        atype: r.slice(0, -3),
                      })}
                    />
                  </Flex>
                </Box>
              ))}
            </Section>
          </Flex.Item>
          <Flex.Item grow={2} basis={0}>
            <Section
              title="Notes"
              minHeight={10}>
              {roleinfo !== undefined && !!roleinfo.action_log
              && roleinfo.action_log.map(log_line => (
                <Box key={log_line}>
                  {log_line}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
