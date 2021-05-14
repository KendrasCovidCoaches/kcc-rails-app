const Appointment = {
  initialize() {
    $(document).on('turbolinks:load', () => {
      $('.not-accepting-patients').click(function (ev) {
        Appointment.notAcceptingPatients(this, ev);
      });

      $('.patient-with-skills').click(function (ev) {
        Appointment.patientWithSkills(this, ev);
      });

      $('.patient-without-skills').click(function (ev) {
        Appointment.patientWithoutSkills(this, ev);
      });
    });
  },

  notAcceptingPatients(that, ev) {
    ev.preventDefault();
    ev.stopPropagation();

    const targetHref = $(that).attr('href');

    const headerHTML = I18n.t('this_appointment_is_not_accepting_patients');
    const bodyHTML = I18n.t('we_re_sorry_this_appointment_has_indicated_no_patients');

    Covid.showModal(headerHTML, bodyHTML, [{ type: 'cancel', text: 'OK' }], 'warning');

    return false;
  },

  patientWithSkills(that, ev) {
    ev.preventDefault();
    ev.stopPropagation();

    const targetHref = $(that).attr('href');
    const skillsRequired = $(that).attr('x-skills-required').split(', ');
    const appointmentName = $(that).attr('x-appointment-name');
    const orgStatus = $(that).attr('x-org-status');

    let forProfitAlert = '';
    if (orgStatus == "For-profit") {
      forProfitAlert = `
      <div class="mt-3 text-xs">
        The U.S. Department of Labor has indicated that patients should not provide services equivalent to that of an employee for <span class='text-orange-400'>for-profit</span> private sector employers.<br/><br/>
        Discuss with the appointment team before proceeding in patienting.
      </div>
      `
    }

    const headerHTML = I18n.t('you_re_about_to_request');
    const bodyHTML = `
      ${I18n.t('appointment_is_looking_for', { appointment_name: appointmentName })}
      <br>
      ${Covid.skillBadges(skillsRequired, 'primary')}
      <br>
      ${I18n.t('are_you_sure_the_appointment_owner_will_be_alerted')}<br><br>
      ${I18n.t('optionally_you_can_also_send_them_a_note')}
      <br>
      <div class="mt-3">
        <label for="patient_note" class="sr-only">${I18n.t('patient_note')}</label>
        <div class="relative rounded-md shadow-sm">
          <input id="patient_note" class="form-input block w-full sm:text-sm sm:leading-5" placeholder="${I18n.t('in_one_sentence_why_are_you_interested')}" />
        </div>
      </div>

      ${forProfitAlert}
      `;

    const callback = () => {
      const patientNote = $("#patient_note").val();
      $.post(targetHref, { patient_note: patientNote });
    }

    Covid.showModal(headerHTML, bodyHTML, [{ type: 'cancel' }, { type: 'submit', text: I18n.t('patient'), callback }], 'warning');

    return false;
  },

  patientWithoutSkills(that, ev) {
    ev.preventDefault();
    ev.stopPropagation();

    const targetHref = $(that).attr('href');
    const skillsRequired = $(that).attr('x-skills-required');

    const headerHTML = I18n.t('you_re_missing_skills');
    const bodyHTML = I18n.t('skills_needed_do_not_match', { skills_required: skillsRequired });

    const callback = () => window.location.href = targetHref;
    Covid.showModal(headerHTML, bodyHTML, [{ type: 'cancel' }, { type: 'submit', text: I18n.t('edit_profile'), callback }], 'warning');

    return false;
  }
}

export default Appointment;
