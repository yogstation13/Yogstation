import { Fragment } from "inferno";
import {
  Box,
  Icon,
  Button,
  LabeledList,
  Section,
  Tabs,
  Grid,
  Tooltip,
} from "../components";
import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";

const number2grade = {
  1: "F",
  2: "D",
  3: "C",
  4: "B",
  5: "A",
};

const GuardianGeneralScene = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      <Section title="General Stuff">
        <Button
          content={data.guardian_name || "Random Name"}
          onClick={() => act("name")}
        />
        <Button icon="undo" content="Reset All" onClick={() => act("reset")} />
      </Section>
      <Section title="Attack Type">
        <Button
          content="Melee"
          selected={data.melee}
          onClick={() => act("melee")}
          tooltip="Your Guardian will punch things. ORA ORA!"
          tooltipPosition="right"
        />
        <Button
          content="Ranged"
          selected={!data.melee}
          disabled={data.melee && data.points < 3}
          onClick={() => act("ranged")}
          tooltip="Your Guardian will shoot ranged projectiles. This will prevent you from using ranged weaponry!"
          tooltipPosition="right"
        />
      </Section>
    </Fragment>
  );
};

const GuardianStatsScene = (props, context) => {
  const { act, data } = useBackend(context);
  const levels = ["A", "B", "C", "D", "F"];
  const icons = {
    Damage: "fist-raised",
    Defense: "shield-alt",
    Speed: "bolt",
    Potential: "battery-half",
    Range: "street-view",
  };
  const tooltips = {
    Damage:
      "Affects how much damage your guardian does per punch/per projectile.",
    Defense:
      "Affects how much damage your guardian takes and transfers back to you.",
    Speed: "Affects how fast your guardian can attack.",
    Potential: "Affects how powerful your guardian's ability is.",
    Range: "Affects how far your guardian can travel from you.",
  };
  return (
    <Section title="Stats">
      <Box>
        {data.ratedskills.map((skill, index) => (
          <Box key={skill.name} textAlign="left">
            <Box
              inline
              position="relative"
              mr={1}
              width="60px"
              textAlign="center">
              <Icon name={icons[skill.name]} size={4} />
              <Tooltip content={tooltips[skill.name]} position="right" />
            </Box>
            <Box inline>
              {levels.map((letter, index) => {
                let cost = 4 - index;
                let level = 5 - index;
                return (
                  <Button
                    bold
                    key={letter}
                    mb="6px"
                    content={letter}
                    selected={skill.level === level}
                    disabled={
                      skill.level < level
                      && data.points + (skill.level - 1) < cost
                    }
                    fontSize="30px"
                    width="110px"
                    onClick={() => act("set", { name: skill.name, level })}
                  />
                );
              })}
            </Box>
          </Box>
        ))}
      </Box>
    </Section>
  );
};

const GuardianMajorAbilityScene = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Major Ability">
      {data.abilities_major.map(ability => (
        <LabeledList.Item
          key={ability.name}
          className="candystripe"
          label={ability.name}
          labelColor={ability.requiem ? "gold" : null}>
          {ability.desc}
          <br />
          <Button
            content={ability.cost + " points"}
            selected={ability.selected}
            disabled={
              !ability.selected
              && (data.points < ability.cost || !ability.available)
            }
            onClick={() => act("ability_major", { path: ability.path })}
          />
        </LabeledList.Item>
      ))}
    </Section>
  );
};

const GuardianMinorAbilityScene = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Minor Abilities">
      {data.abilities_minor.map(ability => (
        <LabeledList.Item
          key={ability.name}
          className="candystripe"
          label={ability.name}>
          {ability.desc}
          <br />
          <Button
            content={ability.cost + " points"}
            selected={ability.selected}
            disabled={
              !ability.selected
              && (data.points < ability.cost || !ability.available)
            }
            onClick={() => act("ability_minor", { path: ability.path })}
          />
        </LabeledList.Item>
      ))}
    </Section>
  );
};

const GuardianSummaryScene = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Summary">
      <Section title="Name">{data.guardian_name || "Random Name"}</Section>
      <Section title="Stats">
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
      {data.abilities_major.filter(ability => ability.selected).length
        > 0 && (
        <Section title="Major Ability">
          <LabeledList>
            {data.abilities_major.map(
              ability =>
                !!ability.selected && (
                  <LabeledList.Item key={ability.name} label={ability.name}>
                    {ability.desc}
                  </LabeledList.Item>
                )
            )}
          </LabeledList>
        </Section>
      )}
      {data.abilities_minor.filter(ability => ability.selected).length
        > 0 && (
        <Section title="Minor Abilities">
          <LabeledList>
            {data.abilities_minor.map(
              ability =>
                !!ability.selected && (
                  <LabeledList.Item
                    key={ability.name}
                    className="candystripe"
                    label={ability.name}>
                    {ability.desc}
                    <br />
                    <br />
                  </LabeledList.Item>
                )
            )}
          </LabeledList>
        </Section>
      )}
      <Button
        content={"Summon " + data.name}
        style={{
          width: "94%",
          "text-align": "center",
          position: "fixed",
          bottom: "0px",
        }}
        mb={2}
        height="50px"
        fontSize="30px"
        onClick={() => act("spawn")}
      />
    </Section>
  );
};

export const Guardian = (props, context) => {
  const { data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, "tab-index", 1);
  return (
    <Window resizable width={700} height={600}>
      <Window.Content scrollable>
        <LabeledList>
          <LabeledList.Item
            label="Points"
            color={data.points > 0 ? "good" : "bad"}>
            {data.points}
          </LabeledList.Item>
        </LabeledList>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => {
              setTabIndex(1);
            }}>
            General
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => {
              setTabIndex(2);
            }}>
            Stats
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 3}
            onClick={() => {
              setTabIndex(3);
            }}>
            Major Ability
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 4}
            onClick={() => {
              setTabIndex(4);
            }}>
            Minor Abilities
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 5}
            onClick={() => {
              setTabIndex(5);
            }}>
            Summary
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 1 && <GuardianGeneralScene />}
        {tabIndex === 2 && <GuardianStatsScene />}
        {tabIndex === 3 && <GuardianMajorAbilityScene />}
        {tabIndex === 4 && <GuardianMinorAbilityScene />}
        {tabIndex === 5 && <GuardianSummaryScene />}
      </Window.Content>
    </Window>
  );
};
