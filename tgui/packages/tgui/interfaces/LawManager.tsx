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
  syndiemmi: BooleanLike;
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
  zeroth: string[];
  zeroth_law: string;
  hacked_law: string;
  ion_law: string;
  inherent_law: string;
  supplied_law: string;
  supplied_law_position: number;
}

export const LawManager = (props, context) => {
  const { act, data } = useBackend<LawManagerData>(context);
  const { cyborg, ai, pai, connected, lawsync, syndiemmi, admin, view } = data;

  return (
    <Window height="600" width="800" title="Law Manager">
      <Window.Content scrollable>
        {!!admin && (
          <NoticeBox>You are viewing this from an admin prespective.</NoticeBox>
        ) }
        {!!(admin && cyborg && syndiemmi) && (
          <NoticeBox>This Cyborg is using a syndicate MMI.</NoticeBox>
        ) }
        {!!(admin && cyborg && !connected) && (
          <NoticeBox>This Cyborg has no master AI.</NoticeBox>
        ) }
        {!!(admin && cyborg && connected && lawsync) && (
          <NoticeBox>This Cyborg is connected to {connected} with lawsync.</NoticeBox>
        ) }
        {!!(admin && cyborg && connected && !lawsync) && (
          <NoticeBox>This Cyborg is connected to {connected} without lawsync.</NoticeBox>
        ) }
        {!!(admin && pai) && (
          <NoticeBox>This pAI has less editing features due to their nature of being a pAI.</NoticeBox>
        ) }
        <Box>
          <Button
            content="Law Management"
            selected={view === 0}
            onClick={() => act('set_view', { set_view: 0 })}
          />
          {!!(admin) && !pai && (
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
  const { data } = useBackend<LawManagementData>(context);
  const { pai, admin } = data;
  return (
    <Fragment>
      <LawSection />
      <LawStatementSection />
      {!!(admin && !pai) && (
        <LawAddSection />
      )}
    </Fragment>
  );
};

const LawSection = (props, context) => {
  const { data } = useBackend<LawSectionData>(context);
  const { devil, zeroth, hacked, ion, inherent, supplied } = data;
  return (
    <Section title="Laws">
      {!!(devil.length > 0) && (
        <LawTable color="#cc5500" title="Devil" laws={devil} />
      )}
      {!!(zeroth.length > 0) && (
        <LawTable color="#ff0000" title="Zeroth" laws={zeroth} />
      )}
      {!!(hacked.length > 0) && (
        <LawTable color="#660000" title="Hacked" laws={hacked} />
      )}
      {!!(ion.length > 0) && (
        <LawTable color="#547DFE" title="Ion" laws={ion} />
      )}
      {!!(inherent.length > 0) && (
        <LawTable title="Inherent" laws={inherent} />
      )}
      {!!(supplied.length > 0) && (
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
  const { admin, zeroth, zeroth_law, hacked_law, ion_law, inherent_law, supplied_law, supplied_law_position } = data;
  return (
    <Section title="Add Laws">
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Type</Table.Cell>
          <Table.Cell width="60%">Law</Table.Cell>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="20%">Actions</Table.Cell>
        </Table.Row>
        {!!(admin && zeroth.length === 0) && (
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
          title={l.name + l.header}
          buttons={
            <Button
              content="Load Laws"
              icon="download"
              onClick={() => act('transfer_laws', { id: l.id })}
            />
          }>
          <LabeledList>
            {l.laws.devil.length > 0 &&
              l.laws.devil.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.zeroth.length > 0 &&
              l.laws.zeroth.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.hacked.length > 0 &&
              l.laws.hacked.map((zl) => (
                <LabeledList.Item key={zl.index} label={zl.indexdisplay}>
                  {zl.law}
                </LabeledList.Item>
            ))}
            {l.laws.ion.length > 0 &&
              l.laws.ion.map((il) => (
                <LabeledList.Item key={il.index} label={il.indexdisplay}>
                  {il.law}
                </LabeledList.Item>
            ))}
            {l.laws.inherent.length > 0 &&
              l.laws.inherent.map((il) => (
                <LabeledList.Item key={il.index} label={il.indexdisplay}>
                  {il.law}
                </LabeledList.Item>
            ))}
            {l.laws.supplied.length > 0 &&
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
