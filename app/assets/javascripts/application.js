//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require chosen-jquery
//= require country_state_select
//= require turbolinks

(function() {
  var registrationRoles = {
    cssSelector: '.button-group input',

    hideSelector: '.toggle-field',

    init: function() {
      this.toggleRoleFields();
      return $(document).on('change', this.cssSelector, this.toggleRoleFields.bind(this));
    },

    toggleRoleFields: function() {
      this.hideRoleFields();
      this.revealSelectedRoleFields();
    },

    revealSelectedRoleFields: function() {
      return $.each($(this.cssSelector + ':checked'), function(_, obj) {
        return $($(obj).data('reveal')).show();
      });
    },

    hideRoleFields: function() {
      $(this.hideSelector).hide();
    }
  };

  var countrySelectFields = {
    eventList: 'ready page:load',

    countryFieldId: 'account_country',

    stateFieldId: 'account_region',

    cityFieldId: 'account_city',

    init: function() {
      return $(document).on(this.eventList, this.initCountrySelect.bind(this));
    },

    initCountrySelect: function(e) {
      return CountryStateSelect({
        chosen_ui: true,
        chosen_options: {
          disable_search_threshold: 10,
        },
        country_id: this.countryFieldId,
      });
    },
  };

  countrySelectFields.init();
  registrationRoles.init();
}())
