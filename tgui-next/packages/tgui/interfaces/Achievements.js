import { useBackend } from '../backend';
import { Collapsible, Section} from '../components';

export const Achievements = props => {
  const { data } = useBackend(props);
  return (
    data["achievements"].map(achievement => (
      <Collapsible title={achievement.name} key={achievement.name}>
        <Section>
          {achievement.desc}<br />
          {achievement.unlocked && (<span className="color-good">unlocked</span>)}
          {!achievement.unlocked && (<span className="color-bad">locked</span>)}
        </Section>
      </Collapsible>
    ))
  );
};
