import { useBackend } from '../backend';
import { Section, Table, Button } from '../components';
import { Window } from '../layouts';
type CassetteDetails = {
  submitter_name: string;
  tape_name: string;
  reviewed: boolean;
  verdict: string;
};

type CassetteReviewData = {
  // List of submitted cassettes. Each cassette id is in hexID_ckey format.
  cassettes: Record<string, CassetteDetails>;
};

export const CassetteManager = (props) => {
  const { act, data } = useBackend<CassetteReviewData>();
  const { cassettes } = data;

  // Convert cassettes object into an array to iterate our buttons
  const cassetteEntries = Object.entries(cassettes);

  return (
    <Window title="Cassette Manager" width={600} height={313}>
      <Window.Content>
        <Section title="List of This Shift's Submissions">
          <CassetteTable
            entries={cassetteEntries}
            onReview={(id: string) => act(id)}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

const CassetteTable = ({
  entries,
  onReview,
}: {
  entries: [string, CassetteDetails][];
  onReview: (id: string) => void;
}) => {
  // If entries is not provided or is empty, show a message instead of the table.
  if (!entries || entries.length === 0) {
    return <b>Nothing to review. The Jam&apos;s must flow.</b>;
  }
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Cassette ID_CKey</Table.Cell>
        <Table.Cell>Submitter</Table.Cell>
        <Table.Cell>Title</Table.Cell>
        <Table.Cell>Reviewed</Table.Cell>
        <Table.Cell>Action</Table.Cell>
      </Table.Row>

      {entries.map(([id, cassette]) => (
        <Table.Row key={id}>
          <Table.Cell>{id}</Table.Cell>
          <Table.Cell>{cassette.submitter_name}</Table.Cell>
          <Table.Cell>{cassette.tape_name}</Table.Cell>
          <Table.Cell>{cassette.reviewed ? 'Yes' : 'No'}</Table.Cell>
          <Table.Cell>
            <ReviewButton
              reviewed={cassette.reviewed}
              verdict={cassette.verdict}
              onClick={() => onReview(id)}
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const ReviewButton = ({
  reviewed,
  verdict,
  onClick,
}: {
  reviewed: boolean;
  verdict: string;
  onClick: () => void;
}) => {
  const { buttonText, buttonColor } = reviewed
    ? verdict === 'APPROVED'
      ? { buttonText: 'Approved', buttonColor: 'good' }
      : { buttonText: 'Denied', buttonColor: 'bad' }
    : { buttonText: 'Pending', buttonColor: undefined };

  return (
    <Button color={buttonColor} onClick={onClick}>
      {buttonText}
    </Button>
  );
};
