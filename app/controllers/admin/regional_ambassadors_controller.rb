module Admin
  class RegionalAmbassadorsController < AdminController
    def index
      params[:status] ||= :pending

      regional_ambassadors = Account.joins(:regional_ambassador_profile)
        .where("regional_ambassador_profiles.status = ?",
               RegionalAmbassadorProfile.statuses[params.fetch(:status)])

      unless params[:text].blank?
        results = regional_ambassadors.search({
          query: {
            query_string: {
              query: "*#{params[:text]}*"
            },
          },
          from: 0,
          size: 10_000
        }).results

        regional_ambassadors = regional_ambassadors.where(id: results.flat_map { |r| r._source.id })
      end

      @regional_ambassadors = regional_ambassadors.paginate(per_page: params[:per_page], page: params[:page])
    end

    def show
      @regional_ambassador = RegionalAmbassadorProfile.find_by(account_id: params.fetch(:id))
      @report = BackgroundCheck::Report.retrieve(@regional_ambassador.background_check_report_id)
      @consent_waiver = @regional_ambassador.consent_waiver
    end

    def update
      ambassador = RegionalAmbassadorProfile.find_by(account_id: params.fetch(:id))
      ambassador.public_send("#{params.fetch(:status)}!")
      redirect_to :back, success: "#{ambassador.full_name} was marked as #{params.fetch(:status)}"
    end
  end
end
