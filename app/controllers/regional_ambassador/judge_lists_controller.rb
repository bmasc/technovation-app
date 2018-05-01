module RegionalAmbassador
  class JudgeListsController < RegionalAmbassadorController
    def show
      event = RegionalPitchEvent.find(params.fetch(:event_id))

      attendees = Attendees.for(
        event: event,
        type: :account,
        context: self,
      )

      render json: AttendeesSerializer.new(attendees).serialized_json
    end
  end
end
