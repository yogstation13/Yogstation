import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPaperworkPrinter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    have_printer,
  } = data;
  if (have_printer) {
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
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "GeneralRequest",
              })} />
            <Button
              icon="print"
              content="Print NT-021 Complaint Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "ComplaintForm",
              })} />
            <Button
              icon="print"
              content="Print NT-400 Incident Report Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "IncidentForm",
              })} />
            <Button
              icon="print"
              content="Print NT-089 Item Request Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "ItemRequest",
              })} />
            <Button
              icon="print"
              content="Print NT-203 Cyberization Consent Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "CyberizationConsent",
              })} />
            <Button
              icon="print"
              content="Print NT-022 HoP Access Request Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "HOPAccessRequest",
              })} />
            <Button
              icon="print"
              content="Print NT-059 Job Reassignment Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "JobReassignment",
              })} />
            <Button
              icon="print"
              content="Print SCI-3 R&D Request Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "RDRequestForm",
              })} />
            <Button
              icon="print"
              content="Print SCI-9 Mech Request Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "MechRequest",
              })} />
            <Button
              icon="print"
              content="Print Job Change Certificate"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "JobChangeCertificate",
              })} />
            <Button
              icon="print"
              content="Print SEC-030 Security Incident Report Form"
              width="100%"
              onClick={() => act('PRG_print', {
                whichpaperwork: "SecIncidentForm",
              })} />
          </Section>
        </NtosWindow.Content>
      </NtosWindow>
    );
  } else {
    return (
      <NtosWindow
        width={400}
        height={480}
        resizable>
        <NtosWindow.Content scrollable>
          <Section title="NTOS Paperwork Printer" />
          <NoticeBox>
            There is no printer installed. Program halted.
          </NoticeBox>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

};
