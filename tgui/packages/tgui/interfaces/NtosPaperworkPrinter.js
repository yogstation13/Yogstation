import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPaperworkPrinter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    have_printer,
    manifest = {},
  } = data;
  return (
    <NtosWindow
      width={400}
      height={480}
      resizable>
      <NtosWindow.Content scrollable>
        <Section title="NTOS Paperwork Printer">
          <Button
            icon="print"
            content="Print NT-010 General Request Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_GenReqForm')} />
          <Button
            icon="print"
            content="Print NT-021 Complaint Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_ComplaintForm')} />
          <Button
            icon="print"
            content="Print NT-400 Incident Report Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_IncidentRepForm')} />
          <Button
            icon="print"
            content="Print NT-089 Item Request Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_ItemReqForm')} />
          <Button
            icon="print"
            content="Print NT-203 Cyberization Consent Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_CyberConsentForm')} />
          <Button
            icon="print"
            content="Print NT-022 HoP Access Request Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_HOPAccessForm')} />
          <Button
            icon="print"
            content="Print NT-059 Job Reassignment Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_JobReassignForm')} />
          <Button
            icon="print"
            content="Print SCI-3 R&D Request Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_RDReqForm')} />
          <Button
            icon="print"
            content="Print SCI-9 Mech Request Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_MechReqForm')} />
          <Button
            icon="print"
            content="Print Job Change Certificate"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_JobChangeCert')} />
          <Button
            icon="print"
            content="Print SEC-030 Security Incident Report Form"
            disabled={!have_printer}
            width="100%"
            onClick={() => act('PRG_print_SecRepForm')} />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
