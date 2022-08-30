import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const SecretsPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    anyRights,
    adminRights,
    funRights,
    debugRights,
    lastsignalers,
    lawchanges,
  } = data;
  return (
    <Window
      width={410}
      height={700}>
      <Window.Content scrollable>
        <NoticeBox textAlign={"center"}>
          The first rule of adminbuse is: you don&apos;t talk about the adminbuse.
        </NoticeBox>
        <Section title={'General Secrets'}>
          <Button content={'Admin Log'} onClick={() => act('admin_log')} disabled={!anyRights} />
          <Button content={'Mentor Log'} onClick={() => act('mentor_log')} disabled={!anyRights} />
          <Button content={'Show Admin List'} onClick={() => act('show_admins')} disabled={!anyRights} />
        </Section>
        <Section title={'Admin Secrets'}>
          <Button color={'bad'} content={'Cure all diseases currently in existence'} onClick={() => act('clear_virus')} disabled={!adminRights} /><br />
          <Button content={'Bombing List'} onClick={() => act('list_bombers')} disabled={!adminRights} /><br />
          <Button content={'Show last '+lastsignalers+' signalers'} onClick={() => act('list_signalers')} disabled={!adminRights} /><br />
          <Button content={'Show last '+lawchanges+' law changes'} onClick={() => act('list_lawchanges')} disabled={!adminRights} /><br />
          <Button content={'Show AI Laws'} onClick={() => act('showailaws')} disabled={!adminRights} /><br />
          <Button content={'Show Game Mode'} onClick={() => act('showgm')} disabled={!adminRights} /><br />
          <Button content={'Show Crew Manifest'} onClick={() => act('manifest')} disabled={!adminRights} /><br />
          <Button content={'List DNA (Blood)'} onClick={() => act('DNA')} disabled={!adminRights} /><br />
          <Button content={'List Fingerprints'} onClick={() => act('fingerprints')} disabled={!adminRights} /><br />
          <Button.Confirm color={'good'} content={'Enable/Disable CTF'} onClick={() => act('ctfbutton')} disabled={!adminRights} /><br />
          <Button color={'good'} content={'Reset Thunderdome to default state'} onClick={() => act('tdomereset')} disabled={!adminRights} /><br />
          <Button color={'average'} content={'Rename Station Name'} onClick={() => act('set_name')} disabled={!adminRights} /><br />
          <Button.Confirm color={'average'} content={'Reset Station Name'} onClick={() => act('reset_name')} disabled={!adminRights} /><br />
          <Button.Confirm color={'average'} content={'Set Night Shift Mode'} onClick={() => act('night_shift_set')} disabled={!adminRights} /><br />
        </Section>
        <Section title={'Shuttles'}>
          <Button.Confirm color={'average'} content={'Move Ferry'} onClick={() => act('moveferry')} disabled={!adminRights} /><br />
          <Button.Confirm color={'average'} content={'Toggle Arrivals Ferry'} onClick={() => act('togglearrivals')} disabled={!adminRights} /><br />
          <Button.Confirm color={'average'} content={'Move Mining Shuttle'} onClick={() => act('moveminingshuttle')} disabled={!adminRights} /><br />
          <Button.Confirm color={'average'} content={'Move Labor Shuttle'} onClick={() => act('movelaborshuttle')} disabled={!adminRights} /><br />
        </Section>
        <Section title={'Fun Secrets'}>
          <Button color={'bad'} content={'Trigger a Virus Outbreak'} onClick={() => act('virus')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Turn all humans into monkeys'} onClick={() => act('monkey')} disabled={!funRights} /><br />
          <Button color={'bad'} content={'Chinese Cartoons (Everyone is schoolgirls)'} onClick={() => act('anime')} disabled={!funRights} /><br />
          <Button color={'bad'} content={'Change the species of all humans'} onClick={() => act('allspecies')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Make all areas powered'} onClick={() => act('power')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Make all areas unpowered'} onClick={() => act('unpower')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Power all SMES'} onClick={() => act('quickpower')} disabled={!funRights} /><br />
          <Button color={'bad'} content={'Triple AI mode (needs to be used in the lobby)'} onClick={() => act('tripleAI')} disabled={!funRights} /><br />
          <Button color={'bad'} content={'Everyone is the traitor (Can specify objective)'} onClick={() => act('traitor_all')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Everyone is the IAA (except sec/cap/hop)'} onClick={() => act('iaa_all')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'There can only be one!'} onClick={() => act('onlyone')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'There can only be one! (40-second delay)'} onClick={() => act('delayed_onlyone')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Make all players stupid'} onClick={() => act('retardify')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Egalitarian Station Mode (All doors are open access)'} onClick={() => act('eagles')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Anarcho-Capitalist Station Mode (More things cost money)'} onClick={() => act('ancap')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Break all lights'} onClick={() => act('blackout')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Fix all lights'} onClick={() => act('whiteout')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'The floor is lava! (DANGEROUS: extremely lame)'} onClick={() => act('floorlava')} disabled={!funRights} /><br />
          <Button color={'bad'} content={'Change bomb cap'} onClick={() => act('changebombcap')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Mass Purrbation'} onClick={() => act('masspurrbation')} disabled={!funRights} /><br />
          <Button.Confirm color={'bad'} content={'Mass Remove Purrbation'} onClick={() => act('massremovepurrbation')} disabled={!funRights} /><br />
        </Section>
        <Section title={'Debug Secrets'}>
          <Button.Confirm color={'bad'} content={'Change all maintenance doors to engie/brig access only'} onClick={() => act('maint_access_engiebrig')} disabled={!debugRights} /><br />
          <Button.Confirm color={'bad'} content={'Change all maintenance doors to brig access only'} onClick={() => act('maint_access_brig')} disabled={!debugRights} /><br />
          <Button.Confirm color={'bad'} content={'Remove cap on security officers'} onClick={() => act('infinite_sec')} disabled={!debugRights} /><br />
        </Section>
      </Window.Content>
    </Window>
  );
};
