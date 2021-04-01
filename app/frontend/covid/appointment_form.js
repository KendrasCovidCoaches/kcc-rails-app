const AppointmentForm = {
  initialize() {
    $(document).on('turbolinks:load', () => {
      if ($('form.new_appointment,form.edit_appointment').length > 0) {
        $('input[name="appointment[accepting_patients]"]').on('click', function (e) {
          AppointmentForm.updateState();
        });

        $('input[name="appointment[accepting_patients]"]').on('click', function (e) {
          AppointmentForm.updateState();
        });

        $('#appointment_organization_status').on('change', function (e) {
          AppointmentForm.updateState();
        });

        AppointmentForm.updateState();
      }
    });
  },

  updateState() {
    if ($('input[name="appointment[accepting_patients]"]:checked').val() == 'true') {
      $('.is-accepting-patients').show();
      $('#appointment_looking_for').attr('required', 'required');
    }
    else {
      $('.is-accepting-patients').hide();
      $('#appointment_looking_for').removeAttr('required');
    }

    if ($('#appointment_organization_status').val() == 'Non-profit') {
      $('.is-non-profit').show();
      $('#appointment_ein').attr('required', 'required');
    } else {
      $('.is-non-profit').hide();
      $('#appointment_ein').removeAttr('required');
    }

    if ($('#appointment_organization_status').val() == 'For-profit') {
      $('.for-profit-warning').show();
    } else {
      $('.for-profit-warning').hide();
    }
  }
}

export default AppointmentForm;
