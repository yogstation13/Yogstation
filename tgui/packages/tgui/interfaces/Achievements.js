import { useBackend } from '../backend';
import { Collapsible, Section } from '../components';
import { Window } from '../layouts';

export const Achievements = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window width={540}
      height={680}>
      <Window.Content>
        {data.achievements.map(achievement => (
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
        ))}
      </Window.Content>
    </Window>
  );
};