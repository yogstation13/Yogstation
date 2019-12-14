import { useBackend } from '../backend';
import { Collapsible, Section } from '../components';

export const Achievements = props => {
  const { data } = useBackend(props);
  return (
    data["achievements"].map(achievement => (
      <Collapsible
        title={achievement.unlocked
          ? "" + achievement.name + " - unlocked"
          : "" + achievement.name + " - locked"}
        key={achievement.name} className={achievement.unlocked
          ? "color-good"
          : ""} >
        <Section>
          {achievement.desc}<br />
        </Section>
      </Collapsible>
    ))
  );
};
