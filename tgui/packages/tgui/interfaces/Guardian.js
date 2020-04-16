import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section, Tabs } from '../components';

export const Guardian = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const number2grade = {
    1: "F",
    2: "D",
    3: "C",
    4: "B",
    5: "A",
  };
  return (
    <Fragment>
      <LabeledList>
        <LabeledList.Item
          label="Points"
          color={data.points > 0 ? 'good' : 'bad'}>
          {data.points}
        </LabeledList.Item>
      </LabeledList>
      <Tabs>
        <Tabs.Tab
          key="General"
          label="General">
          <Section
            title="General stuff">
            <Button
              content={data.guardian_name || "Random Name"}
              onClick={() => act(ref, 'name')} />
            <Button
              icon="undo"
              content="Reset All"
              onClick={() => act(ref, 'reset')} />
          </Section>
          <Section
            title="Attack Type">
            <Button
              content="Melee"
              selected={data.melee}
              onClick={() => act(ref, 'melee')} />
            <Button
              content="Ranged"
              selected={!data.melee}
              disabled={data.melee && data.points < 3}
              onClick={() => act(ref, 'ranged')} />
          </Section>
        </Tabs.Tab>
        <Tabs.Tab
          key="stats"
          label="Stats">
          <LabeledList>
            {data.ratedskills.map(skill => (
              <LabeledList.Item
                key={skill.name}
                className="candystripe"
                label={skill.name}>
                <Button
                  content="A"
                  selected={skill.level === 5}
                  disabled={skill.level < 5 && data.points < 4}
                  onClick={() => act(ref, 'set', { name: skill.name, level: 5 })} />
                <Button
                  content="B"
                  selected={skill.level === 4}
                  disabled={skill.level < 4 && data.points < 3}
                  onClick={() => act(ref, 'set', { name: skill.name, level: 4 })} />
                <Button
                  content="C"
                  selected={skill.level === 3}
                  disabled={skill.level < 3 && data.points < 2}
                  onClick={() => act(ref, 'set', { name: skill.name, level: 3 })} />
                <Button
                  content="D"
                  selected={skill.level === 2}
                  disabled={skill.level < 2 && data.points < 1}
                  onClick={() => act(ref, 'set', { name: skill.name, level: 2 })} />
                <Button
                  content="F"
                  selected={skill.level === 1}
                  onClick={() => act(ref, 'set', { name: skill.name, level: 1 })} />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Tabs.Tab>
        <Tabs.Tab
          key="ability_major"
          label="Major Ability">
          {data.abilities_major.map(ability => (
            <LabeledList.Item
              key={ability.name}
              className="candystripe"
              label={ability.name}
              labelColor={ability.requiem ? "gold" : null}>
              {ability.desc}<br />
              <Button
                content={ability.cost + " points"}
                selected={ability.selected}
                disabled={!ability.selected && (data.points < ability.cost || !ability.available)}
                onClick={() => act(ref, 'ability_major', { path: ability.path })} />
            </LabeledList.Item>
          ))}
        </Tabs.Tab>
        <Tabs.Tab
          key="ability_minor"
          label="Minor Abilities">
          {data.abilities_minor.map(ability => (
            <LabeledList.Item
              key={ability.name}
              className="candystripe"
              label={ability.name}>
              {ability.desc}<br />
              <Button
                content={ability.cost + " points"}
                selected={ability.selected}
                disabled={!ability.selected && (data.points < ability.cost || !ability.available)}
                onClick={() => act(ref, 'ability_minor', { path: ability.path })} />
            </LabeledList.Item>
          ))}
        </Tabs.Tab>
        <Tabs.Tab
          key="create"
          label="Create">
          <Section
            title="Name">
            {data.guardian_name || "Random Name"}
          </Section>
          <Section
            title="Stats">
            <LabeledList>
              {data.ratedskills.map(skill => (
                <LabeledList.Item
                  key={skill.name}
                  className="candystripe"
                  label={skill.name}>
                  {number2grade[skill.level]}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
          {!data.no_ability && (
            <Section
              title="Major Ability">
              <LabeledList>
                {data.abilities_major.map(ability => (
                  (!!ability.selected && (
                    <LabeledList.Item
                      key={ability.name}
                      label={ability.name}>
                      {ability.desc}
                    </LabeledList.Item>
                  ))
                ))}
              </LabeledList>
            </Section>
          )}
          <Section
            title="Minor Abilities">
            <LabeledList>
              {data.abilities_minor.map(ability => (
                (!!ability.selected && (
                  <LabeledList.Item
                    key={ability.name}
                    className="candystripe"
                    label={ability.name}>
                    {ability.desc}
                  </LabeledList.Item>
                ))
              ))}
            </LabeledList>
          </Section>
          <Button
            content={"Summon " + data.name}
            style={{ width: '100%', 'text-align': 'center', position: 'fixed', bottom: '12px' }}
            onClick={() => act(ref, 'spawn')} />
        </Tabs.Tab>
      </Tabs>
    </Fragment>
  );
};
