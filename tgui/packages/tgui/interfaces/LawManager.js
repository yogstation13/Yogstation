import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
  NoticeBox,
  Table,
} from '../components';
import { Window } from '../layouts';

export const LawManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { isCyborg, isAI, isConnected, hasLawsync, isAntag, isAdmin, ispAI, view } = data;

  return (
    <Window>
      <Window.Content scrollable>
        {!!(isAntag) && (
          <NoticeBox>This unit is malfunctioning.</NoticeBox>
        )}
        {!!(ispAI) && (
          <NoticeBox>This unit is a pAI. Options have been limited.</NoticeBox>
        )}
        {!!(isCyborg && isConnected && hasLawsync) && (
          <NoticeBox>This unit is connected to {isConnected}. Law changes here will be ineffective.</NoticeBox>
        )}
        {!!(isCyborg && isConnected && !hasLawsync) && (
          <NoticeBox>This unit is connected to {isConnected} with Lawsync off.</NoticeBox>
        )}

        <Box>
          <Button
            content="Law Management"
            selected={view === 0}
            onClick={() => act('set_view', { set_view: 0 })}
          />
          {!!(isAntag || isAdmin) && !ispAI && (
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
  const { act, data } = useBackend(context);
  const {
    isAntag,
    isAdmin,
    ispAI,
    devil,
    zeroth,
    hacked,
    ion,
    inherent,
    supplied,
    has_devil,
    has_zeroth,
    has_hacked,
    has_ion,
    has_inherent,
    has_supplied,
    channels,
    channel,
    zeroth_law,
    hacked_law,
    ion_law,
    inherent_law,
    supplied_law,
    supplied_law_position,
  } = data;
  return (
    <Fragment>
      <Section title={'Laws'}>
        {!!has_devil && (
          <LawTable color="#cc5500" lawtitle="Devil" laws={devil} ctx={context} />
        )}
        {!!has_zeroth && (
          <LawTable color="#ff0000" lawtitle="Zeroth" laws={zeroth} ctx={context} />
        )}
        {!!has_hacked && (
          <LawTable color="#660000" lawtitle="Hacked" laws={hacked} ctx={context} />
        )}
        {!!has_ion && (
          <LawTable color="#547DFE" lawtitle="Ion" laws={ion} ctx={context} />
        )}
        {!!has_inherent && (
          <LawTable lawtitle={"Inherent"} laws={inherent} ctx={context} />
        )}
        {!!has_supplied && (
          <LawTable color="#990099" lawtitle={"Supplied"} laws={supplied} ctx={context} />
        )}
      </Section>
      <Section title="Statement Settings">
        <LabeledList>
          <LabeledList.Item label="Statement Channel">
            {channels.map((c) => (
              <Button
                content={c.channel}
                key={c.channel}
                selected={c.channel === channel}
                onClick={() => act('law_channel', { law_channel: c.channel })}
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
      {!!(isAdmin || isAntag) && !ispAI && (
        <Section title="Add Laws">
          <Table>
            <Table.Row header>
              <Table.Cell width="10%">Type</Table.Cell>
              <Table.Cell width="60%">Law</Table.Cell>
              <Table.Cell width="10%">Index</Table.Cell>
              <Table.Cell width="20%">Actions</Table.Cell>
            </Table.Row>
            {!!(true && !has_zeroth) && (
              <Table.Row>
                <Table.Cell>Zero</Table.Cell>
                <Table.Cell color="#ff0000">{zeroth_law}</Table.Cell>
                <Table.Cell>N/A</Table.Cell>
                {(isAdmin &&
                  <Table.Cell>
                    <Button
                      content="Edit"
                      icon="pencil-alt"
                      onClick={() => act('change_zeroth_law')}
                    />
                    <Button
                      content="Add"
                      icon="plus"
                      onClick={() => act('add_zeroth_law')}
                    />
                  </Table.Cell>
                )}
              </Table.Row>
            )}
            <Table.Row>
              <Table.Cell>Hacked</Table.Cell>
              <Table.Cell color="#660000">{hacked_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button
                  content="Edit"
                  icon="pencil-alt"
                  onClick={() => act('change_hacked_law')}
                />
                <Button
                  content="Add"
                  icon="plus"
                  onClick={() => act('add_hacked_law')}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Ion</Table.Cell>
              <Table.Cell color="#547DFE">{ion_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button
                  content="Edit"
                  icon="pencil-alt"
                  onClick={() => act('change_ion_law')}
                />
                <Button
                  content="Add"
                  icon="plus"
                  onClick={() => act('add_ion_law')}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Inherent</Table.Cell>
              <Table.Cell>{inherent_law}</Table.Cell>
              <Table.Cell>N/A</Table.Cell>
              <Table.Cell>
                <Button
                  content="Edit"
                  icon="pencil-alt"
                  onClick={() => act('change_inherent_law')}
                />
                <Button
                  content="Add"
                  icon="plus"
                  onClick={() => act('add_inherent_law')}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>Supplied</Table.Cell>
              <Table.Cell color="#990099">{supplied_law}</Table.Cell>
              <Table.Cell>
                <Button
                  content={supplied_law_position}
                  onClick={() => act('change_supplied_law_position')}
                />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Edit"
                  icon="pencil-alt"
                  onClick={() => act('change_supplied_law')}
                />
                <Button
                  content="Add"
                  icon="plus"
                  onClick={() => act('add_supplied_law')}
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      )}
    </Fragment>
  );
};

const LawsetsView = (props, context) => {
  const { act, data } = useBackend(context);
  const { law_sets } = data;
  return (
    <Box>
      {law_sets.map((l) => (
        <Section
          key={l.name}
          title={l.name + ' - ' + l.header}
          buttons={
            <Button
              content="Load Laws"
              icon="download"
              onClick={() => act('transfer_laws', { id: l.id })}
            />
          }
        >
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

const LawTable = (props, context) => {
  const { act, data } = useBackend(props.ctx);
  const {
    isAntag,
    isAdmin,
    ispAI,
  } = data;
  return (
    <Section>
      <Table>
        <Table.Row header>
          <Table.Cell width="10%">Index</Table.Cell>
          <Table.Cell width="69%">{props.lawtitle}</Table.Cell>
          <Table.Cell width="21%">State?</Table.Cell>
        </Table.Row>
        {props.laws.map((l) => (
          <Table.Row key={l.law}>
            <Table.Cell>{l.indexdisplay}</Table.Cell>
            {props.color && (
              <Table.Cell color={props.color}>
                  {l.law}
              </Table.Cell>
            ) }
            {!props.color && (
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
              {!!(isAntag || isAdmin) && (
                <Fragment>
                  <Button
                    content="Edit"
                    icon="pencil-alt"
                    onClick={() => act('edit_law', { index: l.index, type: l.type })}
                  />
                  {!!(true && !ispAI) && (
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
