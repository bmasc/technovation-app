require 'rails_helper'
require 'webmock'
include WebMock::API

describe User, type: :model do
  context '.save' do
    context 'when user is promoted to judging' do
      let(:user) do
        build(:user)
      end

      before do
        default_response = {
          status: 200,
          body: '{"results":[]}',
          headers: {}
        }

        User.skip_callback(
          :create,
          :add_to_campaign_list,
          :send_judge_signup_email,
          :send_mentor_signup_email,
          :email_parents_callback
        )
        stub_request(:any, /.*/).to_return(default_response)

        user.save(validate: false)

        allow(SignupMailer)
          .to receive(:judge_signup_email)
          .and_return double(deliver: nil)
      end

      it 'sends a signup_mail' do
        expect(SignupMailer).to receive(:judge_signup_email)

        User.first.update(judging: true)
      end

      context 'when already able to judge and the user data has updates' do
        let(:user) do
          build(:user, judging: true)
        end

        it 'do not send email' do
          expect(SignupMailer).to_not receive(:judge_signup_email)

          User.first.update(judging: true)
        end
      end
    end
  end

  describe '.ineligible?' do
    subject(:user) { build(:user, birthday: birthday, role: role).ineligible? }
    let(:birthday) { 7.years.ago.to_datetime }
    let(:role) { :student }
    let(:region_submission_enabled?) { true }
    let(:cutoff_day) { DateTime.now }

    before do
      allow(Setting)
        .to receive(:get_boolean)
        .with('manual_region_selection')
        .and_return(region_submission_enabled?)

      allow(Setting)
        .to receive(:get_date)
        .with('cutoff')
        .and_return(cutoff_day)
    end

    context 'when user is a student' do
      context 'and their age is less than 8 years old' do
        it { is_expected.to be true }
      end

      context 'and their age is greater than 19 years old' do
        let (:birthday) { 20.years.ago.to_datetime }
        it { is_expected.to be true }
      end

      context 'and their age is within range' do
        let (:birthday) { 19.years.ago.to_datetime }
        it { is_expected.to be false }
      end
    end

    context 'when user is not a student' do
      context 'and is a coach' do
        let (:role) { :coach }
        it { is_expected.to be false}
      end

      context 'and is a mentor' do
        let (:role) { :mentor }
        it { is_expected.to be false}
      end

      context 'and is a judge' do
        let (:role) { :judge }
        it { is_expected.to be false}
      end

    end

  end

end
