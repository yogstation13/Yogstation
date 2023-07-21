import { Fragment } from 'inferno'; // Check if we need to keep this.
import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, NoticeBox, Table } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

type LawManagerData = {
  cyborg: BooleanLike;
  ai: BooleanLike;
  pai: BooleanLike;
  connected: BooleanLike;
  lawsync: BooleanLike;
  antag: BooleanLike;
  admin: BooleanLike;
  view: number;
};

type LawManagementData = {
  pai: BooleanLike;
  antag: BooleanLike;
  admin: BooleanLike;
};

type LawSectionData = {
  pai: BooleanLike;
  antag: BooleanLike;
  admin: BooleanLike;
  has_devil: number;
  has_zeroth: number;
  has_hacked: number;
  has_ion: number;
  has_inherent: number;
  has_supplied: number;
  devil: string[];
  zeroth: string;
  hacked: string[];
  ion: string[];
  inherent: string[];
  supplied: string[];
};

type LawTableData = {
  pai: BooleanLike;
  antag: BooleanLike;
  admin: BooleanLike;
}

type LawStatementSectionData = {
  channel: string;
  channels: ChannelInfo[]
};

type ChannelInfo = {
  name: string
}

type LawAddData = {
  admin: BooleanLike;
  has_zeroth: number;
  zeroth_law: string;
  hacked_law: string;
  ion_law: string;
  inherent_law: string;
  supplied_law: string;
  supplied_law_position: number;
}

export const LawManager = (props, context) => {
  const { act, data } = useBackend<LawManagerData>(context);
  const { cyborg, ai, pai, connected, lawsync, antag, admin, view } = data;

  return (
    <Window height="600" width="800" title="Law Manager">
      <Window.Content scrollable>
        {!!admin && (
          <NoticeBox>You are viewing this from an admin prespective.</NoticeBox>
        ) }
        {!!(admin && ai && antag) && (
          <NoticeBox>This AI is currently an antagonist.</NoticeBox>
        ) }
        {!!(admin && cyborg && !connected) && (
          <NoticeBox>This Cyborg has no master AI. Law modifications will be effective.</NoticeBox>
        ) }
        {!!(admin && cyborg && connected && lawsync) && (
          <NoticeBox>This Cyborg has lawsync active. Law modifications will be ineffective.</NoticeBox>
        ) }
        {!!(admin && cyborg && connected && !lawsync) && (
          <NoticeBox>This Cyborg has lawsync off. Law modifications will be effective.</NoticeBox>
        ) }
        {!!(admin && pai) && (
          <NoticeBox>This pAI has less editing features due to their nature of being a pAI.</NoticeBox>
        ) }
        {!!(!admin && ai && antag) && (
          <NoticeBox>You have the ability to edit a majority of your laws as a malfunctioning AI.</NoticeBox>
        ) }
        <Box>
          <Button
            content="Law Management"
            selected={view === 0}
            onClick={() => act('set_view', { set_view: 0 })}
          />
          {!!(antag || admin) && !pai && (
            <Button
              content="Lawsets"
              selected={view === 1}
              onClick={() => act('set_view', { set_view: 1 })}
            />
          )}
        </Box>
        {!!(view === 0) && <LawManagementView />}
        {!!(view === 1) && <LawsetsView />}
      </Window.Content>
    </Window>
  );
};

const LawManagementView = (props, context) => {
  const { act, data } = useBackend<LawManagementData>(context);
  const { pai, antag, admin } = data;
  return (
    <Fragment>
      <LawSection />
      <LawStatementSection />
      {!!((antag || admin) && !pai) && (
        <LawAddSection />
      )}
    </Fragment>
  );
};

const LawSection = (props, context) => {
  const { data } = useBackend<LawSectionData>(context);
  const { has_devil, has_zeroth, has_hacked, has_ion, has_inherent, has_supplied } = data;
  const { devil, zeroth, hacked, ion, inherent, supplied } = data;
  return (
    <Section title="Laws">
      {!!(has_devil > 0) && (
        <LawTable color="#cc5500" title="Devil" laws={devil} />
      )}
      {!!(has_zeroth > 0) && (
        <LawTable color="#ff0000" title="Zeroth" laws={zeroth} />
      )}
      {!!(has_hacked > 0) && (
        <LawTable color="#660000" title="Hacked" laws={hacked} />
      )}
      {!!(has_ion > 0) && (
        <LawTable color="#547DFE" title="Ion" laws={ion} />
      )}
      {!!(has_inherent > 0) && (
        <LawTable title="Inherent" laws={inherent} />
      )}
      {!!(has_supplied > 0) && (
        <LawTable color="#990099" title="Supplied" laws={supplied} />
      )}
    </Section>
  );
};

const LawTable = (props, context) => {
  const { act, data } = useBackend<LawTableData>(context);
  const { pai, antag, admin } = data;
  return (
    <Section>
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="69%">{props.title}</Table.Cell>
          <Table.Cell width="21%">State?</Table.Cell>
        </Table.Row>
        {props.laws.map((l) => (
          <Table.Row key={l.law}>
            <Table.Cell>{l.indexdisplay}</Table.Cell>
            {props.color ? (
              <Table.Cell color={props.color}>
                  {l.law}
              </Table.Cell>
            ) : (
              <Table.Cell>
                  {l.law}
              </Table.Cell>
            ) }
            <Table.Cell>
              <Button
                content={l.state ? 'Yes' : 'No'}
                selected={l.state}
                onClick={() =>
                  act('state_law', { index: l.index, type: l.type })
                }
              />
              {!!((antag || admin) && !l.hidebuttons)&& (
                <Fragment>
                  <Button
                    content="Edit"
                    icon="pencil-alt"
                    onClick={() => act('edit_law', { index: l.index, type: l.type })}
                  />
                  {!!(true && !pai) && ( // 'true' clears double negation warning
                    <Button
                      content="Delete"
                      icon="trash"
                      color="red"
                      onClick={() => act('delete_law', { index: l.index, type: l.type })}
                    />
                  )}
                </Fragment>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const LawStatementSection = (props, context) => {
  const { act, data } = useBackend<LawStatementSectionData>(context);
  const { channel, channels } = data;
  return (
    <Section title="Statement Settings">
      <LabeledList>
        <LabeledList.Item label="Statement Channel">
          {channels.map((chn) => (
            <Button
              content={chn.name}
              key={chn.name}
              selected={chn.name === channel}
              onClick={() => act('law_channel', { law_channel: chn.name })}
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="State Laws">
          <Button content="State Laws" onClick={() => act('state_laws')} />
        </LabeledList.Item>
        <LabeledList.Item label="Law Notification">
          <Button content="Notify" onClick={() => act('notify_laws')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const LawAddSection = (props, context) => {
  const { data } = useBackend<LawAddData>(context);
  const { admin, has_zeroth, zeroth_law, hacked_law, ion_law, inherent_law, supplied_law, supplied_law_position } = data;
  return (
    <Section title="Add Laws">
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Type</Table.Cell>
          <Table.Cell width="60%">Law</Table.Cell>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="20%">Actions</Table.Cell>
        </Table.Row>
        {!!(admin && !has_zeroth) && (
            <LawAddTable type="zeroth" type_display="Zeroth" color="#ff0000" law={zeroth_law} index="0" />
        )}
        <LawAddTable type="hacked" type_display="Hacked" color="#660000" law={hacked_law} index="N/A" />
        <LawAddTable type="ion" type_display="Ion" color="#547DFE" law={ion_law} index="N/A" />
        <LawAddTable type="inherent" type_display="Inherent" law={inherent_law} index="N/A" />
        <LawAddTable type="supplied" type_display="Supplied" color="#990099" law={supplied_law} index={supplied_law_position} />
      </Table>
    </Section>
  );
};

const LawAddTable = (props, context) => {
  const { act } = useBackend(context);
  return (
      <Table.Row>
        <Table.Cell>{props.type_display}</Table.Cell>
        {props.color ? <Table.Cell color={props.color}>{props.law}</Table.Cell> : <Table.Cell>{props.law}</Table.Cell> }
        <Table.Cell>
          {props.type === "supplied" ?
            <Button
              content={props.index}
              onClick={() => act('change_supplied_law_position')}
            /> : props.index
          }
        </Table.Cell>
        <Table.Cell>
          <Button
            content="Edit"
            icon="pencil-alt"
            onClick={() => act('change_law', { type: props.type })}
          />
          <Button
            content="Add"
            icon="plus"
            onClick={() => act('add_law', { type: props.type })}
          />
        </Table.Cell>
      </Table.Row>
  );
};

type LawsetViewData = {
  lawsets: any; // Too complicated.
}

const LawsetsView = (props, context) => {
  const { act, data } = useBackend<LawsetViewData>(context);
  const { lawsets } = data;
  return (
    <Box>
      {lawsets.map((l) => (
        <Section
          key={l.name}
          title={l.name + ' - ' + l.header}
          buttons={
            <Button
              content="Load Laws"
              icon="download"
              onClick={() => act('transfer_laws', { id: l.id })}
            />
          }>
          <LabeledList>
            {l.laws.has_devil > 0 &&
              l.laws.devil.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.has_zeroth > 0 &&
              l.laws.zeroth.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.has_hacked > 0 &&
              l.laws.hacked.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.has_ion > 0 &&
              l.laws.ion.map((il) => (
                <LabeledList.Item key={il.index} label={il.indexdisplay}>
                  {il.law}
                </LabeledList.Item>
            ))}
            {l.laws.has_inherent > 0 &&
              l.laws.inherent.map((il) => (
                <LabeledList.Item key={il.index} label={il.indexdisplay}>
                  {il.law}
                </LabeledList.Item>
            ))}
            {l.laws.has_supplied > 0 &&
              l.laws.inherent.map((sl) => (
                <LabeledList.Item key={sl.index} label={sl.indexdisplay}>
                  {sl.law}
                </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
       ))}
    </Box>
  );
};
