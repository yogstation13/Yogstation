import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, Flex, LabeledList, ProgressBar, Icon, Input, Section, Tabs } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const skillLevelToColor = skillLevel => {
  if (skillLevel <= 1) {
    return COLORS.skills.unskilled;
  }
  if (skillLevel <= 2) {
    return COLORS.skills.basic;
  }
  if (skillLevel <= 3) {
    return COLORS.skills.trained;
  }
  if (skillLevel <= 4) {
    return COLORS.skills.experienced;
  }
  if (skillLevel <= 5) {
    return COLORS.skills.master;
  }
};

const skillLevelToText = skillLevel => {
  if (skillLevel === 1) {
    return "Unskilled";
  }
  if (skillLevel === 2) {
    return "Basic";
  }
  if (skillLevel === 3) {
    return "Trained";
  }
  if (skillLevel === 4) {
    return "Experienced";
  }
  if (skillLevel === 5) {
    return "Master";
  }
};

const difficultyLevelToColor = skillLevel => {
  if (skillLevel <= 1) {
    return "good";
  }
  if (skillLevel <= 2) {
    return "average";
  }
  if (skillLevel <= 3) {
    return "bad";
  }
};

const difficultyLevelToText = skillLevel => {
  if (skillLevel === 1) {
    return "Easy";
  }
  if (skillLevel === 2) {
    return "Medium";
  }
  if (skillLevel === 3) {
    return "Hard";
  }
};

export const SkillSelectionMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    currentJob,
    jobs,
    skillBalance,
    maxSkillPoints,
  } = data;
  const skills = data.skills || [];
  return (
    <Window
      title="Skill Selection Menu"
      width={900}
      height={1000}>
      <Window.Content>
        <Flex>
          <Flex.Item>
            <Section
              height="960px"
              width="200px"
              overflowY="auto"
              buttons={
                <Button
                  content="Reset"
                  icon="undo"
                  onClick={() => act(act('resetToJobDefault'))} />
              }>
              <Tabs vertical>
                {jobs.map(job => (
                  <Tabs.Tab
                    key={job}
                    selected={currentJob==job}
                    onClick={() => act('changeCurrentJob', {
                      job: job })}>
                    {job}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item width="700px">
            <Section
              title={(
                <ProgressBar
                  value={skillBalance}
                  minValue={0}
                  maxValue={maxSkillPoints}
                  ranges={{
                    good: [maxSkillPoints, 10],
                    bad: [10, 0],
                  }}>
                  {skillBalance}/{maxSkillPoints}
                </ProgressBar>
              )}
              buttons={(
                <Fragment />
              )}>
              <Flex grow={1} basis={0}>
                <Tabs vertical>
                  {skills.map(skill => (
                    <Tabs.Tab
                      key={skill.name}>
                      <Section
                        title={(
                          <Fragment color={skillLevelToColor(skill.level)}>
                            <Icon name={skill.icon} color={skillLevelToColor(skill.level)} mr={1} />
                            {skill.name}: {skillLevelToText(skill.level)} ({skill.level})
                          </Fragment>
                        )}
                        overflowY="auto"
                        buttons={(
                          <Fragment >
                            {!!skill.canIncrease && (
                              <Button
                                icon="level-up-alt"
                                color={skillLevelToColor(skill.level+1)}
                                content={skill.costIncrease}
                                onClick={() => act('increaseLevel', {
                                  id: skill.id,
                                })} />
                            )}
                            <Button
                              content={skill.cost}
                              color={skillLevelToColor(skill.level)} />
                            {!!skill.canDecrease && (
                              <Button
                                icon="level-down-alt"
                                color={skillLevelToColor(skill.level-1)}
                                content={skill.costDecrease}
                                onClick={() => act('decreaseLevel', {
                                  id: skill.id,
                                })} />
                            )}
                          </Fragment>)}>
                        <LabeledList >
                          <LabeledList.Item
                            label="Description">
                            {skill.desc}
                          </LabeledList.Item>
                          <LabeledList.Item
                            label=" Difficulty"
                            color={difficultyLevelToColor(skill.difficulty)}>
                            {difficultyLevelToText(skill.difficulty)} ({skill.difficulty})
                          </LabeledList.Item>
                          <LabeledList.Item
                            label=" Skill Level Description"
                            color={skillLevelToColor(skill.level)}>
                            {skill.level_desc}
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
