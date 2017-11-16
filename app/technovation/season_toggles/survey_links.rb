class SeasonToggles
  module SurveyLinks
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      %w{mentor student}.each do |scope|
        define_method("#{scope}_survey_link=") do |attrs|
          attrs = attrs.with_indifferent_access
          changed = %w{text long_desc url}.any? do |key|
            not attrs[key] == survey_link(scope, key)
          end

          if changed
            attrs[:changed_at] = Time.current
            store.set("#{scope}_survey_link", JSON.generate(attrs.to_h))
          end
        end
      end

      def survey_link_available?(scope)
        %w{text url changed_at}.all? do |key|
          !!survey_link(scope, key) and not survey_link(scope, key).empty?
        end
      end

      def show_survey_link_modal?(scope, account)
        not account.took_survey? and
          survey_link_available?(scope) and
            account.needs_survey_reminder?
      end

      def set_survey_link(scope, text, url, long_desc = nil)
        send("#{scope}_survey_link=", { text: text, long_desc: long_desc, url: url })
      end

      def survey_link(scope, key)
        value = store.get("#{scope}_survey_link") || "{}"
        parsed = JSON.parse(value)
        parsed[key.to_s]
      end
    end
  end
end
